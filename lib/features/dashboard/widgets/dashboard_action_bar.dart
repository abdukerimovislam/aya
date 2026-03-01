import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/providers/cycle_provider.dart';
import '../../../shared/widgets/animated_edge_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
class _ActionBarConstants {
  static const int pulseTriggerDays = 3;
  static const int maxRetroactiveDays = 60;
  static const int snackbarDurationSeconds = 4;
  static const double snackbarBottomMargin = 100;
  static const double sheetBorderRadius = 32;
  static const double handleWidth = 48;
  static const double handleHeight = 5;
  static const double optionIconSize = 26;
  static const int minDaysBetweenCycles = 11;
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class DashboardActionBar extends StatelessWidget {
  final CycleData data;
  final bool isCOC;
  final CycleProvider provider;
  final AppLocalizations l10n;
  final void Function(BuildContext context, DateTime date, String heroTag) onOpenLogger;

  const DashboardActionBar({
    super.key,
    required this.data,
    required this.isCOC,
    required this.provider,
    required this.l10n,
    required this.onOpenLogger,
  });

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final _ActionConfig config = _resolveActionConfig(context);

    return AnimatedEdgeButton(
      text: config.text,
      icon: config.icon,
      textColor: config.textColor,
      bgColor: config.bgColor,
      onTap: config.onTap,
      isPulsing: config.isPulsing,
    );
  }

  // ─── ACTION CONFIG RESOLVER ─────────────────────────────────────────────────

  _ActionConfig _resolveActionConfig(BuildContext context) {
    if (isCOC) {
      return _ActionConfig(
        text: l10n.btnStartNewPack,
        icon: CupertinoIcons.capsule_fill,
        textColor: Colors.white,
        bgColor: AppColors.primary,
        isPulsing: false,
        onTap: () => _handleStartNewCOCPack(context),
      );
    }

    if (data.phase == CyclePhase.menstruation) {
      // 🔥 УМНЫЙ UX: Если юзер уже нажал "Закончить", даем фидбек текстом и цветом!
      if (provider.isPeriodEnded) {
        return _ActionConfig(
          text: "Ending today", // TODO: Добавить в .arb (например, l10n.periodEndingToday)
          icon: CupertinoIcons.check_mark_circled_solid,
          textColor: Colors.white,
          bgColor: AppColors.menstruation.withOpacity(0.7), // Делаем цвет слегка приглушенным
          isPulsing: false,
          onTap: () => _showActivePeriodSheet(context),
        );
      }

      return _ActionConfig(
        text: l10n.phaseMenstruation,
        icon: CupertinoIcons.drop_fill,
        textColor: Colors.white,
        bgColor: AppColors.menstruation,
        isPulsing: false,
        onTap: () => _showActivePeriodSheet(context),
      );
    }

    final bool isPulsing = data.daysUntilNextPeriod <= _ActionBarConstants.pulseTriggerDays ||
        data.phase == CyclePhase.late;

    return _ActionConfig(
      text: l10n.dialogPeriodStartTitle,
      icon: CupertinoIcons.drop,
      textColor: AppColors.menstruation,
      bgColor: Colors.white,
      isPulsing: isPulsing,
      onTap: () => _showPeriodInterceptorSheet(context),
    );
  }

  // ─── ACTION HANDLERS ────────────────────────────────────────────────────────

  Future<void> _handleStartNewCOCPack(BuildContext context) async {
    try {
      await provider.setCOCMode(true);
    } catch (e) {
      debugPrint('DashboardActionBar: setCOCMode error: $e');
      if (context.mounted) _showErrorSnackbar(context);
    }
  }

  Future<void> _handleSmartPeriodStart(BuildContext context, DateTime selectedDate) async {
    try {
      final result = await provider.logActionStartPeriod(selectedDate);

      if (!context.mounted) return;

      if (result == CycleLogResult.futureDate) {
        _showErrorSnackbar(context, message: "Cannot log a date in the future");
        return;
      }

      if (result == CycleLogResult.suspiciouslyEarly) {
        _showSuspiciouslyEarlyDialog(context, selectedDate);
        return;
      }

      _showSuccessSnackbar(context, l10n.msgSaved);

    } catch (e) {
      debugPrint('DashboardActionBar: logActionStartPeriod error: $e');
      if (context.mounted) _showErrorSnackbar(context);
    }
  }

  // ─── DIALOGS & BOTTOM SHEETS ────────────────────────────────────────────────

