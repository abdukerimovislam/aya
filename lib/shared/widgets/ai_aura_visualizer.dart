import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AiAuraVisualizer extends StatefulWidget {
  final double size;
  final bool isThinking;

  const AiAuraVisualizer({
    super.key,
    this.size = 200,
    this.isThinking = false,
  });

  @override
  State<AiAuraVisualizer> createState() => _AiAuraVisualizerState();
}

class _AiAuraVisualizerState extends State<AiAuraVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _targetDuration =>
      widget.isThinking ? const Duration(seconds: 4) : const Duration(seconds: 9);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _targetDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AiAuraVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isThinking != widget.isThinking) {
      _controller.duration = _targetDuration;
      _controller
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;

    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Внешний мягкий halo
              _OuterHalo(
                size: s,
                animationValue: _controller.value,
                isThinking: widget.isThinking,
              ),

              // 2. Орбитальные частицы
              CustomPaint(
                size: Size.square(s),
                painter: _OrbitParticlesPainter(
                  animationValue: _controller.value,
                  isThinking: widget.isThinking,
                ),
              ),

              // 3. Главная сфера
              CustomPaint(
                size: Size.square(s),
                painter: _AuraSpherePainter(
                  animationValue: _controller.value,
                  isThinking: widget.isThinking,
                ),
              ),

              // 4. Центральное ядро
              _CenterCore(
                size: s,
                animationValue: _controller.value,
                isThinking: widget.isThinking,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OuterHalo extends StatelessWidget {
  final double size;
  final double animationValue;
  final bool isThinking;

  const _OuterHalo({
    required this.size,
    required this.animationValue,
    required this.isThinking,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = 1 + (isThinking ? 0.045 : 0.025) * math.sin(animationValue * 2 * math.pi);

    return Transform.scale(
      scale: pulse,
      child: Container(
        width: size * 0.82,
        height: size * 0.82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2185B).withOpacity(0.20),
              blurRadius: size * 0.18,
              spreadRadius: size * 0.015,
            ),
            BoxShadow(
              color: const Color(0xFF7B3FE4).withOpacity(0.12),
              blurRadius: size * 0.24,
              spreadRadius: size * 0.01,
            ),
            BoxShadow(
              color: const Color(0xFFFFA3C1).withOpacity(0.08),
              blurRadius: size * 0.30,
              spreadRadius: size * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterCore extends StatelessWidget {
  final double size;
  final double animationValue;
  final bool isThinking;

  const _CenterCore({
    required this.size,
    required this.animationValue,
    required this.isThinking,
  });

  @override
  Widget build(BuildContext context) {
    final double t = animationValue * 2 * math.pi;
    final double pulse = 1 + (isThinking ? 0.06 : 0.03) * math.sin(t * 2);

    return Transform.scale(
      scale: pulse,
      child: Container(
        width: size * 0.28,
        height: size * 0.28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              const Color(0xFFFFF4FA).withOpacity(0.92),
              const Color(0xFFF7D7E7).withOpacity(0.70),
              const Color(0xFFE7C5FF).withOpacity(0.26),
            ],
            stops: const [0.0, 0.34, 0.72, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2185B).withOpacity(0.14),
              blurRadius: size * 0.07,
            ),
            BoxShadow(
              color: const Color(0xFF7B3FE4).withOpacity(0.10),
              blurRadius: size * 0.10,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.18,
            height: size * 0.18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.14),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              CupertinoIcons.sparkles,
              color: const Color(0xFFC2185B).withOpacity(0.9),
              size: size * 0.09,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuraSpherePainter extends CustomPainter {
  final double animationValue;
  final bool isThinking;

  _AuraSpherePainter({
    required this.animationValue,
    required this.isThinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final t = animationValue * 2 * math.pi;
    final radius = size.width * 0.34;

    final double pulse = isThinking
        ? 1 + math.sin(t * 3.2) * 0.055
        : 1 + math.sin(t * 1.4) * 0.025;

    // База сферы
    final Rect sphereRect = Rect.fromCircle(
      center: center,
      radius: radius * 1.04 * pulse,
    );

    final Paint basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF7FB).withOpacity(0.96),
          const Color(0xFFFFC1D6).withOpacity(0.72),
          const Color(0xFFC2185B).withOpacity(0.42),
          const Color(0xFF7B3FE4).withOpacity(0.24),
          const Color(0x00000000),
        ],
        stops: const [0.0, 0.22, 0.52, 0.82, 1.0],
      ).createShader(sphereRect);

    canvas.drawCircle(center, radius * 1.02 * pulse, basePaint);

    // Мягкая оболочка
    final Paint shellPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.008
      ..shader = SweepGradient(
        transform: GradientRotation(t * 0.7),
        colors: [
          Colors.white.withOpacity(0.14),
          const Color(0xFFFFB3CA).withOpacity(0.28),
          const Color(0xFFC2185B).withOpacity(0.18),
          const Color(0xFF7B3FE4).withOpacity(0.28),
          Colors.white.withOpacity(0.14),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 0.95),
      );

    canvas.drawCircle(center, radius * 0.92 * pulse, shellPaint);

    // Внутренние текучие формы
    _drawBlob(
      canvas: canvas,
      center: center,
      angle: t * 0.9,
      distance: radius * 0.12,
      width: radius * 1.28 * pulse,
      height: radius * 0.88,
      color: const Color(0xFFC2185B).withOpacity(0.34),
      blur: size.width * 0.040,
    );

    _drawBlob(
      canvas: canvas,
      center: center,
      angle: -t * 1.2 + 0.8,
      distance: radius * 0.10,
      width: radius * 1.08,
      height: radius * 1.12 * pulse,
      color: const Color(0xFF8E44EC).withOpacity(0.28),
      blur: size.width * 0.045,
    );

    _drawBlob(
      canvas: canvas,
      center: center,
      angle: t * 1.8 - 0.6,
      distance: radius * 0.06,
      width: radius * 0.70,
      height: radius * 0.70,
      color: const Color(0xFFFFD6E6).withOpacity(0.28),
      blur: size.width * 0.030,
    );

    // Внутреннее свечение
    final Paint innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.55),
          const Color(0xFFFFE7F1).withOpacity(0.32),
          const Color(0x00FFFFFF),
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 0.48),
      );

    canvas.drawCircle(center, radius * 0.48 * pulse, innerGlow);

    // Блик сверху
    final Rect highlightRect = Rect.fromCenter(
      center: Offset(center.dx - radius * 0.18, center.dy - radius * 0.24),
      width: radius * 0.78,
      height: radius * 0.44,
    );

    final Paint highlightPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.015)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.26),
          Colors.white.withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(highlightRect);

    canvas.save();
    canvas.translate(center.dx - radius * 0.04, center.dy - radius * 0.02);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 0.90,
        height: radius * 0.38,
      ),
      highlightPaint,
    );
    canvas.restore();
  }

  void _drawBlob({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double distance,
    required double width,
    required double height,
    required Color color,
    required double blur,
  }) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.save();
    canvas.translate(
      center.dx + math.cos(angle) * distance,
      center.dy + math.sin(angle) * distance,
    );
    canvas.rotate(angle * 0.75);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AuraSpherePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isThinking != isThinking;
  }
}

