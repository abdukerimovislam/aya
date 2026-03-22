import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/providers/cycle_provider.dart';
import '../../../data/providers/wellness_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/premium_glass_card.dart';

class _ActionBarConstants {
  static const int pulseTriggerDays = 3;
  static const int maxRetroactiveDays = 60;
  static const int snackbarDurationSeconds = 4;
  static const double snackbarBottomMargin = 100;
  static const double sheetBorderRadius = 32;
  static const double handleWidth = 48;
  static const double handleHeight = 5;
  static const double optionIconSize = 26;
}

class DashboardActionBar extends StatelessWidget {
  final CycleData data;
  final bool isCOC;
  final CycleProvider provider;
  final AppLocalizations l10n;
  final void Function(BuildContext context, DateTime date, String heroTag)
  onOpenLogger;

  const DashboardActionBar({
    super.key,
    required this.data,
    required this.isCOC,
    required this.provider,
    required this.l10n,
    required this.onOpenLogger,
  });

  @override
  Widget build(BuildContext context) {
    final wellness = context.watch<WellnessProvider>();
    final todayLog = wellness.getLogForDate(DateTime.now());

    final bool isBbtLogged =
        todayLog.temperature != null && todayLog.temperature! > 0.0;
    final bool isTestLogged =
    todayLog.symptoms.any((s) => s.startsWith('LH:') || s.startsWith('PT:'));
    final bool isSexLogged = todayLog.symptoms.any((s) => s.contains('Sex'));

    final _ActionConfig config = _resolveActionConfig(context);

    if (provider.isTTCMode) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PremiumGlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              borderRadius: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildTTCQuickAction(
                      context: context,
                      icon: CupertinoIcons.thermometer,
                      label: "Log BBT",
                      color: Colors.purple,
                      isLogged: isBbtLogged,
                      onTap: () =>
                          onOpenLogger(context, DateTime.now(), 'log_bbt'),
                    ),
                  ),
                  _buildTTCVerticalDivider(),
                  Expanded(
                    child: _buildTTCQuickAction(
                      context: context,
                      icon: CupertinoIcons.sparkles,
                      label: "Test",
                      color: Colors.pinkAccent,
                      isLogged: isTestLogged,
                      onTap: () =>
                          onOpenLogger(context, DateTime.now(), 'log_test'),
                    ),
                  ),
                  _buildTTCVerticalDivider(),
                  Expanded(
                    child: _buildTTCQuickAction(
                      context: context,
                      icon: CupertinoIcons.heart_fill,
                      label: "Sex",
                      color: Colors.redAccent,
                      isLogged: isSexLogged,
                      onTap: () =>
                          onOpenLogger(context, DateTime.now(), 'log_sex'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CycleActionCard(config: config),
        ],
      );
    }

    return _CycleActionCard(config: config);
  }

  Widget _buildTTCQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isLogged,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLogged ? color : color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: isLogged
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
                  : [],
            ),
            child: Icon(
              isLogged ? CupertinoIcons.check_mark : icon,
              color: isLogged ? Colors.white : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLogged ? "Logged" : label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isLogged ? FontWeight.w800 : FontWeight.bold,
              color: isLogged ? color : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTTCVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.black.withOpacity(0.05),
    );
  }

  _ActionConfig _resolveActionConfig(BuildContext context) {
    if (isCOC) {
      return _ActionConfig(
        title: l10n.logSymptomsTitle,
        subtitle: l10n.symptomSubHeader,
        icon: CupertinoIcons.add,
        isPrimaryFilled: true,
        isPulsing: false,
        showTodayBadge: false,
        onTap: () {
          HapticFeedback.lightImpact();
          onOpenLogger(context, DateTime.now(), 'log_sheet');
        },
      );
    }

    if (data.phase == CyclePhase.menstruation) {
      if (provider.isPeriodEnded) {
        return _ActionConfig(
          title: "Ending today",
          subtitle: "Tap if bleeding has stopped",
          icon: CupertinoIcons.check_mark_circled_solid,
          isPrimaryFilled: false,
          isPulsing: false,
          showTodayBadge: false,
          onTap: () => _showActivePeriodSheet(context),
        );
      }

      return _ActionConfig(
        title: "Day ${data.currentDay} of period",
        subtitle: "Tap to manage or log symptoms",
        icon: CupertinoIcons.drop_fill,
        isPrimaryFilled: true,
        isPulsing: false,
        showTodayBadge: false,
        onTap: () => _showActivePeriodSheet(context),
      );
    }

    final bool isPulsing =
        data.daysUntilNextPeriod <= _ActionBarConstants.pulseTriggerDays ||
            data.phase == CyclePhase.late;

    return _ActionConfig(
      title: "Start period",
      subtitle: "Log today, yesterday, or choose a date",
      icon: CupertinoIcons.drop_fill,
      isPrimaryFilled: true,
      isPulsing: isPulsing,
      showTodayBadge: true,
      onTap: () => _showPeriodInterceptorSheet(context),
    );
  }

  Future<void> _handleSmartPeriodStart(
      BuildContext context,
      DateTime selectedDate,
      ) async {
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

  void _showSuspiciouslyEarlyDialog(
      BuildContext context,
      DateTime selectedDate,
      ) {
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
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: Colors.orange,
              ),
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
        actionsPadding: const EdgeInsets.only(
          bottom: 16,
          right: 16,
          left: 16,
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await provider.logActionStartPeriod(
                selectedDate,
                isConfirmed: true,
              );
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
            firstDate: DateTime.now().subtract(
              const Duration(days: _ActionBarConstants.maxRetroactiveDays),
            ),
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
        isPeriodEnded: provider.isPeriodEnded,
        isDayOne: data.currentDay == 1,
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
          if (context.mounted) {
            _showSuccessSnackbar(context, "Period start removed");
          }
        },
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(message, AppColors.textPrimary.withOpacity(0.9)),
    );
  }

  void _showErrorSnackbar(
      BuildContext context, {
        String message = 'Error. Please try again.',
      }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(message, Colors.redAccent.withOpacity(0.9)),
    );
  }

  SnackBar _buildSnackbar(String message, Color bgColor) {
    return SnackBar(
      content: Text(
        message,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(
        seconds: _ActionBarConstants.snackbarDurationSeconds,
      ),
      margin: const EdgeInsets.only(
        bottom: _ActionBarConstants.snackbarBottomMargin,
        left: 20,
        right: 20,
      ),
    );
  }
}

