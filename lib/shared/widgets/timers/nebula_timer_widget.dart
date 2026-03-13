import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../l10n/app_localizations.dart';

class _NanoParticle {
  final double theta;
  final double phi;
  final double speed;
  final double size;

  _NanoParticle({
    required this.theta,
    required this.phi,
    required this.speed,
    required this.size,
  });
}

class NebulaTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const NebulaTimerWidget({super.key, required this.data, this.isCOC = false});

  @override
  State<NebulaTimerWidget> createState() => _NebulaTimerWidgetState();
}

class _NebulaTimerWidgetState extends State<NebulaTimerWidget> with TickerProviderStateMixin {
  late AnimationController _renderController;
  late AnimationController _pulseController;

  int? _selectedDay;
  bool _isDragging = false;

  final List<_NanoParticle> _particles = [];
  final int _particleCount = 600;

  final int _startTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _renderController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

    final isLate = widget.data.phase == CyclePhase.late;
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: isLate ? 1200 : 2000))..repeat(reverse: true);

    _generate3DSphere();
  }

  void _generate3DSphere() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      double u = random.nextDouble();
      double v = random.nextDouble();

      double theta = 2 * math.pi * u;
      double phi = math.acos(2 * v - 1);

      _particles.add(_NanoParticle(
        theta: theta,
        phi: phi,
        speed: 0.8 + (random.nextDouble() * 0.4),
        size: 0.6 + (random.nextDouble() * 1.2),
      ));
    }
  }

  @override
  void didUpdateWidget(covariant NebulaTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.cycleStartDate != widget.data.cycleStartDate || oldWidget.isCOC != widget.isCOC) {
      setState(() { _selectedDay = null; _isDragging = false; });
    }

    final wasLate = oldWidget.data.phase == CyclePhase.late;
    final isLate = widget.data.phase == CyclePhase.late;
    if (wasLate != isLate) {
      _pulseController.duration = Duration(milliseconds: isLate ? 1200 : 2000);
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _renderController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePan(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    double angle = math.atan2(dy, dx);
    angle += math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    final totalDays = widget.data.totalCycleLength;
    int dayIndex = (angle / (2 * math.pi) * totalDays).round();
    if (dayIndex == 0) dayIndex = totalDays;
    if (dayIndex > totalDays) dayIndex = 1;

    if (_selectedDay != dayIndex) {
      setState(() => _selectedDay = dayIndex);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayDay = _selectedDay ?? widget.data.currentDay;

    final phases = _calculatePhases(widget.data.totalCycleLength);
    CyclePhase displayPhase;
    if (_selectedDay == null) {
      displayPhase = widget.data.phase;
    } else {
      displayPhase = _getPhaseForDay(displayDay, phases);
    }

    final displayColor = _getColor(displayPhase, widget.isCOC);
    final accentColor = _getAccentColor(displayPhase, widget.isCOC);
    final displayName = _getName(context, displayPhase, l10n, widget.isCOC);

    final today = DateTime.now();
    final dateOffset = displayDay - widget.data.currentDay;
    final displayDate = today.add(Duration(days: dateOffset));
    final dateString = DateFormat('MMM d').format(displayDate);

    final bool isLate = displayPhase == CyclePhase.late;
    final int daysLate = displayDay - widget.data.totalCycleLength;
    final String mainNumberText = isLate ? "$daysLate" : "$displayDay";
    final String labelText = isLate ? "DAYS LATE" : "DAY";

    // 🔥 АДАПТИВНАЯ ОБЕРТКА
    return LayoutBuilder(
      builder: (context, constraints) {
        // Берем максимальную ширину, которую выделил нам экран (например 380px)
        final double widgetSize = constraints.maxWidth;
        // Коэффициент масштабирования относительно старого дизайна (320px)
        final double scale = widgetSize / 320.0;

        return RepaintBoundary(
          child: SizedBox(
            width: widgetSize,
            height: widgetSize,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                if (isLate && _selectedDay == null) return;
                setState(() => _isDragging = true);
                _handlePan(details.localPosition, widgetSize);
              },
              onPanUpdate: (details) {
                if (isLate && _selectedDay == null) return;
                _handlePan(details.localPosition, widgetSize);
              },
              onPanEnd: (details) => setState(() => _isDragging = false),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // 🔥 ОРБИТА (масштабируется под размер)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(widgetSize * 0.9375, widgetSize * 0.9375), // Было 300
                        painter: _OrbitTicksPainter(
                          totalDays: widget.data.totalCycleLength,
                          currentDay: widget.data.currentDay,
                          selectedDay: _selectedDay,
                          phases: phases,
                          isCOC: widget.isCOC,
                          pulseValue: _pulseController.value,
                        ),
                      );
                    },
                  ),

                  // 🔥 3D СФЕРА НАНОЧАСТИЦ (масштабируется под размер)
                  AnimatedBuilder(
                    animation: Listenable.merge([_renderController, _pulseController]),
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(widgetSize * 0.84375, widgetSize * 0.84375), // Было 270
                        painter: _NanoSpherePainter(
                          startTime: _startTime,
                          pulseValue: _pulseController.value,
                          baseColor: displayColor,
                          accentColor: accentColor,
                          particles: _particles,
                        ),
                      );
                    },
                  ),

                  // 🔥 ЦЕНТРАЛЬНАЯ КНОПКА (масштабируется)
                  GestureDetector(
                    onTap: () {
                      if (_selectedDay != null) {
                        HapticFeedback.mediumImpact();
                        setState(() => _selectedDay = null);
                      } else {
                        HapticFeedback.selectionClick();
                      }
                    },
                    child: SizedBox(
                      width: 152 * scale, // Умножаем на коэффициент экрана
                      height: 152 * scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(1000),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.65),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5 * scale),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 136 * scale, // Текстовый контейнер тоже растет
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedDay == null ? labelText : dateString.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      color: isLate ? Colors.orangeAccent.shade700 : AppColors.textSecondary,
                                      fontSize: 10 * scale, // Шрифты растут!
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w800
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    mainNumberText,
                                    style: GoogleFonts.inter(
                                        fontSize: (isLate && daysLate > 9 ? 48 : 60) * scale,
                                        fontWeight: FontWeight.w200,
                                        color: isLate ? Colors.orangeAccent.shade700 : AppColors.textPrimary,
                                        height: 1.1,
                                        letterSpacing: -2
                                    ),
                                  ),
                                ),

                                SizedBox(height: 2 * scale),

                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                    decoration: BoxDecoration(
                                        color: displayColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20 * scale)
                                    ),
                                    child: Text(
                                      displayName.toUpperCase(),
                                      style: GoogleFonts.inter(
                                          color: displayColor,
                                          fontSize: 10 * scale,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<int> _calculatePhases(int total) {
    final mEnd = widget.data.periodDuration;
    final fEnd = (total / 2).floor() - 2;
    final oEnd = (total / 2).floor() + 3;
    return [mEnd, fEnd, oEnd];
  }

  CyclePhase _getPhaseForDay(int day, List<int> p) {
    if (day <= p[0]) return CyclePhase.menstruation;
    if (widget.isCOC) return CyclePhase.follicular;
    if (day <= p[1]) return CyclePhase.follicular;
    if (day <= p[2]) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  Color _getColor(CyclePhase phase, bool isCOC) {
    if (isCOC) return phase == CyclePhase.menstruation ? Colors.redAccent : Colors.tealAccent.shade400;
    switch (phase) {
      case CyclePhase.menstruation: return AppColors.menstruation;
      case CyclePhase.follicular: return AppColors.follicular;
      case CyclePhase.ovulation: return AppColors.ovulation;
      case CyclePhase.luteal: return AppColors.luteal;
      case CyclePhase.late: return Colors.orangeAccent.shade700;
    }
  }

  Color _getAccentColor(CyclePhase phase, bool isCOC) {
    if (isCOC) return Colors.indigoAccent;
    switch (phase) {
      case CyclePhase.menstruation: return Colors.redAccent;
      case CyclePhase.follicular: return Colors.lightBlueAccent;
      case CyclePhase.ovulation: return Colors.purpleAccent;
      case CyclePhase.luteal: return Colors.pinkAccent;
      case CyclePhase.late: return Colors.redAccent;
    }
  }

  String _getName(BuildContext context, CyclePhase phase, AppLocalizations l10n, bool isCOC) {
    if (isCOC) return phase == CyclePhase.menstruation ? l10n.cocBreakPhase : l10n.cocActivePhase;
    switch (phase) {
      case CyclePhase.menstruation: return l10n.phaseMenstruation;
      case CyclePhase.follicular: return l10n.phaseFollicular;
      case CyclePhase.ovulation: return l10n.phaseOvulation;
      case CyclePhase.luteal: return l10n.phaseLuteal;
      case CyclePhase.late: return l10n.phaseLate;
    }
  }
}

class _OrbitTicksPainter extends CustomPainter {
  final int totalDays;
  final int currentDay;
  final int? selectedDay;
  final List<int> phases;
  final bool isCOC;
  final double pulseValue;

  _OrbitTicksPainter({
    required this.totalDays,
    required this.currentDay,
    required this.selectedDay,
    required this.phases,
    required this.isCOC,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final Paint trackPaint = Paint()..color = Colors.black.withOpacity(0.02)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final Paint tickPaint = Paint()..style = PaintingStyle.fill;
    final Paint whiteTickPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, trackPaint);

    if (!isCOC) {
      int startFertile = phases[1] + 1;
      int endFertile = phases[2];
      if (startFertile <= totalDays && endFertile <= totalDays) {
        double startAngle = (2 * math.pi / totalDays) * (startFertile - 1) - (math.pi / 2);
        double endAngle = (2 * math.pi / totalDays) * (endFertile - 1) - (math.pi / 2);
        double sweepAngle = endAngle - startAngle;

        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle, sweepAngle, false,
            Paint()
              ..color = AppColors.ovulation.withOpacity(0.25)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 14.0
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        );
      }
    }

    for (int i = 0; i < totalDays; i++) {
      int dayNum = i + 1;
      Color tickColor;
      bool isFertile = false;

      if (isCOC) {
        tickColor = dayNum <= phases[0] ? Colors.redAccent : Colors.tealAccent.shade400;
      } else {
        if (dayNum <= phases[0]) tickColor = AppColors.menstruation;
        else if (dayNum <= phases[1]) tickColor = AppColors.follicular;
        else if (dayNum <= phases[2]) { tickColor = AppColors.ovulation; isFertile = true; }
        else tickColor = AppColors.luteal;
      }

      final angle = (2 * math.pi / totalDays) * i - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 2);

      if (selectedDay == dayNum) {
        tickPaint.color = tickColor.withOpacity(0.4);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 4.5, height: 16), const Radius.circular(3)), tickPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 3.5, height: 14), const Radius.circular(2)), whiteTickPaint);
      } else if (currentDay == dayNum && selectedDay == null) {
        tickPaint.color = tickColor.withOpacity(0.3);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 4.5, height: 14 + (pulseValue * 4)), const Radius.circular(3)), tickPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 3.5, height: 12 + (pulseValue * 2)), const Radius.circular(2)), whiteTickPaint);
      } else {
        bool isPast = dayNum < currentDay;
        double tickWidth = isFertile && !isCOC ? 3.0 : 2.5;
        double tickHeight = isFertile && !isCOC ? 9.0 : 6.0;

        tickPaint.color = isPast ? tickColor.withOpacity(0.3) : tickColor;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: tickWidth, height: tickHeight), Radius.circular(tickWidth / 2)), tickPaint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitTicksPainter oldDelegate) =>
      oldDelegate.currentDay != currentDay ||
          oldDelegate.selectedDay != selectedDay ||
          oldDelegate.pulseValue != pulseValue;
}

