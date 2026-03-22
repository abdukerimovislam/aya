import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/providers/cycle_provider.dart';
import '../../../data/providers/wellness_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/premium_glass_card.dart';

class DashboardMicroCalendar extends StatelessWidget {
  final CycleProvider provider;
  final void Function(BuildContext context, DateTime date, String heroTag)
  onOpenLogger;

  const DashboardMicroCalendar({
    super.key,
    required this.provider,
    required this.onOpenLogger,
  });

  @override
  Widget build(BuildContext context) {
    final wellnessProvider = context.watch<WellnessProvider>();
    final today = _dateOnly(DateTime.now());
    final l10n = AppLocalizations.of(context)!;

    // 7 дней: 3 назад, сегодня, 3 вперед
    final dates = List.generate(
      7,
          (index) => today.subtract(Duration(days: 3 - index)),
    );

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalendarHeader(l10n: l10n, today: today),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dates.map((date) {
              final isToday = _isSameDay(date, today);
              final isFuture = date.isAfter(today);

              // 🔥 Динамически получаем фазу из провайдера
              final phase = provider.getPhaseForDate(date);
              final hasLogs = wellnessProvider.hasLogForDate(date);
              final heroTag = 'day_circle_${date.toIso8601String()}';

              // Передаем фазу в стилизатор
              final style = _DayStyle.resolve(
                isToday: isToday,
                phase: phase,
                isFuture: isFuture,
                hasLogs: hasLogs,
              );

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: isFuture
                    ? null
                    : () async {
                  HapticFeedback.mediumImpact();
                  await provider.togglePeriodDay(date);
                },
                onTap: isFuture
                    ? null
                    : () {
                  HapticFeedback.selectionClick();
                  onOpenLogger(context, date, heroTag);
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isFuture ? 0.6 : 1.0, // Чуть увеличили прозрачность для будущих дней
                  child: SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _weekdayShort(date, l10n.localeName),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: style.weekdayColor,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Hero(
                          tag: heroTag,
                          flightShuttleBuilder: (
                              flightContext,
                              animation,
                              flightDirection,
                              fromHeroContext,
                              toHeroContext,
                              ) {
                            return DefaultTextStyle(
                              style: DefaultTextStyle.of(toHeroContext).style,
                              child: toHeroContext.widget,
                            );
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: style.gradient,
                                color: style.gradient == null
                                    ? style.backgroundColor
                                    : null,
                                border: Border.all(
                                  color: style.borderColor,
                                  width: style.borderWidth,
                                ),
                                boxShadow: style.shadows,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Кольцо для "Сегодня", если фаза нейтральная
                                  if (isToday && phase != CyclePhase.menstruation && phase != CyclePhase.ovulation)
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.5),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.85),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Text(
                                      '${date.day}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: style.dayFontWeight,
                                        color: style.dayTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: hasLogs ? 6 : 4,
                          height: hasLogs ? 6 : 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: style.dotColor,
                            boxShadow: hasLogs
                                ? [
                              BoxShadow(
                                color: style.dotColor.withOpacity(0.35),
                                blurRadius: 6,
                                spreadRadius: 0.5,
                              )
                            ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _weekdayShort(DateTime date, String locale) {
    final raw = DateFormat('E', locale).format(date);
    return raw.characters.first.toUpperCase();
  }
}

class _CalendarHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final DateTime today;

  const _CalendarHeader({
    required this.l10n,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = AppColors.textPrimary;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD6E0).withOpacity(0.95),
                const Color(0xFFFFEFF4).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 15,
            color: Color(0xFFE85D75),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            DateFormat.MMMMEEEEd(l10n.localeName).format(today),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayStyle {
  final Color weekdayColor;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final Color dayTextColor;
  final FontWeight dayFontWeight;
  final Color dotColor;

  const _DayStyle({
    required this.weekdayColor,
    required this.backgroundColor,
    required this.gradient,
    required this.borderColor,
    required this.borderWidth,
    required this.shadows,
    required this.dayTextColor,
    required this.dayFontWeight,
    required this.dotColor,
  });

  static _DayStyle resolve({
    required bool isToday,
    required CyclePhase? phase,
    required bool isFuture,
    required bool hasLogs,
  }) {
    // Палитры для разных фаз
    const periodStart = Color(0xFFFF8FA8);
    const periodEnd = Color(0xFFFFC2CF);

    const ovulationStart = Color(0xFFB7D7FF);
    const ovulationEnd = Color(0xFFE7F1FF);

    // Добавляем нежные цвета для остальных фаз
    const follicularStart = Color(0xFFE0F7FA);
    const follicularEnd = Color(0xFFB2EBF2);

    const lutealStart = Color(0xFFF3E5F5);
    const lutealEnd = Color(0xFFE1BEE7);

    const lateStart = Color(0xFFFFF3E0);
    const lateEnd = Color(0xFFFFE0B2);

    const todayStart = Color(0xFFFFF7FA);
    const todayEnd = Color(0xFFFDE7EE);

    final baseBorder = Colors.white.withOpacity(0.55);
    final mutedText = AppColors.textSecondary.withOpacity(0.45);

    // 1. Месячные
    if (phase == CyclePhase.menstruation) {
      return _DayStyle(
        weekdayColor: const Color(0xFFE06C86),
        backgroundColor: Colors.transparent,
        gradient: const LinearGradient(
          colors: [periodStart, periodEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.25),
        borderWidth: 1,
        shadows: isFuture ? null : [ // Тени только для прошедших/текущих дней
          BoxShadow(
            color: periodStart.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        dayTextColor: Colors.white,
        dayFontWeight: FontWeight.w800,
        dotColor: hasLogs ? const Color(0xFFE85D75) : Colors.transparent,
      );
    }

    // 2. Овуляция
    if (phase == CyclePhase.ovulation) {
      return _DayStyle(
        weekdayColor: const Color(0xFF6D8CCF),
        backgroundColor: Colors.transparent,
        gradient: const LinearGradient(
          colors: [ovulationStart, ovulationEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.35),
        borderWidth: 1,
        shadows: isFuture ? null : [
          BoxShadow(
            color: ovulationStart.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        dayTextColor: const Color(0xFF4267B2),
        dayFontWeight: FontWeight.w700,
        dotColor: hasLogs ? const Color(0xFF7FA9E8) : Colors.transparent,
      );
    }

    // 3. Фолликулярная фаза (Нежно-бирюзовый)
    if (phase == CyclePhase.follicular && !isToday) {
      return _DayStyle(
        weekdayColor: AppColors.textSecondary.withOpacity(0.7),
        backgroundColor: Colors.transparent,
        gradient: const LinearGradient(
          colors: [follicularStart, follicularEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.3),
        borderWidth: 1,
        shadows: null,
        dayTextColor: const Color(0xFF00838F),
        dayFontWeight: FontWeight.w600,
        dotColor: hasLogs ? const Color(0xFF4DD0E1) : Colors.transparent,
      );
    }

    // 4. Лютеиновая фаза (Нежно-сиреневый)
    if (phase == CyclePhase.luteal && !isToday) {
      return _DayStyle(
        weekdayColor: AppColors.textSecondary.withOpacity(0.7),
        backgroundColor: Colors.transparent,
        gradient: const LinearGradient(
          colors: [lutealStart, lutealEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.3),
        borderWidth: 1,
        shadows: null,
        dayTextColor: const Color(0xFF6A1B9A),
        dayFontWeight: FontWeight.w600,
        dotColor: hasLogs ? const Color(0xFFBA68C8) : Colors.transparent,
      );
    }

    // 5. Задержка (Мягкий персиковый)
    if (phase == CyclePhase.late && !isToday) {
      return _DayStyle(
        weekdayColor: const Color(0xFFE65100).withOpacity(0.7),
        backgroundColor: Colors.transparent,
        gradient: const LinearGradient(
          colors: [lateStart, lateEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.3),
        borderWidth: 1,
        shadows: null,
        dayTextColor: const Color(0xFFE65100),
        dayFontWeight: FontWeight.w600,
        dotColor: hasLogs ? const Color(0xFFFFB74D) : Colors.transparent,
      );
    }

    // 6. Сегодня (если не месячные и не овуляция)
    if (isToday) {
      return _DayStyle(
        weekdayColor: const Color(0xFFE06C86),
        backgroundColor: Colors.transparent,
        gradient: LinearGradient(
          colors: [
            todayStart.withOpacity(0.96),
            todayEnd.withOpacity(0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFFFD3DE),
        borderWidth: 1.2,
        shadows: [
          BoxShadow(
            color: const Color(0xFFFFD3DE).withOpacity(0.45),
            blurRadius: 14,
            spreadRadius: 0.5,
            offset: const Offset(0, 6),
          ),
        ],
        dayTextColor: AppColors.textPrimary,
        dayFontWeight: FontWeight.w800,
        dotColor: hasLogs
            ? const Color(0xFFE8A3B5)
            : const Color(0xFFFFD3DE).withOpacity(0.5),
      );
    }

    // 7. Дефолтное состояние (если фаза null или что-то пошло не так)
    return _DayStyle(
      weekdayColor: isFuture
          ? mutedText
          : AppColors.textSecondary.withOpacity(0.7),
      backgroundColor: Colors.white.withOpacity(0.08),
      gradient: null,
      borderColor: baseBorder.withOpacity(isFuture ? 0.18 : 0.32),
      borderWidth: 1,
      shadows: isFuture
          ? null
          : [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      dayTextColor: isFuture
          ? AppColors.textSecondary.withOpacity(0.55)
          : AppColors.textPrimary,
      dayFontWeight: FontWeight.w600,
      dotColor: hasLogs
          ? const Color(0xFFD3A4B1)
          : Colors.transparent,
    );
  }
}