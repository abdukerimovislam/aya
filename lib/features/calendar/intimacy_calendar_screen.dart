import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/live_phase_background.dart';

class IntimacyCalendarScreen extends StatefulWidget {
  const IntimacyCalendarScreen({super.key});

  @override
  State<IntimacyCalendarScreen> createState() => _IntimacyCalendarScreenState();
}

class _IntimacyCalendarScreenState extends State<IntimacyCalendarScreen> {
  DateTime _focusedDate = DateTime.now();

  // 🔥 Премиальные градиенты и свечения
  final LinearGradient _heartGradient = const LinearGradient(
    colors: [Color(0xFFFF0844), Color(0xFFFFB199)], // Малиновый в персиковый
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();
    final currentPhase = cycleProvider.currentData.phase;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Живой анимированный фон с легким романтичным затемнением
          Positioned.fill(
            child: LivePhaseBackground(
              phase: currentPhase,
              isCOC: cycleProvider.isCOCEnabled,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE94057).withOpacity(0.03),
            ),
          ),

          // 2. Основной контент
          SafeArea(
            child: Column(
              children: [
                _buildFloatingHeader(context),
                const SizedBox(height: 20),
                _buildTitleSection(),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildGlassCalendar(wellnessProvider),
                        const SizedBox(height: 60),
                      ],
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

  // Парящая кнопка назад
  Widget _buildFloatingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Icon(CupertinoIcons.back, color: AppColors.textPrimary, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Элегантный заголовок
  Widget _buildTitleSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF0844).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.heart_fill, color: Color(0xFFFF0844), size: 14),
              const SizedBox(width: 8),
              Text(
                "PRIVATE TIMELINE",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  fontSize: 11,
                  color: const Color(0xFFFF0844),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Your Intimacy",
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }

  // Роскошный стеклянный календарь без лишних рамок
  Widget _buildGlassCalendar(WellnessProvider wellness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0844).withOpacity(0.05),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2035, 12, 31),
              focusedDay: _focusedDate,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableGestures: AvailableGestures.horizontalSwipe,
              rowHeight: 56, // Увеличили высоту ячеек для "воздуха"
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDate = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                leftChevronIcon: Icon(CupertinoIcons.chevron_left, color: AppColors.textPrimary, size: 24),
                rightChevronIcon: Icon(CupertinoIcons.chevron_right, color: AppColors.textPrimary, size: 24),
              ),
              daysOfWeekHeight: 40,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary.withOpacity(0.6)),
                weekendStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary.withOpacity(0.4)),
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.transparent),
                weekendTextStyle: TextStyle(color: Colors.transparent),
                todayTextStyle: TextStyle(color: Colors.transparent),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, wellness, isToday: false),
                todayBuilder: (context, day, focusedDay) => _buildDayCell(day, wellness, isToday: true),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, WellnessProvider wellness, {bool isToday = false}) {
    final hasLogs = wellness.hasLogForDate(day);
    bool hasSex = false;

    if (hasLogs) {
      final log = wellness.getLogForDate(day);
      if (log.symptoms.contains('Intimacy') ||
          log.symptoms.contains('Unprotected Sex') ||
          log.symptoms.contains('Protected Sex')) {
        hasSex = true;
      }
    }

    // 🔥 ЕСЛИ БЫЛ ИНТИМ: Рисуем градиентное сердце со свечением
    if (hasSex) {
      return Container(
        margin: const EdgeInsets.all(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Мягкое неоновое свечение позади сердца
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0844).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),

            // Сердце с градиентом
            ShaderMask(
              shaderCallback: (bounds) => _heartGradient.createShader(bounds),
              child: const Icon(
                CupertinoIcons.heart_fill,
                size: 46, // Огромное сердце, перекрывающее ячейку
                color: Colors.white, // Цвет-основа для ShaderMask
              ),
            ),

            // Дата поверх сердца
            Text(
              '${day.day}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // ОБЫЧНАЯ ЯЧЕЙКА (Если интима не было)
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isToday ? AppColors.textPrimary.withOpacity(0.05) : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppColors.textPrimary.withOpacity(0.2), width: 1.5) : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            color: isToday ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}