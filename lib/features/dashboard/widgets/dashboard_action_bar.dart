import 'package:evimoon/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

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
  // Must match CycleConstants.minDaysBetweenCycles in cycle_provider.dart
  static const int minDaysBetweenCycles = 14;
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class DashboardActionBar extends StatelessWidget {
  final CycleData data;
  final bool isCOC;
  final CycleProvider provider;
  final void Function(BuildContext context, DateTime date, String heroTag) onOpenLogger;

  const DashboardActionBar({
    super.key,
    required this.data,
    required this.isCOC,
    required this.provider,
    required this.onOpenLogger, required AppLocalizations l10n,
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
        text: 'Start new pack',
        icon: CupertinoIcons.capsule_fill,
        textColor: Colors.white,
        bgColor: AppColors.primary,
        isPulsing: false,
        onTap: () => _handleStartNewCOCPack(context),
      );
    }

    if (data.phase == CyclePhase.menstruation) {
      return _ActionConfig(
        text: 'Period is active',
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
      text: 'Period started?',
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
    final DateTime currentCycleStart = provider.currentData.cycleStartDate;
    final int daysSinceStart = selectedDate.difference(currentCycleStart).inDays;

    try {
      await provider.logActionStartPeriod(selectedDate);
    } catch (e) {
      debugPrint('DashboardActionBar: logActionStartPeriod error: $e');
      if (context.mounted) _showErrorSnackbar(context);
      return;
    }

    if (!context.mounted) return;

    final String message = (daysSinceStart >= 0 &&
        daysSinceStart < _ActionBarConstants.minDaysBetweenCycles)
        ? 'Logged as spotting or continuation of your current period.'
        : 'New cycle started successfully.';

    _showSuccessSnackbar(context, message);
  }

  // ─── BOTTOM SHEETS ──────────────────────────────────────────────────────────

  void _showPeriodInterceptorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PeriodInterceptorSheet(
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

  void _showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(
        'Something went wrong. Please try again.',
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
  final VoidCallback onTodayTap;
  final VoidCallback onYesterdayTap;
  final VoidCallback onPickDateTap;

  const _PeriodInterceptorSheet({
    required this.onTodayTap,
    required this.onYesterdayTap,
    required this.onPickDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'When did it start?',
      children: [
        _SheetOption(
          icon: CupertinoIcons.calendar_today,
          title: 'Today',
          subtitle: 'Start cycle from today',
          color: AppColors.menstruation,
          onTap: onTodayTap,
        ),
        const SizedBox(height: 12),
        _SheetOption(
          icon: CupertinoIcons.arrow_counterclockwise_circle_fill,
          title: 'Yesterday',
          subtitle: 'Retroactively log period',
          color: AppColors.textSecondary,
          onTap: onYesterdayTap,
        ),
        const SizedBox(height: 12),
        _SheetOption(
          icon: CupertinoIcons.calendar,
          title: 'Pick a date...',
          subtitle: 'Choose from calendar',
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
  final VoidCallback onLogTap;
  final VoidCallback onEndTap;

  const _ActivePeriodSheet({
    required this.onLogTap,
    required this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Manage Period',
      children: [
        _SheetOption(
          icon: CupertinoIcons.add_circled_solid,
          title: 'Log flow & symptoms',
          subtitle: 'Record today\'s details',
          color: AppColors.primary,
          onTap: onLogTap,
        ),
        const SizedBox(height: 12),
        _SheetOption(
          icon: CupertinoIcons.check_mark_circled_solid,
          title: 'Period ended today',
          subtitle: 'Finish current bleeding',
          color: AppColors.textSecondary,
          onTap: onEndTap,
        ),
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