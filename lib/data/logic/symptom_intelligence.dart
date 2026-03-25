import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../models/cycle_model.dart';

class SymptomInsight {
  final String title;
  final String description;
  final bool isWarning;
  final int priority;

  SymptomInsight({
    required this.title,
    required this.description,
    this.isWarning = false,
    this.priority = 10,
  });
}

class SymptomIntelligence {

  /// 🔥 ГЛАВНЫЙ МЕТОД АНАЛИЗА
  static SymptomInsight? getInsight(
      BuildContext context,
      List<String> selectedSymptoms,
      CyclePhase phase,
      {bool isTTCMode = false}
      ) {
    if (selectedSymptoms.isEmpty) return null;

    final l10n = AppLocalizations.of(context)!;
    final symptoms = selectedSymptoms.map((e) => e.toLowerCase()).toList();

    List<SymptomInsight> possibleInsights = [];

    // =========================================================================
    // 👶 ВЕТКА TTC (ПЛАНИРОВАНИЕ БЕРЕМЕННОСТИ) - ПРЕМИУМ
    // =========================================================================
    if (isTTCMode) {

      // 1. ПИК ОВУЛЯЦИИ (ЛГ-тест)
      if (_has(symptoms, ['lh: peak'])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightPeakFertilityDetectedTitle,
          description: l10n.symptomInsightPeakFertilityDetectedBody,
          priority: 95, // 🔥 Снижен со 100 до 95, чтобы уступить место критическим мед. флагам
        ));
      } else if (_has(symptoms, ['lh: high'])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightFertileWindowOpeningTitle,
          description: l10n.symptomInsightFertileWindowOpeningBody,
          priority: 80,
        ));
      }

      // 2. ЦЕРВИКАЛЬНАЯ СЛИЗЬ (Яичный белок)
      if (_has(symptoms, ['egg-white mucus'])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightHighlyFertileMucusTitle,
          description: l10n.symptomInsightHighlyFertileMucusBody,
          priority: 90,
        ));
      } else if (_has(symptoms, ['creamy mucus', 'sticky mucus'])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightBuildingUpFertilityTitle,
          description: l10n.symptomInsightBuildingUpFertilityBody,
          priority: 40,
        ));
      }

      // 3. БЛИЗОСТЬ
      if (_has(symptoms, ['unprotected sex'])) {
        if (phase == CyclePhase.ovulation) {
          possibleInsights.add(SymptomInsight(
            title: l10n.symptomInsightPerfectTimingTitle,
            description: l10n.symptomInsightPerfectTimingBody,
            priority: 85,
          ));
        } else if (phase == CyclePhase.luteal) {
          possibleInsights.add(SymptomInsight(
            title: l10n.symptomInsightTwoWeekWaitTitle,
            description: l10n.symptomInsightTwoWeekWaitBody,
            priority: 30,
          ));
        }
      }

      // 🔥 ИСПРАВЛЕНИЕ: Убран ранний возврат "if (possibleInsights.isNotEmpty) return possibleInsights.first;".
      // Теперь мы продолжаем анализ, чтобы не пропустить медицинские тревоги!
    }


    // =========================================================================
    // УРОВЕНЬ 1: КРАСНЫЕ ФЛАГИ ГИНЕКОЛОГИИ (PRIORITY: 100)
    // =========================================================================

    if (_has(symptoms, ['spotting', 'bleed', 'мазня']) && phase != CyclePhase.menstruation) {
      if (_has(symptoms, ['pain', 'cramp', 'боль', 'спазм', 'severe cramps'])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightMedicalAlertPainSpottingTitle,
          description: l10n.symptomInsightMedicalAlertPainSpottingBody,
          isWarning: true,
          priority: 100, // 🔥 Это перебьет любой инсайт планирования беременности
        ));
      } else {
        possibleInsights.add(SymptomInsight(
          title: l10n.insightSpottingTitle,
          description: l10n.insightSpottingBody,
          isWarning: true,
          priority: 90,
        ));
      }
    }

    // =========================================================================
    // УРОВЕНЬ 2: СИНДРОМЫ И ПАТТЕРНЫ (PRIORITY: 50-80)
    // =========================================================================

    if (phase == CyclePhase.menstruation) {
      if (_hasAllGroups(symptoms, [
        ['cramp', 'pain', 'болит', 'спазм'],
        ['nausea', 'vomit', 'тошнота', 'dizzy', 'головокружение']
      ])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightDysmenorrheaPatternTitle,
          description: l10n.symptomInsightDysmenorrheaPatternBody,
          priority: 80,
          isWarning: true,
        ));
      }
    }

    if (phase == CyclePhase.luteal) {
      if (_hasAllGroups(symptoms, [
        ['sad', 'cry', 'crying spells', 'грусть', 'слезы'],
        ['anxious', 'anxiety', 'panic', 'stress', 'тревога']
      ])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightSeverePmsPmddTitle,
          description: l10n.symptomInsightSeverePmsPmddBody,
          priority: 70,
          isWarning: true,
        ));
      }
    }

    if (phase == CyclePhase.ovulation) {
      if (_hasAllGroups(symptoms, [
        ['high libido', 'sexy', 'horn', 'либидо'],
        ['energy', 'active', 'энергия', 'happy']
      ])) {
        possibleInsights.add(SymptomInsight(
          title: l10n.symptomInsightBiologicalPeakTitle,
          description: l10n.symptomInsightBiologicalPeakBody,
          priority: 60,
        ));
      }
    }

    // =========================================================================
    // УРОВЕНЬ 3: БАЗОВЫЕ ИНСАЙТЫ (PRIORITY: 10-40)
    // =========================================================================

    if (phase == CyclePhase.menstruation) {
      if (_has(symptoms, ['cramp', 'pain', 'болит', 'спазм'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightProstaglandinsTitle, description: l10n.insightProstaglandinsBody, priority: 30));
      }
      if (_has(symptoms, ['fatigue', 'tired', 'low energy', 'усталость'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightWinterPhaseTitle, description: l10n.insightWinterPhaseBody, priority: 20));
      }
    }

    if (phase == CyclePhase.follicular) {
      if (_has(symptoms, ['energy', 'happy', 'active', 'энергия'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightEstrogenTitle, description: l10n.insightEstrogenBody, priority: 20));
      }
    }

    if (phase == CyclePhase.ovulation) {
      if (_has(symptoms, ['pain', 'ovary', 'side', 'боль'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightMittelschmerzTitle, description: l10n.insightMittelschmerzBody, priority: 30));
      }
      if (_has(symptoms, ['libido', 'sexy', 'social', 'либидо'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightFertilityTitle, description: l10n.insightFertilityBody, priority: 20));
      }
    }

    if (phase == CyclePhase.luteal) {
      if (_has(symptoms, ['bloating', 'weight', 'отек', 'вес'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightWaterTitle, description: l10n.insightWaterBody, priority: 20));
      }
      if (_has(symptoms, ['irritab', 'mood', 'sad', 'cry', 'грусть', 'нервы'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightProgesteroneTitle, description: l10n.insightProgesteroneBody, priority: 30));
      }
      if (_has(symptoms, ['acne', 'skin', 'pimple', 'акне', 'кожа'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightSkinTitle, description: l10n.insightSkinBody, priority: 20));
      }
      if (_has(symptoms, ['cravings', 'sugar', 'hungry', 'сладкое', 'аппетит'])) {
        possibleInsights.add(SymptomInsight(title: l10n.insightMetabolismTitle, description: l10n.insightMetabolismBody, priority: 20));
      }
    }

    if (possibleInsights.isEmpty) return null;

    // 🔥 ФИНАЛЬНАЯ СОРТИРОВКА: ВЫБИРАЕТСЯ САМЫЙ КРИТИЧНЫЙ ИНСАЙТ ИЗ ВСЕХ ВОЗМОЖНЫХ
    possibleInsights.sort((a, b) => b.priority.compareTo(a.priority));
    return possibleInsights.first;
  }

  static bool _has(List<String> userSymptoms, List<String> keywords) {
    for (var s in userSymptoms) {
      for (var k in keywords) {
        if (s.contains(k)) return true;
      }
    }
    return false;
  }

  static bool _hasAllGroups(List<String> userSymptoms, List<List<String>> keywordGroups) {
    for (var group in keywordGroups) {
      if (!_has(userSymptoms, group)) {
        return false;
      }
    }
    return true;
  }
}
