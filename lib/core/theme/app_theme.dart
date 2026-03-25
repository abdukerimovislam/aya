import 'package:flutter/material.dart';
import '../../data/models/cycle_model.dart';

class AppColors {
  // =========================
  // 🌺 BRAND / CORE
  // =========================

  /// Главный брендовый цвет — насыщенный малиновый
  static const Color primary = Color(0xFFC2185B);

  /// Более мягкий вариант primary для hover/secondary accents
  static const Color primaryLight = Color(0xFFE25584);

  /// Очень мягкий оттенок primary для background chips / soft states
  static const Color primarySoft = Color(0xFFFCE7EE);

  // =========================
  // 🎨 BASE SURFACES
  // =========================

  /// Общий фон приложения — холодный светлый розово-серый
  static const Color background = Color(0xFFF6F1F4);

  /// Основная поверхность карточек / bottom sheets / inputs
  static const Color surface = Color(0xFFFFFFFF);

  /// Вторичный фон для секций / вложенных блоков
  static const Color secondaryBackground = Color(0xFFF1EAF0);

  /// Тонкая граница карточек и разделителей
  static const Color divider = Color(0xFFE7DCE2);

  /// Лёгкая сетка / вспомогательные линии на чартах
  static Color get gridLines => textPrimary.withValues(alpha: 0.05);

  /// Очень мягкая тень
  static Color get softShadow => const Color(0xFF2D1F26).withValues(alpha: 0.05);

  // =========================
  // ✍️ TEXT
  // =========================

  static const Color textPrimary = Color(0xFF2D1F26);
  static const Color textSecondary = Color(0xFF7C6A73);

  /// Для совсем второстепенного текста / disabled labels
  static const Color textTertiary = Color(0xFFA3919A);

  // =========================
  // 🌸 CYCLE PHASES
  // =========================

  /// Месячные — сильный малиновый
  static const Color menstruation = Color(0xFFC2185B);

  /// Фолликулярная — свежий мятный
  static const Color follicular = Color(0xFF4DB6AC);

  /// Овуляция — мягкий премиальный фиолетовый
  static const Color ovulation = Color(0xFF8E71C7);

  /// Лютеиновая — тёплый taupe / muted cocoa
  static const Color luteal = Color(0xFF9A7B73);

  /// Задержка / warning-state
  static const Color late = Color(0xFFF2A65A);

  // =========================
  // 📊 CHART COLORS
  // =========================

  static const Color chartMenstruation = menstruation;
  static const Color chartFollicular = follicular;
  static const Color chartOvulation = ovulation;
  static const Color chartLuteal = luteal;

  // =========================
  // 🌫 SOFT PHASE BACKGROUNDS
  // =========================

  /// Мягкий фон для period states/cards
  static const Color periodSoft = Color(0xFFFDECEF);
  static const Color periodStrong = menstruation;

  /// Мягкий фон fertile window
  static const Color fertileSoft = Color(0xFFE8F5F2);
  static const Color fertileText = Color(0xFF3E8F84);

  /// Овуляционные состояния
  static const Color ovulationSoft = Color(0xFFF1ECFB);
  static const Color ovulationStrong = Color(0xFF7C5CC0);

  // =========================
  // ✅ STATUS COLORS
  // =========================

  static const Color success = Color(0xFF2FAE8F);
  static const Color warning = late;
  static const Color error = menstruation;

  // =========================
  // 🔖 SPECIAL MARKERS / ICON STATES
  // =========================

  static const Color intimacy = Color(0xFFD45C7A);
  static const Color neutralMarker = Color(0xFFB5A8B0);

  /// Более явная рамка выбранного элемента
  static const Color selectedBorder = Color(0xFF4A2B38);

  /// Обводка для soft-selected состояний
  static const Color selectedSoftBorder = Color(0xFFE7A4B8);

  /// Today marker в календаре — не такой агрессивный как selected
  static const Color todayRing = Color(0xFFE58AA5);

  /// Цвет неактивных иконок
  static const Color iconInactive = Color(0xFFA7969F);

  // =========================
  // 🧩 SURFACE VARIANTS
  // =========================

  /// Чуть тонированная карточка под женственный стиль
  static const Color tintedSurface = Color(0xFFFFFBFD);

  /// Более контрастный слой для стеклянных/overlay элементов
  static const Color elevatedSurface = Color(0xFFFFFFFF);

  /// Подложка для badge/chip
  static const Color chipBackground = Color(0xFFF7EDF2);

  // =========================
  // 📅 CALENDAR HELPERS
  // =========================

  /// Фон выбранного дня
  static const Color calendarSelectedDay = primary;

  /// Фон дня с месячными
  static const Color calendarPeriodDay = menstruation;

  /// Фон fertile day
  static const Color calendarFertileDay = Color(0xFFDDF4EE);

  /// Фон ovulation day
  static const Color calendarOvulationDay = Color(0xFFEDE7FA);

  /// Обычный day text
  static const Color calendarDayText = textPrimary;

  /// Текст вне текущего месяца / disabled days
  static const Color calendarMutedDayText = Color(0xFFB3A6AD);

  // =========================
  // 🎯 HELPERS
  // =========================

  static Color phaseTint(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return menstruation;
      case CyclePhase.follicular:
        return follicular;
      case CyclePhase.ovulation:
        return ovulation;
      case CyclePhase.luteal:
        return luteal;
      case CyclePhase.late:
        return late;
    }
  }

  static Color phaseSoft(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return periodSoft;
      case CyclePhase.follicular:
        return fertileSoft;
      case CyclePhase.ovulation:
        return ovulationSoft;
      case CyclePhase.luteal:
        return const Color(0xFFF3ECE9);
      case CyclePhase.late:
        return const Color(0xFFFFF3E4);
    }
  }

  static Color phaseText(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return menstruation;
      case CyclePhase.follicular:
        return fertileText;
      case CyclePhase.ovulation:
        return ovulationStrong;
      case CyclePhase.luteal:
        return const Color(0xFF7E625C);
      case CyclePhase.late:
        return const Color(0xFFC27A28);
    }
  }

  static Color withSoftOpacity(Color color, [double opacity = 0.12]) {
    return color.withValues(alpha: opacity);
  }

  static Color withMediumOpacity(Color color, [double opacity = 0.22]) {
    return color.withValues(alpha: opacity);
  }
}