class _NanoSpherePainter extends CustomPainter {
  final int startTime;
  final double pulseValue;
  final Color baseColor;
  final Color accentColor;
  final List<_NanoParticle> particles;

  _NanoSpherePainter({
    required this.startTime,
    required this.pulseValue,
    required this.baseColor,
    required this.accentColor,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2 - 20) + (pulseValue * 8);

    final double time = (DateTime.now().millisecondsSinceEpoch - startTime) / 1000.0 * 0.6;

    const tilt = math.pi / 9;
    final double cosTilt = math.cos(tilt);
    final double sinTilt = math.sin(tilt);

    final List<Color> colorPalette = List.generate(
        100,
            (index) => Color.lerp(baseColor, accentColor, index / 99.0)!
    );

    final Paint particlePaint = Paint()..style = PaintingStyle.fill;
    final Paint glowPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      double rotTheta = p.theta + (time * p.speed);
      double rotPhi = p.phi + math.sin(time * 3 + p.theta) * 0.05;

      double x3d = radius * math.sin(rotPhi) * math.cos(rotTheta);
      double y3d = radius * math.sin(rotPhi) * math.sin(rotTheta);
      double z3d = radius * math.cos(rotPhi);

      double y = y3d * cosTilt - z3d * sinTilt;
      double z = y3d * sinTilt + z3d * cosTilt;
      double x = x3d;

      double depth = (z + radius) / (2 * radius);
      double drawSize = (p.size * 0.4) + (p.size * 1.2 * depth);
      double opacity = 0.1 + (0.9 * depth);

      double colorMix = (math.sin(time * 2 + p.theta * 2) + 1) / 2;

      int colorIndex = (colorMix * 99).round().clamp(0, 99);
      Color finalColor = colorPalette[colorIndex];

      particlePaint.color = finalColor.withOpacity(opacity);
      Offset screenPos = Offset(center.dx + x, center.dy + y);

      canvas.drawCircle(screenPos, drawSize, particlePaint);

      if (depth > 0.85) {
        glowPaint.color = finalColor.withOpacity(opacity * 0.15);
        canvas.drawCircle(screenPos, drawSize * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NanoSpherePainter oldDelegate) => true;
}