  void _showSuspiciouslyEarlyDialog(BuildContext context, DateTime selectedDate) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Are you sure?",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "It's been less than 21 days since your last cycle started. Is this a new period, or just spotting?",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.lightImpact();
              await provider.togglePeriodDay(selectedDate);
              if (context.mounted) {
                _showSuccessSnackbar(context, l10n.insightSpottingBody);
              }
            },
            child: Text(
              "Just Spotting",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.menstruation,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await provider.logActionStartPeriod(selectedDate, isConfirmed: true);
              if (context.mounted) {
                _showSuccessSnackbar(context, l10n.msgSaved);
              }
            },
            child: Text(
              "New Period",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodInterceptorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PeriodInterceptorSheet(
        l10n: l10n,
        onTodayTap: () {
          Navigator.pop(ctx);
          _handleSmartPeriodStart(context, DateTime.now());
        },
        onYesterdayTap: () {
          Navigator.pop(ctx);
          _handleSmartPeriodStart(
            context,
            DateTime.now().subtract(const Duration(days: 1)),
          );
        },
        onPickDateTap: () async {
          Navigator.pop(ctx);
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now()
                .subtract(const Duration(days: _ActionBarConstants.maxRetroactiveDays)),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.menstruation,
                  onPrimary: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            HapticFeedback.mediumImpact();
            if (context.mounted) _handleSmartPeriodStart(context, picked);
          }
        },
      ),
    );
  }

  void _showActivePeriodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ActivePeriodSheet(
        l10n: l10n,
        isPeriodEnded: provider.isPeriodEnded, // 🔥 Передаем текущий статус окончания
        isDayOne: data.currentDay == 1,        // 🔥 Передаем флаг первого дня
        onLogTap: () {
          Navigator.pop(ctx);
          onOpenLogger(context, DateTime.now(), 'log_sheet');
        },
        onEndTap: () async {
          HapticFeedback.heavyImpact();
          Navigator.pop(ctx);
          try {
            await provider.endCurrentPeriod();
          } catch (e) {
            debugPrint('DashboardActionBar: endCurrentPeriod error: $e');
            if (context.mounted) _showErrorSnackbar(context);
          }
        },
        onResumeTap: () async {
          HapticFeedback.lightImpact();
          Navigator.pop(ctx);
          await provider.resumePeriod();
        },
        onUndoTap: () async {
          HapticFeedback.heavyImpact();
          Navigator.pop(ctx);
          await provider.undoPeriodStart();
          if (context.mounted) _showSuccessSnackbar(context, "Period start removed"); // TODO: Вынести в l10n
        },
      ),
    );
  }

  // ─── SNACKBARS ──────────────────────────────────────────────────────────────

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(message, AppColors.textPrimary.withOpacity(0.9)),
    );
  }

  void _showErrorSnackbar(BuildContext context, {String message = 'Error. Please try again.'}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(
        message,
        Colors.redAccent.withOpacity(0.9),
      ),
    );
  }

  SnackBar _buildSnackbar(String message, Color bgColor) {
    return SnackBar(
      content: Text(
        message,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: _ActionBarConstants.snackbarDurationSeconds),
      margin: const EdgeInsets.only(
        bottom: _ActionBarConstants.snackbarBottomMargin,
        left: 20,
        right: 20,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE CONFIG MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ActionConfig {
  final String text;
  final IconData icon;
  final Color textColor;
  final Color bgColor;
  final bool isPulsing;
  final VoidCallback onTap;

  const _ActionConfig({
    required this.text,
    required this.icon,
    required this.textColor,
    required this.bgColor,
    required this.isPulsing,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET: Period not active — ask when it started
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodInterceptorSheet extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onTodayTap;
  final VoidCallback onYesterdayTap;
  final VoidCallback onPickDateTap;

  const _PeriodInterceptorSheet({
    required this.l10n,
    required this.onTodayTap,
    required this.onYesterdayTap,
    required this.onPickDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: l10n.dialogPeriodStartTitle,
      children: [
        _SheetOption(
          icon: CupertinoIcons.calendar_today,
          title: l10n.btnToday,
          subtitle: l10n.dialogStartBody,
          color: AppColors.menstruation,
          onTap: onTodayTap,
        ),
        const SizedBox(height: 12),
        _SheetOption(
          icon: CupertinoIcons.arrow_counterclockwise_circle_fill,
          title: l10n.btnYesterday,
          subtitle: l10n.onboardDateTitleCycle,
          color: AppColors.textSecondary,
          onTap: onYesterdayTap,
        ),
        const SizedBox(height: 12),
        _SheetOption(
          icon: CupertinoIcons.calendar,
          title: l10n.btnPickDate,
          subtitle: l10n.pdfTableDate,
          color: AppColors.textSecondary,
          onTap: onPickDateTap,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET: Period active — manage it
// ─────────────────────────────────────────────────────────────────────────────

class _ActivePeriodSheet extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isPeriodEnded;
  final bool isDayOne;
  final VoidCallback onLogTap;
  final VoidCallback onEndTap;
  final VoidCallback onResumeTap;
  final VoidCallback onUndoTap;

  const _ActivePeriodSheet({
    required this.l10n,
    required this.isPeriodEnded,
    required this.isDayOne,
    required this.onLogTap,
    required this.onEndTap,
    required this.onResumeTap,
    required this.onUndoTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: l10n.editPeriod,
      children: [
        _SheetOption(
          icon: CupertinoIcons.add_circled_solid,
          title: l10n.logSymptomsTitle,
          subtitle: l10n.symptomSubHeader,
          color: AppColors.primary,
          onTap: onLogTap,
        ),
        const SizedBox(height: 12),

        // 🔥 Умная логика завершения/возобновления
        if (isPeriodEnded)
          _SheetOption(
            icon: CupertinoIcons.play_circle_fill,
            title: "Resume period", // TODO: Добавить в L10n
            subtitle: "Still bleeding? Continue current period",
            color: Colors.orange.shade700,
            onTap: onResumeTap,
          )
        else
          _SheetOption(
            icon: CupertinoIcons.check_mark_circled_solid,
            title: l10n.btnPeriodEnd,
            subtitle: l10n.dialogEndBody,
            color: AppColors.textSecondary,
            onTap: onEndTap,
          ),

        // 🔥 Опция "Я ошиблась", если это 1-й день цикла!
        if (isDayOne) ...[
          const SizedBox(height: 12),
          _SheetOption(
            icon: CupertinoIcons.trash_circle_fill,
            title: "I made a mistake", // TODO: Добавить в L10n
            subtitle: "Remove period start",
            color: Colors.redAccent,
            onTap: onUndoTap,
          ),
        ]
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SHEET SCAFFOLD
// ─────────────────────────────────────────────────────────────────────────────

class _BaseSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _BaseSheet({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24, top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_ActionBarConstants.sheetBorderRadius),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _ActionBarConstants.handleWidth,
              height: _ActionBarConstants.handleHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED OPTION ROW
// ─────────────────────────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: _ActionBarConstants.optionIconSize,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}