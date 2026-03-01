import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';

// 🔥 Обновленный импорт
import '../../shared/widgets/premium_glass_card.dart';
import 'calendar_visuals.dart';
import '../logger/symptom_log_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // 🔥 МЕДИЦИНСКИЙ ИНТЕРЦЕПТОР ДЛЯ КАЛЕНДАРЯ
  Future<void> _handleDayLongPress(BuildContext context, DateTime selectedDay, CycleProvider cycleProvider, AppLocalizations l10n) async {
    if (selectedDay.isAfter(DateTime.now())) {
      _showSnackbar(context, "Cannot log a date in the future", isError: true);
      return;
    }

    HapticFeedback.heavyImpact();

    // Пытаемся записать день через умный метод
    final result = await cycleProvider.logActionStartPeriod(selectedDay);

    if (!context.mounted) return;

    if (result == CycleLogResult.suspiciouslyEarly) {
      _showSuspiciouslyEarlyDialog(context, selectedDay, cycleProvider, l10n);
    } else if (result == CycleLogResult.ovulationBleeding) {
      _showOvulationBleedingDialog(context, selectedDay, cycleProvider, l10n);
    } else {
      _showSnackbar(context, l10n.msgSaved);
      setState(() {
        _selectedDay = selectedDay;
      });
    }
  }

  // ДИАЛОГ 1: Подозрительно рано
  void _showSuspiciouslyEarlyDialog(BuildContext context, DateTime selectedDate, CycleProvider provider, AppLocalizations l10n) {
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
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text("Are you sure?", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary)),
            ),
          ],
        ),
        content: Text(
          "It's been less than 21 days since the previous cycle start. Is this a new period, or just spotting?",
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.lightImpact();
              await provider.togglePeriodDay(selectedDate); // Просто мазня
              if (context.mounted) {
                _showSnackbar(context, l10n.insightSpottingBody);
                setState(() => _selectedDay = selectedDate);
              }
            },
            child: Text("Just Spotting", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.menstruation, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await provider.logActionStartPeriod(selectedDate, isConfirmed: true); // Форсируем новый цикл
              if (context.mounted) {
                _showSnackbar(context, l10n.msgSaved);
                setState(() => _selectedDay = selectedDate);
              }
            },
            child: Text("New Period", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ДИАЛОГ 2: Овуляторное кровотечение
  void _showOvulationBleedingDialog(BuildContext context, DateTime selectedDate, CycleProvider provider, AppLocalizations l10n) {
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
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.sparkles, color: Colors.purple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text("Ovulation Bleeding?", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary)),
            ),
          ],
        ),
        content: Text(
          "Light bleeding can occur during ovulation. Are you sure you want to start a completely new cycle here?",
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.lightImpact();
              await provider.togglePeriodDay(selectedDate);
              if (context.mounted) {
                _showSnackbar(context, "Logged as spotting");
                setState(() => _selectedDay = selectedDate);
              }
            },
            child: Text("Just Spotting", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.menstruation, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await provider.logActionStartPeriod(selectedDate, isConfirmed: true);
              if (context.mounted) {
                _showSnackbar(context, l10n.msgSaved);
                setState(() => _selectedDay = selectedDate);
              }
            },
            child: Text("New Period", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent.withOpacity(0.9) : AppColors.textPrimary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          l10n.tabCalendar.toUpperCase(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PremiumGlassCard(
                padding: const EdgeInsets.only(bottom: 16),
                child: TableCalendar(
                  locale: l10n.localeName,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() => _calendarFormat = format);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  // 🔥 ЗАМЕНЕНО: Используем умный обработчик вместо прямого togglePeriodDay
                  onDayLongPressed: (selectedDay, focusedDay) {
                    _handleDayLongPress(context, selectedDay, cycleProvider, l10n);
                  },
                  eventLoader: (day) {
                    final log = wellnessProvider.getLogForDate(day);
                    List<dynamic> events = [];
                    if (wellnessProvider.hasLogForDate(day)) events.add('log');
                    if (log.ovulationTest != OvulationTestResult.none) events.add('test');
                    return events;
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    leftChevronIcon: Icon(CupertinoIcons.chevron_left, color: AppColors.textPrimary, size: 20),
                    rightChevronIcon: Icon(CupertinoIcons.chevron_right, color: AppColors.textPrimary, size: 20),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                    weekendStyle: GoogleFonts.inter(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    todayTextStyle: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final phase = cycleProvider.getPhaseForDate(date);
                      final isPeriod = phase == CyclePhase.menstruation;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isPeriod)
                            Positioned(
                              bottom: 4,
                              child: Icon(CupertinoIcons.drop_fill, color: AppColors.menstruation.withOpacity(0.6), size: 10),
                            ),
                          if (events.isNotEmpty && !isPeriod)
                            Positioned(
                              bottom: 6,
                              child: Container(
                                width: 4, height: 4,
                                decoration: BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: CalendarLegend(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _DaySummaryCard(
                date: _selectedDay,
                cycleProvider: cycleProvider,
                wellnessProvider: wellnessProvider,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  final DateTime date;
  final CycleProvider cycleProvider;
  final WellnessProvider wellnessProvider;
  final AppLocalizations l10n;

  const _DaySummaryCard({
    required this.date,
    required this.cycleProvider,
    required this.wellnessProvider,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final phase = cycleProvider.getPhaseForDate(date);
    final isFuture = date.isAfter(DateTime.now());
    final hasLogs = wellnessProvider.hasLogForDate(date);

    String phaseText = l10n.phaseLate;
    Color phaseColor = AppColors.textSecondary;

    if (phase != null) {
      if (cycleProvider.isCOCEnabled) {
        phaseText = phase == CyclePhase.menstruation ? l10n.cocBreakPhase : l10n.cocActivePhase;
        phaseColor = phase == CyclePhase.menstruation ? AppColors.menstruation : AppColors.follicular;
      } else {
        switch (phase) {
          case CyclePhase.menstruation: phaseText = l10n.phaseMenstruation; phaseColor = AppColors.menstruation; break;
          case CyclePhase.follicular: phaseText = l10n.phaseFollicular; phaseColor = AppColors.follicular; break;
          case CyclePhase.ovulation: phaseText = l10n.phaseOvulation; phaseColor = AppColors.ovulation; break;
          case CyclePhase.luteal: phaseText = l10n.phaseLuteal; phaseColor = AppColors.luteal; break;
          case CyclePhase.late: phaseText = l10n.phaseLate; phaseColor = Colors.grey; break;
        }
      }
    } else {
      phaseText = "-";
    }

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d', l10n.localeName).format(date).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: phaseColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      phaseText,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (hasLogs) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Symptoms logged ✓", // Можно вынести в l10n
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ]
              ],
            ),
          ),
          if (!isFuture)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: SymptomLogScreen(date: date),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.textPrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
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