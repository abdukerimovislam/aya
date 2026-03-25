import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/intimacy_logging.dart';
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
    final bool isSexLogged = todayLog.hasAnyIntimacy;

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
                      label: l10n.ttcBtnBBT,
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
                      label: l10n.ttcBtnTest,
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
                      label: l10n.ttcBtnSex,
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
              color: isLogged ? color : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: isLogged
                  ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
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
            isLogged ? l10n.dashboardActionLogged : label,
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
      color: Colors.black.withValues(alpha: 0.05),
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
          title: l10n.dashboardPeriodEndingTitle,
          subtitle: l10n.dashboardPeriodEndingBody,
          icon: CupertinoIcons.check_mark_circled_solid,
          isPrimaryFilled: false,
          isPulsing: false,
          showTodayBadge: false,
          onTap: () => _showActivePeriodSheet(context),
        );
      }

      return _ActionConfig(
        title: l10n.dashboardPeriodDayTitle(data.currentDay),
        subtitle: l10n.dashboardPeriodDayBody,
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
      title: l10n.dashboardStartPeriodTitle,
      subtitle: l10n.dashboardStartPeriodBody,
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
        _showErrorSnackbar(context, message: l10n.dashboardFutureDateError);
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
                color: Colors.orange.withValues(alpha: 0.1),
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
                l10n.alertDeleteTitle,
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
          l10n.dashboardShortCycleSpottingBody,
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
              l10n.symptomLogJustSpottingAction,
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
              l10n.dashboardNewPeriodAction,
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
            _showSuccessSnackbar(context, l10n.dashboardPeriodStartRemoved);
          }
        },
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(message, AppColors.textPrimary.withValues(alpha: 0.9)),
    );
  }

  void _showErrorSnackbar(
      BuildContext context, {
        String message = 'Error. Please try again.',
      }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackbar(message, Colors.redAccent.withValues(alpha: 0.9)),
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
        : Colors.white.withValues(alpha: 0.88);

    final Color borderColor = isEnding
        ? const Color(0xFFFFD3DE)
        : Colors.white.withValues(alpha: 0.18);

    final List<BoxShadow> shadows = isEnding
        ? [
      BoxShadow(
        color: const Color(0xFFFFC7D4).withValues(alpha: 0.35),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ]
        : [
      BoxShadow(
        color: const Color(0xFFE94057).withValues(alpha: 
          widget.config.isPulsing ? _glowOpacity.value * 0.42 : 0.34,
        ),
        blurRadius: widget.config.isPulsing ? 30 : 24,
        spreadRadius: widget.config.isPulsing ? 2 : 1,
        offset: const Offset(0, 14),
      ),
      BoxShadow(
        color: const Color(0xFFFF8DB2).withValues(alpha: 
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
                    : Colors.white.withValues(alpha: 0.95),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
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
                  : Colors.white.withValues(alpha: 0.82),
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
        // 🔥 Главное действие - Градиентная кнопка (как основная)
        _SheetOption(
          icon: CupertinoIcons.calendar_today,
          title: l10n.btnToday,
          subtitle: l10n.dialogStartBody,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6FA1), Color(0xFFFF4D79), Color(0xFFE63E6D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: const Color(0xFFE94057),
          onTap: onTodayTap,
        ),
        const SizedBox(height: 12),
        // Вторичные действия - приглушенные, но тоже премиальные
        _SheetOption(
          icon: CupertinoIcons.arrow_counterclockwise_circle_fill,
          title: l10n.btnYesterday,
          subtitle: l10n.onboardDateTitleCycle,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B7EC3), Color(0xFF7C6A9A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: const Color(0xFF6B5A93),
          onTap: onYesterdayTap,
        ),
        const SizedBox(height: 12),
        _SheetOption(
          icon: CupertinoIcons.calendar,
          title: l10n.btnPickDate,
          subtitle: l10n.pdfTableDate,
          gradient: const LinearGradient(
            colors: [Color(0xFFBCAAA4), Color(0xFF9E8A84)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: const Color(0xFF8D7A74),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF8B7EC3), Color(0xFF6B5A93)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: const Color(0xFF6B5A93),
          onTap: onLogTap,
        ),
        const SizedBox(height: 12),
        if (isPeriodEnded)
          _SheetOption(
            icon: CupertinoIcons.play_circle_fill,
            title: l10n.dashboardResumePeriodTitle,
            subtitle: l10n.dashboardResumePeriodBody,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconColor: const Color(0xFFE65100),
            onTap: onResumeTap,
          )
        else
          _SheetOption(
            icon: CupertinoIcons.check_mark_circled_solid,
            title: l10n.btnPeriodEnd,
            subtitle: l10n.dialogEndBody,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6FA1), Color(0xFFE63E6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconColor: const Color(0xFFE94057),
            onTap: onEndTap,
          ),
        if (isDayOne) ...[
          const SizedBox(height: 12),
          _SheetOption(
            icon: CupertinoIcons.trash_circle_fill,
            title: l10n.dashboardMistakeTitle,
            subtitle: l10n.dashboardMistakeBody,
            gradient: const LinearGradient(
              colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconColor: const Color(0xFFB71C1C),
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
        color: AppColors.background, // Используем фон из темы
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
                color: AppColors.textSecondary.withValues(alpha: 0.3),
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

// 🔥 ОБНОВЛЕННЫЙ КОМПОНЕНТ ДЛЯ МЕНЮ
class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient, // Используем градиент как у главной кнопки
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.3
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Белый кружок с цветной иконкой (как в главной карточке)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.95),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
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
                      fontWeight: FontWeight.w800,
                      color: Colors.white, // Белый текст
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85), // Белый полупрозрачный подзаголовок
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
