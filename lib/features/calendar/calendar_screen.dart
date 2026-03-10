import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';
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
    // final l10n = AppLocalizations.of(context)!; // Для локализации в будущем

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _buildViewToggle(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ВЕРХНЯЯ ПАНЕЛЬ: Статус дня
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildStatusPanel(cycleProvider),
            ),

            const SizedBox(height: 12),

            // ОСНОВНАЯ ЧАСТЬ: Календарь или Линейка
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _viewMode == CalendarViewMode.month
                    ? _buildMonthCalendar(cycleProvider, wellnessProvider)
                    : _buildLinearCycleView(cycleProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ПЕРЕКЛЮЧАТЕЛЬ РЕЖИМОВ ──────────────────────────────────────────────────
  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
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
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── ВЕРХНЯЯ ПАНЕЛЬ СТАТУСА ──────────────────────────────────────────────────
  Widget _buildStatusPanel(CycleProvider cycle) {
    bool hasData = cycle.history.isNotEmpty || cycle.isCOCEnabled;

    String title = cycle.isCOCEnabled ? "Pill Day ${cycle.currentData.dayOfCycle}" : "Day ${cycle.currentData.dayOfCycle}";
    String phaseName = _getPhaseName(cycle.currentData.phase, cycle.isCOCEnabled);

    String forecast = cycle.isCOCEnabled
        ? "~${cycle.currentData.daysToNextPeriod} days to break"
        : "~${cycle.currentData.daysToNextPeriod} days to period";

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
              Text(phaseName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
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

  String _getPhaseName(CyclePhase phase, bool isCOC) {
    if (isCOC) {
      switch (phase) {
        case CyclePhase.menstruation: return "Pill-free Break";
        case CyclePhase.follicular: return "Active Pill Days";
        default: return "Active Pill Days";
      }
    }
    switch (phase) {
      case CyclePhase.menstruation: return "Menstrual Phase";
      case CyclePhase.follicular: return "Follicular Phase";
      case CyclePhase.ovulation: return "Ovulation Window";
      case CyclePhase.luteal: return "Luteal Phase";
      case CyclePhase.late: return "Cycle Delayed";
    }
  }

  // ─── СЕТКА МЕСЯЦА И КАРТОЧКА ДНЯ ───────────────────────────────────────────
  // 🔥 ИСПРАВЛЕНИЕ 1: ИСПОЛЬЗУЕМ LISTVIEW ДЛЯ ЗАЩИТЫ ОТ OVERFLOW
  Widget _buildMonthCalendar(CycleProvider cycle, WellnessProvider wellness) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40), // Безопасный отступ снизу
      children: [
        // 1. Календарь
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PremiumGlassCard(
            padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8, top: 4),
            borderRadius: 24,
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDate,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
              },
              onPageChanged: (focusedDay) => _focusedDate = focusedDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                leftChevronIcon: Icon(CupertinoIcons.chevron_left, color: AppColors.textPrimary, size: 20),
                rightChevronIcon: Icon(CupertinoIcons.chevron_right, color: AppColors.textPrimary, size: 20),
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
                defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, cycle, wellness, isSelected: false),
                todayBuilder: (context, day, focusedDay) => _buildDayCell(day, cycle, wellness, isSelected: false, isToday: true),
                selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, cycle, wellness, isSelected: true),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Легенда
        _buildLegend(cycle.isCOCEnabled),

        const SizedBox(height: 24), // 🔥 ЗАМЕНИЛ Spacer() НА SizedBox

        // 3. Карточка выбранного дня
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DaySummaryCard(
            date: _selectedDate,
            cycleProvider: cycle,
            wellnessProvider: wellness,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(bool isCOC) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        borderRadius: 20,
        child: Row(
          mainAxisAlignment: isCOC ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(isCOC ? "Withdrawal Bleed" : "Period", Colors.redAccent.withOpacity(0.8)),
            if (!isCOC) ...[
              _buildLegendItem("Fertile", AppColors.primary.withOpacity(0.15)),
              _buildLegendItem("Ovulation", AppColors.primary.withOpacity(0.25), dotColor: AppColors.primary),
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
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  // 🔥 ИСПРАВЛЕНИЕ 2: МАТЕМАТИЧЕСКАЯ ФУНКЦИЯ ПРОГНОЗА ДЛЯ БУДУЩИХ ЦИКЛОВ
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

    // Если дата в прошлом или в текущем цикле, используем точную логику провайдера
    if (diff < length) {
      return cycle.getDayType(date);
    }

    // Если дата в БУДУЩЕМ цикле (следующий месяц и далее), зацикливаем расчеты
    int dayOfCycle = (diff % length) + 1;

    // Для КОК предсказываем только дни отмены (перерыва)
    if (cycle.isCOCEnabled) {
      final active = 21;
      final total = 28;
      if (dayOfCycle > active && dayOfCycle <= total) return DayType.period;
      return DayType.none;
    }

    // Обычный режим
    if (dayOfCycle <= cycle.periodDuration) return DayType.period;

    int ovDay = cycle.ovulationDay;
    if (dayOfCycle == ovDay) return DayType.ovulation;
    if (dayOfCycle >= ovDay - 5 && dayOfCycle < ovDay) return DayType.fertile;

    return DayType.none;
  }

  // 🔥 ЯЧЕЙКА КАЛЕНДАРЯ
  Widget _buildDayCell(DateTime day, CycleProvider cycle, WellnessProvider wellness, {bool isSelected = false, bool isToday = false}) {
    // Используем нашу новую математическую функцию предсказания!
    final dayType = _getCorrectDayType(day, cycle);
    final hasLogs = wellness.hasLogForDate(day);
    final isFuture = day.isAfter(DateTime.now());

    Color bgColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    bool showDot = false;
    Color dotColor = Colors.transparent;

    if (dayType == DayType.period) {
      bgColor = isFuture ? Colors.redAccent.withOpacity(0.15) : Colors.redAccent.withOpacity(0.8);
      textColor = isFuture ? AppColors.textPrimary : Colors.white;
    } else if (dayType == DayType.fertile && !cycle.isCOCEnabled) {
      bgColor = AppColors.primary.withOpacity(0.15);
      textColor = AppColors.primary;
    } else if (dayType == DayType.ovulation && !cycle.isCOCEnabled) {
      bgColor = AppColors.primary.withOpacity(0.25);
      textColor = AppColors.primary;
      showDot = true;
      dotColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.textPrimary, width: 2) : (isToday ? Border.all(color: AppColors.textSecondary.withOpacity(0.3), width: 1) : null),
      ),
      child: Stack(
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
          if (showDot)
            Positioned(top: 4, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle))),

          if (hasLogs)
            Positioned(bottom: 4, child: Icon(CupertinoIcons.checkmark_alt, size: 8, color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }

  // ─── ЛИНЕЙНЫЙ РЕЖИМ (CYCLE VIEW) ───────────────────────────────────────────
  Widget _buildLinearCycleView(CycleProvider cycle) {
    if (cycle.history.isEmpty && !cycle.isCOCEnabled) {
      return Center(child: Text("Need data to build cycle view", style: GoogleFonts.inter(color: AppColors.textSecondary)));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.arrow_left_right, size: 48, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("Linear Cycle View", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text("Day 1 to ${cycle.cycleLength} timeline will be mapped here.", textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── ПЛАВАЮЩАЯ КАРТОЧКА ВЫБРАННОГО ДНЯ ──────────────────────────────────────
class _DaySummaryCard extends StatelessWidget {
  final DateTime date;
  final CycleProvider cycleProvider;
  final WellnessProvider wellnessProvider;

  const _DaySummaryCard({
    required this.date,
    required this.cycleProvider,
    required this.wellnessProvider,
  });

  @override
  Widget build(BuildContext context) {
    final phase = cycleProvider.getPhaseForDate(date);
    final isFuture = date.isAfter(DateTime.now());
    final hasLogs = wellnessProvider.hasLogForDate(date);

    String phaseText = "Predicted";
    Color phaseColor = AppColors.textSecondary;

    if (phase != null) {
      if (cycleProvider.isCOCEnabled) {
        phaseText = phase == CyclePhase.menstruation ? "Pill-free Break" : "Active Pill";
        phaseColor = phase == CyclePhase.menstruation ? AppColors.menstruation : AppColors.follicular;
      } else {
        switch (phase) {
          case CyclePhase.menstruation: phaseText = "Menstrual Phase"; phaseColor = AppColors.menstruation; break;
          case CyclePhase.follicular: phaseText = "Follicular Phase"; phaseColor = AppColors.follicular; break;
          case CyclePhase.ovulation: phaseText = "Ovulation Window"; phaseColor = AppColors.ovulation; break;
          case CyclePhase.luteal: phaseText = "Luteal Phase"; phaseColor = AppColors.luteal; break;
          case CyclePhase.late: phaseText = "Cycle Delayed"; phaseColor = Colors.orangeAccent; break;
        }
      }
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
                  DateFormat('EEEE, MMM d').format(date).toUpperCase(),
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
                    Text(
                      phaseText,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5
                      ),
                    ),
                  ],
                ),
                if (hasLogs) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text("Symptoms logged", style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  )
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
                  enableDrag: true,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.textPrimary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
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