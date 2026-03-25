import 'package:flutter/foundation.dart';
import '../../l10n/app_localizations.dart';
import '../models/cycle_model.dart';
import '../providers/wellness_provider.dart';

enum HealthFlagType {
  pcos, endometriosis, lutealDefect, menorrhagia, polymenorrhea, pmdd, amenorrhea
}

class HealthFlag {
  final HealthFlagType type;

  const HealthFlag({required this.type});

  String title(AppLocalizations l10n) {
    switch (type) {
      case HealthFlagType.pcos:
        return l10n.healthFlagPcosTitle;
      case HealthFlagType.endometriosis:
        return l10n.healthFlagEndometriosisTitle;
      case HealthFlagType.lutealDefect:
        return l10n.healthFlagLutealDefectTitle;
      case HealthFlagType.menorrhagia:
        return l10n.healthFlagMenorrhagiaTitle;
      case HealthFlagType.polymenorrhea:
        return l10n.healthFlagPolymenorrheaTitle;
      case HealthFlagType.pmdd:
        return l10n.healthFlagPmddTitle;
      case HealthFlagType.amenorrhea:
        return l10n.healthFlagAmenorrheaTitle;
    }
  }

  String description(AppLocalizations l10n) {
    switch (type) {
      case HealthFlagType.pcos:
        return l10n.healthFlagPcosBody;
      case HealthFlagType.endometriosis:
        return l10n.healthFlagEndometriosisBody;
      case HealthFlagType.lutealDefect:
        return l10n.healthFlagLutealDefectBody;
      case HealthFlagType.menorrhagia:
        return l10n.healthFlagMenorrhagiaBody;
      case HealthFlagType.polymenorrhea:
        return l10n.healthFlagPolymenorrheaBody;
      case HealthFlagType.pmdd:
        return l10n.healthFlagPmddBody;
      case HealthFlagType.amenorrhea:
        return l10n.healthFlagAmenorrheaBody;
    }
  }

  String recommendation(AppLocalizations l10n) {
    switch (type) {
      case HealthFlagType.pcos:
        return l10n.healthFlagPcosRecommendation;
      case HealthFlagType.endometriosis:
        return l10n.healthFlagEndometriosisRecommendation;
      case HealthFlagType.lutealDefect:
        return l10n.healthFlagLutealDefectRecommendation;
      case HealthFlagType.menorrhagia:
        return l10n.healthFlagMenorrhagiaRecommendation;
      case HealthFlagType.polymenorrhea:
        return l10n.healthFlagPolymenorrheaRecommendation;
      case HealthFlagType.pmdd:
        return l10n.healthFlagPmddRecommendation;
      case HealthFlagType.amenorrhea:
        return l10n.healthFlagAmenorrheaRecommendation;
    }
  }
}

// 🔥 ЧИСТЫЕ КЛАССЫ БЕЗ HIVE ДЛЯ ПЕРЕДАЧИ В ИЗОЛЯТ
class _PureCycle {
  final DateTime startDate;
  final DateTime? endDate;
  final int? length;
  final int? periodDuration;
  final DateTime? ovulationOverrideDate;

  _PureCycle(this.startDate, this.endDate, this.length, this.periodDuration, this.ovulationOverrideDate);
}

class _PureLog {
  final DateTime date;
  final int mood;
  final List<String> symptoms; // 🔥 ИСПРАВЛЕНИЕ: Теперь принимаем реальные симптомы из UI
  final List<String> painSymptoms;
  final int flowIndex;

  _PureLog(this.date, this.mood, this.symptoms, this.painSymptoms, this.flowIndex);
}

class HealthPatternDetector {
  static Future<List<HealthFlag>> analyzePatterns(
      List<CycleModel> cycles,
      WellnessProvider wellness, {
        bool isCocEnabled = false,
      }) async {
    if (isCocEnabled) return [];

    // 🔥 ОЧИЩАЕМ ДАННЫЕ ОТ СВЯЗЕЙ С БАЗОЙ HIVE (MAP TO PURE DART OBJECTS)
    final pureCycles = cycles.map((c) => _PureCycle(
      c.startDate, c.endDate, c.length, c.periodDuration, c.ovulationOverrideDate,
    )).toList();

    final pureLogs = wellness.getLogHistory().map((l) => _PureLog(
      l.date, l.mood, List<String>.from(l.symptoms), List<String>.from(l.painSymptoms), l.flow.index,
    )).toList();

    final payload = {
      'cycles': pureCycles,
      'logs': pureLogs,
      'now': DateTime.now(),
    };

    // Теперь Isolate не упадет, так как получает чистые данные
    return await compute(_analyzeIsolate, payload);
  }

