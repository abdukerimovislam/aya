import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'notification_service.dart';

class AiOracleService {
  static const String _proxyUrl = 'https://aya-ai-proxy.stopprocrastination16.workers.dev/';

  // Токен хранится только в оперативной памяти.
  static String? _inMemoryToken;

  // 🛡️ АРХИТЕКТУРА DYNAMIC SECRET (Firebase Remote Config)
  static Future<String> _getSecretToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken!;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // 🔥 СТАВИМ КЭШ В НОЛЬ: Заставляем Firebase скачать новые данные прямо сейчас!
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await remoteConfig.fetchAndActivate();

      // 🕵️ ВЫВОДИМ В КОНСОЛЬ ВСЕ КЛЮЧИ ИЗ FIREBASE (чтобы видеть реальную картину)
      if (kDebugMode) {
        final allKeys = remoteConfig.getAll().keys.toList();
        debugPrint("☁️ Ключи, которые реально пришли из Firebase: $allKeys");
      }

      // 🔥 "УМНЫЙ ПОИСК": Ищем пароль по всем возможным именам
      String token = remoteConfig.getString('aya_ai_proxy');

      if (token.isEmpty) {
        token = remoteConfig.getString('ayla_proxy_token');
      }
      if (token.isEmpty) {
        token = remoteConfig.getString('APP_SECRET_TOKEN');
      }
      if (token.isEmpty) {
        // Даже если Firebase как-то пропустил дефисы, проверим и их
        token = remoteConfig.getString('aya-ai-proxy');
      }

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

  static Future<void> fetchDailyInsight({bool isManual = false}) async {
    try {
      final aiBox = await Hive.openBox('ai_insights');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 🔥 Защита от спама (переживает рестарт приложения)
      if (isManual) {
        final lastMs = aiBox.get('last_manual_request_ms') as int?;
        if (lastMs != null) {
          final difference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastMs));
          if (difference.inSeconds < 60) {
            if (kDebugMode) debugPrint("⏳ ИИ: Сработала персистентная защита от спама.");
            throw Exception("RateLimit: Please wait a minute before refreshing.");
          }
        }
      }

      if (!isManual && aiBox.get('last_update_date') == todayStr && aiBox.get('is_offline') != true) {
        if (kDebugMode) debugPrint("🔮 ИИ: Инсайт на сегодня уже актуален.");
        return;
      }

      // Записываем время текущего ручного запроса на диск
      if (isManual) {
        await aiBox.put('last_manual_request_ms', DateTime.now().millisecondsSinceEpoch);
      }

      if (kDebugMode) debugPrint("🔮 ИИ: Отправляю данные на Proxy-сервер...");

      // 🔒 ПОЛУЧАЕМ ТОКЕН ИЗ БЕСПЛАТНОГО ОБЛАКА
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
          'X-Ayla-App-Token': safeToken, // 🔥 Передаем токен из Firebase
        },
        body: jsonEncode({"prompt": prompt}),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException("Timeout"),
      );

      // Защита от утечек логов в Crashlytics
      if (response.statusCode != 200) {
        if (kDebugMode) debugPrint("Proxy HTTP Error Details: ${response.statusCode} - ${response.body}");
        throw Exception("Proxy HTTP Error: ${response.statusCode}");
      }

      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) debugPrint("Proxy JSON Error Details: ${response.body}");
        throw Exception("Proxy did not return valid JSON.");
      }

      final candidates = jsonResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        if (kDebugMode) debugPrint("No candidates. Feedback: ${jsonResponse['promptFeedback']}");
        throw Exception("No candidates returned.");
      }

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      final content = firstCandidate?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;

      if (parts == null || parts.isEmpty) {
        throw Exception("AI generated no text parts.");
      }

      final String? generatedText = parts.first['text'] as String?;
      if (generatedText == null || generatedText.trim().isEmpty) {
        throw Exception("Generated text is completely empty.");
      }

      if (kDebugMode) debugPrint("🔮 ИИ Сырой ответ получен.");

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
        if (kDebugMode) debugPrint("AI JSON Format Error Details: $cleanJsonStr");
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

      // Сброс таймера кулдауна в случае технической ошибки
      if (e.toString().contains("RateLimit") == false) {
        try {
          final aiBox = await Hive.openBox('ai_insights');
          await aiBox.delete('last_manual_request_ms');
        } catch (_) {}
      }

      try {
        final aiBox = await Hive.openBox('ai_insights');
        await aiBox.put('is_offline', true);
      } catch (boxError) {
        if (kDebugMode) debugPrint("🔥 Fatal error opening Hive box in fallback: $boxError");
      }
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