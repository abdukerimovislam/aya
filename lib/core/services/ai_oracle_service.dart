import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'notification_service.dart';
import '../../data/models/cycle_model.dart';

class AiOracleService {
  static const String _proxyUrl = 'https://aya-ai-proxy.stopprocrastination16.workers.dev/';
  static String? _inMemoryToken;

  static Future<String> _getSecretToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken!;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await remoteConfig.fetchAndActivate();

      String token = remoteConfig.getString('aya_ai_proxy');
      if (token.isEmpty) token = remoteConfig.getString('ayla_proxy_token');
      if (token.isEmpty) token = remoteConfig.getString('APP_SECRET_TOKEN');
      if (token.isEmpty) token = remoteConfig.getString('aya-ai-proxy');

      if (token.isEmpty) {
        throw Exception("Security Token is missing in Cloud Configuration");
      }

      _inMemoryToken = token;
      return _inMemoryToken!;
    } catch (e) {
      if (kDebugMode) debugPrint("☁️ Ошибка связи с облаком Firebase: $e");
      throw Exception("Failed to load secure token from cloud");
    }
  }

  // 🔥 ОБНОВЛЕННЫЙ МЕТОД С КЭШИРОВАНИЕМ
  static Future<String> generateDailyAdvice({
    required CyclePhase phase,
    required List<dynamic> logs,
    required bool isCoc,
    bool forceRefresh = false, // 🔥 Флаг принудительного обновления
  }) async {
    try {
      final aiBox = await Hive.openBox('ai_insights');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 1. Проверяем кэш, если не запрошено принудительное обновление
      if (!forceRefresh) {
        final savedDate = aiBox.get('cached_advice_date');
        final savedAdvice = aiBox.get('cached_advice_text');

        if (savedDate == todayStr && savedAdvice != null && savedAdvice.toString().isNotEmpty) {
          return savedAdvice.toString(); // Возвращаем моментально из памяти!
        }
      }

      final safeToken = await _getSecretToken();

      String symptomsText = "No specific physical symptoms logged today.";
      if (logs.isNotEmpty && logs.first != null) {
        final log = logs.first;
        final List<String> allSymptoms = [];

        try {
          if (log.symptoms != null && log.symptoms.isNotEmpty) {
            allSymptoms.addAll((log.symptoms as List).map((e) => e.toString()));
          }
          if (log.painSymptoms != null && log.painSymptoms.isNotEmpty) {
            allSymptoms.addAll((log.painSymptoms as List).map((e) => e.toString()));
          }
          if (log.mood != null && log.mood.toString().isNotEmpty) {
            allSymptoms.add("Mood: ${log.mood}");
          }
        } catch(e) {
          if (kDebugMode) debugPrint("Error parsing logs: $e");
        }

        if (allSymptoms.isNotEmpty) {
          symptomsText = allSymptoms.join(", ");
        }
      }

      final String phaseStr = phase.toString().split('.').last;

      final prompt = '''
      You are Ayla, an empathetic and highly professional AI endocrinologist and women's health coach.
      Analyze the user's current state and explain WHY they might be feeling this way based on their hormones.
      
      Context:
      - Current cycle phase: $phaseStr
      - Contraceptive pill user: $isCoc
      - Today's symptoms/moods: $symptomsText
      
      Task:
      Provide a short, comforting, and medically accurate explanation (2-4 sentences max) of how their current hormonal profile (e.g., estrogen, progesterone peaks or drops) is causing these specific symptoms. 
      
      CRITICAL INSTRUCTION:
      RESPOND IN RAW PLAIN TEXT ONLY. 
      DO NOT USE JSON. DO NOT WRAP IN BRACES {}. 
      DO NOT USE MARKDOWN LIKE ```json OR **.
      Just write the sentences directly.
      ''';

      final response = await http.post(
        Uri.parse(_proxyUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Ayla-App-Token': safeToken,
        },
        body: jsonEncode({"prompt": prompt}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception("Proxy HTTP Error: ${response.statusCode}");
      }

      final jsonResponse = jsonDecode(response.body);
      final candidates = jsonResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) throw Exception("No candidates returned");

      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) throw Exception("No text parts returned");

      final String generatedText = parts.first['text'] as String? ?? "";
      if (generatedText.trim().isEmpty) throw Exception("Generated text is empty");

      String cleanText = generatedText.trim();

      if (cleanText.startsWith('```')) {
        final lines = cleanText.split('\n');
        if (lines.length > 2) {
          cleanText = lines.sublist(1, lines.length - 1).join('\n').trim();
        }
      }

      try {
        final parsed = jsonDecode(cleanText);
        if (parsed is Map) {
          cleanText = parsed.values.firstWhere((v) => v is String, orElse: () => cleanText).toString();
        } else if (parsed is List && parsed.isNotEmpty) {
          cleanText = parsed.first.toString();
        }
      } catch (_) {}

      cleanText = cleanText.replaceAll('**', '');
      if (cleanText.startsWith('"') && cleanText.endsWith('"') && cleanText.length > 2) {
        cleanText = cleanText.substring(1, cleanText.length - 1);
      }
      cleanText = cleanText.replaceAll(r'\"', '"').replaceAll(r'\n', '\n').trim();

      // 🔥 2. СОХРАНЯЕМ В КЭШ ПЕРЕД ВОЗВРАТОМ
      await aiBox.put('cached_advice_date', todayStr);
      await aiBox.put('cached_advice_text', cleanText);

      return cleanText;
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 AI Oracle Error: $e");
      return "It looks like my AI engine is currently resting. Please check your internet connection and try again in a moment. I'm here for you! ✨";
    }
  }

  static Future<void> fetchDailyInsight({bool isManual = false}) async {
    try {
      final aiBox = await Hive.openBox('ai_insights');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (isManual) {
        final lastMs = aiBox.get('last_manual_request_ms') as int?;
        if (lastMs != null) {
          final difference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastMs));
          if (difference.inSeconds < 60) {
            throw Exception("RateLimit: Please wait a minute before refreshing.");
          }
        }
      }

      if (!isManual && aiBox.get('last_update_date') == todayStr && aiBox.get('is_offline') != true) {
        return;
      }

      if (isManual) {
        await aiBox.put('last_manual_request_ms', DateTime.now().millisecondsSinceEpoch);
      }

      final safeToken = await _getSecretToken();
      final cycleBox = await Hive.openBox('cycles');
      final wellnessBox = await Hive.openBox('symptom_logs');

      int totalCycles = cycleBox.length;
      int totalLogs = wellnessBox.length;

      final String contextData = """
      Пользователь приложения Ayla. 
      Записано циклов: $totalCycles. 
      Записано дней с симптомами: $totalLogs.
      Текущая дата: $todayStr.
      """;

      final prompt = '''
      Ты медицинский ИИ-аналитик женского здоровья в приложении Ayla.
      Проанализируй контекст пользователя и выдай один короткий инсайт или совет на сегодня. 
      Если данных мало (например, 0 циклов), поприветствуй и посоветуй начать вести дневник.
      
      Контекст: $contextData
      
      Верни ответ СТРОГО в валидном JSON-формате с тремя ключами:
      "title": Короткий заголовок (до 3-4 слов на английском, например "Rest & Reset").
      "body": Одно-два предложения с советом или анализом (на английском).
      "type": Одно из значений строго (neutral, positive, warning).
      ''';

      final response = await http.post(
        Uri.parse(_proxyUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Ayla-App-Token': safeToken,
        },
        body: jsonEncode({"prompt": prompt}),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException("Timeout"),
      );

      if (response.statusCode != 200) {
        throw Exception("Proxy HTTP Error: ${response.statusCode}");
      }

      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        throw Exception("Proxy did not return valid JSON.");
      }

      final candidates = jsonResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception("No candidates returned.");
      }

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      final content = firstCandidate?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;

      if (parts == null || parts.isEmpty) throw Exception("AI generated no text parts.");

      final String? generatedText = parts.first['text'] as String?;
      if (generatedText == null || generatedText.trim().isEmpty) throw Exception("Generated text is completely empty.");

      String cleanJsonStr = generatedText.trim();
      if (cleanJsonStr.startsWith('```json')) {
        cleanJsonStr = cleanJsonStr.replaceFirst('```json', '');
        if (cleanJsonStr.endsWith('```')) cleanJsonStr = cleanJsonStr.substring(0, cleanJsonStr.length - 3);
      } else if (cleanJsonStr.startsWith('```')) {
        cleanJsonStr = cleanJsonStr.replaceFirst('```', '');
        if (cleanJsonStr.endsWith('```')) cleanJsonStr = cleanJsonStr.substring(0, cleanJsonStr.length - 3);
      }
      cleanJsonStr = cleanJsonStr.trim();

      Map<String, dynamic> jsonInsight;
      try {
        jsonInsight = jsonDecode(cleanJsonStr);
      } catch (e) {
        throw Exception("AI JSON Format Error.");
      }

      final title = jsonInsight['title']?.toString() ?? "Daily Insight";
      final bodyText = jsonInsight['body']?.toString() ?? "Listen to your body today.";
      String type = jsonInsight['type']?.toString().toLowerCase() ?? "neutral";
      if (type != 'warning' && type != 'positive') type = 'neutral';

      await aiBox.put('current_insight_title', title);
      await aiBox.put('current_insight_body', bodyText);
      await aiBox.put('current_insight_type', type);
      await aiBox.put('last_update_date', todayStr);
      await aiBox.put('is_offline', false);

      if (!isManual) _triggerSmartNotification(title);

    } catch (e) {
      if (kDebugMode) debugPrint("🔥 AI Oracle Error (Falling back to local AI): $e");

      if (e.toString().contains("RateLimit") == false) {
        try {
          final aiBox = await Hive.openBox('ai_insights');
          await aiBox.delete('last_manual_request_ms');
        } catch (_) {}
      }

      try {
        final aiBox = await Hive.openBox('ai_insights');
        await aiBox.put('is_offline', true);
      } catch (_) {}
    }
  }

  static void _triggerSmartNotification(String title) {
    final now = DateTime.now();
    final notificationService = NotificationService();

    if (now.hour >= 10 && now.hour <= 20) {
      notificationService.showLocalNotification(
        id: 999, title: "Ayla Insight ✨", body: title, payload: "/home",
      );
    } else {
      var scheduledTime = DateTime(now.year, now.month, now.day, 10, 0);
      if (now.hour > 20) scheduledTime = scheduledTime.add(const Duration(days: 1));

      notificationService.scheduleNotification(
        id: 999, title: "Ayla Insight ✨", body: title, scheduledDate: scheduledTime,
      );
    }
  }
}