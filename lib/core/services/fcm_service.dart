import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

import 'notification_service.dart';
import '../../main.dart'; // 🔥 ИМПОРТ ПЕРЕНЕСЕН НАВЕРХ!

// 🔥 ГЛОБАЛЬНЫЙ ПЕРЕХВАТЧИК (Для фоновых уведомлений)
// Должен быть Top-Level функцией, чтобы работать, когда приложение убито.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Нам не нужно явно показывать уведомление, система сделает это сама.
  // Но здесь можно логировать получение или обновлять бейджики.
  debugPrint("🔔 [FCM Background] Received message: ${message.messageId}");
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      // 1. Запрашиваем права (Особенно важно для iOS)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('⚠️ FCM: User declined or has not accepted permission');
        return;
      }

      // 2. Настраиваем обработчик фоновых сообщений
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Обработка уведомлений, когда приложение ОТКРЫТО (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM Foreground] Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('🔔 [FCM Foreground] Message also contained a notification: ${message.notification}');

          // 🔥 Показываем локальный пуш через наш NotificationService
          NotificationService().showLocalNotification(
            id: message.hashCode,
            title: message.notification!.title ?? 'Ayla',
            body: message.notification!.body ?? '',
            payload: message.data['route'],
          );
        }
      });

      // 4. Обработка клика по пушу, если приложение было в фоне
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM Opened] Message clicked!');
        _handleRouting(message.data);
      });

      // 5. Обработка клика, если приложение было полностью убито (Terminated)
      final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 [FCM Terminated] App opened from push!');
        // Даем Flutter время отрисовать первый экран перед роутингом
        Future.delayed(const Duration(milliseconds: 1500), () {
          _handleRouting(initialMessage.data);
        });
      }

      // 6. Подписываем юзера на языковые и общие топики
      await _subscribeToTopics();

      debugPrint("✅ FCM Service initialized successfully.");

    } catch (e) {
      if (kDebugMode) debugPrint("❌ FCM Service Init Error: $e");
    }
  }

  // --- МАРКЕТИНГОВЫЕ ТОПИКИ ---

  static Future<void> _subscribeToTopics() async {
    try {
      // Подписываем на общие новости
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('new_articles');

      // Подписываем в зависимости от языка
      final box = await Hive.openBox('settings');
      final String? lang = box.get('language_code');

      if (lang != null && lang.isNotEmpty) {
        await _messaging.subscribeToTopic('lang_$lang');
      } else {
        await _messaging.subscribeToTopic('lang_en');
      }

      debugPrint("✅ Subscribed to FCM topics.");
    } catch (e) {
      debugPrint("❌ Failed to subscribe to topics: $e");
    }
  }

  // --- РОУТИНГ ПОСЛЕ КЛИКА ---

  static void _handleRouting(Map<String, dynamic> data) {
    if (data.containsKey('route')) {
      final route = data['route'];

      // Пример: если маркетолог прислал пуш с { "route": "/profile" }
      if (route == '/profile' || route == '/calendar') {
        navigatorKey.currentState?.pushNamed(route);
      }
    }
  }
}