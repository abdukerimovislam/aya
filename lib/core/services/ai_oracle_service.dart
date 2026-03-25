import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'notification_service.dart';
import '../../data/models/cycle_model.dart';
import '../../l10n/app_localizations.dart';

class AiOracleService {
  // 🔥 Fallback URL на случай, если Firebase недоступен (нет интернета)
  static const String _defaultProxyUrl = 'https://aya-ai-proxy.stopprocrastination16.workers.dev/';

  static String? _inMemoryToken;
  static String? _inMemoryProxyUrl;

  static AppLocalizations get _englishL10n =>
      lookupAppLocalizations(const Locale('en'));

  // 🔥 Получаем динамический URL сервера из облака
  static Future<String> _getProxyUrl() async {
    if (_inMemoryProxyUrl != null && _inMemoryProxyUrl!.isNotEmpty) {
      return _inMemoryProxyUrl!;
    }
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      String url = remoteConfig.getString('aya_api_url');

      if (url.isEmpty) {
        _inMemoryProxyUrl = _defaultProxyUrl;
      } else {
        _inMemoryProxyUrl = url;
      }
      return _inMemoryProxyUrl!;
    } catch (e) {
      return _defaultProxyUrl;
    }
  }

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

  static Future<String> generateDailyAdvice({
    required CyclePhase phase,
    required List<dynamic> logs,
    required bool isCoc,
    bool forceRefresh = false,
  }) async {
    try {
      final aiBox = await Hive.openBox('ai_insights');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (!forceRefresh) {
        final savedDate = aiBox.get('cached_advice_date');
        final savedAdvice = aiBox.get('cached_advice_text');

        if (savedDate == todayStr && savedAdvice != null && savedAdvice.toString().isNotEmpty) {
          return savedAdvice.toString();
        }
      }

      final safeToken = await _getSecretToken();
      final apiUrl = await _getProxyUrl();

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

      // 🔥 Юридически безопасный промпт
      final prompt = '''
      You are Ayla, an empathetic and highly professional Cycle Intelligence Assistant and women's wellness guide.
      Analyze the user's current state and explain WHY they might be feeling this way based on their cycle.
      Always remind the user to consult a healthcare provider for any medical concerns.
      
      Context:
      - Current cycle phase: $phaseStr
      - Contraceptive pill user: $isCoc
      - Today's symptoms/moods: $symptomsText
      
      Task:
      Provide a short, comforting, and scientifically accurate explanation (2-4 sentences max) of how their current hormonal profile is likely causing these specific symptoms. 
      
      CRITICAL INSTRUCTION:
      RESPOND IN RAW PLAIN TEXT ONLY. 
      DO NOT USE JSON. DO NOT WRAP IN BRACES {}. 
      DO NOT USE MARKDOWN LIKE ```json OR **.
      Just write the sentences directly.
      ''';

      final response = await http.post(
        Uri.parse(apiUrl),
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

      await aiBox.put('cached_advice_date', todayStr);
      await aiBox.put('cached_advice_text', cleanText);

      return cleanText;
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 AI Oracle Error: $e");
      return _englishL10n.chatConnectionIssue;
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
      final apiUrl = await _getProxyUrl();

      final cycleBox = Hive.isBoxOpen('cycles') ? Hive.box('cycles') : null;
      final wellnessBox = Hive.isBoxOpen('symptom_logs') ? Hive.box('symptom_logs') : null;

      int totalCycles = cycleBox?.length ?? 0;
      int totalLogs = wellnessBox?.length ?? 0;

      final String contextData = """
      Пользователь приложения Ayla. 
      Записано циклов: $totalCycles. 
      Записано дней с симптомами: $totalLogs.
      Текущая дата: $todayStr.
      """;

      // 🔥 Юридически безопасный промпт
      final prompt = '''
      Ты ИИ-ассистент по женскому здоровью (Cycle Intelligence Assistant) в приложении Ayla.
      Проанализируй контекст пользователя и выдай один короткий инсайт или совет на сегодня. 
      Если данных мало (например, 0 циклов), поприветствуй и посоветуй начать вести дневник.
      
      Контекст: $contextData
      
      Верни ответ СТРОГО в валидном JSON-формате с тремя ключами:
      "title": Короткий заголовок (до 3-4 слов на английском, например "Rest & Reset").
      "body": Одно-два предложения с советом или анализом (на английском).
      "type": Одно из значений строго (neutral, positive, warning).
      ''';

      final response = await http.post(
        Uri.parse(apiUrl),
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

      // 🔥 ИСПРАВЛЕНИЕ: Бронебойный парсер JSON (Вытащит JSON даже если ИИ налил воды вокруг)
      String cleanJsonStr = generatedText.trim();
      final RegExp regex = RegExp(r'\{.*\}', dotAll: true);
      final match = regex.firstMatch(cleanJsonStr);

      if (match != null) {
        cleanJsonStr = match.group(0)!;
      } else {
        throw Exception("AI did not return a valid JSON object.");
      }

      Map<String, dynamic> jsonInsight;
      try {
        jsonInsight = jsonDecode(cleanJsonStr);
      } catch (e) {
        throw Exception("AI JSON Format Error: $e");
      }

      final title = jsonInsight['title']?.toString() ?? _englishL10n.aiDailyInsightTitle;
      final bodyText = jsonInsight['body']?.toString() ?? _englishL10n.aiDailyInsightBody;
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

      // 🔥 ИСПРАВЛЕНИЕ: Не удаляем rate limit при ошибках (чтобы не заддосить прокси при сбоях ИИ)
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
        id: 999,
        title: _englishL10n.notifAylaInsightTitle,
        body: title,
        payload: "/home",
      );
    } else {
      var scheduledTime = DateTime(now.year, now.month, now.day, 10, 0);
      if (now.hour > 20) scheduledTime = scheduledTime.add(const Duration(days: 1));

      notificationService.scheduleNotification(
        id: 999,
        title: _englishL10n.notifAylaInsightTitle,
        body: title,
        scheduledDate: scheduledTime,
        payload: "/home",
      );
    }
  }

  // --- 🔥 ЧАТ С АЙЛОЙ ---

  static Future<String> chatWithAyla({
    required String userMessage,
    required List<Map<String, String>> chatHistory,
    required String currentPhase,
    required int currentDay,
    required List<dynamic> recentLogs,
    required bool isCoc,
  }) async {
    try {
      final safeToken = await _getSecretToken();
      final apiUrl = await _getProxyUrl();

      // Формируем медицинский контекст пользователя
      String contextStr = "User context: Phase: $currentPhase, Day: $currentDay, COC user: $isCoc. ";
      if (recentLogs.isNotEmpty && recentLogs.first != null) {
        final log = recentLogs.first;
        List<String> symptoms = [];
        try {
          if (log.symptoms != null) symptoms.addAll((log.symptoms as List).map((e) => e.toString()));
          if (log.painSymptoms != null) symptoms.addAll((log.painSymptoms as List).map((e) => e.toString()));
        } catch (_) {}
        if (symptoms.isNotEmpty) {
          contextStr += "Symptoms today: ${symptoms.join(', ')}.";
        }
      }

      // 🔥 Юридически безопасный системный промпт
      final systemPrompt = '''
      You are Ayla, an empathetic, highly professional Cycle Intelligence Assistant and women's wellness guide.
      You are chatting directly with the user. Keep responses warm, concise, and scientifically accurate.
      You are NOT a doctor. Do not give dangerous medical diagnoses. Always remind the user to consult a healthcare provider for any serious or concerning medical symptoms.
      $contextStr
      ''';

      // Собираем историю диалога в текстовый вид для промпта
      String conversationText = "$systemPrompt\n\n";
      for (var msg in chatHistory) {
        conversationText += "${msg['role'] == 'user' ? 'User' : 'Ayla'}: ${msg['content']}\n";
      }
      conversationText += "User: $userMessage\nAyla:";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Ayla-App-Token': safeToken,
        },
        body: jsonEncode({"prompt": conversationText}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception("Chat HTTP Error: ${response.statusCode}");
      }

      final jsonResponse = jsonDecode(response.body);
      final candidates = jsonResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) throw Exception("No candidates");

      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) throw Exception("No text parts");

      String generatedText = parts.first['text'] as String? ?? "";

      // Очистка от маркдауна и лишних символов
      generatedText = generatedText.replaceAll('**', '').trim();

      return generatedText;
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 AI Chat Error: $e");
      return _englishL10n.chatConnectionIssue;
    }
  }
}
