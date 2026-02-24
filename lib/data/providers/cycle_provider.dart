import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../models/cycle_model.dart';
import '../logic/cycle_ai_engine.dart';

enum FertilityChance { low, high, peak }
enum TTCStrategy { minimal, maximal }

class CycleProvider with ChangeNotifier {
  Box _cycleBox;
  Box _settingsBox;
  final NotificationService? _notificationService;

  CycleData _currentData = CycleData.empty();
  List<CycleModel> _history = [];
  CycleConfidenceResult? _aiConfidence;

  bool _isCOCEnabled = false;
  bool _isTTCMode = false;
  int _avgCycleLength = 28;
  int _avgPeriodDuration = 5;

  TTCStrategy _ttcStrategy = TTCStrategy.minimal;

  DateTime? _ovulationOverride;
  String? _ovulationOverrideSource;

  bool _isLoaded = false;

  CycleProvider(this._cycleBox, this._settingsBox, [this._notificationService]) {
    _init();
  }

  CycleData get currentData => _currentData;
  List<CycleModel> get history => List.unmodifiable(_history);
  CycleConfidenceResult? get aiConfidence => _aiConfidence;

  int get cycleLength => _currentData.totalCycleLength > 0
      ? _currentData.totalCycleLength
      : (_isCOCEnabled ? 28 : _avgCycleLength);

  int get avgPeriodDuration => _avgPeriodDuration;
  int get periodDuration => _avgPeriodDuration;

  bool get isCOCEnabled => _isCOCEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get isLoaded => _isLoaded;

  TTCStrategy get ttcStrategy => _ttcStrategy;
  bool get isOvulationConfirmed => _ovulationOverride != null;
  String? get ovulationOverrideSource => _ovulationOverrideSource;

  int get ovulationDay {
    if (_isCOCEnabled) return 14;
    if (_currentData.cycleStartDate.year == 1970) return 14;

    if (_ovulationOverride != null) {
      return _ovulationOverride!.difference(_currentData.cycleStartDate).inDays + 1;
    }
    return cycleLength - 14;
  }

  int? get currentDPO {
    if (!_isTTCMode || _isCOCEnabled) return null;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    if (current > ovDay) return current - ovDay;
    return null;
  }

  FertilityChance get conceptionChance {
    if (!_isTTCMode || _isCOCEnabled) return FertilityChance.low;

    final current = _currentData.currentDay;
    final ovDay = ovulationDay;

    if (_currentData.phase == CyclePhase.menstruation && current < 6) {
      return FertilityChance.low;
    }

    if (current == ovDay || current == ovDay - 1) {
      return FertilityChance.peak;
    }
    if (current >= ovDay - 5 && current < ovDay - 1) {
      return FertilityChance.high;
    }
    return FertilityChance.low;
  }

  bool get isFertileWindow {
    if (!_isTTCMode || _isCOCEnabled) return false;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    return current >= (ovDay - 5) && current <= ovDay;
  }

  Future<void> _ensureBoxOpen() async {
    if (!_settingsBox.isOpen) {
      _settingsBox = await Hive.openBox(_settingsBox.name);
    }
    if (!_cycleBox.isOpen) {
      _cycleBox = await Hive.openBox(_cycleBox.name);
    }
  }

