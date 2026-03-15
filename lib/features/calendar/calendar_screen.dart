import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../l10n/app_localizations.dart';
import '../logger/symptom_log_screen.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _buildViewToggle(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildStatusPanel(cycleProvider, l10n, isTTC),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _viewMode == CalendarViewMode.month
                        ? _buildMonthCalendar(cycleProvider, wellnessProvider, l10n, isTTC)
                        : _buildLinearCycleView(cycleProvider, wellnessProvider, isTTC, l10n),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn("Month", CalendarViewMode.month),
          _buildToggleBtn("Cycle", CalendarViewMode.cycle),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            color: isActive ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPanel(CycleProvider cycle, AppLocalizations l10n, bool isTTC) {
    bool hasData = cycle.history.isNotEmpty || cycle.isCOCEnabled;

    String title = cycle.isCOCEnabled ? "Pill Day ${cycle.currentData.dayOfCycle}" : "Day ${cycle.currentData.dayOfCycle}";
    String phaseName = _getPhaseName(cycle.currentData.phase, cycle.isCOCEnabled, isTTC, l10n);

    String forecast = cycle.isCOCEnabled
        ? "~${cycle.currentData.daysToNextPeriod} days to break"
        : "~${cycle.currentData.daysToNextPeriod} days to period";

    if (isTTC && hasData) {
      if (cycle.currentData.phase == CyclePhase.follicular) {
        int daysToFertile = math.max(0, cycle.ovulationDay - 5 - cycle.currentData.dayOfCycle);
        forecast = "~$daysToFertile days to fertile window";
      } else if (cycle.currentData.phase == CyclePhase.luteal) {
        forecast = "~${cycle.currentData.daysToNextPeriod} days to test day";
      }
    }

    if (!hasData) {
      title = "Welcome to Ayla";
      phaseName = "Tracking paused";
      forecast = "Add first day of your period to start.";
    }

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(phaseName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isTTC ? Colors.purple : AppColors.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(CupertinoIcons.sparkles, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(forecast, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  String _getPhaseName(CyclePhase phase, bool isCOC, bool isTTC, AppLocalizations l10n) {
    if (isCOC) return phase == CyclePhase.menstruation ? l10n.cocBreakPhase : l10n.cocActivePhase;
    if (isTTC && phase == CyclePhase.luteal) return "Two Week Wait (TWW)";

    switch (phase) {
      case CyclePhase.menstruation: return l10n.phaseMenstruation;
      case CyclePhase.follicular: return l10n.phaseFollicular;
      case CyclePhase.ovulation: return l10n.phaseOvulation;
      case CyclePhase.luteal: return l10n.phaseLuteal;
      case CyclePhase.late: return l10n.phaseLate;
    }
  }

  void _showQuickActionMenu(BuildContext context, DateTime date, CycleProvider cycle, WellnessProvider wellness) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(DateFormat('EEEE, MMM d').format(date).toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1)),
        message: const Text('Quick Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.drop_fill, color: AppColors.menstruation, size: 20),
                const SizedBox(width: 8),
                Text('Log Period', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              cycle.togglePeriodDay(date);
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.thermometer, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text('Log Temp & Tests', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _openFullLogger(context, date);
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.heart_fill, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                Text('Log Intimacy', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
          child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // 🔥 ИСПРАВЛЕННЫЙ МЕТОД (Безопасный MediaQuery)
  void _openFullLogger(BuildContext context, DateTime date) {
    final screenHeight = MediaQuery.of(context).size.height; // Вычисляем ДО билдера

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: SizedBox(
          height: screenHeight * 0.92, // Используем безопасную переменную
          child: SymptomLogScreen(date: date),
        ),
      ),
    );
  }

  Widget _buildMonthCalendar(CycleProvider cycle, WellnessProvider wellness, AppLocalizations l10n, bool isTTC) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PremiumGlassCard(
            padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8, top: 4),
            borderRadius: 24,
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
                _showQuickActionMenu(context, selectedDay, cycle, wellness);
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDate = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                leftChevronIcon: Icon(CupertinoIcons.chevron_left, color: AppColors.textPrimary, size: 24),
                rightChevronIcon: Icon(CupertinoIcons.chevron_right, color: AppColors.textPrimary, size: 24),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                weekendStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary.withOpacity(0.5)),
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.transparent),
                weekendTextStyle: TextStyle(color: Colors.transparent),
                todayTextStyle: TextStyle(color: Colors.transparent),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, cycle, wellness, isSelected: false, isTTC: isTTC),
                todayBuilder: (context, day, focusedDay) => _buildDayCell(day, cycle, wellness, isSelected: false, isToday: true, isTTC: isTTC),
                selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, cycle, wellness, isSelected: true, isTTC: isTTC),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildLegend(cycle.isCOCEnabled, isTTC),
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        borderRadius: 20,
        child: Row(
          mainAxisAlignment: isCOC ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(isCOC ? "Break" : "Period", Colors.redAccent.withOpacity(0.8)),
            if (!isCOC) ...[
              _buildLegendItem(
                  isTTC ? "Fertile Window" : "Fertile",
                  isTTC ? Colors.pinkAccent.withOpacity(0.15) : AppColors.primary.withOpacity(0.15)
              ),
              _buildLegendItem(
                  isTTC ? "Peak Ovulation" : "Ovulation",
                  isTTC ? Colors.purple : AppColors.primary.withOpacity(0.25),
                  dotColor: isTTC ? null : AppColors.primary
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color bgColor, {Color? dotColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: Colors.black.withOpacity(0.05))),
          child: dotColor != null ? Center(child: Container(width: 4, height: 4, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle))) : null,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  DayType _getCorrectDayType(DateTime date, CycleProvider cycle) {
    final normDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(
        cycle.currentData.cycleStartDate.year,
        cycle.currentData.cycleStartDate.month,
        cycle.currentData.cycleStartDate.day
    );

    int diff = normDate.difference(start).inDays;
    int length = cycle.cycleLength;
    if (length <= 0) length = 28;

    if (diff < 0) {
      return cycle.getDayType(date);
    }

    int dayOfCycle = (diff % length) + 1;

    if (cycle.isCOCEnabled) {
      final active = 21;
      final total = 28;
      if (dayOfCycle > active && dayOfCycle <= total) return DayType.period;
      return DayType.none;
    }

    if (dayOfCycle <= cycle.periodDuration) return DayType.period;

    int ovDay = cycle.ovulationDay;
    if (dayOfCycle == ovDay) return DayType.ovulation;
    if (dayOfCycle >= ovDay - 5 && dayOfCycle < ovDay) return DayType.fertile;

    return DayType.none;
  }

  Widget _buildDayCell(DateTime day, CycleProvider cycle, WellnessProvider wellness, {bool isSelected = false, bool isToday = false, required bool isTTC}) {
    final dayType = _getCorrectDayType(day, cycle);
    final hasLogs = wellness.hasLogForDate(day);
    final log = hasLogs ? wellness.getLogForDate(day) : null;

    final cleanDay = DateTime(day.year, day.month, day.day);
    final cleanToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    Color bgColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    bool showDot = false;
    Color dotColor = Colors.transparent;

    String? dpoText;
    bool hasSex = false;
    bool hasBBT = false;
    String? emojiMarker;

    if (log != null) {
      if (log.symptoms.contains('Unprotected Sex') || log.symptoms.contains('Protected Sex')) hasSex = true;
      if (log.temperature != null && log.temperature! > 0) hasBBT = true;

      if (log.painSymptoms.contains('Cramps')) emojiMarker = '😣';
      else if (log.symptoms.contains('Spotting')) emojiMarker = '🩸';
      else if (log.painSymptoms.contains('Headache')) emojiMarker = '🤕';
      else if (log.symptoms.contains('Crying Spells') || log.mood <= 2) emojiMarker = '💧';
      else if (log.symptoms.contains('High Stress')) emojiMarker = '⚡';
    }

    if (isTTC && dayType == DayType.none) {
      final normDate = DateTime(day.year, day.month, day.day);
      final start = DateTime(cycle.currentData.cycleStartDate.year, cycle.currentData.cycleStartDate.month, cycle.currentData.cycleStartDate.day);
      int diff = normDate.difference(start).inDays;
      int length = cycle.cycleLength;
      if (length <= 0) length = 28;

      if (diff >= 0) {
        int dayOfCycle = (diff % length) + 1;
        int ovDay = cycle.ovulationDay;
        if (dayOfCycle > ovDay && dayOfCycle <= length) {
          int dpo = dayOfCycle - ovDay;
          if (dpo <= 14) dpoText = "$dpo";
        }
      }
    }

    bool isPredictedPeriod = false;

    if (dayType == DayType.period) {
      if (log != null && log.flow != FlowIntensity.none) {
        bgColor = Colors.redAccent.withOpacity(0.8);
        textColor = Colors.white;
      } else {
        isPredictedPeriod = true;
        bgColor = Colors.transparent;
        textColor = AppColors.textPrimary;
      }
    } else if (dayType == DayType.fertile && !cycle.isCOCEnabled) {
      bgColor = isTTC ? Colors.pinkAccent.withOpacity(0.15) : AppColors.primary.withOpacity(0.15);
      textColor = isTTC ? Colors.pinkAccent : AppColors.primary;
    } else if (dayType == DayType.ovulation && !cycle.isCOCEnabled) {
      if (isTTC) {
        bgColor = Colors.purple;
        textColor = Colors.white;
      } else {
        bgColor = AppColors.primary.withOpacity(0.25);
        textColor = AppColors.primary;
        showDot = true;
        dotColor = AppColors.primary;
      }
    }

    Widget cellContent = Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '${day.day}',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
            color: textColor,
          ),
        ),

        if (emojiMarker != null)
          Positioned(
              top: 2, left: 4,
              child: Text(emojiMarker, style: const TextStyle(fontSize: 8))
          ),

        if (dpoText != null && !cleanDay.isAfter(cleanToday))
          Positioned(
              top: 2, right: 4,
              child: Text(dpoText, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withOpacity(0.5)))
          ),

        if (showDot)
          Positioned(top: 4, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle))),

        if (hasLogs)
          Positioned(
              bottom: 2,
              child: isTTC
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasBBT) const Icon(CupertinoIcons.thermometer, size: 8, color: Colors.purple),
                  if (hasSex) const Icon(CupertinoIcons.heart_fill, size: 8, color: Colors.redAccent),
                  if (!hasBBT && !hasSex) Icon(CupertinoIcons.checkmark_alt, size: 8, color: textColor.withOpacity(0.7)),
                ],
              )
                  : Icon(CupertinoIcons.checkmark_alt, size: 8, color: textColor.withOpacity(0.7))
          ),
      ],
    );

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.textPrimary, width: 2)
            : (isToday ? Border.all(color: AppColors.textSecondary.withOpacity(0.3), width: 1) : null),
      ),
      child: isPredictedPeriod
          ? CustomPaint(
        painter: _DashedBorderPainter(color: Colors.redAccent.withOpacity(0.5)),
        child: cellContent,
      )
          : cellContent,
    );
  }

  Widget _buildLinearCycleView(CycleProvider cycle, WellnessProvider wellness, bool isTTC, AppLocalizations l10n) {
    if (cycle.history.isEmpty && !cycle.isCOCEnabled) {
      return Center(child: Text("Need data to build cycle view", style: GoogleFonts.inter(color: AppColors.textSecondary)));
    }

    final startDate = cycle.currentData.cycleStartDate;
    final length = cycle.cycleLength > 0 ? cycle.cycleLength : 28;
    final currentDayNum = cycle.currentData.currentDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "Cycle Timeline",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: length,
            itemBuilder: (context, index) {
              final dayNum = index + 1;
              final date = startDate.add(Duration(days: index));
              final isToday = dayNum == currentDayNum;

              final dayType = _getCorrectDayType(date, cycle);
              final log = wellness.getLogForDate(date);
              final hasFlow = log.flow != FlowIntensity.none;

              Color cardColor = AppColors.textSecondary.withOpacity(0.05);
              Color textColor = AppColors.textPrimary;
              String phaseLabel = "Follicular";
              IconData? mainIcon;

              if (dayType == DayType.period) {
                cardColor = hasFlow ? Colors.redAccent.withOpacity(0.8) : Colors.redAccent.withOpacity(0.1);
                textColor = hasFlow ? Colors.white : Colors.redAccent;
                phaseLabel = "Period";
                mainIcon = CupertinoIcons.drop_fill;
              } else if (dayType == DayType.fertile && !cycle.isCOCEnabled) {
                cardColor = isTTC ? Colors.pinkAccent.withOpacity(0.15) : AppColors.primary.withOpacity(0.15);
                textColor = isTTC ? Colors.pinkAccent : AppColors.primary;
                phaseLabel = "Fertile";
                mainIcon = CupertinoIcons.sparkles;
              } else if (dayType == DayType.ovulation && !cycle.isCOCEnabled) {
                cardColor = isTTC ? Colors.purple : AppColors.primary.withOpacity(0.3);
                textColor = isTTC ? Colors.white : AppColors.primary;
                phaseLabel = "Ovulation";
                mainIcon = isTTC ? CupertinoIcons.heart_circle_fill : CupertinoIcons.circle_bottomthird_split;
              } else if (dayNum > cycle.ovulationDay) {
                phaseLabel = "Luteal";
              }

              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isToday ? Border.all(color: AppColors.textPrimary, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Day $dayNum", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
                    const SizedBox(height: 4),
                    Text(DateFormat('MMM d').format(date), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7))),
                    const SizedBox(height: 12),
                    if (mainIcon != null) Icon(mainIcon, color: textColor, size: 24),
                    const SizedBox(height: 12),
                    Text(phaseLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.8))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    final path = Path()..addRRect(rrect);

    Path dashPath = Path();
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(pathMetric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final cleanDate = DateTime(date.year, date.month, date.day);
    final cleanToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isFuture = cleanDate.isAfter(cleanToday);
    final hasLogs = wellnessProvider.hasLogForDate(date);

    String phaseText = "Predicted";
    Color phaseColor = AppColors.textSecondary;
    String subText = "No symptoms logged";

    if (phase != null) {
      if (cycleProvider.isCOCEnabled) {
        phaseText = phase == CyclePhase.menstruation ? l10n.cocBreakPhase : l10n.cocActivePhase;
        phaseColor = phase == CyclePhase.menstruation ? AppColors.menstruation : AppColors.follicular;
      } else {
        switch (phase) {
          case CyclePhase.menstruation: phaseText = l10n.phaseMenstruation; phaseColor = AppColors.menstruation; break;
          case CyclePhase.follicular: phaseText = l10n.phaseFollicular; phaseColor = AppColors.follicular; break;
          case CyclePhase.ovulation: phaseText = isTTC ? "Peak Ovulation" : l10n.phaseOvulation; phaseColor = isTTC ? Colors.purple : AppColors.ovulation; break;
          case CyclePhase.luteal: phaseText = isTTC ? "Two Week Wait" : l10n.phaseLuteal; phaseColor = AppColors.luteal; break;
          case CyclePhase.late: phaseText = isTTC ? "Test Day" : l10n.phaseLate; phaseColor = Colors.orangeAccent; break;
        }
      }
    }

    if (hasLogs) {
      final log = wellnessProvider.getLogForDate(date);
      List<String> loggedItems = [];
      if (log.flow != FlowIntensity.none) loggedItems.add("Bleeding");
      if (log.temperature != null && log.temperature! > 0) loggedItems.add("BBT: ${log.temperature}");
      if (log.symptoms.contains('Unprotected Sex') || log.symptoms.contains('Protected Sex')) loggedItems.add("Intimacy");
      if (log.symptoms.any((s) => s.startsWith("LH:"))) loggedItems.add("OPK Logged");

      if (loggedItems.isNotEmpty) {
        subText = loggedItems.join(" • ");
      } else {
        subText = "Symptoms logged";
      }
    } else if (isFuture) {
      subText = "Prediction";
    }

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d', l10n.localeName).format(date).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: phaseColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        phaseText,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(hasLogs ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.circle, size: 14, color: hasLogs ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(subText, style: GoogleFonts.inter(fontSize: 12, color: hasLogs ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                )
              ],
            ),
          ),
          if (!isFuture)
            GestureDetector(
              onTap: onOpenLogger,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isTTC ? Colors.purple : AppColors.textPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: (isTTC ? Colors.purple : AppColors.textPrimary).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: const Icon(CupertinoIcons.add, color: Colors.white, size: 24),
              ),
            ),
        ],
      ),
    );
  }
}