import 'package:evimoon/data/logic/cycle_calculator.dart';
import 'package:evimoon/data/models/cycle_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CycleCalculator Tests', () {

    test('normalizeDate correctly removes hours and sets to 12:00 UTC', () {
      final inputDate = DateTime(2026, 10, 5, 23, 45, 10);
      final normalized = CycleCalculator.normalizeDate(inputDate);

      expect(normalized.year, 2026);
      expect(normalized.month, 10);
      expect(normalized.day, 5);
      expect(normalized.hour, 12);
      expect(normalized.isUtc, true);
    });

    test('calculatePhase for COC (Birth Control) works correctly', () {
      final cycleStart = DateTime.utc(2026, 1, 1, 12);

      // День 10: Активная таблетка -> Фолликулярная фаза
      var phase = CycleCalculator.calculatePhase(
        day: 10,
        length: 28,
        dateToCheck: cycleStart.add(const Duration(days: 9)),
        isCOC: true,
        cocActivePills: 21,
        cocBreakDays: 7,
        cycleStart: cycleStart,
        ovulationDate: cycleStart.add(const Duration(days: 14)), // Неважно для КОК
        bleedingTimestamps: [],
        history: [],
        avgPeriodDuration: 5,
        isPeriodEndedExplicitly: false,
      );
      expect(phase, CyclePhase.follicular);

      // День 24: Перерыв (Break) -> Месячные
      phase = CycleCalculator.calculatePhase(
        day: 24,
        length: 28,
        dateToCheck: cycleStart.add(const Duration(days: 23)),
        isCOC: true,
        cocActivePills: 21,
        cocBreakDays: 7,
        cycleStart: cycleStart,
        ovulationDate: cycleStart.add(const Duration(days: 14)),
        bleedingTimestamps: [],
        history: [],
        avgPeriodDuration: 5,
        isPeriodEndedExplicitly: false,
      );
      expect(phase, CyclePhase.menstruation);
    });

    test('detectOvulationShift (FAM Algorithm) finds correct shift', () {
      // Имитируем температуры
      // Первые 6 дней: низкие (в среднем 36.2)
      // День 7, 8, 9: скачок (должны быть >= 36.4)
      final temps = [
        MapEntry(DateTime(2026, 1, 1), 36.2), // i=0
        MapEntry(DateTime(2026, 1, 2), 36.1), // i=1
        MapEntry(DateTime(2026, 1, 3), 36.2), // i=2
        MapEntry(DateTime(2026, 1, 4), 36.3), // i=3
        MapEntry(DateTime(2026, 1, 5), 36.1), // i=4
        MapEntry(DateTime(2026, 1, 6), 36.2), // i=5
        // Baseline = ~36.18, Threshold = ~36.38
        MapEntry(DateTime(2026, 1, 7), 36.5), // i=6 (Скачок!)
        MapEntry(DateTime(2026, 1, 8), 36.6), // i=7
        MapEntry(DateTime(2026, 1, 9), 36.5), // i=8
      ];

      final shiftDate = CycleCalculator.detectOvulationShift(temps: temps);

      expect(shiftDate, isNotNull);
      expect(shiftDate?.day, 7); // Скачок зафиксирован 7 января
    });

    test('detectOvulationShift ignores invalid shifts (less than 3 days high)', () {
      final temps = [
        MapEntry(DateTime(2026, 1, 1), 36.2),
        MapEntry(DateTime(2026, 1, 2), 36.1),
        MapEntry(DateTime(2026, 1, 3), 36.2),
        MapEntry(DateTime(2026, 1, 4), 36.3),
        MapEntry(DateTime(2026, 1, 5), 36.1),
        MapEntry(DateTime(2026, 1, 6), 36.2),
        MapEntry(DateTime(2026, 1, 7), 36.5), // Скачок
        MapEntry(DateTime(2026, 1, 8), 36.6), // Скачок
        MapEntry(DateTime(2026, 1, 9), 36.2), // ОШИБКА: Температура упала, это не овуляция
      ];

      final shiftDate = CycleCalculator.detectOvulationShift(temps: temps);

      expect(shiftDate, isNull);
    });

  });
}