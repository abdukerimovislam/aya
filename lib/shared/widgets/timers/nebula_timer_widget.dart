import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../l10n/app_localizations.dart';

enum TimerShape { sphere, dna, infinity }

class _NanoParticle {
  final double u;
  final double v;
  final double speed;
  final double size;
  final double rand1;
  final double rand2;

  _NanoParticle({
    required this.u,
    required this.v,
    required this.speed,
    required this.size,
    required this.rand1,
    required this.rand2,
  });
}

class NebulaTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;
  final bool isTTC;

  const NebulaTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
    this.isTTC = false,
  });

  @override
  State<NebulaTimerWidget> createState() => _NebulaTimerWidgetState();
}

class _NebulaTimerWidgetState extends State<NebulaTimerWidget> with TickerProviderStateMixin {
  late AnimationController _renderController;
  late AnimationController _pulseController;

  int? _selectedDay;

  final List<_NanoParticle> _particles = [];
  final int _particleCount = 600;

  // 🔥 Аккумулятор времени для бесшовного изменения скорости
  double _accumulatedTime = 0.0;
  DateTime _lastFrameTime = DateTime.now();
  double _currentSpeed = 0.6;
  double _targetSpeed = 0.6;

  TimerShape get _currentShape {
    if (widget.isCOC) return TimerShape.infinity;
    if (widget.isTTC) return TimerShape.dna;
    return TimerShape.sphere;
  }