class _CycleActionCard extends StatefulWidget {
  final _ActionConfig config;

  const _CycleActionCard({
    required this.config,
  });

  @override
  State<_CycleActionCard> createState() => _CycleActionCardState();
}

class _CycleActionCardState extends State<_CycleActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.028).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.config.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _CycleActionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.config.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.config.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEndingState =>
      widget.config.title.toLowerCase().contains('ending');

  @override
  Widget build(BuildContext context) {
    final bool isFilled = widget.config.isPrimaryFilled;
    final bool isEnding = _isEndingState;

    final Gradient backgroundGradient = isEnding
        ? const LinearGradient(
      colors: [
        Color(0xFFFFF1F5),
        Color(0xFFFFE4EC),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [
        Color(0xFFFF6FA1),
        Color(0xFFFF4D79),
        Color(0xFFE63E6D),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final Color titleColor = isEnding
        ? const Color(0xFF3C2A31)
        : Colors.white;

    final Color subtitleColor = isEnding
        ? const Color(0xFF8C6B75)
        : Colors.white.withOpacity(0.88);

    final Color borderColor = isEnding
        ? const Color(0xFFFFD3DE)
        : Colors.white.withOpacity(0.18);

    final List<BoxShadow> shadows = isEnding
        ? [
      BoxShadow(
        color: const Color(0xFFFFC7D4).withOpacity(0.35),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ]
        : [
      BoxShadow(
        color: const Color(0xFFE94057).withOpacity(
          widget.config.isPulsing ? _glowOpacity.value * 0.42 : 0.34,
        ),
        blurRadius: widget.config.isPulsing ? 30 : 24,
        spreadRadius: widget.config.isPulsing ? 2 : 1,
        offset: const Offset(0, 14),
      ),
      BoxShadow(
        color: const Color(0xFFFF8DB2).withOpacity(
          widget.config.isPulsing ? _glowOpacity.value * 0.24 : 0.18,
        ),
        blurRadius: 10,
        spreadRadius: -1,
        offset: const Offset(0, 4),
      ),
    ];

    Widget card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.3),
        boxShadow: shadows,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isEnding
                    ? const Color(0xFFFFD3DE)
                    : Colors.white.withOpacity(0.95),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              widget.config.icon,
              color: const Color(0xFFE94057),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.config.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.config.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (widget.config.showTodayBadge && !isEnding)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.24),
                ),
              ),
              child: Text(
                'TODAY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            )
          else
            Icon(
              CupertinoIcons.chevron_right,
              color: isEnding
                  ? const Color(0xFFC89AA8)
                  : Colors.white.withOpacity(0.82),
              size: 18,
            ),
        ],
      ),
    );

    if (widget.config.isPulsing && !isEnding) {
      card = AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: card,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.config.onTap();
        },
        child: card,
      ),
    );
  }
}

class _ActionConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimaryFilled;
  final bool isPulsing;
  final bool showTodayBadge;
  final VoidCallback onTap;

  const _ActionConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimaryFilled,
    required this.isPulsing,
    required this.showTodayBadge,
    required this.onTap,
  });
}

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
        if (isPeriodEnded)
          _SheetOption(
            icon: CupertinoIcons.play_circle_fill,
            title: "Resume period",
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
        if (isDayOne) ...[
          const SizedBox(height: 12),
          _SheetOption(
            icon: CupertinoIcons.trash_circle_fill,
            title: "I made a mistake",
            subtitle: "Remove period start",
            color: Colors.redAccent,
            onTap: onUndoTap,
          ),
        ],
      ],
    );
  }
}

class _BaseSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _BaseSheet({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 40,
        left: 24,
        right: 24,
        top: 12,
      ),
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
                color: Colors.grey,
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