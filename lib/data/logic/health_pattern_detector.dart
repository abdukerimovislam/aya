import 'package:flutter/foundation.dart';
import '../models/cycle_model.dart';
import '../providers/wellness_provider.dart';

enum HealthFlagType {
  pcos,
  endometriosis,
  lutealDefect,
  menorrhagia,
  polymenorrhea,
  pmdd,
  amenorrhea
}

class HealthFlag {
  final HealthFlagType type;
  final String title;
  final String description;
  final String recommendation;

  HealthFlag({
    required this.type,
    required this.title,
    required this.description,
    required this.recommendation
  });
}

class HealthPatternDetector {
  /// Главный метод анализа. Возвращает список найденных "красных флагов".
  static List<HealthFlag> analyzePatterns(List<CycleModel> cycles, WellnessProvider wellness, {bool isCocEnabled = false}) {
    List<HealthFlag> detectedFlags = [];

    // Если включены гормональные контрацептивы, естественные паттерны смазаны.
    // Большинство проверок не имеют смысла, так как цикл искусственный.
    if (isCocEnabled) return detectedFlags;

    final completedCycles = cycles.where((c) => c.length != null).toList();

    // Проверка на Аменорею (задержка > 90 дней в текущем незавершенном цикле)
    if (_detectAmenorrhea(cycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.amenorrhea,
        title: "Prolonged Cycle Delay",
        description: "Your current cycle has lasted over 90 days.",
        recommendation: "This is known as secondary amenorrhea. If pregnancy is ruled out, it can be caused by stress, weight changes, or hormonal imbalances. Please consult a doctor.",
      ));
    }

    // Для остальных паттернов нам нужно хотя бы 3 завершенных цикла
    if (completedCycles.length < 3) return detectedFlags;