  DateTime _normalizeDate(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  void _loadOverrides() {
    try {
      final ovMs = _settingsBox.get('current_ovulation_override') as int?;
      _ovulationOverride = ovMs != null ? DateTime.fromMillisecondsSinceEpoch(ovMs) : null;
      _ovulationOverrideSource = _settingsBox.get('current_ovulation_override_source') as String?;

      final rawStrategy = _settingsBox.get('ttc_strategy') as String?;
      _ttcStrategy = rawStrategy == 'maximal' ? TTCStrategy.maximal : TTCStrategy.minimal;
    } catch (_) {
      _ovulationOverride = null;
      _ovulationOverrideSource = null;
      _ttcStrategy = TTCStrategy.minimal;
    }
  }

  Future<void> _clearOvulationOverride() async {
    _ovulationOverride = null;
    _ovulationOverrideSource = null;
    try {
      await _settingsBox.delete('current_ovulation_override');
      await _settingsBox.delete('current_ovulation_override_source');
    } catch (_) {}
  }

  Future<void> _init() async {
    _isLoaded = false;

    try {
      await _ensureBoxOpen();

      _isCOCEnabled = _settingsBox.get('coc_enabled', defaultValue: false);
      _isTTCMode = _settingsBox.get('ttc_mode_enabled', defaultValue: false);
      _avgCycleLength = _settingsBox.get('avg_cycle_len', defaultValue: 28);
      _avgPeriodDuration = _settingsBox.get('avg_period_len', defaultValue: 5);

      _loadOverrides();

      // МИГРАЦИЯ
      List<int> savedDays = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];
      if (savedDays.isEmpty && _cycleBox.isNotEmpty) {
        Set<DateTime> migratedDays = {};
        for (var c in _cycleBox.values.cast<CycleModel>()) {
          int duration = c.periodDuration ?? _avgPeriodDuration;
          for (int i = 0; i < duration; i++) {
            migratedDays.add(_normalizeDate(c.startDate.add(Duration(days: i))));
          }
        }
        savedDays = migratedDays.map((e) => e.millisecondsSinceEpoch).toList();
        await _settingsBox.put('bleeding_days', savedDays);
      }

      await _recalculateEngine();

      _isLoaded = true;
      notifyListeners();
      rescheduleNotifications();
    } catch (e) {
      debugPrint("CycleProvider Init Error: $e");
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _recalculateEngine() async {
    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];

    if (timestamps.isEmpty) {
      await _cycleBox.clear();
      _history = [];

      // ЗАЩИТА: Фиксируем дату скачивания, чтобы цикл шел, даже если девушка ничего не отметила
      DateTime fallbackStart = DateTime.now();
      int? savedFallback = _settingsBox.get('fallback_start_date');
      if (savedFallback != null) {
        fallbackStart = DateTime.fromMillisecondsSinceEpoch(savedFallback);
      } else {
        _settingsBox.put('fallback_start_date', fallbackStart.millisecondsSinceEpoch);
      }

      _updateCurrentData(fallbackStart, _avgCycleLength, _avgPeriodDuration);
      return;
    } else {
      _settingsBox.delete('fallback_start_date');
    }

    List<DateTime> days = timestamps.map((ts) => DateTime.fromMillisecondsSinceEpoch(ts)).toList();
    days.sort();

    List<List<DateTime>> periods = [];
    List<DateTime> currentPeriod = [days.first];

    for (int i = 1; i < days.length; i++) {
      final diff = days[i].difference(currentPeriod.last).inDays;
      if (diff <= 8) {
        currentPeriod.add(days[i]);
      } else {
        periods.add(currentPeriod);
        currentPeriod = [days[i]];
      }
    }
    periods.add(currentPeriod);

    List<CycleModel> newHistory = [];
    for (int i = 0; i < periods.length; i++) {
      final periodStart = periods[i].first;
      final periodEnd = periods[i].last;
      final pLen = periodEnd.difference(periodStart).inDays + 1;

      int? cycleLen;
      DateTime? cycleEndDate;
      if (i < periods.length - 1) {
        cycleEndDate = periods[i + 1].first.subtract(const Duration(days: 1));
        cycleLen = periods[i + 1].first.difference(periodStart).inDays;

        if (cycleLen > 90) cycleLen = null;
      }

      newHistory.add(CycleModel(
        startDate: periodStart,
        endDate: cycleEndDate,
        length: cycleLen,
        periodDuration: pLen,
      ));
    }

    await _cycleBox.clear();
    await _cycleBox.addAll(newHistory);

    // 🔥 ЗАЩИТА СБРОСА: Если начался новый цикл, сбрасываем маркер ручной остановки старого цикла
    final oldHistory = _history.isNotEmpty ? _history.first : null;
    _history = newHistory.reversed.toList();

    if (oldHistory != null && _history.first.startDate.isAfter(oldHistory.startDate)) {
      await _settingsBox.put('current_period_ended', false);
    }

    _calculateSMA();
    _calculateAIConfidence();

    final latestCycle = _history.first;
    _updateCurrentData(latestCycle.startDate, _avgCycleLength, _avgPeriodDuration);
  }

  void _calculateSMA() {
    if (_history.isEmpty || _isCOCEnabled) return;

    int totalCycleLen = 0;
    int countCycle = 0;
    int totalPeriodLen = 0;
    int countPeriod = 0;

    final completedCycles = _history.where((c) => c.length != null).take(6).toList();

    for (var c in completedCycles) {
      if (c.length! >= 21 && c.length! <= 60) {
        totalCycleLen += c.length!;
        countCycle++;
      }
    }

    final recentPeriods = _history.take(6).toList();
    for (var c in recentPeriods) {
      if (c.periodDuration != null && c.periodDuration! >= 1 && c.periodDuration! <= 14) {
        totalPeriodLen += c.periodDuration!;
        countPeriod++;
      }
    }

    if (countCycle > 0) {
      _avgCycleLength = (totalCycleLen / countCycle).round().clamp(21, 60);
      _settingsBox.put('avg_cycle_len', _avgCycleLength);
    }
    if (countPeriod > 0) {
      _avgPeriodDuration = (totalPeriodLen / countPeriod).round().clamp(1, 14);
      _settingsBox.put('avg_period_len', _avgPeriodDuration);
    }
  }

  void _updateCurrentData(DateTime startDate, int avgLen, int periodLen, {bool notify = true}) {
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final safeStart = _normalizeDate(startDate);

    // 🔥 ЗАЩИТА: Сброс овуляции из старого цикла
    if (_ovulationOverride != null && _ovulationOverride!.isBefore(safeStart)) {
      _clearOvulationOverride(); // Удаляем устаревшие данные овуляции
    }

    final diff = normalizedNow.difference(safeStart).inDays;
    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    int effectiveCycleLen;
    DateTime predictedOvulation;

    if (_isCOCEnabled) {
      effectiveCycleLen = 28;
      predictedOvulation = safeStart.add(const Duration(days: 14));
    } else if (_ovulationOverride != null) {
      predictedOvulation = _normalizeDate(_ovulationOverride!);
      final daysToOvulation = predictedOvulation.difference(safeStart).inDays;
      effectiveCycleLen = daysToOvulation + 14;
    } else {
      effectiveCycleLen = avgLen.clamp(21, 60);
      predictedOvulation = safeStart.add(Duration(days: effectiveCycleLen - 14));
    }

    final phase = _calculatePhase(
      day: currentDay,
      length: effectiveCycleLen,
      dateToCheck: normalizedNow,
      isCOC: _isCOCEnabled,
      cycleStart: safeStart,
      ovulationDate: predictedOvulation,
    );

    final ovDayIndex = predictedOvulation.difference(safeStart).inDays + 1;
    final bool isFertile = !_isCOCEnabled && (currentDay >= (ovDayIndex - 5) && currentDay <= ovDayIndex);

    final nextPeriodDate = safeStart.add(Duration(days: effectiveCycleLen));
    int daysUntilNext = nextPeriodDate.difference(normalizedNow).inDays;

    if (phase == CyclePhase.late) daysUntilNext = 0;
    if (daysUntilNext < 0) daysUntilNext = 0;

    _currentData = CycleData(
      cycleStartDate: safeStart,
      totalCycleLength: effectiveCycleLen,
      periodDuration: _history.isNotEmpty ? _history.first.periodDuration ?? periodLen : periodLen,
      currentDay: currentDay,
      phase: phase,
      daysUntilNextPeriod: daysUntilNext,
      isFertile: isFertile,
      lastPeriodDate: safeStart,
    );

    if (notify) notifyListeners();
  }

  CyclePhase _calculatePhase({
    required int day,
    required int length,
    required DateTime dateToCheck,
    required bool isCOC,
    required DateTime cycleStart,
    required DateTime ovulationDate,
  }) {
    if (isCOC) {
      if (day <= 21) return CyclePhase.follicular;
      if (day <= 28) return CyclePhase.menstruation;
      return CyclePhase.late;
    }

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];

    // 1. Физически записанный день? -> 100% Менструация
    if (timestamps.contains(dateToCheck.millisecondsSinceEpoch)) {
      return CyclePhase.menstruation;
    }

    // Заливка пробелов внутри уже зафиксированных месячных
    if (_history.isNotEmpty) {
      final latestCycle = _history.first;
      final cycleEnd = latestCycle.startDate.add(Duration(days: (latestCycle.periodDuration ?? 1) - 1));
      if (!dateToCheck.isBefore(latestCycle.startDate) && !dateToCheck.isAfter(cycleEnd)) {
        return CyclePhase.menstruation;
      }
    }

    // 2. Умное предсказание (Только если девушка не нажала Стоп)
    bool isEndedExplicitly = _settingsBox.get('current_period_ended', defaultValue: false);
    if (!isEndedExplicitly && day <= _avgPeriodDuration && day > 0) {
      return CyclePhase.menstruation;
    }

    final ovDayIndex = ovulationDate.difference(cycleStart).inDays + 1;

    if (day >= ovDayIndex - 2 && day <= ovDayIndex + 1) return CyclePhase.ovulation;
    if (day < ovDayIndex - 2) return CyclePhase.follicular;
    if (day > length) return CyclePhase.late;

    return CyclePhase.luteal;
  }

