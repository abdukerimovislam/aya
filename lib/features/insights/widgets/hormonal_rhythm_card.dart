import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';

class HormonalRhythmCard extends StatefulWidget {
  final CycleData data;
  final Map<int, List<String>> dailySymptoms;

  const HormonalRhythmCard({
    super.key,
    required this.data,
    required this.dailySymptoms,
  });

  @override
  State<HormonalRhythmCard> createState() => _HormonalRhythmCardState();
}

class _HormonalRhythmCardState extends State<HormonalRhythmCard> {
  int? _focusedDay;

  int get _safeCycleLength {
    final length = widget.data.totalCycleLength;
    return length > 0 ? length : 28;
  }

  int get _safeCurrentDay {
    return widget.data.dayOfCycle.clamp(1, _safeCycleLength);
  }

  int get _safeOvulationDay {
    final approx = (_safeCycleLength / 2).floor() + 2;
    return approx.clamp(1, _safeCycleLength);
  }

  static const Color _cardBgTop = Color(0xFFFFFBFC);
  static const Color _cardBgBottom = Color(0xFFFDF1F5);
  static const Color _cardStroke = Color(0xFFF2DCE4);
  static const Color _titleColor = Color(0xFF4B313A);
  static const Color _subtitleColor = Color(0xFF8D7580);
  static const Color _secondaryCurve = Color(0xFFB892C8);
  static const Color _softGrid = Color(0xFFF1E3E8);
  static const Color _tooltipBg = Color(0xFFFFFCFD);
  static const Color _pillBg = Color(0xFFFFF8FA);
  static const Color _pillBorder = Color(0xFFF1DCE4);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 368,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [_cardBgTop, _cardBgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _cardStroke,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 14,
            offset: const Offset(0, -2),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SoftFeminineBackdropPainter(
                  accent: AppColors.primary,
                  secondary: _secondaryCurve,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: (_) {
                  setState(() => _focusedDay = null);
                },
                onTapDown: (details) {
                  _calculateFocus(details.localPosition);
                },
                child: CustomPaint(
                  painter: _HormoneWavePainter(
                    cycleLength: _safeCycleLength,
                    currentDay: _safeCurrentDay,
                    ovulationDay: _safeOvulationDay,
                    focusedDay: _focusedDay,
                    dailySymptoms: widget.dailySymptoms,
                    primaryCurve: AppColors.primary,
                    secondaryCurve: _secondaryCurve,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeader()),
                  if (_focusedDay != null) ...[
                    const SizedBox(width: 12),
                    _buildTooltip(_focusedDay!),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: _buildBottomPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hormonal Rhythm',
          style: GoogleFonts.outfit(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _titleColor,
            height: 1,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A soft view of estrogen and progesterone across your cycle.',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: _subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildLegendChip(
              label: 'Estrogen',
              color: AppColors.primary,
            ),
            _buildLegendChip(
              label: 'Progesterone',
              color: _secondaryCurve,
            ),
            _buildLegendChip(
              label: 'Symptoms',
              color: Colors.white,
              isGhost: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendChip({
    required String label,
    required Color color,
    bool isGhost = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: isGhost ? Colors.white.withOpacity(0.78) : Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _pillBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(int day) {
    final symptoms = widget.dailySymptoms[day] ?? [];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 158,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _tooltipBg.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _pillBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Day $day',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _phaseLabelForDay(day),
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _subtitleColor,
                ),
              ),
              const SizedBox(height: 10),
              if (symptoms.isEmpty)
                Text(
                  'No symptoms logged',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _subtitleColor,
                    height: 1.3,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...symptoms.take(3).map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          item,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _titleColor,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                    if (symptoms.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+${symptoms.length - 3} more',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _subtitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _pillBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildPhasePill(
                  'Menstrual',
                  isActive: _safeCurrentDay <= 5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhasePill(
                  'Follicular',
                  isActive: _safeCurrentDay > 5 &&
                      _safeCurrentDay < _safeOvulationDay,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhasePill(
                  'Ovulation',
                  isActive: (_safeCurrentDay - _safeOvulationDay).abs() <= 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhasePill(
                  'Luteal',
                  isActive: _safeCurrentDay > _safeOvulationDay,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Day $_safeCurrentDay of $_safeCycleLength',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _titleColor.withOpacity(0.78),
              ),
            ),
            const Spacer(),
            Text(
              _focusedDay == null
                  ? 'Touch the chart to inspect'
                  : 'Scrubbing day ${_focusedDay!}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _subtitleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhasePill(String label, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.12)
            : _pillBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.20)
              : _pillBorder,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? AppColors.primary : _subtitleColor,
          ),
        ),
      ),
    );
  }

  String _phaseLabelForDay(int day) {
    if (day <= 5) return 'Menstrual phase';
    if (day < _safeOvulationDay) return 'Follicular phase';
    if ((day - _safeOvulationDay).abs() <= 1) return 'Ovulation window';
    return 'Luteal phase';
  }

  void _handlePanStart(DragStartDetails details) {
    _calculateFocus(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _calculateFocus(details.localPosition);
  }

  void _calculateFocus(Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;

    const horizontalPadding = 22.0;
    final graphWidth = size.width - horizontalPadding * 2;

    double normalizedX = (localPosition.dx - horizontalPadding) / graphWidth;
    normalizedX = normalizedX.clamp(0.0, 1.0);

    final day = (normalizedX * (_safeCycleLength - 1)).round() + 1;

    if (_focusedDay != day) {
      setState(() => _focusedDay = day);
      HapticFeedback.selectionClick();
    }
  }
}

class _SoftFeminineBackdropPainter extends CustomPainter {
  final Color accent;
  final Color secondary;

  _SoftFeminineBackdropPainter({
    required this.accent,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glowTopLeft = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.16, size.height * 0.16),
        size.width * 0.42,
        [
          accent.withOpacity(0.12),
          Colors.transparent,
        ],
      );

    final glowBottomRight = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.82, size.height * 0.72),
        size.width * 0.34,
        [
          secondary.withOpacity(0.10),
          Colors.transparent,
        ],
      );

    final softCenter = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.50, size.height * 0.45),
        size.width * 0.28,
        [
          Colors.white.withOpacity(0.42),
          Colors.transparent,
        ],
      );

    canvas.drawRect(Offset.zero & size, glowTopLeft);
    canvas.drawRect(Offset.zero & size, glowBottomRight);
    canvas.drawRect(Offset.zero & size, softCenter);
  }