    // 1. СПКЯ (PCOS)
    if (_detectPCOS(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.pcos,
        title: "Irregular Cycle Pattern",
        description: "Your cycles vary significantly in length or are consistently longer than 35 days.",
        recommendation: "This pattern is sometimes associated with PCOS or thyroid issues. Consider sharing this data with your gynecologist.",
      ));
    }

    // 2. Эндометриоз / Сильная дисменорея
    if (_detectEndo(wellness)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.endometriosis,
        title: "High Pain Profile",
        description: "You frequently log severe pelvic pain combined with heavy flow.",
        recommendation: "Severe period pain that disrupts your life is not normal. This pattern can sometimes indicate endometriosis or fibroids. A doctor can help you manage this.",
      ));
    }

    // 3. Дефект лютеиновой фазы
    if (_detectLutealDefect(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.lutealDefect,
        title: "Short Luteal Phase",
        description: "The time between your ovulation and your next period is consistently short (< 10 days).",
        recommendation: "A short luteal phase is often linked to low progesterone, which can make it harder to conceive. Useful to mention if you are planning a pregnancy.",
      ));
    }

    // 4. Меноррагия (Затяжные кровотечения)
    if (_detectMenorrhagia(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.menorrhagia,
        title: "Prolonged Bleeding",
        description: "Your periods consistently last 8 days or longer.",
        recommendation: "Prolonged bleeding (menorrhagia) can lead to iron deficiency and fatigue. It's highly recommended to check your iron levels.",
      ));
    }

    // 5. Полименорея (Слишком короткие циклы)
    if (_detectPolymenorrhea(completedCycles)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.polymenorrhea,
        title: "Unusually Short Cycles",
        description: "Your cycles are consistently shorter than 21 days.",
        recommendation: "Frequent periods can cause anemia and indicate an ovulation issue. Worth discussing with a healthcare provider.",
      ));
    }

    // 6. ПМДД (Тяжелый ПМС)
    if (_detectPMDD(completedCycles, wellness)) {
      detectedFlags.add(HealthFlag(
        type: HealthFlagType.pmdd,
        title: "Severe Mood Drops (Luteal)",
        description: "You consistently log very low mood, anxiety, or depression in the week before your period.",
        recommendation: "This cyclic emotional drop may be PMDD (Premenstrual Dysphoric Disorder). You don't have to suffer through this alone—treatments are available.",
      ));
    }

    return detectedFlags;
  }

  // --- ЛОГИКА ДЕТЕКТИРОВАНИЯ ---

  static bool _detectPCOS(List<CycleModel> completedCycles) {
    int longCycles = 0;
    int highVarianceCount = 0;

    for (int i = 0; i < completedCycles.length; i++) {
      if (completedCycles[i].length! > 35) longCycles++;

      if (i > 0) {
        int diff = (completedCycles[i].length! - completedCycles[i-1].length!).abs();
        if (diff > 8) highVarianceCount++;
      }
    }
    return (longCycles >= 2) || (highVarianceCount >= 2);
  }

  static bool _detectEndo(WellnessProvider wellness) {
    final recentLogs = wellness.allLogs.where((log) =>
    DateTime.now().difference(log.date).inDays <= 90
    ).toList();

    int severePainDays = 0;
    int heavyFlowDays = 0;

    for (var log in recentLogs) {
      if (log.painSymptoms.contains('cramps') || log.painSymptoms.contains('pelvic_pain')) {
        severePainDays++;
      }
      if (log.flow.index >= 3) { // 3 = heavy, 4 = extremely_heavy
        heavyFlowDays++;
      }
    }
    return severePainDays >= 6 && heavyFlowDays >= 3;
  }

  static bool _detectLutealDefect(List<CycleModel> completedCycles) {
    int shortLutealCount = 0;
    for (var cycle in completedCycles) {
      if (cycle.ovulationOverrideDate != null && cycle.endDate != null) {
        int lutealLength = cycle.endDate!.difference(cycle.ovulationOverrideDate!).inDays;
        if (lutealLength < 10 && lutealLength > 0) {
          shortLutealCount++;
        }
      }
    }
    return shortLutealCount >= 2;
  }

  static bool _detectMenorrhagia(List<CycleModel> completedCycles) {
    int prolongedPeriods = 0;
    for (var cycle in completedCycles) {
      if (cycle.periodDuration != null && cycle.periodDuration! >= 8) {
        prolongedPeriods++;
      }
    }
    return prolongedPeriods >= 2;
  }

  static bool _detectPolymenorrhea(List<CycleModel> completedCycles) {
    int shortCycles = 0;
    for (var cycle in completedCycles) {
      if (cycle.length! < 21) shortCycles++;
    }
    // Если 2 из 3 последних циклов были короче 21 дня
    return shortCycles >= 2;
  }

  static bool _detectAmenorrhea(List<CycleModel> cycles) {
    if (cycles.isEmpty) return false;
    final currentCycle = cycles.first; // Самый свежий (текущий) цикл
    if (currentCycle.endDate == null) {
      int currentLength = DateTime.now().difference(currentCycle.startDate).inDays;
      if (currentLength > 90) return true;
    }
    return false;
  }

  static bool _detectPMDD(List<CycleModel> completedCycles, WellnessProvider wellness) {
    int cyclesWithLutealCrash = 0;

    for (var cycle in completedCycles) {
      if (cycle.endDate == null) continue;

      // Смотрим окно за 7 дней до конца цикла
      final lutealStart = cycle.endDate!.subtract(const Duration(days: 7));
      final lutealEnd = cycle.endDate!;

      bool hasSevereMoodDrop = false;

      for (int i = 0; i <= 7; i++) {
        final date = lutealStart.add(Duration(days: i));
        try {
          if (wellness.hasLogForDate(date)) {
            final log = wellness.getLogForDate(date);
            // Если юзер отметил настроение как очень плохое (1-2 из 5)
            // ИЛИ добавил теги 'depression', 'anxiety', 'severe_mood_swings'
            if (log.mood <= 2 ||
                log.moodSymptoms.contains('depression') ||
                log.moodSymptoms.contains('anxiety')) {
              hasSevereMoodDrop = true;
              break;
            }
          }
        } catch (_) {}
      }

      if (hasSevereMoodDrop) cyclesWithLutealCrash++;
    }

    // Если в 2 из 3 последних циклов было жесткое падение настроения перед М
    return cyclesWithLutealCrash >= 2;
  }
}