import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/cycle_model.dart';
import 'cycle_provider.dart';

class WellnessProvider extends ChangeNotifier {
  final Box _logsBox;
  final Map<String, SymptomLog> _logsCache = {};

  WellnessProvider(this._logsBox) {
    _init();
  }

  void _init() {
    try {
      if (!_logsBox.isOpen) return;

      for (var key in _logsBox.keys) {
        final log = _logsBox.get(key);
        if (log is SymptomLog) {
          _logsCache[_dateKey(log.date)] = log;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing WellnessProvider: $e");
    }
  }

  void reload() {
    notifyListeners();
  }

  // --- CRUD METHODS ---

  bool hasLogForDate(DateTime date) {
    return _logsCache.containsKey(_dateKey(date));
  }

  SymptomLog getLogForDate(DateTime date) {
    if (hasLogForDate(date)) {
      return _logsCache[_dateKey(date)]!;
    }
    return SymptomLog(
      date: date,
      flow: FlowIntensity.none,
      mood: 3,
      energy: 3,
      sleep: 3,
      skin: 3,
      libido: 3,
      painSymptoms: [],
      moodSymptoms: [],
      symptoms: [],
      ovulationTest: OvulationTestResult.none,
    );
  }

  List<SymptomLog> get allLogs => _logsCache.values.toList();

  List<SymptomLog> getLogHistory() {
    return _logsCache.values.toList();
  }

  Future<void> saveLog(SymptomLog log) async {
    final key = _dateKey(log.date);

    if (log.isEmpty) {
      await _logsBox.delete(key);
      _logsCache.remove(key);
    } else {
      await _logsBox.put(key, log);
      _logsCache[key] = log;
    }
    notifyListeners();
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // --- CHART METHODS ---

  List<MapEntry<DateTime, double>> getTemperatureHistory() {
    final entries = _logsCache.values
        .where((log) {
      if (log.temperature == null) return false;
      final t = log.temperature!;
      // 🔥 ИСПРАВЛЕНИЕ: Пропускаем и Цельсий (35-42), и Фаренгейт (95-108)
      final isCelsius = t > 35.0 && t < 42.0;
      final isFahrenheit = t > 95.0 && t < 108.0;
      return isCelsius || isFahrenheit;
    })
        .map((log) => MapEntry(log.date, log.temperature!))
        .toList();

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  List<MapEntry<DateTime, double>> getWeightHistory() {
    final entries = _logsCache.values
        .where((log) => log.weight != null && log.weight! > 30)
        .map((log) => MapEntry(log.date, log.weight!))
        .toList();

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Map<String, List<double>> calculateRadarData(CycleProvider cycle) {
    if (_logsCache.isEmpty) {
      return {
        'follicular': [3.0, 3.0, 3.0, 3.0, 3.0],
        'luteal': [3.0, 3.0, 3.0, 3.0, 3.0],
      };
    }

    final allLogs = _logsCache.values.toList();
    List<SymptomLog> follLogs = [];
    List<SymptomLog> lutLogs = [];

    for (var log in allLogs) {
      final phase = cycle.getPhaseForDate(log.date);
      if (phase == CyclePhase.follicular || phase == CyclePhase.ovulation) {
        follLogs.add(log);
      }
      // 🔥 ИСПРАВЛЕНИЕ: Добавили фазу Late (задержка), чтобы логи не пропадали
      else if (phase == CyclePhase.luteal || phase == CyclePhase.menstruation || phase == CyclePhase.late) {
        lutLogs.add(log);
      }
    }

    double getAvg(List<SymptomLog> logs, int Function(SymptomLog) selector) {
      if (logs.isEmpty) return 3.0;
      final validLogs = logs.where((l) => selector(l) > 0).toList();
      if (validLogs.isEmpty) return 3.0;
      final sum = validLogs.fold(0, (prev, e) => prev + selector(e));
      return sum / validLogs.length;
    }

    return {
      'follicular': [
        getAvg(follLogs, (l) => l.mood),
        getAvg(follLogs, (l) => l.energy),
        getAvg(follLogs, (l) => l.sleep),
        getAvg(follLogs, (l) => l.libido),
        getAvg(follLogs, (l) => l.skin),
      ],
      'luteal': [
        getAvg(lutLogs, (l) => l.mood),
        getAvg(lutLogs, (l) => l.energy),
        getAvg(lutLogs, (l) => l.sleep),
        getAvg(lutLogs, (l) => l.libido),
        getAvg(lutLogs, (l) => l.skin),
      ],
    };
  }

  List<double> calculateWaveData() {
    if (_logsCache.isEmpty) return List.filled(30, 3.0);

    List<double> moodValues = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      if (hasLogForDate(date)) {
        double val = getLogForDate(date).mood.toDouble();
        if (val == 0) val = 3.0;
        moodValues.add(val);
      } else {
        moodValues.add(moodValues.isNotEmpty ? moodValues.last : 3.0);
      }
    }
    return moodValues;
  }

  // --- 🧠 SMART ANALYTICS ---

  List<String> getTopSymptomsForPhase(CyclePhase targetPhase, CycleProvider cycle) {
    final Map<String, int> counts = {};

    for (var log in _logsCache.values) {
      if (DateTime.now().difference(log.date).inDays > 90) continue;

      if (cycle.getPhaseForDate(log.date) == targetPhase) {
        for (var s in log.painSymptoms) counts[s] = (counts[s] ?? 0) + 1;
        for (var s in log.symptoms) counts[s] = (counts[s] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return [];

    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return sortedKeys.take(3).toList();
  }

  List<Map<String, dynamic>> analyzeCorrelations() {
    final List<Map<String, dynamic>> insights = [];
    final logs = _logsCache.values.toList();

    if (logs.length < 5) return [];

    final Set<String> allFactors = {};
    for (var log in logs) allFactors.addAll(log.symptoms);

    for (var factor in allFactors) {
      int factorCount = 0;
      Map<String, int> painCounts = {};

      for (var log in logs) {
        if (log.symptoms.contains(factor)) {
          factorCount++;

          final Set<String> incidentPains = {};
          incidentPains.addAll(log.painSymptoms);

          final nextDay = DateTime(log.date.year, log.date.month, log.date.day + 1);
          if (hasLogForDate(nextDay)) {
            incidentPains.addAll(getLogForDate(nextDay).painSymptoms);
          }

          for (var pain in incidentPains) {
            painCounts[pain] = (painCounts[pain] ?? 0) + 1;
          }
        }
      }

      if (factorCount >= 3) {
        painCounts.forEach((pain, count) {
          double probability = count / factorCount;
          if (probability >= 0.6) {
            insights.add({
              'factor': factor,
              'symptom': pain,
              'probability': (probability * 100).toInt(),
              'count': factorCount
            });
          }
        });
      }
    }

    insights.sort((a, b) => b['probability'].compareTo(a['probability']));
    return insights;
  }

  List<double?> getLast14DaysTemps() {
    final List<double?> temps = [];
    final now = DateTime.now();
    for (int i = 13; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final log = getLogForDate(date);
      temps.add(log.temperature);
    }
    return temps;
  }

  List<Map<String, dynamic>> analyzeFertilityPatterns() {
    List<Map<String, dynamic>> patterns = [];
    final logs = _logsCache.values.toList();

    int positiveTests = 0;
    int highLibidoWithTest = 0;
    int painWithTest = 0;

    for (var log in logs) {
      bool isPositiveTest = log.ovulationTest == OvulationTestResult.positive ||
          log.ovulationTest == OvulationTestResult.peak;

      if (isPositiveTest) {
        positiveTests++;
        if (log.libido >= 4) highLibidoWithTest++;
        if (log.painSymptoms.isNotEmpty) painWithTest++;
      }
    }

    if (positiveTests > 0) {
      if (highLibidoWithTest > 0) patterns.add({'type': 'libido', 'count': highLibidoWithTest});
      if (painWithTest > 0) patterns.add({'type': 'pain', 'count': painWithTest});
    }

    return patterns;
  }
}