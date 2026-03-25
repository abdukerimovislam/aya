import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/services/notification_service.dart';

enum PillStatus { taken, missed, pending, future }

class COCProvider with ChangeNotifier {
  final Box _box;
  final NotificationService _notifications;
  final Future<void> Function({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  })? _scheduleDailyNotificationOverride;
  final Future<void> Function(int id)? _cancelNotificationOverride;

  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  List<DateTime> _history = [];
  List<DateTime> _missed = [];

  DateTime _startDate = DateTime.now();
  int _activePillCount = 21;
  int _breakDays = 7;
  int _packFormatCode = 21;

  static const String _keyEnabled = 'coc_enabled';
  static const String _keyPillCount = 'coc_active_count';
  static const String _keyBreakDays = 'coc_break_days';
  static const String _keyPackFormat = 'coc_pack_format';

  static const String _keyStartDate = 'coc_start_date';
  static const String _keyTimeHour = 'coc_time_hour';
  static const String _keyTimeMinute = 'coc_time_minute';
  static const String _keyHistory = 'coc_history';
  static const String _keyMissed = 'coc_missed_history';

  static const int _notificationId = 1001;

  COCProvider(
    this._box,
    this._notifications, {
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      required TimeOfDay time,
    })? scheduleDailyNotificationOverride,
    Future<void> Function(int id)? cancelNotificationOverride,
  })  : _scheduleDailyNotificationOverride = scheduleDailyNotificationOverride,
        _cancelNotificationOverride = cancelNotificationOverride {
    _init();
  }

  void _init() {
    _isEnabled = _box.get(_keyEnabled, defaultValue: false);
    _activePillCount = _box.get(_keyPillCount, defaultValue: 21);
    _breakDays = _box.get(_keyBreakDays, defaultValue: 7);
    _packFormatCode = _box.get(_keyPackFormat, defaultValue: 21);

    final startMs = _box.get(_keyStartDate);
    if (startMs != null) {
      _startDate = DateTime.fromMillisecondsSinceEpoch(startMs);
    } else {
      _startDate = DateTime.now();
    }

    final h = _box.get(_keyTimeHour, defaultValue: 20);
    final m = _box.get(_keyTimeMinute, defaultValue: 0);
    _reminderTime = TimeOfDay(hour: h, minute: m);

    final rawHistory = _box.get(_keyHistory, defaultValue: []);
    if (rawHistory is List) {
      _history = rawHistory.map((e) {
        if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
        return DateTime.now();
      }).toList();
    }
    _history.sort();

    final rawMissed = _box.get(_keyMissed, defaultValue: []);
    if (rawMissed is List) {
      _missed = rawMissed.map((e) {
        if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
        return DateTime.now();
      }).toList();
    }
    _missed.sort();
  }

  // --- Getters ---
  bool get isEnabled => _isEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  int get activePillCount => _activePillCount;
  int get pillCount => _packFormatCode;
  int get breakDays => _breakDays;
  DateTime get startDate => _startDate;
  bool get isLoaded => true;

  int get totalCycleLength => _activePillCount + _breakDays;

  bool get isTakenToday {
    final today = _normalizeDate(DateTime.now());
    return _isSameDayInList(_history, today);
  }

  int get currentPillNumber {
    final now = _normalizeDate(DateTime.now());
    final start = _normalizeDate(_startDate);
    final diff = now.difference(start).inDays;

    if (diff < 0) return 1;
    final dayInCycle = (diff % totalCycleLength) + 1;
    return dayInCycle;
  }

  bool get isOnBreak {
    return currentPillNumber > _activePillCount;
  }

  // --- Smart Logic ---

  bool isBreakDay(DateTime date) {
    if (_breakDays == 0) return false;

    final normDate = _normalizeDate(date);
    final start = _normalizeDate(_startDate);
    final diff = normDate.difference(start).inDays;

    if (diff < 0) return false;
    final dayInCycle = (diff % totalCycleLength) + 1;

    return dayInCycle > _activePillCount;
  }

  PillStatus getPillStatus(DateTime date) {
    final normDate = _normalizeDate(date);
    final today = _normalizeDate(DateTime.now());

    if (normDate.isAfter(today)) return PillStatus.future;
    if (_isSameDayInList(_history, normDate)) return PillStatus.taken;
    if (_isSameDayInList(_missed, normDate)) return PillStatus.missed;

    return PillStatus.pending;
  }

  List<DateTime> getUntrackedDates({int limit = 5}) {
    List<DateTime> untracked = [];
    final today = _normalizeDate(DateTime.now());

    for (int i = 1; i <= limit; i++) {
      final d = today.subtract(Duration(days: i));
      if (d.isBefore(_normalizeDate(_startDate))) break;

      if (isBreakDay(d)) continue;

      if (getPillStatus(d) == PillStatus.pending) {
        untracked.add(d);
      }
    }
    return untracked;
  }

  // --- Actions ---

  Future<void> startNewPack({required DateTime startDate}) async {
    _startDate = _normalizeDate(startDate);
    await _box.put(_keyStartDate, _startDate.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> initSettings({
    required DateTime startDate,
    required int activePills,
    required int breakDays,
    String? notifTitle,
    String? notifBody,
  }) async {
    _startDate = _normalizeDate(startDate);
    _activePillCount = activePills;
    _breakDays = breakDays;

    await _box.put(_keyStartDate, _startDate.millisecondsSinceEpoch);
    await _box.put(_keyPillCount, activePills);
    await _box.put(_keyBreakDays, breakDays);

    await toggleCOC(true, notifTitle: notifTitle, notifBody: notifBody);
  }

  Future<void> toggleCOC(bool value, {String? notifTitle, String? notifBody}) async {
    _isEnabled = value;
    await _box.put(_keyEnabled, value);

    if (value) {
      if (notifTitle != null && notifBody != null) {
        await _scheduleNotification(notifTitle, notifBody);
      }
    } else {
      if (_cancelNotificationOverride != null) {
        await _cancelNotificationOverride!(_notificationId);
      } else {
        await _notifications.cancelNotification(_notificationId);
      }
    }
    notifyListeners();
  }

  Future<void> setPackSize(int size) async {
    int active;
    int brk;

    if (size == 21) {
      active = 21; brk = 7;
    } else if (size == 24) {
      active = 24; brk = 4;
    } else if (size == 28) {
      active = 21; brk = 7;
    } else { // size == 0 (Continuous/Mini-pill)
      active = 28; brk = 0;
    }

    _activePillCount = active;
    _breakDays = brk;
    _packFormatCode = size;

    await _box.put(_keyPillCount, active);
    await _box.put(_keyBreakDays, brk);
    await _box.put(_keyPackFormat, size);

    notifyListeners();
  }

  Future<void> setPillCount(int count) async {
    _activePillCount = count;
    _packFormatCode = count;
    await _box.put(_keyPillCount, count);
    await _box.put(_keyPackFormat, count);
    notifyListeners();
  }

  Future<void> setPackData(int active, int brk) async {
    _activePillCount = active;
    _breakDays = brk;

    // 🔥 ИСПРАВЛЕНИЕ: Корректно вычисляем и сохраняем код формата, чтобы UI не ломался
    _packFormatCode = (brk == 0) ? 0 : (active + brk);

    await _box.put(_keyPillCount, active);
    await _box.put(_keyBreakDays, brk);
    await _box.put(_keyPackFormat, _packFormatCode); // Синхронизируем код
    notifyListeners();
  }

  Future<void> setTime(TimeOfDay time, {required String notifTitle, required String notifBody}) async {
    _reminderTime = time;
    await _box.put(_keyTimeHour, time.hour);
    await _box.put(_keyTimeMinute, time.minute);

    if (_isEnabled) {
      await _scheduleNotification(notifTitle, notifBody);
    }
    notifyListeners();
  }

  // --- Pill Management ---

  Future<void> takePill() async {
    final now = _normalizeDate(DateTime.now());
    await takePillOnDate(now);
  }

  Future<void> takePillOnDate(DateTime date) async {
    final normDate = _normalizeDate(date);
    final today = _normalizeDate(DateTime.now());

    // 🔥 ИСПРАВЛЕНИЕ: Защита от "путешествий во времени"
    if (normDate.isAfter(today)) return;

    if (_isSameDayInList(_missed, normDate)) {
      _missed.removeWhere((d) => _isSameDay(d, normDate));
    }

    if (_isSameDayInList(_history, normDate)) return;

    _history.add(normDate);
    _history.sort();

    await _saveHistory();
    notifyListeners();
  }

  Future<void> markAsMissed(DateTime date) async {
    final normDate = _normalizeDate(date);

    if (_isSameDayInList(_history, normDate)) {
      _history.removeWhere((d) => _isSameDay(d, normDate));
    }

    if (_isSameDayInList(_missed, normDate)) return;

    _missed.add(normDate);
    _missed.sort();

    await _saveHistory();
    notifyListeners();
  }

  Future<void> undoTakePill() async {
    final now = _normalizeDate(DateTime.now());
    await undoTakePillOnDate(now);
  }

  Future<void> undoTakePillOnDate(DateTime date) async {
    final normDate = _normalizeDate(date);
    _history.removeWhere((d) => _isSameDay(d, normDate));
    _missed.removeWhere((d) => _isSameDay(d, normDate));

    await _saveHistory();
    notifyListeners();
  }

  bool isTakenOnDate(DateTime date) {
    final target = _normalizeDate(date);
    return _isSameDayInList(_history, target);
  }

  // --- Helpers ---

  DateTime _normalizeDate(DateTime d) {
    return DateTime.utc(d.year, d.month, d.day, 12, 0, 0);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameDayInList(List<DateTime> list, DateTime target) {
    return list.any((d) => _isSameDay(d, target));
  }

  Future<void> _saveHistory() async {
    final historyMs = _history.map((e) => e.millisecondsSinceEpoch).toList();
    final missedMs = _missed.map((e) => e.millisecondsSinceEpoch).toList();

    await _box.put(_keyHistory, historyMs);
    await _box.put(_keyMissed, missedMs);
  }

  // --- Notifications ---

  Future<void> _scheduleNotification(String title, String body) async {
    if (_scheduleDailyNotificationOverride != null) {
      await _scheduleDailyNotificationOverride!(
        id: _notificationId,
        title: title,
        body: body,
        time: _reminderTime,
      );
      return;
    }
    await _notifications.scheduleDailyNotification(
      id: _notificationId,
      title: title,
      body: body,
      time: _reminderTime,
    );
  }

  Future<void> reschedule(String title, String body) async {
    if (_isEnabled) {
      await _scheduleNotification(title, body);
    }
  }

  Future<void> resetData() async {
    _isEnabled = false;
    _reminderTime = const TimeOfDay(hour: 20, minute: 0);
    _history = [];
    _missed = [];
    _startDate = DateTime.now();
    _activePillCount = 21;
    _breakDays = 7;
    _packFormatCode = 21;

    await _box.clear();

    if (_cancelNotificationOverride != null) {
      await _cancelNotificationOverride!(_notificationId);
    } else {
      await _notifications.cancelNotification(_notificationId);
    }

    notifyListeners();
  }
}