  static List<HealthFlag> _analyzeIsolate(Map<String, dynamic> payload) {
    final List<_PureCycle> cycles = payload['cycles'] as List<_PureCycle>;
    final List<_PureLog> allLogs = payload['logs'] as List<_PureLog>;
    final DateTime now = payload['now'] as DateTime;

    List<HealthFlag> detectedFlags = [];
    final completedCycles = cycles.where((c) => c.length != null).toList();

    if (_detectAmenorrhea(cycles, now)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.amenorrhea,
      ));
    }

    if (completedCycles.length < 3) return detectedFlags;

    if (_detectPCOS(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.pcos,
      ));
    }

    if (_detectEndo(allLogs, now)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.endometriosis,
      ));
    }

    if (_detectLutealDefect(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.lutealDefect,
      ));
    }

    if (_detectMenorrhagia(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.menorrhagia,
      ));
    }

    if (_detectPolymenorrhea(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.polymenorrhea,
      ));
    }

    if (_detectPMDD(completedCycles, allLogs)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.pmdd,
      ));
    }

    return detectedFlags;
  }

  static bool _detectPCOS(List<_PureCycle> completedCycles) {
    int longCycles = 0;
    int highVarianceCount = 0;
    for (int i = 0; i < completedCycles.length; i++) {
      if (completedCycles[i].length! > 35) longCycles++;
      if (i > 0) {
        if ((completedCycles[i].length! - completedCycles[i - 1].length!).abs() > 8) highVarianceCount++;
      }
    }
    return (longCycles >= 2) || (highVarianceCount >= 2);
  }

  static bool _detectEndo(List<_PureLog> allLogs, DateTime now) {
    final recentLogs = allLogs.where((log) => now.difference(log.date).inDays <= 90).toList();
    int severePainDays = 0, heavyFlowDays = 0;
    for (var log in recentLogs) {
      // 🔥 ИСПРАВЛЕНИЕ: Ищем по реальным тегам UI из массива painSymptoms
      if (log.painSymptoms.contains('Cramps') || log.painSymptoms.contains('Backache')) severePainDays++;
      if (log.flowIndex >= 3) heavyFlowDays++;
    }
    return severePainDays >= 6 && heavyFlowDays >= 3;
  }

  static bool _detectLutealDefect(List<_PureCycle> completedCycles) {
    int count = 0;
    for (var cycle in completedCycles) {
      if (cycle.ovulationOverrideDate != null && cycle.endDate != null) {
        int len = cycle.endDate!.difference(cycle.ovulationOverrideDate!).inDays;
        if (len < 10 && len > 0) count++;
      }
    }
    return count >= 2;
  }

  static bool _detectMenorrhagia(List<_PureCycle> completedCycles) {
    int count = 0;
    for (var cycle in completedCycles) {
      if (cycle.periodDuration != null && cycle.periodDuration! >= 8) count++;
    }
    return count >= 2;
  }

  static bool _detectPolymenorrhea(List<_PureCycle> completedCycles) {
    int count = 0;
    for (var cycle in completedCycles) {
      if (cycle.length! < 21) count++;
    }
    return count >= 2;
  }

  static bool _detectAmenorrhea(List<_PureCycle> cycles, DateTime now) {
    if (cycles.isEmpty) return false;
    final c = cycles.first;
    if (c.endDate == null && now.difference(c.startDate).inDays > 90) return true;
    return false;
  }

  static bool _detectPMDD(List<_PureCycle> completedCycles, List<_PureLog> allLogs) {
    int count = 0;
    final Map<String, _PureLog> logsMap = {
      for (var log in allLogs) "${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}": log
    };
    for (var cycle in completedCycles) {
      if (cycle.endDate == null) continue;
      final lutealStart = cycle.endDate!.subtract(const Duration(days: 7));
      bool hasDrop = false;
      for (int i = 0; i <= 7; i++) {
        final date = lutealStart.add(Duration(days: i));
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        if (logsMap.containsKey(key)) {
          final log = logsMap[key]!;
          // 🔥 ИСПРАВЛЕНИЕ: Ищем по реальным тегам UI из массива symptoms
          if (log.mood <= 2 || log.symptoms.contains('Anxious') || log.symptoms.contains('Crying Spells') || log.symptoms.contains('Irritable')) {
            hasDrop = true;
            break;
          }
        }
      }
      if (hasDrop) count++;
    }
    return count >= 2;
  }
}
