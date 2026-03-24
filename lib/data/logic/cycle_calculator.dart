import '../models/cycle_model.dart';
import 'dart:math' as math;

class CycleCalculator {
  /// Безопасная нормализация даты (защита от багов с DST)
  static DateTime normalizeDate(DateTime d) {
    return DateTime.utc(d.year, d.month, d.day, 12, 0, 0);
  }

  /// Рассчитывает фазу цикла на конкретный день
  static CyclePhase calculatePhase({
    required int day,
    required int length,
    required DateTime dateToCheck,
    required bool isCOC,
    required int cocActivePills,
    required int cocBreakDays,
    required DateTime cycleStart,
    required DateTime ovulationDate,
    required List<int> bleedingTimestamps,
    required List<CycleModel> history,
    required int avgPeriodDuration,
    required bool isPeriodEndedExplicitly,
  }) {
    if (isCOC) {
      final totalPills = cocActivePills + cocBreakDays;
      if (day <= cocActivePills) return CyclePhase.follicular;
      if (day <= totalPills) return CyclePhase.menstruation;
      return CyclePhase.late;
    }

    if (bleedingTimestamps.contains(dateToCheck.millisecondsSinceEpoch)) {
      return CyclePhase.menstruation;
    }

    if (history.isNotEmpty) {
      final latestCycle = history.first;
      final cycleEnd = latestCycle.startDate.add(
        Duration(days: (latestCycle.periodDuration ?? 1) - 1),
      );

      if (!dateToCheck.isBefore(latestCycle.startDate) && !dateToCheck.isAfter(cycleEnd)) {
        return CyclePhase.menstruation;
      }

      if (!isPeriodEndedExplicitly && dateToCheck.isAfter(cycleEnd) && dateToCheck.difference(cycleEnd).inDays <= 1) {
        if (dateToCheck.difference(latestCycle.startDate).inDays < 14) {
          return CyclePhase.menstruation;
        }
      }
    }

    if (!isPeriodEndedExplicitly && day <= avgPeriodDuration && day > 0) {
      return CyclePhase.menstruation;
    }

    final ovDayIndex = ovulationDate.difference(cycleStart).inDays + 1;
    if (day >= ovDayIndex - 2 && day <= ovDayIndex + 1) return CyclePhase.ovulation;
    if (day < ovDayIndex - 2) return CyclePhase.follicular;
    if (day > length) return CyclePhase.late;

    return CyclePhase.luteal;
  }

  /// Алгоритм FAM: поиск температурного скачка для подтверждения овуляции
  static DateTime? detectOvulationShift({
    required List<MapEntry<DateTime, double>> temps,
  }) {
    if (temps.length < 9) return null;

    for (int i = 6; i < temps.length - 2; i++) {
      final currentTemp = temps[i];
      final prevTemps = temps.sublist(i - 6, i);

      final baseline = prevTemps.map((e) => e.value).reduce((a, b) => a + b) / 6;
      final threshold = baseline + 0.20;

      final temp1 = temps[i + 1].value;
      final temp2 = temps[i + 2].value;

      if (currentTemp.value >= threshold && temp1 >= threshold && temp2 >= threshold) {
        return currentTemp.key;
      }
    }
    return null;
  }
}