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
          title: "Peak Fertility Detected! 🎯",
          description: "Your LH surge indicates ovulation will likely occur within 24-36 hours. Today and tomorrow are your best days to try to conceive.",
          priority: 100, // Максимальный приоритет
        ));
      } else if (_has(symptoms, ['lh: high'])) {
        possibleInsights.add(SymptomInsight(
          title: "Fertile Window Opening",
          description: "LH levels are rising. Start having intercourse every 1-2 days to maximize your chances as ovulation approaches.",
          priority: 80,
        ));
      }

      // 2. ЦЕРВИКАЛЬНАЯ СЛИЗЬ (Яичный белок)
      if (_has(symptoms, ['egg-white mucus'])) {
        possibleInsights.add(SymptomInsight(
          title: "Highly Fertile Mucus",
          description: "Egg-white cervical mucus creates the perfect environment for sperm to survive and swim. This is a primary sign of high fertility.",
          priority: 90,
        ));
      } else if (_has(symptoms, ['creamy mucus', 'sticky mucus'])) {
        possibleInsights.add(SymptomInsight(
          title: "Building Up Fertility",
          description: "Your cervical mucus is transitioning. As you get closer to ovulation, it will become clearer and more stretchy.",
          priority: 40,
        ));
      }

      // 3. БЛИЗОСТЬ
      if (_has(symptoms, ['unprotected sex'])) {
        if (phase == CyclePhase.ovulation) {
          possibleInsights.add(SymptomInsight(
            title: "Perfect Timing! ✨",
            description: "You've logged unprotected sex during your ovulation phase. You've maximized your chances for this cycle. Now, time for the Two Week Wait (TWW).",
            priority: 85,
          ));
        } else if (phase == CyclePhase.luteal) {
          possibleInsights.add(SymptomInsight(
            title: "The Two Week Wait",
            description: "The egg only survives 24h after ovulation. Intercourse in the luteal phase usually doesn't lead to conception, but it's great for connection!",
            priority: 30,
          ));
        }
      }

      // Если нашли инсайты планирования — отдаем их первыми
      if (possibleInsights.isNotEmpty) {
        possibleInsights.sort((a, b) => b.priority.compareTo(a.priority));
        return possibleInsights.first;
      }
    }


    // =========================================================================
    // УРОВЕНЬ 1: КРАСНЫЕ ФЛАГИ ГИНЕКОЛОГИИ (PRIORITY: 100)
    // =========================================================================

    if (_has(symptoms, ['spotting', 'bleed', 'мазня']) && phase != CyclePhase.menstruation) {
      if (_has(symptoms, ['pain', 'cramp', 'боль', 'спазм', 'severe cramps'])) {
        possibleInsights.add(SymptomInsight(
          title: "Medical Alert: Pain & Spotting",
          description: "Spotting accompanied by pain outside your period can indicate cysts, polyps, or hormonal issues. Consider consulting a doctor.",
          isWarning: true,
          priority: 100,
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
          title: "Dysmenorrhea Pattern",
          description: "High levels of prostaglandins are causing both severe cramps and nausea. Warmth and NSAIDs (like Ibuprofen) can help block this chemical.",
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
          title: "Severe PMS / PMDD Indicator",
          description: "Your emotional symptoms are compounding. This sharp drop in serotonin alongside progesterone is normal, but requires extreme self-care today.",
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
          title: "Biological Peak",
          description: "Estrogen and testosterone are cresting simultaneously. Your body is biologically primed for socializing, mating, and high-energy tasks.",
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