  // 🔥 ИСПРАВЛЕНИЕ: Идеальное отображение всей истории циклов в Календаре
  CyclePhase? getPhaseForDate(DateTime date) {
    final normalized = _normalizeDate(date);
    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];

    if (timestamps.contains(normalized.millisecondsSinceEpoch)) {
      return CyclePhase.menstruation;
    }

    // Если это текущий/будущий цикл
    if (!normalized.isBefore(_normalizeDate(_currentData.cycleStartDate))) {
      final dayIndex = normalized.difference(_normalizeDate(_currentData.cycleStartDate)).inDays + 1;

      bool isEndedExplicitly = _settingsBox.get('current_period_ended', defaultValue: false);
      if (!isEndedExplicitly && dayIndex <= _avgPeriodDuration && dayIndex > 0) {
        return CyclePhase.menstruation;
      }

      final ovDayIndex = _normalizeDate(_currentData.cycleStartDate).add(Duration(days: ovulationDay - 1)).difference(_normalizeDate(_currentData.cycleStartDate)).inDays + 1;

      if (dayIndex >= ovDayIndex - 2 && dayIndex <= ovDayIndex + 1) return CyclePhase.ovulation;
      if (dayIndex < ovDayIndex - 2) return CyclePhase.follicular;
      if (dayIndex > _currentData.totalCycleLength) return CyclePhase.late;
      return CyclePhase.luteal;
    }

