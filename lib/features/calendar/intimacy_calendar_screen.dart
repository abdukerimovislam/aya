import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/live_phase_background.dart';

class IntimacyCalendarScreen extends StatefulWidget {
  const IntimacyCalendarScreen({super.key});

  @override
  State<IntimacyCalendarScreen> createState() => _IntimacyCalendarScreenState();
}

class _IntimacyCalendarScreenState extends State<IntimacyCalendarScreen> {
  DateTime _focusedDate = DateTime.now();

  // Independent palette for this screen only
  static const Color _bgBase = Color(0xFFF8F3F7);
  static const Color _mist = Color(0xFFFFFBFD);
  static const Color _textPrimary = Color(0xFF2B2230);
  static const Color _textSecondary = Color(0xFF7C6A78);

  static const Color _sexPink = Color(0xFFE94B7B);
  static const Color _sexPinkSoft = Color(0xFFF6A2BB);
  static const Color _protectedGreen = Color(0xFF18B47A);
  static const Color _warningRed = Color(0xFFE05A5A);
  static const Color _plum = Color(0xFF7A5874);
  static const Color _lavenderMist = Color(0xFFE8DFF0);

  final LinearGradient _heroGradient = const LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFCEEF4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final LinearGradient _surfaceGradient = const LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFF7FA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final LinearGradient _eventGradient = const LinearGradient(
    colors: [
      _sexPink,
      _sexPinkSoft,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final LinearGradient _chipGradient = const LinearGradient(
    colors: [
      Color(0xFFFBE8EF),
      Color(0xFFFFF8FB),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();
    final currentPhase = cycleProvider.currentData.phase;

    return Scaffold(
      backgroundColor: _bgBase,
      body: Stack(
        children: [
          Positioned.fill(
            child: LivePhaseBackground(
              phase: currentPhase,
              isCOC: cycleProvider.isCOCEnabled,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _mist.withValues(alpha: 0.76),
                    _mist.withValues(alpha: 0.82),
                    _bgBase.withValues(alpha: 0.90),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Positioned(
            top: -90,
            right: -50,
            child: _buildAmbientGlow(
              size: 230,
              color: _sexPinkSoft.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 180,
            left: -70,
            child: _buildAmbientGlow(
              size: 180,
              color: _lavenderMist.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: _buildAmbientGlow(
              size: 210,
              color: _sexPink.withValues(alpha: 0.10),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildFloatingHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 20),
                        _buildLegendCard(),
                        const SizedBox(height: 20),
                        _buildGlassCalendar(wellnessProvider),
                        const SizedBox(height: 18),
                        _buildBottomHint(),
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

  Widget _buildAmbientGlow({
    required double size,
    required Color color,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 90,
              spreadRadius: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _buildGlassIconButton(
            icon: CupertinoIcons.back,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: _chipGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.78),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _sexPinkSoft.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.heart_fill,
                  size: 14,
                  color: _sexPink,
                ),
                const SizedBox(width: 8),
                Text(
                  'SEX CALENDAR',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _sexPink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.60),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _plum.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: _textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: _heroGradient,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.76),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: _sexPinkSoft.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: _sexPink.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.heart_fill,
                      color: _sexPink,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'INTIMACY TRACKER',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        fontSize: 11,
                        color: _sexPink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your sex\ncalendar',
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  height: 1.02,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Track intimacy, protected sex and unprotected sex in one clear calendar view.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary.withValues(alpha: 0.96),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendCard() {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: _surfaceGradient,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.78),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: _sexPinkSoft.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Wrap(
            spacing: 18,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLegendItem(
                icon: CupertinoIcons.heart_fill,
                color: _sexPink,
                label: l10n.symIntimacy,
              ),
              _buildLegendItem(
                icon: CupertinoIcons.lock_fill,
                color: _protectedGreen,
                label: l10n.symProtectedSex,
              ),
              _buildLegendItem(
                icon: CupertinoIcons.exclamationmark_triangle_fill,
                color: _warningRed,
                label: l10n.symUnprotectedSex,
              ),
              _buildLegendItem(
                icon: CupertinoIcons.circle_fill,
                color: _plum.withValues(alpha: 0.55),
                label: l10n.btnToday,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCalendar(WellnessProvider wellness) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: _surfaceGradient,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: _sexPinkSoft.withValues(alpha: 0.16),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: _plum.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2035, 12, 31),
            focusedDay: _focusedDate,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.horizontalSwipe,
            rowHeight: 62,
            headerVisible: true,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDate = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            daysOfWeekHeight: 38,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) =>
                  DateFormat('MMMM yyyy').format(date),
              titleTextStyle: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
              leftChevronIcon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.84),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _plum.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.chevron_left,
                  size: 18,
                  color: _textPrimary,
                ),
              ),
              rightChevronIcon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.84),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _plum.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: _textPrimary,
                ),
              ),
              headerPadding: const EdgeInsets.fromLTRB(6, 4, 6, 12),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _textSecondary.withValues(alpha: 0.92),
                letterSpacing: 0.2,
              ),
              weekendStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _textSecondary.withValues(alpha: 0.60),
                letterSpacing: 0.2,
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(color: Colors.transparent),
              weekendTextStyle: TextStyle(color: Colors.transparent),
              todayTextStyle: TextStyle(color: Colors.transparent),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(
                  day,
                  wellness,
                  isToday: false,
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(
                  day,
                  wellness,
                  isToday: true,
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
      DateTime day,
      WellnessProvider wellness, {
        bool isToday = false,
      }) {
    final hasLogs = wellness.hasLogForDate(day);

    String? sexType; // intimacy / protected / unprotected
    IconData? eventIcon;
    Color? eventColor;

    if (hasLogs) {
      final log = wellness.getLogForDate(day);

      if (log.symptoms.contains('Unprotected Sex')) {
        sexType = 'unprotected';
        eventIcon = CupertinoIcons.exclamationmark_triangle_fill;
        eventColor = _warningRed;
      } else if (log.symptoms.contains('Protected Sex')) {
        sexType = 'protected';
        eventIcon = CupertinoIcons.lock_fill;
        eventColor = _protectedGreen;
      } else if (log.symptoms.contains('Intimacy')) {
        sexType = 'intimacy';
        eventIcon = CupertinoIcons.heart_fill;
        eventColor = _sexPink;
      }
    }

    final now = DateTime.now();
    final bool isFuture = day.isAfter(
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    final bool hasSexEvent = sexType != null;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasSexEvent && sexType == 'intimacy' ? _eventGradient : null,
          color: hasSexEvent
              ? (sexType == 'intimacy'
              ? null
              : eventColor!.withValues(alpha: 0.14))
              : isToday
              ? Colors.white.withValues(alpha: 0.98)
              : Colors.white.withValues(alpha: 0.56),
          border: Border.all(
            color: hasSexEvent
                ? eventColor!.withValues(alpha: sexType == 'intimacy' ? 0.10 : 0.28)
                : isToday
                ? _plum.withValues(alpha: 0.24)
                : _plum.withValues(alpha: 0.10),
            width: isToday ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (hasSexEvent)
              BoxShadow(
                color: eventColor!.withValues(alpha: 0.22),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            if (isToday && !hasSexEvent)
              BoxShadow(
                color: _sexPinkSoft.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: hasSexEvent
                    ? FontWeight.w900
                    : isToday
                    ? FontWeight.w800
                    : FontWeight.w700,
                color: hasSexEvent
                    ? (sexType == 'intimacy' ? Colors.white : eventColor)
                    : isFuture
                    ? _textPrimary.withValues(alpha: 0.34)
                    : _textPrimary.withValues(alpha: 0.90),
              ),
            ),

            if (hasSexEvent)
              Positioned(
                bottom: 3,
                child: Icon(
                  eventIcon,
                  size: sexType == 'unprotected' ? 13 : 12,
                  color: sexType == 'intimacy'
                      ? Colors.white.withValues(alpha: 0.96)
                      : eventColor,
                ),
              ),

            if (isToday && !hasSexEvent)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _plum.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Swipe horizontally to move between months.',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _textSecondary.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
