import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'notification_service.dart';
import '../../l10n/app_localizations.dart';

class CycleNotificationManager {
  // 🔥 БЕЗОПАСНЫЙ РЕЕСТР ID
  // Мы перечисляем только те ID, которые относятся к фазам цикла и журналу.
  // Это гарантирует, что мы не удалим пуш таблеток КОК (у него свой ID в COCProvider).
  static const List<int> _cycleNotificationIds = [100, 101, 201, 202, 203, 204, 205, 206, 300];

  static Future<void> rescheduleNotifications({
    required NotificationService? notificationService,
    required bool isCOCEnabled,
    required DateTime cycleStartDate,
    required int cycleLength,
    required int ovulationDay,
    required int cocActivePills,
    required String? savedLanguageCode,
  }) async {
    if (notificationService == null) return;

    try {
      final box = await Hive.openBox('settings');
      final notificationsEnabled = box.get('notifications_enabled', defaultValue: true) as bool;

      // Очищаем только старые цикловые уведомления перед тем, как поставить новые
      for (int id in _cycleNotificationIds) {
        await notificationService.cancelNotification(id);
      }

      if (!notificationsEnabled) {
        return; // Если пуши выключены глобально, просто выходим
      }

      Locale targetLocale;
      if (savedLanguageCode != null) {
        targetLocale = Locale(savedLanguageCode);
      } else {
        final sysCode = Intl.defaultLocale?.split('_')[0] ?? 'en';
        targetLocale = Locale(sysCode);
      }

      final l10n = await AppLocalizations.delegate.load(targetLocale);
      final nextPeriodStart = cycleStartDate.add(Duration(days: cycleLength));

      // 1. 🔥 ЕЖЕДНЕВНЫЙ ЖУРНАЛ СИМПТОМОВ (Ежедневный рекуррентный пуш)
      final dailyLogEnabled = box.get('daily_log_enabled', defaultValue: true) as bool;
      if (dailyLogEnabled) {
        await notificationService.scheduleDailyNotification(
          id: 300,
          title: l10n.notifCheckinTitle,
          body: l10n.notifCheckinBody,
          time: const TimeOfDay(hour: 20, minute: 0), // В 20:00 каждый вечер
          payload: "screen_calendar",
        );
      }

      // 2. 💊 РЕЖИМ ТАБЛЕТОК (Фазы не скачут, ставим только уведомления о пачке)
      if (isCOCEnabled) {
        await _scheduleIfFuture(notificationService, 100, nextPeriodStart, l10n.notifNewPackTitle, l10n.notifNewPackBody, payload: "screen_coc");
        final breakDate = cycleStartDate.add(Duration(days: cocActivePills));
        await _scheduleIfFuture(notificationService, 101, breakDate, l10n.notifBreakTitle, l10n.notifBreakBody, payload: "screen_coc");
        return;
      }

      // 3. 🌙 СТАНДАРТНЫЙ ЦИКЛ (Фазы, Овуляция, ПМС и задержка)
      final day7 = cycleStartDate.add(const Duration(days: 6));
      await _scheduleIfFuture(notificationService, 201, day7, l10n.notifFollTitle, l10n.notifFollBody, payload: "screen_calendar");

      if (ovulationDay > 1) {
        final ovDate = cycleStartDate.add(Duration(days: ovulationDay - 1));
        await _scheduleIfFuture(notificationService, 202, ovDate, l10n.notifOvulationTitle, l10n.notifOvulationBody, payload: "screen_calendar");
      }

      final pmsDay = cycleLength - 5;
      if (pmsDay > 10) {
        final pmsDate = cycleStartDate.add(Duration(days: pmsDay - 1));
        await _scheduleIfFuture(notificationService, 203, pmsDate, l10n.notifLutealTitle, l10n.notifLutealBody, payload: "screen_calendar");
      }

      final prePeriodDate = nextPeriodStart.subtract(const Duration(days: 1));
      await _scheduleIfFuture(notificationService, 204, prePeriodDate, l10n.notifPeriodSoonTitle, l10n.notifPeriodSoonBody, payload: "screen_calendar");

      final lateDay1 = nextPeriodStart.add(const Duration(days: 1));
      await _scheduleIfFuture(notificationService, 205, lateDay1, l10n.notifLateTitle, l10n.notifLateBody, payload: "screen_calendar");

      final lateDay5 = nextPeriodStart.add(const Duration(days: 5));
      await _scheduleIfFuture(
          notificationService,
          206,
          lateDay5,
          "Period is 5 days late",
          "Consider taking a pregnancy test if you've been sexually active.",
          payload: "screen_calendar"
      );

    } catch (e) {
      if (kDebugMode) debugPrint("Reschedule notifications error: $e");
    }
  }

  static Future<void> _scheduleIfFuture(NotificationService service, int id, DateTime date, String title, String body, {String? payload}) async {
    // Ставим все одноразовые уведомления (о фазах) на 09:00 утра
    DateTime scheduleTime = DateTime(date.year, date.month, date.day, 9, 0);
    if (scheduleTime.isAfter(DateTime.now())) {
      await service.scheduleNotification(id: id, title: title, body: body, scheduledDate: scheduleTime, payload: payload ?? 'screen_calendar');
    }
  }
}