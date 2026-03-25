import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;

import '../../core/services/notification_service.dart';
import '../../core/services/cycle_notification_manager.dart';
import '../../core/services/partner_sync_service.dart';
import '../models/cycle_model.dart';
import '../logic/cycle_ai_engine.dart';
import '../logic/cycle_calculator.dart';

enum AppMode { standard, coc, ttc }

enum FertilityChance { low, high, peak }
enum TTCStrategy { minimal, maximal }

enum DayType { period, fertile, ovulation, none }

enum CycleLogResult {
  success,
  suspiciouslyEarly,
  ovulationBleeding,
  futureDate
}

class CycleProvider with ChangeNotifier {
  Box _cycleBox;
  Box _settingsBox;
  final NotificationService? _notificationService;
  final Future<Box> Function(String name)? _encryptedBoxOpener;

  CycleData _currentData = CycleData.empty();
  List<CycleModel> _history = [];
  List<CycleModel>? _cachedHistory;

  CycleConfidenceResult? _aiConfidence;

  AppMode _appMode = AppMode.standard;

  int _avgCycleLength = 28;
  int _avgPeriodDuration = 5;

  TTCStrategy _ttcStrategy = TTCStrategy.minimal;

  DateTime? _ovulationOverride;
  String? _ovulationOverrideSource;

  bool _isLoaded = false;

  // --- GETTERS ---
  AppMode get appMode => _appMode;
  bool get isCOCEnabled => _appMode == AppMode.coc;
  bool get isTTCMode => _appMode == AppMode.ttc;

  bool get hasProlongedBleeding {
    if (_history.isEmpty || isCOCEnabled) return false;
    return (_history.first.periodDuration ?? 0) > 8;
  }

  bool get isCycleLate {
    if (isCOCEnabled) return false;
    return _currentData.phase == CyclePhase.late;
  }

  int get daysLate {
    if (isCOCEnabled) return 0;
    final diff = _currentData.currentDay - _currentData.totalCycleLength;
    return diff > 0 ? diff : 0;
  }

  bool get isAmenorrhea => daysLate >= 60;

  bool get isPeriodEnded => _settingsBox.get('current_period_ended', defaultValue: false);

  CycleProvider(
    this._cycleBox,
    this._settingsBox, [
    this._notificationService,
    this._encryptedBoxOpener,
  ]) {
    _init();
  }

  CycleData get currentData => _currentData;
  List<CycleModel> get history => _cachedHistory ??= List.unmodifiable(_history);
  CycleConfidenceResult? get aiConfidence => _aiConfidence;

  int get cycleLength => _currentData.totalCycleLength > 0
      ? _currentData.totalCycleLength
      : (isCOCEnabled ? 28 : _avgCycleLength);

  int get avgPeriodDuration => _avgPeriodDuration;
  int get periodDuration => _avgPeriodDuration;
  bool get isLoaded => _isLoaded;
  TTCStrategy get ttcStrategy => _ttcStrategy;
  bool get isOvulationConfirmed => _ovulationOverride != null;
  String? get ovulationOverrideSource => _ovulationOverrideSource;

  int get ovulationDay {
    if (isCOCEnabled) return 14;
    if (_currentData.cycleStartDate.year == 1970) return 14;

    if (_ovulationOverride != null) {
      return _ovulationOverride!.difference(_currentData.cycleStartDate).inDays + 1;
    }
    return math.max(1, cycleLength - 14);
  }

  int? get currentDPO {
    if (!isTTCMode || isCOCEnabled) return null;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    if (current > ovDay) return current - ovDay;
    return null;
  }

  FertilityChance get conceptionChance {
    if (!isTTCMode || isCOCEnabled) return FertilityChance.low;

    final current = _currentData.currentDay;
    final ovDay = ovulationDay;

    if (current == ovDay || current == ovDay - 1) return FertilityChance.peak;

    if ((current >= math.max(1, ovDay - 5) && current < ovDay - 1) || current == ovDay + 1) {
      return FertilityChance.high;
    }
    return FertilityChance.low;
  }