  @override
  void initState() {
    super.initState();
    _renderController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

    // Подписываемся на кадры, чтобы плавно накапливать время с нужной скоростью
    _renderController.addListener(() {
      final now = DateTime.now();
      final dt = now.difference(_lastFrameTime).inMilliseconds / 1000.0;
      _lastFrameTime = now;

      // Плавное ускорение/замедление (инерция)
      _currentSpeed += (_targetSpeed - _currentSpeed) * 0.05;
      _accumulatedTime += dt * _currentSpeed;
    });

    final isLate = widget.data.phase == CyclePhase.late;
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: isLate ? 1200 : 2000))..repeat(reverse: true);

    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_NanoParticle(
        u: random.nextDouble(),
        v: random.nextDouble(),
        speed: 0.8 + (random.nextDouble() * 0.4),
        size: 0.6 + (random.nextDouble() * 1.2),
        rand1: random.nextDouble(),
        rand2: random.nextDouble(),
      ));
    }
  }

  @override
  void didUpdateWidget(covariant NebulaTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.cycleStartDate != widget.data.cycleStartDate ||
        oldWidget.isCOC != widget.isCOC ||
        oldWidget.isTTC != widget.isTTC) {
      setState(() {
        _selectedDay = null;
      });
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

  Map<String, String> _getTTCLabels(
    int currentDay,
    int ovulationDay,
    int totalLength,
    CyclePhase phase,
    AppLocalizations l10n,
  ) {
    if (phase == CyclePhase.menstruation) {
      return {
        "label": l10n.timerPeriod,
        "value": l10n.timerDayValue(currentDay).toUpperCase(),
      };
    } else if (phase == CyclePhase.follicular) {
      int fertileStart = math.max(1, ovulationDay - 5);
      int daysToFertile = fertileStart - currentDay;
      if (daysToFertile > 0) {
        return {
          "label": l10n.timerFertileIn,
          "value": l10n.timerDaysValue(daysToFertile).toUpperCase(),
        };
      } else {
        int fertileDayNum = currentDay - fertileStart + 1;
        return {
          "label": l10n.timerFertileWindow,
          "value": l10n.timerDayValue(fertileDayNum).toUpperCase(),
        };
      }
    } else if (phase == CyclePhase.ovulation) {
      if (currentDay == ovulationDay) {
        return {"label": l10n.timerOvulation, "value": l10n.lblPeak.toUpperCase()};
      } else {
        int fertileStart = math.max(1, ovulationDay - 5);
        int fertileDayNum = currentDay - fertileStart + 1;
        return {
          "label": l10n.timerFertileWindow,
          "value": l10n.timerDayValue(fertileDayNum).toUpperCase(),
        };
      }
    } else if (phase == CyclePhase.luteal) {
      int dpo = currentDay - ovulationDay;
      if (dpo <= 0) dpo = 1;
      return {
        "label": l10n.timerPastOvulation,
        "value": l10n.timerDpoValue(dpo).toUpperCase(),
      };
    } else {
      int daysLate = currentDay - totalLength;
      return {
        "label": l10n.timerCycleDelay,
        "value": l10n.timerDaysValue(daysLate).toUpperCase(),
      };
    }
  }

  // 🔥 Получаем целевую скорость в зависимости от фазы
  double _getSpeedForPhase(CyclePhase phase, bool isCOC) {
    if (isCOC) return 0.5; // У КОК скорость всегда ровная и медитативная

    switch (phase) {
      case CyclePhase.menstruation: return 0.2; // Убаюкивающая, медленная (усталость)
      case CyclePhase.follicular: return 0.7;   // Бодрая (эстроген растет)
      case CyclePhase.ovulation: return 1.4;    // Очень быстрая (энергетический пик)
      case CyclePhase.luteal: return 0.4;       // Тягучая (прогестерон заземляет)
      case CyclePhase.late: return 0.1;         // Почти замершая (невесомость/ожидание)
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

    // Обновляем целевую скорость при смене фазы (например, при свайпе)
    _targetSpeed = _getSpeedForPhase(displayPhase, widget.isCOC);

    final displayColor = _getColor(displayPhase, widget.isCOC, widget.isTTC);
    final accentColor = _getAccentColor(displayPhase, widget.isCOC, widget.isTTC);
    final displayName = _getName(context, displayPhase, l10n, widget.isCOC, widget.isTTC);

    final today = DateTime.now();
    final dateOffset = displayDay - widget.data.currentDay;
    final displayDate = today.add(Duration(days: dateOffset));
    final dateString = DateFormat('MMM d').format(displayDate);

    final bool isLate = displayPhase == CyclePhase.late;
    final int daysLate = displayDay - widget.data.totalCycleLength;

    String mainNumberText;
    String labelText;

    if (widget.isTTC && _selectedDay == null) {
      final ttcData = _getTTCLabels(
        widget.data.currentDay,
        phases[2] - 1,
        widget.data.totalCycleLength,
        displayPhase,
        l10n,
      );
      labelText = ttcData['label']!;
      mainNumberText = ttcData['value']!;
    } else {
      mainNumberText = isLate ? "$daysLate" : "$displayDay";
      labelText = isLate ? l10n.timerDaysLate : l10n.dayTitle.toUpperCase();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double widgetSize = constraints.maxWidth;
        final double scale = widgetSize / 320.0;

        return RepaintBoundary(
          child: SizedBox(
            width: widgetSize,
            height: widgetSize,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                if (isLate && _selectedDay == null) return;
                _handlePan(details.localPosition, widgetSize);
              },
              onPanUpdate: (details) {
                if (isLate && _selectedDay == null) return;
                _handlePan(details.localPosition, widgetSize);
              },
              onPanEnd: (details) {},
              child: Stack(
                alignment: Alignment.center,
                children: [

                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(widgetSize * 0.9375, widgetSize * 0.9375),
                        painter: _OrbitTicksPainter(
                          totalDays: widget.data.totalCycleLength,
                          currentDay: widget.data.currentDay,
                          selectedDay: _selectedDay,
                          phases: phases,
                          isCOC: widget.isCOC,
                          isTTC: widget.isTTC,
                          pulseValue: _pulseController.value,
                        ),
                      );
                    },
                  ),

                  AnimatedBuilder(
                    animation: Listenable.merge([_renderController, _pulseController]),
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(widgetSize * 0.84375, widgetSize * 0.84375),
                        painter: _NanoParticlePainter(
                          time: _accumulatedTime, // 🔥 Передаем накопленное время
                          pulseValue: _pulseController.value,
                          baseColor: displayColor,
                          accentColor: accentColor,
                          particles: _particles,
                          shape: _currentShape,
                          isFrontLayer: false,
                        ),
                      );
                    },
                  ),

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
                      width: 152 * scale,
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
                                  color: Colors.white.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5 * scale),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 136 * scale,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedDay == null ? labelText : dateString.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      color: isLate ? const Color(0xFFE65100) : AppColors.textSecondary,
                                      fontSize: 10 * scale,
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
                                        color: isLate ? const Color(0xFFE65100) : AppColors.textPrimary,
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
                                        color: displayColor.withValues(alpha: 0.15),
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

                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_renderController, _pulseController]),
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(widgetSize * 0.84375, widgetSize * 0.84375),
                          painter: _NanoParticlePainter(
                            time: _accumulatedTime, // 🔥 Передаем накопленное время
                            pulseValue: _pulseController.value,
                            baseColor: displayColor,
                            accentColor: accentColor,
                            particles: _particles,
                            shape: _currentShape,
                            isFrontLayer: true,
                          ),
                        );
                      },
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

  Color _getColor(CyclePhase phase, bool isCOC, bool isTTC) {
    if (isCOC) return phase == CyclePhase.menstruation ? const Color(0xFFFF8FA8) : const Color(0xFFB2EBF2);
    if (isTTC && phase == CyclePhase.ovulation) return const Color(0xFFBCAAA4);

    switch (phase) {
      case CyclePhase.menstruation: return const Color(0xFFFF8FA8);
      case CyclePhase.follicular: return const Color(0xFFB2EBF2);
      case CyclePhase.ovulation: return const Color(0xFFB7D7FF);
      case CyclePhase.luteal: return const Color(0xFFE1BEE7);
      case CyclePhase.late: return const Color(0xFFFFE0B2);
    }
  }

  Color _getAccentColor(CyclePhase phase, bool isCOC, bool isTTC) {
    if (isCOC) return const Color(0xFF4DD0E1);
    if (isTTC && phase == CyclePhase.ovulation) return const Color(0xFFE85D75);

    switch (phase) {
      case CyclePhase.menstruation: return const Color(0xFFE85D75);
      case CyclePhase.follicular: return const Color(0xFF4DD0E1);
      case CyclePhase.ovulation: return const Color(0xFF4267B2);
      case CyclePhase.luteal: return const Color(0xFFBA68C8);
      case CyclePhase.late: return const Color(0xFFFFB74D);
    }
  }

  String _getName(BuildContext context, CyclePhase phase, AppLocalizations l10n, bool isCOC, bool isTTC) {
    if (isCOC) return phase == CyclePhase.menstruation ? l10n.cocBreakPhase : l10n.cocActivePhase;
    if (isTTC && phase == CyclePhase.follicular) return l10n.timerPreparing;
    if (isTTC && phase == CyclePhase.luteal) return l10n.timerTwwDpo;

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
  final bool isTTC;
  final double pulseValue;

  _OrbitTicksPainter({
    required this.totalDays,
    required this.currentDay,
    required this.selectedDay,
    required this.phases,
    required this.isCOC,
    required this.isTTC,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final Paint trackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
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

        Color glowColor = isTTC ? const Color(0xFFBCAAA4).withValues(alpha: 0.5) : const Color(0xFFB7D7FF).withValues(alpha: 0.4);

        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle, sweepAngle, false,
            Paint()
              ..color = glowColor
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
        tickColor = dayNum <= phases[0] ? const Color(0xFFFF8FA8) : const Color(0xFFB2EBF2);
      } else {
        if (dayNum <= phases[0]) {
          tickColor = const Color(0xFFFF8FA8);
        } else if (dayNum <= phases[1]) {
          tickColor = const Color(0xFFB2EBF2);
        } else if (dayNum <= phases[2]) {
          tickColor = isTTC ? const Color(0xFFBCAAA4) : const Color(0xFFB7D7FF);
          isFertile = true;
        } else {
          tickColor = const Color(0xFFE1BEE7);
        }
      }

      final angle = (2 * math.pi / totalDays) * i - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.save();
      canvas.translate(x, y);

      if (selectedDay == dayNum) {
        tickPaint.color = tickColor.withValues(alpha: 0.9);
        canvas.drawCircle(Offset.zero, 8, tickPaint);
        canvas.drawCircle(Offset.zero, 6.5, whiteTickPaint);
      } else if (currentDay == dayNum && selectedDay == null) {
        tickPaint.color = tickColor.withValues(alpha: 0.85);

        final Paint haloPaint = Paint()..color = tickColor.withValues(alpha: 0.3 * (1 - pulseValue))..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, 8 + (pulseValue * 5), haloPaint);

        canvas.drawCircle(Offset.zero, 8, tickPaint);
        canvas.drawCircle(Offset.zero, 6.5, whiteTickPaint);
      } else {
        bool isPast = dayNum < currentDay;
        double circleRadius = isFertile && !isCOC ? 4.0 : 3.2;

        if (isPast) {
          tickPaint.color = tickColor.withValues(alpha: 0.8);
          canvas.drawCircle(Offset.zero, circleRadius, tickPaint);
        } else {
          final Paint strokePaint = Paint()
            ..color = tickColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8;
          canvas.drawCircle(Offset.zero, circleRadius, strokePaint);
        }
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

class _NanoParticlePainter extends CustomPainter {
  final double time; // 🔥 Теперь принимаем накопленное время, а не стартовое
  final double pulseValue;
  final Color baseColor;
  final Color accentColor;
  final List<_NanoParticle> particles;
  final TimerShape shape;
  final bool isFrontLayer;

  _NanoParticlePainter({
    required this.time,
    required this.pulseValue,
    required this.baseColor,
    required this.accentColor,
    required this.particles,
    required this.shape,
    required this.isFrontLayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2 - 20) + (pulseValue * 8);

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

      double x3d = 0;
      double y3d = 0;
      double z3d = 0;
      double r = radius;

      switch (shape) {
        case TimerShape.sphere:
          double rotTheta = (p.u * 2 * math.pi) + (time * p.speed);
          double rotPhi = math.acos(2 * p.v - 1) + math.sin(time * 3 + p.u) * 0.05;
          x3d = r * math.sin(rotPhi) * math.cos(rotTheta);
          y3d = r * math.sin(rotPhi) * math.sin(rotTheta);
          z3d = r * math.cos(rotPhi);
          break;

        case TimerShape.dna:
          double globalTime = time * 1.5;
          double zRaw = (p.u - 0.5) * 2.0;
          double twist = math.pi * 3.5;
          double currentR = r * 0.6;

          if (p.rand1 < 0.75) {
            double strandOffset = p.rand1 < 0.375 ? 0.0 : math.pi;
            double theta = zRaw * twist - globalTime;

            double thickness = 4.0;
            double tubeX = math.cos(p.v * math.pi * 2) * thickness;
            double tubeZ = math.sin(p.v * math.pi * 2) * thickness;

            x3d = currentR * math.cos(theta + strandOffset) + tubeX;
            y3d = zRaw * r * 0.95 + (p.rand2 - 0.5) * thickness;
            z3d = currentR * math.sin(theta + strandOffset) + tubeZ;
          } else {
            int rungs = 18;
            double step = (p.u * (rungs - 1)).round() / (rungs - 1);
            double zRung = (step - 0.5) * 2.0;
            double theta = zRung * twist - globalTime;

            double bridgeT = (p.v - 0.5) * 2.0;

            x3d = currentR * bridgeT * math.cos(theta);
            y3d = zRung * r * 0.95;
            z3d = currentR * bridgeT * math.sin(theta);
          }
          break;

        case TimerShape.infinity:
          double t = p.u * 2 * math.pi + (time * p.speed * 0.5);
          double rInf = r * 0.85;
          num denom = 1 + math.pow(math.sin(t), 2);

          double xBase = rInf * math.cos(t) / denom;
          double yBase = rInf * math.sin(t) * math.cos(t) / denom;
          double zBase = rInf * math.sin(t) * 0.5;

          x3d = xBase + (p.rand1 - 0.5) * 30;
          y3d = yBase + (p.rand2 - 0.5) * 30;
          z3d = zBase + (p.v - 0.5) * 30;
          break;
      }

      double y = y3d * cosTilt - z3d * sinTilt;
      double z = y3d * sinTilt + z3d * cosTilt;
      double x = x3d;

      if (isFrontLayer && z < 0) continue;
      if (!isFrontLayer && z >= 0) continue;

      double depth = ((z + radius) / (2 * radius)).clamp(0.0, 1.0);
      double drawSize = (p.size * 0.4) + (p.size * 1.2 * depth);

      double textProtection = isFrontLayer ? 0.5 : 1.0;
      double opacity = ((0.1 + (0.9 * depth)) * textProtection).clamp(0.0, 1.0);

      double rotTheta = (p.u * 2 * math.pi) + (time * p.speed);
      double colorMix = ((math.sin(time * 2 + rotTheta * 2) + 1) / 2).clamp(0.0, 1.0);

      int colorIndex = (colorMix * 99).round().clamp(0, 99);
      Color finalColor = colorPalette[colorIndex];

      particlePaint.color = finalColor.withValues(alpha: opacity);
      Offset screenPos = Offset(center.dx + x, center.dy + y);

      canvas.drawCircle(screenPos, drawSize, particlePaint);

      if (depth > 0.85) {
        glowPaint.color = finalColor.withValues(alpha: (opacity * 0.15).clamp(0.0, 1.0));
        canvas.drawCircle(screenPos, drawSize * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NanoParticlePainter oldDelegate) => true;
}
