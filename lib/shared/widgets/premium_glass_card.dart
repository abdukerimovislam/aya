import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';

class PremiumGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  /// Optional cycle phase tint
  final CyclePhase? phase;

  /// Disable if a neutral card is needed
  final bool phaseAware;

  /// 0.0 - 1.0, recommended range: 0.06 - 0.18
  final double phaseTintStrength;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 24,
    this.phase,
    this.phaseAware = true,
    this.phaseTintStrength = 0.14,
  });

  @override
  State<PremiumGlassCard> createState() => _PremiumGlassCardState();
}

class _PremiumGlassCardState extends State<PremiumGlassCard> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      if (!mounted) return;

      final nextX = (event.x / 18).clamp(-0.45, 0.45);
      final nextY = (event.y / 18).clamp(-0.45, 0.45);

      if ((nextX - _tiltX).abs() < 0.01 && (nextY - _tiltY).abs() < 0.01) {
        return;
      }

      setState(() {
        _tiltX = nextX;
        _tiltY = nextY;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool usePhaseTint = widget.phaseAware && widget.phase != null;
    final Color phaseColor =
    usePhaseTint ? AppColors.phaseTint(widget.phase!) : AppColors.primary;

    final Color topColor = Color.lerp(
      AppColors.glassBase,
      phaseColor,
      widget.phaseTintStrength * 0.22,
    )!;
    final Color midColor = Color.lerp(
      AppColors.glassSecondary,
      phaseColor,
      widget.phaseTintStrength * 0.38,
    )!;
    final Color bottomColor = Color.lerp(
      AppColors.background,
      phaseColor,
      widget.phaseTintStrength * 0.46,
    )!;

    final borderRadius = BorderRadius.circular(widget.borderRadius);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  topColor.withOpacity(0.84),
                  midColor.withOpacity(0.68),
                  bottomColor.withOpacity(0.46),
                ],
              ),
              border: Border.all(
                color: AppColors.glassBorder.withOpacity(0.68),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(
                    AppColors.glassShadow,
                    phaseColor,
                    0.35,
                  )!
                      .withOpacity(usePhaseTint ? 0.18 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _GlassCardPainter(
                borderRadius: widget.borderRadius,
                phaseColor: phaseColor,
                phaseAware: usePhaseTint,
                tiltX: _tiltX,
                tiltY: _tiltY,
              ),
              child: Padding(
                padding: widget.padding ?? EdgeInsets.zero,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCardPainter extends CustomPainter {
  final double borderRadius;
  final Color phaseColor;
  final bool phaseAware;
  final double tiltX;
  final double tiltY;

  const _GlassCardPainter({
    required this.borderRadius,
    required this.phaseColor,
    required this.phaseAware,
    required this.tiltX,
    required this.tiltY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    _paintTopSoftLight(canvas, size);
    _paintRadialGlow(canvas, size);
    _paintMovingSheen(canvas, size);
    _paintBottomTint(canvas, size);

    canvas.restore();
  }

  void _paintTopSoftLight(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.16),
          Color.fromRGBO(255, 255, 255, 0.00),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 56));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 56), paint);
  }

  void _paintRadialGlow(Canvas canvas, Size size) {
    final glowColor = phaseAware
        ? phaseColor.withOpacity(0.08)
        : AppColors.primary.withOpacity(0.05);

    final rect = Rect.fromCircle(
      center: Offset(size.width * 0.28, size.height * 0.18),
      radius: size.longestSide * 0.72,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.55),
        radius: 1.1,
        colors: [
          Colors.white.withOpacity(0.24),
          glowColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(rect);

    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintMovingSheen(Canvas canvas, Size size) {
    final sheenColor = phaseAware
        ? phaseColor.withOpacity(0.10)
        : AppColors.primary.withOpacity(0.07);

    final begin = Alignment(-1.0 - tiltX, -0.8 + tiltY);
    final end = Alignment(1.0 - tiltX, 0.8 + tiltY);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: [
          Colors.transparent,
          sheenColor,
          Colors.white.withOpacity(0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.55, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintBottomTint(Canvas canvas, Size size) {
    final tint = phaseAware
        ? phaseColor.withOpacity(0.12)
        : AppColors.primary.withOpacity(0.08);

    final h = size.height.clamp(0.0, 72.0);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          tint,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height - h, size.width, h));

    canvas.drawRect(Rect.fromLTWH(0, size.height - h, size.width, h), paint);
  }

  @override
  bool shouldRepaint(covariant _GlassCardPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.phaseColor != phaseColor ||
        oldDelegate.phaseAware != phaseAware ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY;
  }
}