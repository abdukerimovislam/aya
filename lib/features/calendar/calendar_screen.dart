import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/intimacy_logging.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../logger/symptom_log_screen.dart';
import 'intimacy_calendar_screen.dart';

enum CalendarViewMode { month, cycle }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.month;
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();
    final l10n = AppLocalizations.of(context)!;

    final bool isTTC = cycleProvider.isTTCMode;
    final currentPhase = cycleProvider.currentData.phase;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    const bottomNavHeight = 88.0;
    final bottomContentPadding = bottomInset + bottomNavHeight + 20;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _buildViewToggle(),
        actions: [
          // 🔥 ИСПРАВЛЕНИЕ: Убрали if (isTTC), теперь кнопка интимного календаря доступна всем
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const IntimacyCalendarScreen(),
                  ),
                );
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.intimacy.withValues(alpha: 0.18),
                      AppColors.intimacy.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.heart_fill, // Красивое сердечко
                  color: AppColors.intimacy,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LivePhaseBackground(
              phase: currentPhase,
              isCOC: cycleProvider.isCOCEnabled,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: _buildStatusPanel(cycleProvider, l10n, isTTC),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _viewMode == CalendarViewMode.month
                        ? _buildMonthCalendar(
                      cycleProvider,
                      wellnessProvider,
                      l10n,
                      isTTC,
                      bottomContentPadding,
                    )
                        : _buildLinearCycleView(
                      cycleProvider,
                      wellnessProvider,
                      isTTC,
                      l10n,
                      bottomContentPadding,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(l10n.calendarViewMonth, CalendarViewMode.month),
          _buildToggleBtn(l10n.tabCycle, CalendarViewMode.cycle),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, CalendarViewMode mode) {
    final isActive = _viewMode == mode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _viewMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.56),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPanel(
      CycleProvider cycle,
      AppLocalizations l10n,
      bool isTTC,
      ) {
    final bool hasData = cycle.history.isNotEmpty || cycle.isCOCEnabled;

    String title = cycle.isCOCEnabled
        ? l10n.calendarPillDay(cycle.currentData.dayOfCycle)
        : l10n.dayOfCycle(cycle.currentData.dayOfCycle);
    String phaseName = _getPhaseName(
      cycle.currentData.phase,
      cycle.isCOCEnabled,
      isTTC,
      l10n,
    );

    String forecast = cycle.isCOCEnabled
        ? l10n.calendarDaysToBreak(cycle.currentData.daysToNextPeriod)
        : l10n.calendarDaysToPeriod(cycle.currentData.daysToNextPeriod);

    if (isTTC && hasData) {
      if (cycle.currentData.phase == CyclePhase.follicular) {
        final int daysToFertile =
        math.max(0, cycle.ovulationDay - 5 - cycle.currentData.dayOfCycle);
        forecast = l10n.calendarDaysToFertileWindow(daysToFertile);
      } else if (cycle.currentData.phase == CyclePhase.luteal) {
        forecast = l10n.calendarDaysToTestDay(cycle.currentData.daysToNextPeriod);
      }
    }

    if (!hasData) {
      title = l10n.calendarWelcomeTitle;
      phaseName = l10n.calendarTrackingPaused;
      forecast = l10n.calendarAddFirstPeriodBody;
    }

    final Color accentColor = cycle.isCOCEnabled
        ? AppColors.follicular
        : isTTC
        ? AppColors.ovulationStrong
        : AppColors.primary;

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      borderRadius: 28,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.22),
                  accentColor.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              cycle.isCOCEnabled
                  ? CupertinoIcons.circle_grid_3x3_fill
                  : isTTC
                  ? CupertinoIcons.sparkles
                  : CupertinoIcons.drop_fill,
              size: 22,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  phaseName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        forecast,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseName(
      CyclePhase phase,
      bool isCOC,
      bool isTTC,
      AppLocalizations l10n,
      ) {
    if (isCOC) {
      return phase == CyclePhase.menstruation
          ? l10n.cocBreakPhase
          : l10n.cocActivePhase;
    }
    if (isTTC && phase == CyclePhase.luteal) {
      return l10n.calendarTwoWeekWaitTtc;
    }

    switch (phase) {
      case CyclePhase.menstruation:
        return l10n.phaseMenstruation;
      case CyclePhase.follicular:
        return l10n.phaseFollicular;
      case CyclePhase.ovulation:
        return l10n.phaseOvulation;
      case CyclePhase.luteal:
        return l10n.phaseLuteal;
      case CyclePhase.late:
        return l10n.phaseLate;
    }
  }

  void _showQuickActionMenu(
      BuildContext context,
      DateTime date,
      WellnessProvider wellness,
      ) {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          DateFormat('EEEE, MMM d').format(date).toUpperCase(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        message: Text(l10n.calendarIntimacyQuickLog),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColors.intimacy,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.calendarLogUnprotectedSex,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _quickLogIntimacy(date, wellness, 'Unprotected Sex');
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.shield_fill,
                  color: Color(0xFF5FA8D3),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.calendarLogProtectedSex,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _quickLogIntimacy(date, wellness, 'Protected Sex');
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.square_list,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.calendarOpenFullLogger,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _openFullLogger(context, date);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.btnCancel,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _quickLogIntimacy(
    DateTime date,
    WellnessProvider wellness,
    String intimacyType,
  ) async {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context)!;
    final log = wellness.getLogForDate(date);
    final updatedSymptoms = toggleIntimacySymptoms(log.symptoms, intimacyType);
    final wasLogged = updatedSymptoms.contains(intimacyType);

    await wellness.saveLog(log.copyWith(symptoms: updatedSymptoms));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasLogged
                ? l10n.calendarIntimacyLogged(DateFormat('MMM d').format(date))
                : l10n.calendarIntimacyRemoved(DateFormat('MMM d').format(date)),
          ),
          backgroundColor: AppColors.intimacy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  void _openFullLogger(BuildContext context, DateTime date) {
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: SizedBox(
          height: screenHeight * 0.92,
          child: SymptomLogScreen(date: date),
        ),
      ),
    );
  }

  Widget _buildMonthCalendar(
      CycleProvider cycle,
      WellnessProvider wellness,
      AppLocalizations l10n,
      bool isTTC,
      double bottomContentPadding,
      ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: bottomContentPadding),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: PremiumGlassCard(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
            borderRadius: 28,
            child: TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2035, 12, 31),
              focusedDay: _focusedDate,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableGestures: AvailableGestures.horizontalSwipe,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
              },
              onDayLongPressed: (selectedDay, focusedDay) {
                HapticFeedback.heavyImpact();
                _showQuickActionMenu(context, selectedDay, wellness);
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDate = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 10),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              daysOfWeekHeight: 28,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                weekendStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                ),
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.transparent),
                weekendTextStyle: TextStyle(color: Colors.transparent),
                todayTextStyle: TextStyle(color: Colors.transparent),
                selectedTextStyle: TextStyle(color: Colors.transparent),
                outsideDaysVisible: false,
                cellMargin: EdgeInsets.zero,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _buildDayCell(
                  day,
                  cycle,
                  wellness,
                  isSelected: false,
                  isTTC: isTTC,
                ),
                todayBuilder: (context, day, focusedDay) => _buildDayCell(
                  day,
                  cycle,
                  wellness,
                  isSelected: false,
                  isToday: true,
                  isTTC: isTTC,
                ),
                selectedBuilder: (context, day, focusedDay) => _buildDayCell(
                  day,
                  cycle,
                  wellness,
                  isSelected: true,
                  isTTC: isTTC,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(cycle.isCOCEnabled, isTTC),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _DaySummaryCard(
            date: _selectedDate,
            cycleProvider: cycle,
            wellnessProvider: wellness,
            l10n: l10n,
            isTTC: isTTC,
            onOpenLogger: () => _openFullLogger(context, _selectedDate),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(bool isCOC, bool isTTC) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        borderRadius: 22,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 10,
          children: [
            _buildLegendItem(
              isCOC ? l10n.calendarLoggedBreak : l10n.calendarLoggedPeriod,
              AppColors.menstruation,
            ),
            _buildLegendItem(
              l10n.calendarPredictedPeriod,
              Colors.transparent,
              borderColor: AppColors.menstruation.withValues(alpha: 0.48),
            ),
            if (!isCOC) ...[
              _buildLegendItem(
                isTTC ? l10n.calendarFertileWindow : l10n.legendFertile,
                AppColors.follicular.withValues(alpha: 0.45),
              ),
              _buildLegendItem(
                l10n.legendOvulation,
                AppColors.ovulation.withValues(alpha: 0.25),
                dotColor: AppColors.ovulationStrong,
              ),
              _buildLegendItem(
                l10n.calendarHasLog,
                AppColors.textSecondary.withValues(alpha: 0.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
      String title,
      Color bgColor, {
        Color? dotColor,
        Color? borderColor,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: dotColor != null
              ? Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          )
              : null,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
      DateTime day,
      CycleProvider cycle,
      WellnessProvider wellness, {
        bool isSelected = false,
        bool isToday = false,
        required bool isTTC,
      }) {
    final phase = cycle.getPhaseForDate(day);
    final hasLogs = wellness.hasLogForDate(day);
    final log = hasLogs ? wellness.getLogForDate(day) : null;

    Color bgColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    Color? outlineColor;
    bool isPredictedPeriod = false;
    bool showOvulationDot = false;

    bool hasSex = false;
    bool hasBBT = false;
    bool hasAnyLog = false;

    if (log != null) {
      hasAnyLog = true;
      hasSex = log.hasAnyIntimacy;
      hasBBT = log.temperature != null && log.temperature! > 0;
    }

    if (phase == CyclePhase.menstruation) {
      if (log != null && log.flow != FlowIntensity.none) {
        bgColor = AppColors.periodStrong;
        textColor = Colors.white;
      } else {
        isPredictedPeriod = true;
        textColor = AppColors.periodStrong;
      }
    } else if (phase == CyclePhase.follicular && !cycle.isCOCEnabled) {
      bgColor = AppColors.follicular.withValues(alpha: 0.20);
      textColor = const Color(0xFF3A7C73);
    } else if (phase == CyclePhase.ovulation && !cycle.isCOCEnabled) {
      bgColor = isTTC
          ? AppColors.ovulationStrong
          : AppColors.ovulation.withValues(alpha: 0.26);
      textColor = isTTC ? Colors.white : AppColors.ovulationStrong;
      showOvulationDot = !isTTC;
    } else if (phase == CyclePhase.luteal && isTTC) {
      bgColor = AppColors.ovulationSoft.withValues(alpha: 0.35);
      textColor = AppColors.ovulationStrong;
    }

    if (isSelected) {
      outlineColor = AppColors.primary.withValues(alpha: 0.52);
    } else if (isToday) {
      outlineColor = AppColors.textSecondary.withValues(alpha: 0.24);
    }

    Widget bottomMarkers() {
      if (!hasAnyLog) return const SizedBox.shrink();

      final List<Widget> markers = [];

      if (hasBBT) {
        markers.add(Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.ovulationStrong,
            shape: BoxShape.circle,
          ),
        ));
      }

      if (hasSex) {
        markers.add(Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.intimacy,
            shape: BoxShape.circle,
          ),
        ));
      }

      if (!hasBBT && !hasSex) {
        markers.add(Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        ));
      }

      final children = <Widget>[];
      for (int i = 0; i < markers.length; i++) {
        children.add(markers[i]);
        if (i != markers.length - 1) {
          children.add(const SizedBox(width: 3));
        }
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    final baseChild = Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '${day.day}',
          style: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight:
            isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
          ),
        ),
        if (showOvulationDot)
          Positioned(
            top: 5,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        Positioned(
          bottom: 5,
          child: bottomMarkers(),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPredictedPeriod
              ? AppColors.periodStrong.withValues(alpha: 0.44)
              : (outlineColor ?? Colors.transparent),
          width: isSelected ? 2 : (isPredictedPeriod ? 1.4 : 1.1),
        ),
      ),
      child: isPredictedPeriod
          ? DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.periodSoft.withValues(alpha: 0.32),
        ),
        child: baseChild,
      )
          : baseChild,
    );
  }

  // 🔥 ПОЛНОСТЬЮ ПЕРЕПИСАННЫЙ CYCLE VIEW
  Widget _buildLinearCycleView(
      CycleProvider cycle,
      WellnessProvider wellness,
      bool isTTC,
      AppLocalizations l10n,
      double bottomContentPadding,
      ) {
    final bool hasEnoughData = cycle.history.length >= 2 || cycle.isCOCEnabled;

    if (!hasEnoughData && cycle.history.isEmpty) {
      return _buildEmptyState(
        l10n.calendarNeedMoreTimelineData,
        CupertinoIcons.chart_bar_alt_fill,
      );
    }

    final startDate = cycle.currentData.cycleStartDate;
    final length = cycle.cycleLength > 0 ? cycle.cycleLength : 28;
    final currentDayNum = cycle.currentData.currentDay;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomContentPadding),
      children: [
        // 1. ГОРИЗОНТАЛЬНЫЙ ТАЙМЛАЙН ТЕКУЩЕГО ЦИКЛА
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            l10n.calendarCurrentCycleTimeline,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: length,
            itemBuilder: (context, index) {
              final int dayNum = index + 1;
              final DateTime date = startDate.add(Duration(days: index));
              final bool isToday = dayNum == currentDayNum;

              final phase = cycle.getPhaseForDate(date);
              final log = wellness.getLogForDate(date);
              final hasFlow = log.flow != FlowIntensity.none;

              Color cardColor = AppColors.surface;
              Color textColor = AppColors.textPrimary;
              Color accentColor = AppColors.textSecondary;
              String phaseLabel = l10n.calendarNormalPhase;

              if (phase == CyclePhase.menstruation) {
                cardColor = hasFlow ? AppColors.menstruation : AppColors.periodSoft;
                textColor = hasFlow ? Colors.white : AppColors.menstruation;
                accentColor = hasFlow ? Colors.white : AppColors.menstruation;
                phaseLabel = l10n.legendPeriod;
              } else if (phase == CyclePhase.follicular && !cycle.isCOCEnabled) {
                cardColor = AppColors.follicular.withValues(alpha: 0.3);
                textColor = const Color(0xFF3A7C73);
                accentColor = const Color(0xFF3A7C73);
                phaseLabel = l10n.legendFollicular;
              } else if (phase == CyclePhase.ovulation && !cycle.isCOCEnabled) {
                cardColor = isTTC ? AppColors.ovulationStrong : AppColors.ovulationSoft;
                textColor = isTTC ? Colors.white : AppColors.ovulationStrong;
                accentColor = isTTC ? Colors.white : AppColors.ovulationStrong;
                phaseLabel = l10n.legendOvulation;
              } else if (phase == CyclePhase.luteal) {
                phaseLabel = l10n.legendLuteal;
                cardColor = AppColors.luteal.withValues(alpha: 0.3);
                textColor = AppColors.textPrimary;
                accentColor = AppColors.luteal;
              } else if (phase == CyclePhase.late) {
                phaseLabel = l10n.phaseLate;
                cardColor = AppColors.late.withValues(alpha: 0.3);
                textColor = const Color(0xFF8F651E);
                accentColor = AppColors.late;
              }

              return Container(
                width: 72,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : Border.all(color: AppColors.divider, width: 1),
                  boxShadow: [
                    if (isToday)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase(), // ПН, ВТ...
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${date.day}",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.calendarTimelineDay(dayNum),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phaseLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 32),

        // 2. ДЕТАЛЬНАЯ СВОДКА (STATISTICS)
        if (hasEnoughData) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.calendarYourAverages,
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildCycleStatistics(cycle, l10n),
        ],

        const SizedBox(height: 32),

        // 3. ИНТЕРАКТИВНЫЙ ГРАФИК ЦИКЛОВ (С РАЗБИВКОЙ НА ФАЗЫ)
        if (hasEnoughData) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.calendarRecentCycles,
                  style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PremiumGlassCard(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              borderRadius: 24,
              child: SizedBox(
                height: 240, // Чуть выше для легенды
                child: _buildCycleBarChart(cycle),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.softShadow, blurRadius: 20)],
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 НОВЫЙ БЛОК СО СТАТИСТИКОЙ
  Widget _buildCycleStatistics(CycleProvider cycle, AppLocalizations l10n) {
    // Считаем регулярность (вариативность)
    String regularityStatus = l10n.factorStable;
    Color regularityColor = AppColors.success;

    if (cycle.history.length >= 3) {
      final lengths = cycle.history.map((e) => e.length ?? cycle.cycleLength).toList();
      final maxLen = lengths.reduce(math.max);
      final minLen = lengths.reduce(math.min);
      final variation = maxLen - minLen;

      if (variation > 9) {
        regularityStatus = l10n.factorHighVar;
        regularityColor = AppColors.error;
      } else if (variation > 5) {
        regularityStatus = l10n.factorSlightVar;
        regularityColor = AppColors.warning;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: PremiumGlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.arrow_2_circlepath, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(l10n.lblCycleLength, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("${cycle.cycleLength}", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text(" ${l10n.daysUnit}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: regularityColor, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(regularityStatus, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PremiumGlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.drop_fill, size: 14, color: AppColors.menstruation),
                      const SizedBox(width: 6),
                      Text(l10n.lblPeriodLength, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("${cycle.avgPeriodDuration}", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text(" ${l10n.daysUnit}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.calendarBasedOnRecentLogs, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ОБНОВЛЕННЫЙ ГРАФИК ЦИКЛОВ (С РАЗБИВКОЙ НА ФАЗЫ)
  // 🔥 ОБНОВЛЕННЫЙ ГРАФИК ЦИКЛОВ (С РАЗБИВКОЙ НА ФАЗЫ)
  Widget _buildCycleBarChart(CycleProvider cycle) {
    final l10n = AppLocalizations.of(context)!;
    final history = cycle.history.reversed.take(6).toList().reversed.toList();
    final avgCycle = cycle.cycleLength.toDouble();
    final avgPeriod = cycle.avgPeriodDuration.toDouble();

    // 🔥 ИСПРАВЛЕНИЕ: Динамический maxY для поддержки длинных циклов (PCOS)
    double maxRecordedLength = 40.0;
    for (var c in history) {
      if (c.length != null && c.length! > maxRecordedLength) {
        maxRecordedLength = c.length!.toDouble();
      }
    }
    final double chartMaxY = maxRecordedLength + 5.0; // Даем запас сверху

    const double lutealLength = 14.0;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMaxY, // 🔥 Применили динамический лимит!
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (event.isInterestedForInteractions) {
                    HapticFeedback.selectionClick();
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: AppColors.textPrimary,
                  tooltipRoundedRadius: 8,
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final cycleLen = rod.toY.toInt();
                    return BarTooltipItem(
                      "$cycleLen ${l10n.daysUnit}",
                      GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final monthName = DateFormat('MMM').format(history[value.toInt()].startDate);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          monthName, // Показываем месяц вместо "C1"
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 10,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: avgCycle,
                    color: AppColors.primary.withValues(alpha: 0.3),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 0, bottom: 4),
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary.withValues(alpha: 0.5)),
                      labelResolver: (_) => l10n.calendarAvgShort,
                    ),
                  ),
                ],
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: AppColors.divider, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(history.length, (index) {
                final cycleItem = history[index];
                final double cycleLength = cycleItem.length?.toDouble() ?? avgCycle;

                // Считаем доли фаз в столбике
                final double periodDays = cycleItem.periodDuration?.toDouble() ?? avgPeriod;
                // Фолликулярная = общая длина - месячные - лютеиновая
                final double follicularDays = math.max(0, cycleLength - periodDays - lutealLength);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: cycleLength,
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                      // 🔥 Разбиваем столбик на секции фаз!
                      rodStackItems: [
                        BarChartRodStackItem(0, periodDays, AppColors.menstruation), // Низ - Месячные
                        BarChartRodStackItem(periodDays, periodDays + follicularDays, AppColors.follicular), // Середина - Фолликулярная
                        BarChartRodStackItem(periodDays + follicularDays, cycleLength, AppColors.luteal), // Верх - Лютеиновая
                      ],
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 40,
                        color: AppColors.background,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Легенда графика
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGraphLegend(l10n.legendPeriod, AppColors.menstruation),
            const SizedBox(width: 12),
            _buildGraphLegend(l10n.legendFollicular, AppColors.follicular),
            const SizedBox(width: 12),
            _buildGraphLegend(l10n.legendLuteal, AppColors.luteal),
          ],
        )
      ],
    );
  }

  Widget _buildGraphLegend(String text, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  final DateTime date;
  final CycleProvider cycleProvider;
  final WellnessProvider wellnessProvider;
  final AppLocalizations l10n;
  final bool isTTC;
  final VoidCallback onOpenLogger;

  const _DaySummaryCard({
    required this.date,
    required this.cycleProvider,
    required this.wellnessProvider,
    required this.l10n,
    required this.isTTC,
    required this.onOpenLogger,
  });

  @override
  Widget build(BuildContext context) {
    final phase = cycleProvider.getPhaseForDate(date);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cleanDate = DateTime(date.year, date.month, date.day);
    final isFuture = cleanDate.isAfter(today);

    final hasLogs = wellnessProvider.hasLogForDate(date);

    String phaseText = l10n.legendPredictedPeriod;
    Color phaseColor = AppColors.textSecondary;
    String subText = l10n.lblNoSymptoms;

    if (phase != null) {
      if (cycleProvider.isCOCEnabled) {
        phaseText = phase == CyclePhase.menstruation
            ? l10n.cocBreakPhase
            : l10n.cocActivePhase;
        phaseColor = phase == CyclePhase.menstruation
            ? AppColors.menstruation
            : AppColors.follicular;
      } else {
        switch (phase) {
          case CyclePhase.menstruation:
            phaseText = l10n.phaseMenstruation;
            phaseColor = AppColors.menstruation;
            break;
          case CyclePhase.follicular:
            phaseText = l10n.phaseFollicular;
            phaseColor = AppColors.follicular;
            break;
          case CyclePhase.ovulation:
            phaseText = isTTC ? l10n.calendarPeakOvulation : l10n.phaseOvulation;
            phaseColor =
            isTTC ? AppColors.ovulationStrong : AppColors.ovulation;
            break;
          case CyclePhase.luteal:
            phaseText = isTTC ? l10n.calendarTwoWeekWait : l10n.phaseLuteal;
            phaseColor = AppColors.luteal;
            break;
          case CyclePhase.late:
            phaseText = isTTC ? l10n.calendarTestDay : l10n.phaseLate;
            phaseColor = AppColors.late;
            break;
        }
      }
    }

    if (hasLogs) {
      final log = wellnessProvider.getLogForDate(date);
      final List<String> loggedItems = [];

      if (log.flow != FlowIntensity.none) loggedItems.add(l10n.calendarLoggedBleeding);
      if (log.temperature != null && log.temperature! > 0) {
        loggedItems.add(l10n.calendarBbtLogged(log.temperature!.toString()));
      }
      if (log.hasAnyIntimacy) {
        loggedItems.add(l10n.lblIntimacy);
      }
      if (log.symptoms.any((s) => s.startsWith("LH:"))) {
        loggedItems.add(l10n.calendarOpkLogged);
      }

      if (loggedItems.isNotEmpty) {
        subText = loggedItems.join(" • ");
      } else {
        subText = l10n.calendarSymptomsLogged;
      }
    } else if (isFuture) {
      subText = l10n.calendarPrediction;
    }

    final Color ctaColor =
    isTTC ? AppColors.ovulationStrong : AppColors.primary;

    return PremiumGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d', l10n.localeName)
                      .format(date)
                      .toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: phaseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phaseText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      hasLogs
                          ? CupertinoIcons.checkmark_seal_fill
                          : CupertinoIcons.circle,
                      size: 14,
                      color: hasLogs
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        subText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: hasLogs
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isFuture)
            GestureDetector(
              onTap: onOpenLogger,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ctaColor.withValues(alpha: 0.96),
                      ctaColor.withValues(alpha: 0.84),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ctaColor.withValues(alpha: 0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