class _OrbitParticlesPainter extends CustomPainter {
  final double animationValue;
  final bool isThinking;

  _OrbitParticlesPainter({
    required this.animationValue,
    required this.isThinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final t = animationValue * 2 * math.pi;

    final particles = <_Particle>[
      _Particle(
        angle: t * 1.2,
        radius: size.width * 0.34,
        dotSize: size.width * 0.014,
        color: const Color(0xFFFFB3CA).withOpacity(0.85),
      ),
      _Particle(
        angle: -t * 0.95 + 1.4,
        radius: size.width * 0.29,
        dotSize: size.width * 0.011,
        color: const Color(0xFFB38CFF).withOpacity(0.72),
      ),
      _Particle(
        angle: t * 1.55 + 2.2,
        radius: size.width * 0.25,
        dotSize: size.width * 0.009,
        color: Colors.white.withOpacity(0.78),
      ),
    ];

    for (final p in particles) {
      final offset = Offset(
        center.dx + math.cos(p.angle) * p.radius,
        center.dy + math.sin(p.angle) * p.radius,
      );

      final paint = Paint()
        ..color = p.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          isThinking ? size.width * 0.008 : size.width * 0.005,
        );

      canvas.drawCircle(offset, p.dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isThinking != isThinking;
  }
}

class _Particle {
  final double angle;
  final double radius;
  final double dotSize;
  final Color color;

  _Particle({
    required this.angle,
    required this.radius,
    required this.dotSize,
    required this.color,
  });
}