  @override
  bool shouldRepaint(covariant _SoftFeminineBackdropPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.secondary != secondary;
  }
}

class _HormoneWavePainter extends CustomPainter {
  final int cycleLength;
  final int currentDay;
  final int ovulationDay;
  final int? focusedDay;
  final Map<int, List<String>> dailySymptoms;
  final Color primaryCurve;
  final Color secondaryCurve;

  _HormoneWavePainter({
    required this.cycleLength,
    required this.currentDay,
    required this.ovulationDay,
    required this.focusedDay,
    required this.dailySymptoms,
    required this.primaryCurve,
    required this.secondaryCurve,
  });

  static const Color _gridColor = Color(0xFFF0E0E7);
  static const Color _textColor = Color(0xFF4B313A);
  static const Color _subtleText = Color(0xFF8D7580);

  @override
  void paint(Canvas canvas, Size size) {
    if (cycleLength < 2) return;

    const horizontalPadding = 22.0;
    const chartTop = 92.0;
    const chartBottom = 82.0;

    final width = size.width;
    final height = size.height;
    final graphWidth = width - horizontalPadding * 2;
    final graphHeight = height - chartTop - chartBottom;

    double xForDay(int day) {
      return horizontalPadding +
          ((day - 1) / (cycleLength - 1)) * graphWidth;
    }

    double estrogenLevel(int day) {
      if (day <= ovulationDay) {
        return math.sin((day / ovulationDay) * (math.pi / 2));
      } else {
        final lutealDays = math.max(1, cycleLength - ovulationDay);
        final currentLuteal = day - ovulationDay;
        return 0.30 + 0.28 * math.sin((currentLuteal / lutealDays) * math.pi);
      }
    }

    double progesteroneLevel(int day) {
      if (day <= ovulationDay) {
        return 0.10;
      } else {
        final lutealDays = math.max(1, cycleLength - ovulationDay);
        final currentLuteal = day - ovulationDay;
        return math.sin((currentLuteal / lutealDays) * math.pi);
      }
    }

    double yForEstrogen(int day) {
      return height - chartBottom - (estrogenLevel(day) * graphHeight * 0.68);
    }

    double yForProgesterone(int day) {
      return height - chartBottom -
          (progesteroneLevel(day) * graphHeight * 0.80);
    }

    _drawGrid(canvas, size, chartTop, chartBottom);

    final estrogenPoints = <Offset>[];
    final progesteronePoints = <Offset>[];

    for (int i = 1; i <= cycleLength; i++) {
      estrogenPoints.add(Offset(xForDay(i), yForEstrogen(i)));
      progesteronePoints.add(Offset(xForDay(i), yForProgesterone(i)));
    }

    final estrogenPath = _buildSmoothPath(estrogenPoints);
    final progesteronePath = _buildSmoothPath(progesteronePoints);

    final estrogenFill = Path.from(estrogenPath)
      ..lineTo(xForDay(cycleLength), height - chartBottom)
      ..lineTo(xForDay(1), height - chartBottom)
      ..close();

    final progesteroneFill = Path.from(progesteronePath)
      ..lineTo(xForDay(cycleLength), height - chartBottom)
      ..lineTo(xForDay(1), height - chartBottom)
      ..close();

    final estrogenFillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, chartTop),
        Offset(0, height - chartBottom),
        [
          primaryCurve.withOpacity(0.20),
          primaryCurve.withOpacity(0.00),
        ],
      );

    final progesteroneFillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, chartTop),
        Offset(0, height - chartBottom),
        [
          secondaryCurve.withOpacity(0.20),
          secondaryCurve.withOpacity(0.00),
        ],
      );

    canvas.drawPath(estrogenFill, estrogenFillPaint);
    canvas.drawPath(progesteroneFill, progesteroneFillPaint);

    final estrogenPaint = Paint()
      ..color = primaryCurve
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final progesteronePaint = Paint()
      ..color = secondaryCurve
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(estrogenPath, estrogenPaint);
    canvas.drawPath(progesteronePath, progesteronePaint);

    _drawSymptoms(
      canvas,
      xForDay: xForDay,
      yForEstrogen: yForEstrogen,
      yForProgesterone: yForProgesterone,
    );

    if (focusedDay == null) {
      final currentX = xForDay(currentDay.clamp(1, cycleLength));
      _drawDashedLine(
        canvas,
        Offset(currentX, chartTop + 4),
        Offset(currentX, height - chartBottom + 2),
        primaryCurve.withOpacity(0.32),
      );

      final todayLabel = TextPainter(
        text: TextSpan(
          text: 'TODAY',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: _subtleText,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      todayLabel.paint(
        canvas,
        Offset(currentX - todayLabel.width / 2, chartTop - 18),
      );
    }

    if (focusedDay != null) {
      final focusX = xForDay(focusedDay!);
      final yEst = yForEstrogen(focusedDay!);
      final yProg = yForProgesterone(focusedDay!);

      final focusLinePaint = Paint()
        ..color = primaryCurve.withOpacity(0.82)
        ..strokeWidth = 1.4;

      canvas.drawLine(
        Offset(focusX, chartTop),
        Offset(focusX, height - chartBottom + 2),
        focusLinePaint,
      );

      canvas.drawCircle(
        Offset(focusX, yEst),
        7,
        Paint()..color = primaryCurve.withOpacity(0.16),
      );
      canvas.drawCircle(
        Offset(focusX, yProg),
        7,
        Paint()..color = secondaryCurve.withOpacity(0.16),
      );

      canvas.drawCircle(
        Offset(focusX, yEst),
        5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(focusX, yProg),
        5,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        Offset(focusX, yEst),
        3.7,
        Paint()..color = primaryCurve,
      );
      canvas.drawCircle(
        Offset(focusX, yProg),
        3.7,
        Paint()..color = secondaryCurve,
      );
    }
  }

  void _drawGrid(
      Canvas canvas,
      Size size,
      double chartTop,
      double chartBottom,
      ) {
    final paint = Paint()
      ..color = _gridColor
      ..strokeWidth = 1;

    final usableHeight = size.height - chartTop - chartBottom;

    for (int i = 0; i < 3; i++) {
      final y = chartTop + (usableHeight / 2) * i;
      canvas.drawLine(
        Offset(22, y),
        Offset(size.width - 22, y),
        paint,
      );
    }
  }

  void _drawSymptoms(
      Canvas canvas, {
        required double Function(int) xForDay,
        required double Function(int) yForEstrogen,
        required double Function(int) yForProgesterone,
      }) {
    for (int day = 1; day <= cycleLength; day++) {
      final symptoms = dailySymptoms[day];
      if (symptoms == null || symptoms.isEmpty) continue;

      final x = xForDay(day);
      final y = (yForEstrogen(day) + yForProgesterone(day)) / 2;
      final severity = symptoms.length;
      final radius = (3.4 + severity * 1.15).clamp(3.6, 8.2);

      final haloPaint = Paint()
        ..color = AppColors.primary.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final corePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            Colors.white.withOpacity(0.96),
            AppColors.primary.withOpacity(0.30),
          ],
        );

      canvas.drawCircle(Offset(x, y), radius + 2.2, haloPaint);
      canvas.drawCircle(Offset(x, y), radius, corePaint);
    }
  }

  Path _buildSmoothPath(List<Offset> points) {
    if (points.length < 2) return Path();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;

      path.cubicTo(
        controlX,
        current.dy,
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;

    final distance = (p2 - p1).distance;
    const dashWidth = 5.0;
    const dashSpace = 5.0;

    double startX = p1.dx;
    double startY = p1.dy;

    final dx = (p2.dx - p1.dx) / distance;
    final dy = (p2.dy - p1.dy) / distance;

    double currentDistance = 0;
    while (currentDistance < distance) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + dx * dashWidth, startY + dy * dashWidth),
        paint,
      );
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _HormoneWavePainter oldDelegate) {
    return oldDelegate.cycleLength != cycleLength ||
        oldDelegate.currentDay != currentDay ||
        oldDelegate.ovulationDay != ovulationDay ||
        oldDelegate.focusedDay != focusedDay ||
        oldDelegate.dailySymptoms != dailySymptoms ||
        oldDelegate.primaryCurve != primaryCurve ||
        oldDelegate.secondaryCurve != secondaryCurve;
  }
}