    // Если это прошлый цикл, точно восстанавливаем его фазы
    for (final h in _history) {
      if (h.endDate != null && !normalized.isBefore(h.startDate) && !normalized.isAfter(h.endDate!)) {
        final day = normalized.difference(h.startDate).inDays + 1;
        if (day <= (h.periodDuration ?? 5)) return CyclePhase.menstruation;

        // Восстанавливаем реальную лютеиновую и овуляторную фазу старого цикла!
        final cLen = h.length ?? _avgCycleLength;
        final ovDay = cLen - 14;
        if (day >= ovDay - 2 && day <= ovDay + 1) return CyclePhase.ovulation;
        if (day < ovDay - 2) return CyclePhase.follicular;
        if (day > cLen) return CyclePhase.late;
        return CyclePhase.luteal;
      }
    }
    return null;
  }

  Future<void> togglePeriodDay(DateTime date) async {
    await _ensureBoxOpen();
    final normDate = _normalizeDate(date);

    // ЗАЩИТА: Никаких отметок месячных в будущем
    if (normDate.isAfter(_normalizeDate(DateTime.now()))) return;

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];
    final ms = normDate.millisecondsSinceEpoch;

    if (timestamps.contains(ms)) {
      timestamps.remove(ms);
    } else {
      timestamps.add(ms);

      // ЗАЩИТА: Отмена остановки. Добавили кровь = цикл снова активен
      if (!normDate.isBefore(_normalizeDate(_currentData.cycleStartDate))) {
        await _settingsBox.put('current_period_ended', false);
      }
    }

    await _settingsBox.put('bleeding_days', timestamps);
    await _recalculateEngine();
    await rescheduleNotifications();
  }

  Future<void> startNewCycle() async => togglePeriodDay(DateTime.now());

  Future<void> endCurrentPeriod() async {
    await _ensureBoxOpen();
    final today = _normalizeDate(DateTime.now());
    final start = _normalizeDate(_currentData.cycleStartDate);

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];

    // Превращаем фантомные (предсказанные) дни в реальные
    if (!today.isBefore(start)) {
      for (int i = 0; i < today.difference(start).inDays; i++) {
        final d = start.add(Duration(days: i));
        if (!timestamps.contains(d.millisecondsSinceEpoch)) {
          timestamps.add(d.millisecondsSinceEpoch);
        }
      }
    }

    // Удаляем отметки "Сегодня" и "В будущем"
    timestamps.removeWhere((ts) {
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      return !d.isBefore(today);
    });

    await _settingsBox.put('bleeding_days', timestamps);

    // Глобальная печать "Остановлено"
    await _settingsBox.put('current_period_ended', true);

    await _recalculateEngine();
    await rescheduleNotifications();
  }

  Future<void> setSpecificCycleStartDate(DateTime date) async => togglePeriodDay(date);
  Future<void> setPeriodDate(DateTime date) async => togglePeriodDay(date);

  Future<void> setTTCStrategy(TTCStrategy strategy) async {
    await _ensureBoxOpen();
    _ttcStrategy = strategy;
    try {
      await _settingsBox.put('ttc_strategy', strategy == TTCStrategy.maximal ? 'maximal' : 'minimal');
    } catch (_) {}
    notifyListeners();
  }

  Future<void> confirmOvulation(DateTime date, {String source = 'manual'}) async {
    await _ensureBoxOpen();
    final normDate = _normalizeDate(date);
    if (normDate.isBefore(_currentData.cycleStartDate)) return;

    _ovulationOverride = normDate;
    _ovulationOverrideSource = source;
    await _settingsBox.put('current_ovulation_override', _ovulationOverride!.millisecondsSinceEpoch);
    await _settingsBox.put('current_ovulation_override_source', source);

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  Future<void> clearOvulationIfMatchesLHTestDate(DateTime testDate) async {
    await _ensureBoxOpen();
    if (_ovulationOverride == null || _ovulationOverrideSource != 'lh') return;

    final expectedOvulation = _normalizeDate(testDate.add(const Duration(days: 1)));
    if (_normalizeDate(_ovulationOverride!) != expectedOvulation) return;

    await _clearOvulationOverride();
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
    notifyListeners();
  }

  Future<void> tryAutoConfirmOvulationFromBBT(List<MapEntry<DateTime, double>> tempHistory) async {
    await _ensureBoxOpen();
    if (!_isTTCMode || _isCOCEnabled || _ovulationOverride != null) return;

    final cycleStart = _normalizeDate(_currentData.cycleStartDate);
    final temps = tempHistory
        .map((e) => MapEntry(_normalizeDate(e.key), e.value))
        .where((e) => !e.key.isBefore(cycleStart))
        .toList()..sort((a, b) => a.key.compareTo(b.key));

    if (temps.length < 10) return;

    final Map<DateTime, double> map = {for (final e in temps) e.key: e.value};
    final dates = map.keys.toList()..sort();
    DateTime? shiftStart;

    for (int i = 6; i < dates.length; i++) {
      final d = dates[i];
      final prevDates = <DateTime>[];
      for (int k = 1; k <= 6; k++) {
        final pd = d.subtract(Duration(days: k));
        if (map.containsKey(pd)) prevDates.add(pd);
      }
      if (prevDates.length < 5) continue;

      final baseline = prevDates.map((pd) => map[pd]!).reduce((a, b) => a + b) / prevDates.length;
      final d1 = d.add(const Duration(days: 1));
      final d2 = d.add(const Duration(days: 2));
      if (!map.containsKey(d1) || !map.containsKey(d2)) continue;

      final threshold = baseline + 0.20;
      if (map[d]! >= threshold && map[d1]! >= threshold && map[d2]! >= threshold) {
        shiftStart = d;
        break;
      }
    }

    if (shiftStart == null) return;

    final estimatedOvulation = _normalizeDate(shiftStart.subtract(const Duration(days: 1)));
    final minOvulation = cycleStart.add(Duration(days: _avgPeriodDuration));
    if (!estimatedOvulation.isAfter(minOvulation)) return;

    _ovulationOverride = estimatedOvulation;
    _ovulationOverrideSource = 'bbt';
    await _settingsBox.put('current_ovulation_override', estimatedOvulation.millisecondsSinceEpoch);
    await _settingsBox.put('current_ovulation_override_source', 'bbt');

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
    notifyListeners();
  }

  Future<void> clearOvulationData(DateTime date) async {
    await _ensureBoxOpen();
    if (date.isBefore(_currentData.cycleStartDate)) return;
    await _clearOvulationOverride();
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
    notifyListeners();
  }

  Future<void> setTTCMode(bool enabled) async {
    await _ensureBoxOpen();
    if (enabled && _isCOCEnabled) return;
    _isTTCMode = enabled;
    await _settingsBox.put('ttc_mode_enabled', enabled);
    notifyListeners();
  }

  Future<void> setCOCMode(bool enabled, {int currentPillNumber = 1}) async {
    await _ensureBoxOpen();

    _isCOCEnabled = enabled;
    await _settingsBox.put('coc_enabled', enabled);

    if (enabled) {
      _aiConfidence = null;
      if (_isTTCMode) {
        _isTTCMode = false;
        await _settingsBox.put('ttc_mode_enabled', false);
      }
      await _clearOvulationOverride();

      if (currentPillNumber > 1) {
        final daysToSubtract = currentPillNumber - 1;
        final correctedStart = DateTime.now().subtract(Duration(days: daysToSubtract));
        await togglePeriodDay(correctedStart);
      } else {
        await togglePeriodDay(DateTime.now());
      }
    } else {
      _calculateAIConfidence();
      _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
      await rescheduleNotifications();
    }
    notifyListeners();
  }

  Future<void> setAveragePeriodDuration(int days) async {
    await _ensureBoxOpen();
    days = days.clamp(1, 14);
    await _settingsBox.put('avg_period_len', days);
    _avgPeriodDuration = days;
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, days);
    await rescheduleNotifications();
  }

  Future<void> setCycleLength(int length) async {
    await _ensureBoxOpen();
    length = length.clamp(21, 60);
    await _settingsBox.put('avg_cycle_len', length);
    _avgCycleLength = length;
    _updateCurrentData(_currentData.cycleStartDate, length, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  void _calculateAIConfidence() {
    if (_isCOCEnabled) {
      _aiConfidence = null;
      return;
    }
    try {
      _aiConfidence = CycleAIEngine.calculateConfidence(_history);
    } catch (e) {
      debugPrint("AI Engine error: $e");
      _aiConfidence = null;
    }
  }

  Future<void> rescheduleNotifications() async {
    if (_notificationService == null) return;
    try {
      await _notificationService!.cancelAll();
      Locale targetLocale;
      final savedLang = _settingsBox.get('language_code') as String?;

      if (savedLang != null) {
        targetLocale = Locale(savedLang);
      } else {
        final sysCode = Intl.defaultLocale?.split('_')[0] ?? 'en';
        targetLocale = Locale(sysCode);
      }

      final l10n = await AppLocalizations.delegate.load(targetLocale);
      final lastStart = _normalizeDate(_currentData.cycleStartDate);
      final len = cycleLength;
      final nextPeriodStart = lastStart.add(Duration(days: len));

      if (_isCOCEnabled) {
        await _scheduleIfFuture(100, nextPeriodStart, l10n.notifNewPackTitle, l10n.notifNewPackBody, payload: "screen_coc");
        final breakDate = lastStart.add(const Duration(days: 21));
        await _scheduleIfFuture(101, breakDate, l10n.notifBreakTitle, l10n.notifBreakBody, payload: "screen_coc");
        return;
      }

      final day7 = lastStart.add(const Duration(days: 6));
      await _scheduleIfFuture(201, day7, l10n.notifFollTitle, l10n.notifFollBody, payload: "screen_calendar");

      final ovDay = ovulationDay;
      if (ovDay > 1) {
        final ovDate = lastStart.add(Duration(days: ovDay - 1));
        await _scheduleIfFuture(202, ovDate, l10n.notifOvulationTitle, l10n.notifOvulationBody, payload: "screen_calendar");
      }

      final pmsDay = len - 5;
      if (pmsDay > 10) {
        final pmsDate = lastStart.add(Duration(days: pmsDay - 1));
        await _scheduleIfFuture(203, pmsDate, l10n.notifLutealTitle, l10n.notifLutealBody, payload: "screen_calendar");
      }

      final prePeriodDate = nextPeriodStart.subtract(const Duration(days: 1));
      await _scheduleIfFuture(204, prePeriodDate, l10n.notifPeriodSoonTitle, l10n.notifPeriodSoonBody, payload: "screen_calendar");

      final lateDate = nextPeriodStart.add(const Duration(days: 3));
      await _scheduleIfFuture(205, lateDate, l10n.notifLateTitle, l10n.notifLateBody, payload: "screen_calendar");

      final now = DateTime.now();
      final todayEvening = DateTime(now.year, now.month, now.day, 20, 0);
      if (todayEvening.isAfter(now)) {
        await _scheduleIfFuture(300, todayEvening, l10n.notifCheckinTitle, l10n.notifCheckinBody, payload: "screen_calendar");
      }

    } catch (e) {
      debugPrint("Reschedule notifications error: $e");
    }
  }

  Future<void> _scheduleIfFuture(int id, DateTime date, String title, String body, {String? payload}) async {
    if (_notificationService == null) return;
    DateTime scheduleTime = (date.hour == 0 && date.minute == 0) ? DateTime(date.year, date.month, date.day, 9, 0) : date;

    if (scheduleTime.isAfter(DateTime.now())) {
      await _notificationService!.scheduleNotification(id: id, title: title, body: body, scheduledDate: scheduleTime, payload: payload ?? 'screen_calendar');
    }
  }

  Future<void> reload() async => _init();
}