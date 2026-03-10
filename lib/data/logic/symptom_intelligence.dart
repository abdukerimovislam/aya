import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../models/cycle_model.dart';

class SymptomInsight {
  final String title;
  final String description;
  final bool isWarning;
  final int priority; // 🔥 Уровень важности: 100 (Критично), 50 (Синдром), 10 (Обычный)

  SymptomInsight({
    required this.title,
    required this.description,
    this.isWarning = false,
    this.priority = 10,
  });
}

class SymptomIntelligence {

  /// Главный метод: Анализирует симптомы как врач (Expert System)
  static SymptomInsight? getInsight(BuildContext context, List<String> selectedSymptoms, CyclePhase phase) {
    if (selectedSymptoms.isEmpty) return null;

    final l10n = AppLocalizations.of(context)!;
    final symptoms = selectedSymptoms.map((e) => e.toLowerCase()).toList();

    List<SymptomInsight> possibleInsights = [];

    // =========================================================================
    // УРОВЕНЬ 1: КРАСНЫЕ ФЛАГИ (PRIORITY: 100) - Высший приоритет
    // =========================================================================

    // 🚩 Аномальное кровотечение (Spotting вне месячных)
    if (_has(symptoms, ['spotting', 'bleed', 'мазня']) && phase != CyclePhase.menstruation) {
      // Если еще и болит - это повод обратиться к врачу
      if (_has(symptoms, ['pain', 'cramp', 'боль', 'спазм'])) {
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
    // УРОВЕНЬ 2: СИНДРОМЫ И ПАТТЕРНЫ (PRIORITY: 50-80) - Комбинации симптомов
    // =========================================================================

    // 🔴 Дисменорея (Тяжелая менструация)
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

    // 🟡 ПМДР (Предменструальное дисфорическое расстройство) - Сильный ПМС
    if (phase == CyclePhase.luteal) {
      if (_hasAllGroups(symptoms, [
        ['sad', 'cry', 'depress', 'грусть', 'слезы'],
        ['anxiety', 'panic', 'stress', 'тревога', 'нервы']
      ])) {
        possibleInsights.add(SymptomInsight(
          title: "Severe PMS / PMDD Indicator",
          description: "Your emotional symptoms are compounding. This sharp drop in serotonin alongside progesterone is normal, but requires extreme self-care today.",
          priority: 70,
          isWarning: true,
        ));
      }
    }

    // 🟢 Пик Фертильности (Супер-комбо овуляции)
    if (phase == CyclePhase.ovulation) {
      if (_hasAllGroups(symptoms, [
        ['libido', 'sexy', 'horn', 'либидо'],
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
    // УРОВЕНЬ 3: БАЗОВЫЕ ИНСАЙТЫ (PRIORITY: 10-40) - Одиночные симптомы
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

    // =========================================================================
    // ФИНАЛИЗАЦИЯ: Выбираем самый важный инсайт
    // =========================================================================

    if (possibleInsights.isEmpty) return null;

    // Сортируем по приоритету (от большего к меньшему)
    possibleInsights.sort((a, b) => b.priority.compareTo(a.priority));

    // Возвращаем самый релевантный и важный медицинский вывод на сегодня
    return possibleInsights.first;
  }

  // --- Вспомогательные методы (AI Helpers) ---

  /// Проверяет, есть ли хотя бы одно совпадение из списка ключей
  static bool _has(List<String> userSymptoms, List<String> keywords) {
    for (var s in userSymptoms) {
      for (var k in keywords) {
        if (s.contains(k)) return true;
      }
    }
    return false;
  }

  /// Продвинутый метод: Проверяет наличие комбинации симптомов (Синдромы)
  /// Например: Должна быть (Боль ИЛИ Спазм) ПЛЮС (Тошнота ИЛИ Головокружение)
  static bool _hasAllGroups(List<String> userSymptoms, List<List<String>> keywordGroups) {
    for (var group in keywordGroups) {
      if (!_has(userSymptoms, group)) {
        return false; // Если хотя бы одной группы симптомов нет - паттерн не совпал
      }
    }
    return true; // Нашли все требуемые группы симптомов!
  }
}