  bool get isFertileWindow {
    if (!isTTCMode || isCOCEnabled) return false;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    return current >= math.max(1, ovDay - 5) && current <= (ovDay + 1);
  }

  Future<Box> _reopenEncryptedBox(String name) async {
    if (_encryptedBoxOpener != null) {
      return _encryptedBoxOpener!(name);
    }
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    }
    throw StateError("Encrypted Hive box '$name' is closed and no encrypted opener was provided.");
  }

  Future<void> _ensureBoxOpen() async {
    if (!_settingsBox.isOpen) _settingsBox = await _reopenEncryptedBox(_settingsBox.name);
    if (!_cycleBox.isOpen) _cycleBox = await _reopenEncryptedBox(_cycleBox.name);
  }

  void _loadOverrides() {
    try {
      final ovMs = _settingsBox.get('current_ovulation_override') as int?;
      _ovulationOverride = ovMs != null ? CycleCalculator.normalizeDate(DateTime.fromMillisecondsSinceEpoch(ovMs)) : null;
      _ovulationOverrideSource = _settingsBox.get('current_ovulation_override_source') as String?;

      final rawStrategy = _settingsBox.get('ttc_strategy') as String?;
      _ttcStrategy = rawStrategy == 'maximal' ? TTCStrategy.maximal : TTCStrategy.minimal;
    } catch (e) {
      if (kDebugMode) debugPrint("Error loading overrides: $e");
      _ovulationOverride = null;
      _ovulationOverrideSource = null;
      _ttcStrategy = TTCStrategy.minimal;
    }
  }

  Future<void> _clearOvulationOverride() async {
    _ovulationOverride = null;
    _ovulationOverrideSource = null;
    try {
      await _settingsBox.deleteAll(['current_ovulation_override', 'current_ovulation_override_source']);
    } catch (e) {
      if (kDebugMode) debugPrint("Error clearing ovulation override: $e");
    }
  }

  Future<void> _init() async {
    _isLoaded = false;
    try {
      await _ensureBoxOpen();

      final savedMode = _settingsBox.get('app_mode') as int?;
      if (savedMode != null && savedMode >= 0 && savedMode < AppMode.values.length) {
        _appMode = AppMode.values[savedMode];
      } else {
        final bool oldCOC = _settingsBox.get('coc_enabled', defaultValue: false);
        final bool oldTTC = _settingsBox.get('ttc_mode_enabled', defaultValue: false);
        if (oldCOC) {
          _appMode = AppMode.coc;
        } else if (oldTTC) {
          _appMode = AppMode.ttc;
        } else {
          _appMode = AppMode.standard;
        }
        await _settingsBox.put('app_mode', _appMode.index);
      }

      _avgCycleLength = _settingsBox.get('avg_cycle_len', defaultValue: 28);
      _avgPeriodDuration = _settingsBox.get('avg_period_len', defaultValue: 5);

      _loadOverrides();
      await _recalculateEngine();

      _isLoaded = true;
      notifyListeners();
      await rescheduleNotifications();
    } catch (e) {
      if (kDebugMode) debugPrint("CycleProvider Init Error: $e");
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setAppMode(AppMode newMode, {DateTime? packStartDate}) async {
    await _ensureBoxOpen();

    final bool isSameMode = _appMode == newMode;
    if (isSameMode && packStartDate == null) return;

    _appMode = newMode;
    await _settingsBox.put('app_mode', _appMode.index);

    if (!isSameMode) {
      await _clearOvulationOverride();
      _aiConfidence = null;
    }

    if (newMode == AppMode.coc) {
      DateTime effectiveStart = packStartDate ?? (isSameMode ? _currentData.cycleStartDate : CycleCalculator.normalizeDate(DateTime.now()));
      final active = _settingsBox.get('coc_active_count', defaultValue: 21);
      final brk = _settingsBox.get('coc_break_days', defaultValue: 7);
      await _updateCurrentData(effectiveStart, active + brk, brk);
    } else {
      if (!isSameMode) {
        await _recalculateEngine();
      }
    }

    await rescheduleNotifications();
    notifyListeners();
  }

  Future<void> setCOCMode(bool enabled, {int currentPillNumber = 1, DateTime? packStartDate}) async {
    if (enabled) {
      DateTime effectiveStart = packStartDate ?? CycleCalculator.normalizeDate(DateTime.now()).subtract(Duration(days: currentPillNumber > 1 ? currentPillNumber - 1 : 0));
      await setAppMode(AppMode.coc, packStartDate: effectiveStart);
    } else {
      await setAppMode(AppMode.standard);
    }
  }

  Future<void> setTTCMode(bool enabled) async {
    await setAppMode(enabled ? AppMode.ttc : AppMode.standard);
  }

  Future<void> _recalculateEngine() async {
    if (isCOCEnabled) {
      final activePills = _settingsBox.get('coc_active_count', defaultValue: 21);
      final breakDays = _settingsBox.get('coc_break_days', defaultValue: 7);
      await _updateCurrentData(_currentData.cycleStartDate, activePills + breakDays, breakDays);
      return;
    }

    List<int> timestamps = List<int>.from(_settingsBox.get('bleeding_days') ?? []);
    List<int> manualStarts = List<int>.from(_settingsBox.get('manual_cycle_starts') ?? []);

    if (timestamps.isEmpty) {
      await _cycleBox.clear();
      _history = [];
      _cachedHistory = null;
      DateTime fallbackStart = DateTime.now();
      int? savedFallback = _settingsBox.get('fallback_start_date');
      if (savedFallback != null) {
        fallbackStart = DateTime.fromMillisecondsSinceEpoch(savedFallback);
      } else {
        _settingsBox.put('fallback_start_date', fallbackStart.millisecondsSinceEpoch);
      }
      await _updateCurrentData(fallbackStart, _avgCycleLength, _avgPeriodDuration);
      return;
    } else {
      _settingsBox.delete('fallback_start_date');
    }

    List<DateTime> days = timestamps.map((ts) => DateTime.fromMillisecondsSinceEpoch(ts)).toList();
    days.sort();

    List<CycleModel> newHistory = [];
    DateTime cycleStart = days.first;
    List<DateTime> currentCycleBleedingDays = [days.first];

    for (int i = 1; i < days.length; i++) {
      DateTime currentDay = days[i];
      bool isExplicitNewCycle = manualStarts.contains(currentDay.millisecondsSinceEpoch);
      int daysSinceCycleStart = currentDay.difference(cycleStart).inDays;
      bool gapLargeEnough = currentDay.difference(currentCycleBleedingDays.last).inDays > 2;

      bool isMedicallyPlausibleNewCycle = daysSinceCycleStart >= 21;

      if (isExplicitNewCycle || (gapLargeEnough && isMedicallyPlausibleNewCycle)) {
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
          endDate: currentDay.subtract(const Duration(days: 1)),
          length: daysSinceCycleStart,
          periodDuration: pLen,
        ));

        cycleStart = currentDay;
        currentCycleBleedingDays = [currentDay];
      } else {
        currentCycleBleedingDays.add(currentDay);
      }
    }

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

    final Map<int, CycleModel> updates = {};
    for (int i = 0; i < newHistory.length; i++) {
      updates[i] = newHistory[i];
    }
    await _cycleBox.putAll(updates);

    if (_cycleBox.length > newHistory.length) {
      final keysToDelete = _cycleBox.keys.skip(newHistory.length).toList();
      await _cycleBox.deleteAll(keysToDelete);
    }

    final oldHistory = _history.isNotEmpty ? _history.first : null;

    _history = newHistory.reversed.toList();
    _cachedHistory = null;

    if (oldHistory != null && _history.first.startDate.isAfter(oldHistory.startDate)) {
      await _settingsBox.put('current_period_ended', false);
    }

    _calculateSmartAverages();
    _calculateAIConfidence();

    final latestCycle = _history.first;
    await _updateCurrentData(latestCycle.startDate, _avgCycleLength, _avgPeriodDuration);
  }

  void _calculateSmartAverages() {
    if (_history.isEmpty || isCOCEnabled) return;

    final completedCycles = _history.where((c) => c.length != null).take(8).toList();

    if (completedCycles.length < 3) return;

    double weightedSumCycle = 0;
    double weightTotalCycle = 0;
    double currentWeight = completedCycles.length.toDouble();

    for (var c in completedCycles) {
      if (c.length! >= 20 && c.length! <= 45) {
        weightedSumCycle += c.length! * currentWeight;
        weightTotalCycle += currentWeight;
      }
      currentWeight -= 1.0;
    }

    if (weightTotalCycle > 0) {
      _avgCycleLength = (weightedSumCycle / weightTotalCycle).round().clamp(21, 45);
      _settingsBox.put('avg_cycle_len', _avgCycleLength);
    }

    double weightedSumPeriod = 0;
    double weightTotalPeriod = 0;
    currentWeight = completedCycles.length.toDouble();

    for (var c in completedCycles) {
      if (c.periodDuration != null && c.periodDuration! >= 2 && c.periodDuration! <= 10) {
        weightedSumPeriod += c.periodDuration! * currentWeight;
        weightTotalPeriod += currentWeight;
      }
      currentWeight -= 1.0;
    }

    if (weightTotalPeriod > 0) {
      _avgPeriodDuration = (weightedSumPeriod / weightTotalPeriod).round().clamp(2, 10);
      _settingsBox.put('avg_period_len', _avgPeriodDuration);
    }
  }

  Future<void> _updateCurrentData(DateTime startDate, int avgLen, int periodLen, {bool notify = true}) async {
    final now = DateTime.now();
    final normalizedNow = CycleCalculator.normalizeDate(now);
    final safeStart = CycleCalculator.normalizeDate(startDate);

    final diff = normalizedNow.difference(safeStart).inDays;
    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    if (_ovulationOverride != null && _ovulationOverride!.isBefore(safeStart)) {
      await _clearOvulationOverride();
    }

    int effectiveCycleLen;
    DateTime predictedOvulation;

    if (isCOCEnabled) {
      effectiveCycleLen = _settingsBox.get('coc_active_count', defaultValue: 21) + _settingsBox.get('coc_break_days', defaultValue: 7);
      predictedOvulation = safeStart.add(const Duration(days: 14));
    } else if (_ovulationOverride != null) {
      predictedOvulation = CycleCalculator.normalizeDate(_ovulationOverride!);
      effectiveCycleLen = predictedOvulation.difference(safeStart).inDays + 14;
    } else {
      effectiveCycleLen = avgLen.clamp(12, 180);
      predictedOvulation = safeStart.add(Duration(days: effectiveCycleLen - 14));
    }

    final bleedingDays = List<int>.from(_settingsBox.get('bleeding_days') ?? []);

    final phase = CycleCalculator.calculatePhase(
      day: currentDay,
      length: effectiveCycleLen,
      dateToCheck: normalizedNow,
      isCOC: isCOCEnabled,
      cocActivePills: _settingsBox.get('coc_active_count', defaultValue: 21),
      cocBreakDays: _settingsBox.get('coc_break_days', defaultValue: 7),
      cycleStart: safeStart,
      ovulationDate: predictedOvulation,
      bleedingTimestamps: bleedingDays,
      history: _history,
      avgPeriodDuration: periodLen,
      isPeriodEndedExplicitly: _settingsBox.get('current_period_ended', defaultValue: false),
    );

    final ovDayIndex = predictedOvulation.difference(safeStart).inDays + 1;
    final bool isFertile = !isCOCEnabled && (currentDay >= (ovDayIndex - 5) && currentDay <= ovDayIndex + 1);

    final nextPeriodDate = safeStart.add(Duration(days: effectiveCycleLen));
    int daysUntilNext = nextPeriodDate.difference(normalizedNow).inDays;
    if (phase == CyclePhase.late || daysUntilNext < 0) daysUntilNext = 0;

    int currentExpectedPeriodDuration = periodLen;
    bool isEndedExplicitly = _settingsBox.get('current_period_ended', defaultValue: false);

    if (_history.isNotEmpty && !isEndedExplicitly && !isCOCEnabled) {
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

    PartnerSyncService.syncStateToCloud(
      phase: phase,
      cycleDay: currentDay,
      daysUntilNextPeriod: daysUntilNext,
      isCoc: isCOCEnabled,
      fertilityChance: isTTCMode ? conceptionChance : null,
    );

    if (notify) notifyListeners();
  }

  CycleModel? _getCycleForDate(DateTime date) {
    final normDate = CycleCalculator.normalizeDate(date);
    final normStart = CycleCalculator.normalizeDate(_currentData.cycleStartDate);

    if (!normDate.isBefore(normStart)) return null;

    for (var cycle in _history) {
      final cStart = CycleCalculator.normalizeDate(cycle.startDate);
      final cEnd = cycle.endDate != null ? CycleCalculator.normalizeDate(cycle.endDate!) : normStart.subtract(const Duration(days: 1));

      if (!normDate.isBefore(cStart) && !normDate.isAfter(cEnd)) {
        return cycle;
      }
    }
    return null;
  }

  DayType getDayType(DateTime date) {
    final phase = getPhaseForDate(date);

    if (phase == CyclePhase.menstruation) return DayType.period;
    if (phase == CyclePhase.ovulation) return DayType.ovulation;

    final cycleDay = getCycleDayFromDate(date);

    int ovDay = ovulationDay;
    final histCycle = _getCycleForDate(date);
    if (histCycle != null && !isCOCEnabled) {
      int cLen = histCycle.length ?? _avgCycleLength;
      ovDay = histCycle.ovulationOverrideDate != null
          ? CycleCalculator.normalizeDate(histCycle.ovulationOverrideDate!).difference(CycleCalculator.normalizeDate(histCycle.startDate)).inDays + 1
          : math.max(1, cLen - 14);
    }

    if (cycleDay >= ovDay - 5 && cycleDay < ovDay) {
      return DayType.fertile;
    }

    return DayType.none;
  }

  int getCycleDayFromDate(DateTime date) {
    if (_history.isEmpty) return 1;
    final normDate = CycleCalculator.normalizeDate(date);
    final normStart = CycleCalculator.normalizeDate(_currentData.cycleStartDate);

    if (!normDate.isBefore(normStart)) {
      return normDate.difference(normStart).inDays + 1;
    }

    final histCycle = _getCycleForDate(date);
    if (histCycle != null) {
      return normDate.difference(CycleCalculator.normalizeDate(histCycle.startDate)).inDays + 1;
    }

    return 1;
  }

  CyclePhase? getPhaseForDate(DateTime date) {
    final normDate = CycleCalculator.normalizeDate(date);
    final normStart = CycleCalculator.normalizeDate(_currentData.cycleStartDate);

    final bleedingDays = List<int>.from(_settingsBox.get('bleeding_days') ?? []);

    if (isCOCEnabled) {
      int day = getCycleDayFromDate(date);
      return CycleCalculator.calculatePhase(
        day: day,
        length: _currentData.totalCycleLength,
        dateToCheck: normDate,
        isCOC: true,
        cocActivePills: _settingsBox.get('coc_active_count', defaultValue: 21),
        cocBreakDays: _settingsBox.get('coc_break_days', defaultValue: 7),
        cycleStart: normStart,
        ovulationDate: normDate,
        bleedingTimestamps: bleedingDays,
        history: _history,
        avgPeriodDuration: _avgPeriodDuration,
        isPeriodEndedExplicitly: _settingsBox.get('current_period_ended', defaultValue: false),
      );
    }

    final histCycle = _getCycleForDate(date);

    if (histCycle != null) {
      int day = normDate.difference(CycleCalculator.normalizeDate(histCycle.startDate)).inDays + 1;
      int cLen = histCycle.length ?? _avgCycleLength;

      int hOvDay = histCycle.ovulationOverrideDate != null
          ? CycleCalculator.normalizeDate(histCycle.ovulationOverrideDate!).difference(CycleCalculator.normalizeDate(histCycle.startDate)).inDays + 1
          : math.max(1, cLen - 14);

      return CycleCalculator.calculatePhase(
        day: day,
        length: cLen,
        dateToCheck: normDate,
        isCOC: false,
        cocActivePills: 21,
        cocBreakDays: 7,
        cycleStart: CycleCalculator.normalizeDate(histCycle.startDate),
        ovulationDate: CycleCalculator.normalizeDate(histCycle.startDate).add(Duration(days: hOvDay - 1)),
        bleedingTimestamps: bleedingDays,
        history: _history,
        avgPeriodDuration: _avgPeriodDuration,
        isPeriodEndedExplicitly: _settingsBox.get('current_period_ended', defaultValue: false),
      );
    }

    int day = normDate.difference(normStart).inDays + 1;
    return CycleCalculator.calculatePhase(
        day: day,
        length: _currentData.totalCycleLength,
        dateToCheck: normDate,
        isCOC: false,
        cocActivePills: 21,
        cocBreakDays: 7,
        cycleStart: normStart,
        ovulationDate: normStart.add(Duration(days: ovulationDay - 1)),
        bleedingTimestamps: bleedingDays,
        history: _history,
        avgPeriodDuration: _avgPeriodDuration,
        isPeriodEndedExplicitly: _settingsBox.get('current_period_ended', defaultValue: false)
    );
  }

  Future<void> togglePeriodDay(DateTime date) async {
    await _ensureBoxOpen();

    final normDate = CycleCalculator.normalizeDate(date);
    if (normDate.isAfter(CycleCalculator.normalizeDate(DateTime.now()))) return;

    List<int> timestamps = List<int>.from(_settingsBox.get('bleeding_days') ?? []);
    List<int> manualStarts = List<int>.from(_settingsBox.get('manual_cycle_starts') ?? []);
    final ms = normDate.millisecondsSinceEpoch;

    bool shouldUnsetPeriodEnded = false;

    if (timestamps.contains(ms)) {
      timestamps.remove(ms);
      manualStarts.remove(ms);
    } else {
      timestamps.add(ms);
      // 🔥 ОТКЛЮЧЕНО ДЛЯ ТЕСТОВ
      // HealthIntegrationService.syncPeriodDay(normDate);

      if (!isCOCEnabled && !normDate.isBefore(CycleCalculator.normalizeDate(_currentData.cycleStartDate))) {
        shouldUnsetPeriodEnded = true;
      }
    }

    Map<String, dynamic> updates = {
      'bleeding_days': timestamps,
      'manual_cycle_starts': manualStarts,
    };
    if (shouldUnsetPeriodEnded) updates['current_period_ended'] = false;

    await _settingsBox.putAll(updates);

    if (isCOCEnabled) {
      final active = _settingsBox.get('coc_active_count', defaultValue: 21);
      final brk = _settingsBox.get('coc_break_days', defaultValue: 7);
      await _updateCurrentData(_currentData.cycleStartDate, active + brk, brk);
      return;
    }

    await _recalculateEngine();
    await rescheduleNotifications();
  }

  Future<CycleLogResult> logActionStartPeriod(DateTime date, {bool isConfirmed = false}) async {
    await _ensureBoxOpen();
    if (isCOCEnabled) return CycleLogResult.success;

    final normDate = CycleCalculator.normalizeDate(date);
    if (normDate.isAfter(CycleCalculator.normalizeDate(DateTime.now()))) return CycleLogResult.futureDate;

    if (!isConfirmed) {
      final currentStart = CycleCalculator.normalizeDate(_currentData.cycleStartDate);
      final diffFromCurrent = normDate.difference(currentStart).inDays;

      if (diffFromCurrent > 0 && diffFromCurrent < 21) {
        final ovDay = ovulationDay;
        if (diffFromCurrent >= (ovDay - 2) && diffFromCurrent <= (ovDay + 2)) {
          return CycleLogResult.ovulationBleeding;
        }
        return CycleLogResult.suspiciouslyEarly;
      }

      if (diffFromCurrent < 0) {
        for (var cycle in _history) {
          final histDiff = normDate.difference(CycleCalculator.normalizeDate(cycle.startDate)).inDays.abs();
          if (histDiff > 0 && histDiff < 21) {
            return CycleLogResult.suspiciouslyEarly;
          }
        }
      }
    }

    List<int> timestamps = List<int>.from(_settingsBox.get('bleeding_days') ?? []);
    List<int> manualStarts = List<int>.from(_settingsBox.get('manual_cycle_starts') ?? []);

    timestamps.removeWhere((ts) {
      final tDate = DateTime.fromMillisecondsSinceEpoch(ts);
      return tDate.isAfter(normDate);
    });

    manualStarts.removeWhere((ts) {
      final tDate = DateTime.fromMillisecondsSinceEpoch(ts);
      return tDate.isAfter(normDate);
    });

    final ms = normDate.millisecondsSinceEpoch;

    if (!timestamps.contains(ms)) {
      timestamps.add(ms);
      // 🔥 ОТКЛЮЧЕНО ДЛЯ ТЕСТОВ
      // HealthIntegrationService.syncPeriodDay(normDate);
    }
    if (!manualStarts.contains(ms)) manualStarts.add(ms);

    await _clearOvulationOverride();

    await _settingsBox.putAll({
      'current_period_ended': false,
      'bleeding_days': timestamps,
      'manual_cycle_starts': manualStarts,
    });

    await _recalculateEngine();
    await rescheduleNotifications();

    return CycleLogResult.success;
  }

  Future<CycleLogResult> startNewCycle({bool isConfirmed = false}) async =>
      logActionStartPeriod(DateTime.now(), isConfirmed: isConfirmed);

  Future<void> endCurrentPeriod({DateTime? endDate}) async {
    await _ensureBoxOpen();
    if (isCOCEnabled) return;

    final end = CycleCalculator.normalizeDate(endDate ?? DateTime.now());
    final start = CycleCalculator.normalizeDate(_currentData.cycleStartDate);

    if (end.isBefore(start)) return;

    List<int> timestamps = List<int>.from(_settingsBox.get('bleeding_days') ?? []);

    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final d = start.add(Duration(days: i));
      if (d.isBefore(end)) {
        if (!timestamps.contains(d.millisecondsSinceEpoch)) {
          timestamps.add(d.millisecondsSinceEpoch);
          // 🔥 ОТКЛЮЧЕНО ДЛЯ ТЕСТОВ
          // HealthIntegrationService.syncPeriodDay(d);
        }
      }
    }

    final maxPeriodEnd = start.add(const Duration(days: 15));
    timestamps.removeWhere((ts) {
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      return !d.isBefore(end) && d.isBefore(maxPeriodEnd);
    });

    await _settingsBox.putAll({
      'bleeding_days': timestamps.toSet().toList(),
      'current_period_ended': true,
    });

    await _recalculateEngine();
    await rescheduleNotifications();
  }

  Future<void> setSpecificCycleStartDate(DateTime date) async => logActionStartPeriod(date, isConfirmed: true);
  Future<void> setPeriodDate(DateTime date) async => togglePeriodDay(date);

  Future<void> confirmOvulation(DateTime date, {String source = 'manual'}) async {
    await _ensureBoxOpen();
    final normDate = CycleCalculator.normalizeDate(date);

    if (normDate.isBefore(_currentData.cycleStartDate)) return;

    if (_ovulationOverride != null && _ovulationOverrideSource == 'lh' && source == 'lh') {
      final diff = normDate.difference(_ovulationOverride!).inDays.abs();
      if (diff <= 2) return;
    }

    _ovulationOverride = normDate;
    _ovulationOverrideSource = source;

    await _settingsBox.putAll({
      'current_ovulation_override': _ovulationOverride!.millisecondsSinceEpoch,
      'current_ovulation_override_source': source,
    });

    await _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  Future<void> clearOvulationIfMatchesLHTestDate(DateTime testDate) async {
    await _ensureBoxOpen();
    if (_ovulationOverride == null || _ovulationOverrideSource != 'lh') return;

    final expectedOvulation = CycleCalculator.normalizeDate(testDate.add(const Duration(days: 1)));
    if (CycleCalculator.normalizeDate(_ovulationOverride!) != expectedOvulation) return;

    await _clearOvulationOverride();
    await _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  Future<void> tryAutoConfirmOvulationFromBBT(List<MapEntry<DateTime, double>> tempHistory) async {
    await _ensureBoxOpen();
    if (!isTTCMode || isCOCEnabled || _ovulationOverride != null) return;

    final cycleStart = CycleCalculator.normalizeDate(_currentData.cycleStartDate);
    final temps = tempHistory
        .map((e) => MapEntry(CycleCalculator.normalizeDate(e.key), e.value))
        .where((e) => !e.key.isBefore(cycleStart))
        .toList()..sort((a, b) => a.key.compareTo(b.key));

    final shiftStart = CycleCalculator.detectOvulationShift(temps: temps);

    if (shiftStart != null) {
      final estimatedOvulation = CycleCalculator.normalizeDate(shiftStart.subtract(const Duration(days: 1)));
      final minOvulation = cycleStart.add(Duration(days: _avgPeriodDuration));
      if (!estimatedOvulation.isAfter(minOvulation)) return;

      _ovulationOverride = estimatedOvulation;
      _ovulationOverrideSource = 'bbt';

      await _settingsBox.putAll({
        'current_ovulation_override': estimatedOvulation.millisecondsSinceEpoch,
        'current_ovulation_override_source': 'bbt',
      });

      await _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
      await rescheduleNotifications();
    }
  }

  Future<void> clearOvulationData(DateTime date) async {
    await _ensureBoxOpen();
    if (date.isBefore(_currentData.cycleStartDate)) return;
    await _clearOvulationOverride();
    await _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  Future<void> setAveragePeriodDuration(int days) async {
    await _ensureBoxOpen();
    days = days.clamp(1, 14);
    await _settingsBox.put('avg_period_len', days);
    _avgPeriodDuration = days;
    await _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, days);
    await rescheduleNotifications();
  }

  Future<void> setCycleLength(int length) async {
    await _ensureBoxOpen();
    length = length.clamp(12, 180);
    await _settingsBox.put('avg_cycle_len', length);
    _avgCycleLength = length;
    await _updateCurrentData(_currentData.cycleStartDate, length, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  void _calculateAIConfidence() {
    if (isCOCEnabled) {
      _aiConfidence = null;
      return;
    }
    try {
      _aiConfidence = CycleAIEngine.calculateConfidence(_history);
    } catch (e) {
      if (kDebugMode) debugPrint("AI Engine error: $e");
      _aiConfidence = null;
    }
  }

  Future<void> resumePeriod() async {
    await _ensureBoxOpen();
    if (isCOCEnabled) return;

    await _settingsBox.put('current_period_ended', false);
    await _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  Future<void> undoPeriodStart() async {
    await _ensureBoxOpen();
    if (isCOCEnabled) return;

    final normDate = CycleCalculator.normalizeDate(_currentData.cycleStartDate);
    final ms = normDate.millisecondsSinceEpoch;

    List<int> timestamps = List<int>.from(_settingsBox.get('bleeding_days') ?? []);
    List<int> manualStarts = List<int>.from(_settingsBox.get('manual_cycle_starts') ?? []);

    timestamps.remove(ms);
    manualStarts.remove(ms);

    await _settingsBox.putAll({
      'bleeding_days': timestamps,
      'manual_cycle_starts': manualStarts,
      'current_period_ended': false,
    });

    await _recalculateEngine();
    await rescheduleNotifications();
  }

  Future<void> rescheduleNotifications() async {
    await CycleNotificationManager.rescheduleNotifications(
      notificationService: _notificationService,
      isCOCEnabled: isCOCEnabled,
      cycleStartDate: _currentData.cycleStartDate,
      cycleLength: cycleLength,
      ovulationDay: ovulationDay,
      cocActivePills: _settingsBox.get('coc_active_count', defaultValue: 21),
      savedLanguageCode: _settingsBox.get('language_code'),
    );
  }

  Future<void> reload() async => _init();
}
