import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'notification_service.dart';

class AiOracleService {
  // 🔥 Твой Cloudflare Worker Proxy
  static const String _proxyUrl = 'https://aya-ai-proxy.stopprocrastination16.workers.dev/';

  // 🛡️ ВАЖНО: Вставь сюда тот же пароль, что указал в Cloudflare Variables (APP_SECRET_TOKEN)
  static const String _appSecretToken = 'D62I99S01';

  // Переменная для кулдауна (запоминает время последнего запроса)
  static DateTime? _lastRequestTime;

  static Future<void> fetchDailyInsight({bool isManual = false}) async {
    try {
      final aiBox = await Hive.openBox('ai_insights');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 🛡️ ФРОНТЕНД-ЗАЩИТА ОТ СПАМА (Анти-кликкер)
      // Если это ручное обновление, проверяем, прошла ли минута с прошлого запроса
      if (isManual && _lastRequestTime != null) {
        final difference = DateTime.now().difference(_lastRequestTime!);
        if (difference.inSeconds < 60) {
          debugPrint("⏳ ИИ: Защита от спама. Ждем перезарядку (осталось ${60 - difference.inSeconds} сек).");
          // Бросаем кастомную ошибку, чтобы UI (если нужно) показал Toast "Подождите минуту"
          throw Exception("RateLimit: Please wait a minute before refreshing.");
        }
      }

      if (!isManual && aiBox.get('last_update_date') == todayStr && aiBox.get('is_offline') != true) {
        debugPrint("🔮 ИИ: Инсайт на сегодня уже актуален.");
        return;
      }

      // Обновляем таймер
      if (isManual) _lastRequestTime = DateTime.now();

      debugPrint("🔮 ИИ: Отправляю данные на безопасный Proxy-сервер (Cloudflare)...");

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

      // 🛡️ ЗАЩИТА ОТ ЗАВИСАНИЙ И ПЕРЕДАЧА СЕКРЕТА
      final response = await http.post(
        Uri.parse(_proxyUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Ayla-App-Token': _appSecretToken, // 🔥 Передаем секретный пропуск
        },
        body: jsonEncode({"prompt": prompt}),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException("⏳ Proxy server took too long to respond."),
      );

      // Проверка статуса ответа от Cloudflare (например, 403 Forbidden, если пароль не совпал)
      if (response.statusCode != 200) {
        throw Exception("❌ Proxy HTTP Error: ${response.statusCode}. Body: ${response.body}");
      }

      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        throw Exception("❌ Proxy did not return valid JSON. Raw body: ${response.body}");
      }

      // Глубокая проверка на null и перехват медицинских блокировок
      final candidates = jsonResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        final promptFeedback = jsonResponse['promptFeedback'];
        throw Exception("❌ No candidates returned. Safety/Feedback: $promptFeedback | Raw: ${response.body}");
      }

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      final content = firstCandidate?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;

      if (parts == null || parts.isEmpty) {
        final finishReason = firstCandidate?['finishReason'];
        throw Exception("❌ AI generated no text parts. Finish reason: $finishReason");
      }

      final String? generatedText = parts.first['text'] as String?;
      if (generatedText == null || generatedText.trim().isEmpty) {
        throw Exception("❌ Generated text is completely empty.");
      }

      debugPrint("🔮 ИИ Сырой ответ: $generatedText");

      // Очистка от Markdown разметки
      String cleanJsonStr = generatedText.trim();
      if (cleanJsonStr.startsWith('```json')) {
        cleanJsonStr = cleanJsonStr.replaceFirst('```json', '');
        if (cleanJsonStr.endsWith('```')) {
          cleanJsonStr = cleanJsonStr.substring(0, cleanJsonStr.length - 3);
        }
      } else if (cleanJsonStr.startsWith('```')) {
        cleanJsonStr = cleanJsonStr.replaceFirst('```', '');
        if (cleanJsonStr.endsWith('```')) {
          cleanJsonStr = cleanJsonStr.substring(0, cleanJsonStr.length - 3);
        }
      }
      cleanJsonStr = cleanJsonStr.trim();

      // Финальный парсинг JSON с безопасными дефолтными значениями
      Map<String, dynamic> jsonInsight;
      try {
        jsonInsight = jsonDecode(cleanJsonStr);
      } catch (e) {
        throw Exception("❌ AI JSON Format Error. Text was: $cleanJsonStr");
      }

      final title = jsonInsight['title']?.toString() ?? "Daily Insight";
      final bodyText = jsonInsight['body']?.toString() ?? "Listen to your body today.";

      String type = jsonInsight['type']?.toString().toLowerCase() ?? "neutral";
      if (type != 'warning' && type != 'positive') type = 'neutral';

      // Сохранение в Hive
      await aiBox.put('current_insight_title', title);
      await aiBox.put('current_insight_body', bodyText);
      await aiBox.put('current_insight_type', type);
      await aiBox.put('last_update_date', todayStr);
      await aiBox.put('is_offline', false);

      // Вызов уведомления
      if (!isManual) {
        _triggerSmartNotification(title);
      }

    } catch (e) {
      debugPrint("🔥 AI Oracle Error (Falling back to local AI): $e");

      // Сброс таймера кулдауна в случае ошибки (чтобы юзер мог повторить попытку сразу)
      if (e.toString().contains("RateLimit") == false) {
        _lastRequestTime = null;
      }

      try {
        final aiBox = await Hive.openBox('ai_insights');
        await aiBox.put('is_offline', true);
      } catch (boxError) {
        debugPrint("🔥 Fatal error opening Hive box in fallback: $boxError");
      }
    }
  }

  static void _triggerSmartNotification(String title) {
    final now = DateTime.now();
    final notificationService = NotificationService();

    if (now.hour >= 10 && now.hour <= 20) {
      notificationService.showLocalNotification(
        id: 999,
        title: "Ayla Insight ✨",
        body: title,
        payload: "/home",
      );
    } else {
      var scheduledTime = DateTime(now.year, now.month, now.day, 10, 0);
      if (now.hour > 20) scheduledTime = scheduledTime.add(const Duration(days: 1));

      notificationService.scheduleNotification(
        id: 999,
        title: "Ayla Insight ✨",
        body: title,
        scheduledDate: scheduledTime,
      );
    }
  }
}