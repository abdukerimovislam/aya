import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../core/l10n/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../models/cycle_model.dart';
import '../logic/cycle_ai_engine.dart';

enum FertilityChance { low, high, peak }
enum TTCStrategy { minimal, maximal }

// 🔥 НОВОЕ: Результат логирования цикла для умного UI
enum CycleLogResult {
  success,
  suspiciouslyEarly, // Прошло слишком мало времени (нужно спросить "Вы уверены?")
  futureDate         // Попытка отметить цикл в будущем
}

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
    return math.max(1, cycleLength - 14);
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

    if (current == ovDay || current == ovDay - 1) return FertilityChance.peak;

    if ((current >= math.max(1, ovDay - 5) && current < ovDay - 1) || current == ovDay + 1) {
      return FertilityChance.high;
    }
    return FertilityChance.low;
  }

  bool get isFertileWindow {
    if (!_isTTCMode || _isCOCEnabled) return false;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    return current >= math.max(1, ovDay - 5) && current <= (ovDay + 1);
  }

  Future<void> _ensureBoxOpen() async {
    if (!_settingsBox.isOpen) _settingsBox = await Hive.openBox(_settingsBox.name);
    if (!_cycleBox.isOpen) _cycleBox = await Hive.openBox(_cycleBox.name);
  }

  DateTime _normalizeDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
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
    if (_isCOCEnabled) {
      final activePills = _settingsBox.get('coc_active_count', defaultValue: 21);
      final breakDays = _settingsBox.get('coc_break_days', defaultValue: 7);
      _updateCurrentData(_currentData.cycleStartDate, activePills + breakDays, breakDays);
      return;
    }

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];
    List<int> manualStarts = (_settingsBox.get('manual_cycle_starts') as List?)?.cast<int>() ?? [];

    if (timestamps.isEmpty) {
      await _cycleBox.clear();
      _history = [];
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

    List<CycleModel> newHistory = [];
    DateTime cycleStart = days.first;
    List<DateTime> currentCycleBleedingDays = [days.first];

    // 🔥 АЛГОРИТМ МЕДИЦИНСКОГО ГРУППИРОВАНИЯ ЦИКЛОВ (МЕГА УМНЫЙ)
    for (int i = 1; i < days.length; i++) {
      DateTime currentDay = days[i];
      bool isExplicitNewCycle = manualStarts.contains(currentDay.millisecondsSinceEpoch);
      int daysSinceCycleStart = currentDay.difference(cycleStart).inDays;
      bool gapLargeEnough = currentDay.difference(currentCycleBleedingDays.last).inDays > 2;

      // Нормальный новый цикл: разрыв больше 2 дней И прошло хотя бы 21 день
      bool isMedicallyPlausibleNewCycle = daysSinceCycleStart >= 21;

      if (isExplicitNewCycle || (gapLargeEnough && isMedicallyPlausibleNewCycle)) {
        // ЗАВЕРШАЕМ СТАРЫЙ ЦИКЛ
        // Считаем длину месячных ТОЛЬКО по первому непрерывному блоку (отсекаем Spotting)
        int pLen = 1;
        for (int j = 1; j < currentCycleBleedingDays.length; j++) {
          if (currentCycleBleedingDays[j].difference(currentCycleBleedingDays[j - 1]).inDays <= 2) {
            pLen = currentCycleBleedingDays[j].difference(currentCycleBleedingDays.first).inDays + 1;
          } else {
            break; // Наткнулись на разрыв. Дальше - межменструальные выделения.
          }
        }

        newHistory.add(CycleModel(
          startDate: cycleStart,
          endDate: currentDay.subtract(const Duration(days: 1)),
          length: daysSinceCycleStart,
          periodDuration: pLen,
        ));

        // НАЧИНАЕМ НОВЫЙ
        cycleStart = currentDay;
        currentCycleBleedingDays = [currentDay];
      } else {
        // Это кровь в пределах ТЕКУЩЕГО цикла (Spotting или длинные непрерывные месячные)
        currentCycleBleedingDays.add(currentDay);
      }
    }

    // Добавляем текущий (незавершенный) цикл
    int pLen = 1;
    for (int j = 1; j < currentCycleBleedingDays.length; j++) {
      if (currentCycleBleedingDays[j].difference(currentCycleBleedingDays[j - 1]).inDays <= 2) {
        pLen = currentCycleBleedingDays[j].difference(currentCycleBleedingDays.first).inDays + 1;
      } else {
        break;
      }
    }

    newHistory.add(CycleModel(
      startDate: cycleStart,
      endDate: null,
      length: null,
      periodDuration: pLen,
    ));

    await _cycleBox.clear();
    await _cycleBox.addAll(newHistory);

    final oldHistory = _history.isNotEmpty ? _history.first : null;
    _history = newHistory.reversed.toList();

    if (oldHistory != null && _history.first.startDate.isAfter(oldHistory.startDate)) {
      await _settingsBox.put('current_period_ended', false);
    }

    _calculateSmartAverages();
    _calculateAIConfidence();

    final latestCycle = _history.first;
    _updateCurrentData(latestCycle.startDate, _avgCycleLength, _avgPeriodDuration);
  }

  void _calculateSmartAverages() {
    if (_history.isEmpty || _isCOCEnabled) return;

    final completedCycles = _history.where((c) => c.length != null).take(8).toList();
    if (completedCycles.isEmpty) return;

    double weightedSumCycle = 0;
    double weightTotalCycle = 0;
    double currentWeight = completedCycles.length.toDouble();

    for (var c in completedCycles) {
      if (c.length! >= 15 && c.length! <= 90) {
        weightedSumCycle += c.length! * currentWeight;
        weightTotalCycle += currentWeight;
      }
      currentWeight -= 1.0;
    }

    if (weightTotalCycle > 0) {
      _avgCycleLength = (weightedSumCycle / weightTotalCycle).round().clamp(15, 90);
      _settingsBox.put('avg_cycle_len', _avgCycleLength);
    }

    double weightedSumPeriod = 0;
    double weightTotalPeriod = 0;
    currentWeight = completedCycles.length.toDouble();

    for (var c in completedCycles) {
      if (c.periodDuration != null && c.periodDuration! >= 2 && c.periodDuration! <= 14) {
        weightedSumPeriod += c.periodDuration! * currentWeight;
        weightTotalPeriod += currentWeight;
      }
      currentWeight -= 1.0;
    }

    if (weightTotalPeriod > 0) {
      _avgPeriodDuration = (weightedSumPeriod / weightTotalPeriod).round().clamp(2, 14);
      _settingsBox.put('avg_period_len', _avgPeriodDuration);
    }
  }

  void _updateCurrentData(DateTime startDate, int avgLen, int periodLen, {bool notify = true}) {
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final safeStart = _normalizeDate(startDate);

    if (_ovulationOverride != null && _ovulationOverride!.isBefore(safeStart)) {
      _clearOvulationOverride();
    }

    final diff = normalizedNow.difference(safeStart).inDays;
    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    int effectiveCycleLen;
    DateTime predictedOvulation;

    if (_isCOCEnabled) {
      effectiveCycleLen = _settingsBox.get('coc_active_count', defaultValue: 21) + _settingsBox.get('coc_break_days', defaultValue: 7);
      predictedOvulation = safeStart.add(const Duration(days: 14));
    } else if (_ovulationOverride != null) {
      predictedOvulation = _normalizeDate(_ovulationOverride!);
      effectiveCycleLen = predictedOvulation.difference(safeStart).inDays + 14;
    } else {
      effectiveCycleLen = avgLen.clamp(15, 90);
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
    final bool isFertile = !_isCOCEnabled && (currentDay >= (ovDayIndex - 5) && currentDay <= ovDayIndex + 1);

    final nextPeriodDate = safeStart.add(Duration(days: effectiveCycleLen));
    int daysUntilNext = nextPeriodDate.difference(normalizedNow).inDays;
    if (phase == CyclePhase.late || daysUntilNext < 0) daysUntilNext = 0;

    int currentExpectedPeriodDuration = periodLen;
    bool isEndedExplicitly = _settingsBox.get('current_period_ended', defaultValue: false);

    if (_history.isNotEmpty && !isEndedExplicitly && !_isCOCEnabled) {
      final lastRecordedBleedingInCurrentCycle = _history.first.startDate.add(Duration(days: (_history.first.periodDuration ?? 1) - 1));

      if (normalizedNow.difference(lastRecordedBleedingInCurrentCycle).inDays <= 1) {
        currentExpectedPeriodDuration = math.min(14, math.max(periodLen, _history.first.periodDuration ?? periodLen + 1));
      } else {
        currentExpectedPeriodDuration = math.min(14, _history.first.periodDuration ?? periodLen);
      }
    }

    _currentData = CycleData(
      cycleStartDate: safeStart,
      totalCycleLength: effectiveCycleLen,
      periodDuration: currentExpectedPeriodDuration,
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
      final activePills = _settingsBox.get('coc_active_count', defaultValue: 21);
      final breakDays = _settingsBox.get('coc_break_days', defaultValue: 7);
      final totalPills = activePills + breakDays;

      if (day <= activePills) return CyclePhase.follicular;
      if (day <= totalPills) return CyclePhase.menstruation;
      return CyclePhase.late;
    }

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];
    if (timestamps.contains(dateToCheck.millisecondsSinceEpoch)) return CyclePhase.menstruation;

    if (_history.isNotEmpty) {
      final latestCycle = _history.first;
      final cycleEnd = latestCycle.startDate.add(Duration(days: (latestCycle.periodDuration ?? 1) - 1));

      if (!dateToCheck.isBefore(latestCycle.startDate) && !dateToCheck.isAfter(cycleEnd)) return CyclePhase.menstruation;

      bool isEndedExplicitly = _settingsBox.get('current_period_ended', defaultValue: false);
      if (!isEndedExplicitly && dateToCheck.isAfter(cycleEnd) && dateToCheck.difference(cycleEnd).inDays <= 1) {
        if (dateToCheck.difference(latestCycle.startDate).inDays < 14) {
          return CyclePhase.menstruation;
        }
      }
    }

    bool isEndedExplicitly = _settingsBox.get('current_period_ended', defaultValue: false);
    if (!isEndedExplicitly && day <= _avgPeriodDuration && day > 0) return CyclePhase.menstruation;

    final ovDayIndex = ovulationDate.difference(cycleStart).inDays + 1;
    if (day >= ovDayIndex - 2 && day <= ovDayIndex + 1) return CyclePhase.ovulation;
    if (day < ovDayIndex - 2) return CyclePhase.follicular;
    if (day > length) return CyclePhase.late;

    return CyclePhase.luteal;
  }

  CyclePhase? getPhaseForDate(DateTime date) {
    final normalized = _normalizeDate(date);
    return _calculatePhase(
        day: normalized.difference(_normalizeDate(_currentData.cycleStartDate)).inDays + 1,
        length: _currentData.totalCycleLength,
        dateToCheck: normalized,
        isCOC: _isCOCEnabled,
        cycleStart: _normalizeDate(_currentData.cycleStartDate),
        ovulationDate: _normalizeDate(_currentData.cycleStartDate).add(Duration(days: ovulationDay - 1))
    );
  }

  Future<void> togglePeriodDay(DateTime date) async {
    await _ensureBoxOpen();
    final normDate = _normalizeDate(date);
    if (normDate.isAfter(_normalizeDate(DateTime.now()))) return;

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];
    List<int> manualStarts = (_settingsBox.get('manual_cycle_starts') as List?)?.cast<int>() ?? [];
    final ms = normDate.millisecondsSinceEpoch;

    if (timestamps.contains(ms)) {
      timestamps.remove(ms);
      manualStarts.remove(ms);
    } else {
      timestamps.add(ms);

      if (!_isCOCEnabled) {
        final currentStart = _normalizeDate(_currentData.cycleStartDate);
        if (!normDate.isBefore(currentStart)) {
          await _settingsBox.put('current_period_ended', false);
        }
      }
    }

    await _settingsBox.put('bleeding_days', timestamps);
    await _settingsBox.put('manual_cycle_starts', manualStarts);

    if (_isCOCEnabled) {
      final active = _settingsBox.get('coc_active_count', defaultValue: 21);
      final brk = _settingsBox.get('coc_break_days', defaultValue: 7);
      _updateCurrentData(_currentData.cycleStartDate, active + brk, brk);
      return;
    }

    await _recalculateEngine();
    await rescheduleNotifications();
  }

  // 🔥 ИНТЕЛЛЕКТУАЛЬНАЯ ПРОВЕРКА ЦИКЛА: Добавлен флаг isConfirmed и возврат Enum
  Future<CycleLogResult> logActionStartPeriod(DateTime date, {bool isConfirmed = false}) async {
    await _ensureBoxOpen();
    if (_isCOCEnabled) return CycleLogResult.success;

    final normDate = _normalizeDate(date);
    if (normDate.isAfter(_normalizeDate(DateTime.now()))) {
      return CycleLogResult.futureDate;
    }

    // Защита от ошибочных случайных кликов (Меньше 21 дня - это Полименорея или выделения)
    if (!isConfirmed) {
      final currentStart = _normalizeDate(_currentData.cycleStartDate);
      final diff = normDate.difference(currentStart).inDays;
      // Если пытаются начать цикл раньше, чем через 21 день (и это не тот же самый день)
      if (diff > 0 && diff < 21) {
        return CycleLogResult.suspiciouslyEarly; // Триггер для UI показать алерт "Вы уверены?"
      }
    }

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];
    List<int> manualStarts = (_settingsBox.get('manual_cycle_starts') as List?)?.cast<int>() ?? [];

    timestamps.removeWhere((ts) {
      return DateTime.fromMillisecondsSinceEpoch(ts).isAfter(normDate);
    });
    manualStarts.removeWhere((ts) {
      return DateTime.fromMillisecondsSinceEpoch(ts).isAfter(normDate);
    });

    final ms = normDate.millisecondsSinceEpoch;
    if (!timestamps.contains(ms)) timestamps.add(ms);

    // Если прошли проверку, записываем как точный старт
    if (!manualStarts.contains(ms)) manualStarts.add(ms);

    await _clearOvulationOverride();

    await _settingsBox.put('current_period_ended', false);
    await _settingsBox.put('bleeding_days', timestamps);
    await _settingsBox.put('manual_cycle_starts', manualStarts);

    await _recalculateEngine();
    await rescheduleNotifications();

    return CycleLogResult.success;
  }

  Future<CycleLogResult> startNewCycle({bool isConfirmed = false}) async =>
      logActionStartPeriod(DateTime.now(), isConfirmed: isConfirmed);

  Future<void> endCurrentPeriod({DateTime? endDate}) async {
    await _ensureBoxOpen();
    if (_isCOCEnabled) return;

    final end = _normalizeDate(endDate ?? DateTime.now());
    final start = _normalizeDate(_currentData.cycleStartDate);

    if (end.isBefore(start)) return;

    List<int> timestamps = (_settingsBox.get('bleeding_days') as List?)?.cast<int>() ?? [];

    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final d = start.add(Duration(days: i));
      if (d.isBefore(end)) {
        if (!timestamps.contains(d.millisecondsSinceEpoch)) {
          timestamps.add(d.millisecondsSinceEpoch);
        }
      }
    }

    timestamps.removeWhere((ts) {
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      return !d.isBefore(end);
    });

    timestamps = timestamps.toSet().toList();

    await _settingsBox.put('bleeding_days', timestamps);
    await _settingsBox.put('current_period_ended', true);

    await _recalculateEngine();
    await rescheduleNotifications();
  }

  Future<void> setSpecificCycleStartDate(DateTime date) async => logActionStartPeriod(date, isConfirmed: true);
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
        final active = _settingsBox.get('coc_active_count', defaultValue: 21);
        final brk = _settingsBox.get('coc_break_days', defaultValue: 7);
        _updateCurrentData(correctedStart, active + brk, brk);
      } else {
        final active = _settingsBox.get('coc_active_count', defaultValue: 21);
        final brk = _settingsBox.get('coc_break_days', defaultValue: 7);
        _updateCurrentData(DateTime.now(), active + brk, brk);
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
    length = length.clamp(15, 90);
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