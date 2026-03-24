import 'package:flutter/foundation.dart';
import '../models/cycle_model.dart';
import '../providers/wellness_provider.dart';

enum HealthFlagType {
  pcos, endometriosis, lutealDefect, menorrhagia, polymenorrhea, pmdd, amenorrhea
}

class HealthFlag {
  final HealthFlagType type;
  final String title;
  final String description;
  final String recommendation;

  HealthFlag({required this.type, required this.title, required this.description, required this.recommendation});
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
  final List<String> moodSymptoms;
  final List<String> painSymptoms;
  final int flowIndex;

  _PureLog(this.date, this.mood, this.moodSymptoms, this.painSymptoms, this.flowIndex);
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
      l.date, l.mood, List<String>.from(l.moodSymptoms), List<String>.from(l.painSymptoms), l.flow.index,
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
        type: HealthFlagType.amenorrhea, title: "Prolonged Cycle Delay",
        description: "Your current cycle has lasted over 90 days.",
        recommendation: "This is known as secondary amenorrhea. If pregnancy is ruled out, it can be caused by stress, weight changes, or hormonal imbalances. Please consult a doctor.",
      ));
    }

    if (completedCycles.length < 3) return detectedFlags;

    if (_detectPCOS(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.pcos, title: "Irregular Cycle Pattern",
        description: "Your cycles vary significantly in length or are consistently longer than 35 days.",
        recommendation: "This pattern is sometimes associated with PCOS or thyroid issues. Consider sharing this data with your gynecologist.",
      ));
    }

    if (_detectEndo(allLogs, now)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.endometriosis, title: "High Pain Profile",
        description: "You frequently log severe pelvic pain combined with heavy flow.",
        recommendation: "Severe period pain that disrupts your life is not normal. This pattern can sometimes indicate endometriosis or fibroids. A doctor can help you manage this.",
      ));
    }

    if (_detectLutealDefect(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.lutealDefect, title: "Short Luteal Phase",
        description: "The time between your ovulation and your next period is consistently short (< 10 days).",
        recommendation: "A short luteal phase is often linked to low progesterone, which can make it harder to conceive. Useful to mention if you are planning a pregnancy.",
      ));
    }

    if (_detectMenorrhagia(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.menorrhagia, title: "Prolonged Bleeding",
        description: "Your periods consistently last 8 days or longer.",
        recommendation: "Prolonged bleeding (menorrhagia) can lead to iron deficiency and fatigue. It's highly recommended to check your iron levels.",
      ));
    }

    if (_detectPolymenorrhea(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.polymenorrhea, title: "Unusually Short Cycles",
        description: "Your cycles are consistently shorter than 21 days.",
        recommendation: "Frequent periods can cause anemia and indicate an ovulation issue. Worth discussing with a healthcare provider.",
      ));
    }

    if (_detectPMDD(completedCycles, allLogs)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.pmdd, title: "Severe Mood Drops (Luteal)",
        description: "You consistently log very low mood, anxiety, or depression in the week before your period.",
        recommendation: "This cyclic emotional drop may be PMDD (Premenstrual Dysphoric Disorder). You don't have to suffer through this alone—treatments are available.",
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
      if (log.painSymptoms.contains('cramps') || log.painSymptoms.contains('pelvic_pain')) severePainDays++;
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
          if (log.mood <= 2 || log.moodSymptoms.contains('depression') || log.moodSymptoms.contains('anxiety')) {
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