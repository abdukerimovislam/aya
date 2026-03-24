import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Channels
  static const String _channelIdCycle = 'cycle_channel';
  static const String _channelIdPills = 'pills_channel';

  // Payloads
  static const String payloadCalendar = 'screen_calendar';
  static const String payloadCOC = 'screen_coc';

  bool _isInitialized = false;

  Future<void> init({Function(String?)? onNotificationTap}) async {
    if (_isInitialized) return;

    // 1. Настройка времени (Критично)
    await _configureLocalTimeZone();

    // 2. Настройки Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Настройки iOS/macOS (Darwin)
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 4. Инициализация
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        debugPrint("🔔 Notification tapped. payload=$payload");
        onNotificationTap?.call(payload);
      },
    );

    // 5. Каналы (Android 8+)
    await _ensureAndroidChannels();

    // 6. 🔥 ЗАПРОС ПРАВ НА ANDROID 13+ и EXACT ALARMS (Android 14+)
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }

    _isInitialized = true;
    debugPrint("✅ NotificationService initialized");
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
      (await FlutterTimezone.getLocalTimezone()).toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("🕒 Local timezone set: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Could not set local timezone, fallback to UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _ensureAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    const cycleChannel = AndroidNotificationChannel(
      _channelIdCycle,
      'Cycle Updates',
      description: 'Notifications about period start and fertility window',
      importance: Importance.defaultImportance,
    );

    const pillsChannel = AndroidNotificationChannel(
      _channelIdPills,
      'Pill Reminders',
      description: 'Daily reminders to take contraception',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    try {
      await android.createNotificationChannel(cycleChannel);
      await android.createNotificationChannel(pillsChannel);
      debugPrint("✅ Android channels ensured");
    } catch (e) {
      debugPrint("⚠️ Could not create Android channels: $e");
    }
  }

  /// 🔒 Ручной запрос прав (вызывается из экрана профиля/настроек)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      // 🔥 ИСПРАВЛЕНО: возвращаем IOSFlutterLocalNotificationsPlugin
      final IOSFlutterLocalNotificationsPlugin? ios =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      return (await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      )) ??
          false;
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      bool notifGranted = (await android?.requestNotificationsPermission()) ?? false;
      await android?.requestExactAlarmsPermission(); // Запрашиваем точные алармы
      return notifGranted;
    }

    return false;
  }

  /// 🚀 Мгновенное уведомление
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        _notificationDetails(channelId: _channelIdCycle),
        payload: payload,
      );
      debugPrint("✅ Showed immediate notification [$id] '$title'");
    } catch (e) {
      debugPrint("❌ Error showing immediate notification [$id]: $e");
    }
  }

  /// 📅 Одиночное уведомление
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime target = tz.TZDateTime.from(scheduledDate, tz.local);

      if (target.isBefore(now)) {
        debugPrint("⚠️ Skipping past notification [$id]");
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        target,
        _notificationDetails(channelId: _channelIdCycle),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint("✅ Scheduled [$id] '$title' at $target payload=$payload");
    } catch (e) {
      debugPrint("❌ Error scheduling notification [$id]: $e");
    }
  }

  /// 💊 Ежедневное уведомление
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Пытаемся поставить точное время (ExactAlarm)
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _notificationDetails(channelId: _channelIdPills),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload ?? payloadCOC,
        );
      } catch (e) {
        debugPrint("⚠️ exactAllowWhileIdle failed, fallback to inexact: $e");
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _notificationDetails(channelId: _channelIdPills),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload ?? payloadCOC,
        );
      }

      final hh = time.hour.toString().padLeft(2, '0');
      final mm = time.minute.toString().padLeft(2, '0');
      debugPrint("✅ Daily scheduled [$id] '$title' at $hh:$mm");
    } catch (e) {
      debugPrint("❌ Error scheduling daily notification [$id]: $e");
    }
  }

  NotificationDetails _notificationDetails({required String channelId}) {
    final bool isPill = channelId == _channelIdPills;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        isPill ? 'Pill Reminders' : 'Cycle Updates',
        channelDescription: isPill
            ? 'Daily reminders to take contraception'
            : 'Notifications about period start and fertility window',
        importance: isPill ? Importance.max : Importance.defaultImportance,
        priority: isPill ? Priority.high : Priority.defaultPriority,
        enableVibration: true,
        playSound: true,
        color: const Color(0xFF8E71C7),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> cancelAll() async => _notificationsPlugin.cancelAll();

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}