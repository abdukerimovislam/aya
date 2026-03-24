import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';

class LivePhaseBackground extends StatefulWidget {
  final CyclePhase phase;
  final bool isCOC;

  const LivePhaseBackground({
    super.key,
    required this.phase,
    required this.isCOC,
  });

  @override
  State<LivePhaseBackground> createState() => _LivePhaseBackgroundState();
}

class _LivePhaseBackgroundState extends State<LivePhaseBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _PhasePalette.resolve(
      phase: widget.phase,
      isCOC: widget.isCOC,
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;
          final dynamicShift = 0.04 * math.sin(t * 0.6);

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      palette.baseTop,
                      Color.lerp(
                        palette.baseBottom,
                        palette.blobA,
                        dynamicShift.abs(),
                      )!,
                    ],
                  ),
                ),
              ),

              Align(
                alignment: const Alignment(0.0, -0.18),
                child: Container(
                  width: 430,
                  height: 430,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.white.withOpacity(0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.36, 1.0],
                    ),
                  ),
                ),
              ),

              _MovingBlob(
                size: 330,
                dx: 34 * math.cos(t * 0.92),
                dy: 28 * math.sin(t * 0.78),
                alignment: const Alignment(-0.96, -0.82),
                color: palette.blobA,
                opacity: 0.36,
              ),
              _MovingBlob(
                size: 400,
                dx: 24 * math.sin(t * 0.70),
                dy: 36 * math.cos(t * 0.86),
                alignment: const Alignment(1.02, -0.08),
                color: palette.blobB,
                opacity: 0.32,
              ),
              _MovingBlob(
                size: 280,
                dx: 22 * math.cos(t * 1.08),
                dy: 30 * math.sin(t * 0.62),
                alignment: const Alignment(-0.12, 1.03),
                color: palette.blobC,
                opacity: 0.28,
              ),

              Align(
                alignment: const Alignment(0.72, 0.78),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.highlight.withOpacity(0.14),
                  ),
                ),
              ),

              // 🔥 ОПТИМИЗАЦИЯ ПРОИЗВОДИТЕЛЬНОСТИ (Снижен sigma до 35 для предотвращения лагов на Android/старых iOS)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(color: Colors.transparent),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.04),
                      palette.overlay.withOpacity(0.10),
                      palette.overlay.withOpacity(0.16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MovingBlob extends StatelessWidget {
  final double size;
  final double dx;
  final double dy;
  final Alignment alignment;
  final Color color;
  final double opacity;

  const _MovingBlob({
    required this.size,
    required this.dx,
    required this.dy,
    required this.alignment,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(opacity),
                color.withOpacity(opacity * 0.5),
                color.withOpacity(0.0),
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhasePalette {
  final Color baseTop;
  final Color baseBottom;
  final Color blobA;
  final Color blobB;
  final Color blobC;
  final Color highlight;
  final Color overlay;

  const _PhasePalette({
    required this.baseTop,
    required this.baseBottom,
    required this.blobA,
    required this.blobB,
    required this.blobC,
    required this.highlight,
    required this.overlay,
  });

  static _PhasePalette resolve({
    required CyclePhase phase,
    required bool isCOC,
  }) {
    if (isCOC) {
      return _build(
        accentA: const Color(0xFFCFE6E9),
        accentB: const Color(0xFFD9E8F7),
        accentC: const Color(0xFFE9E3FA),
        baseMixTop: 0.06,
        baseMixBottom: 0.12,
      );
    }

    switch (phase) {
      case CyclePhase.menstruation:
        return _build(
          accentA: AppColors.menstruation,
          accentB: const Color(0xFFFFD5DF),
          accentC: const Color(0xFFFFE8EE),
          baseMixTop: 0.07,
          baseMixBottom: 0.14,
        );

      case CyclePhase.follicular:
        return _build(
          accentA: AppColors.follicular,
          accentB: const Color(0xFFE0F7F2),
          accentC: const Color(0xFFF0FBF8),
          baseMixTop: 0.06,
          baseMixBottom: 0.12,
        );

      case CyclePhase.ovulation:
        return _build(
          accentA: AppColors.ovulation,
          accentB: const Color(0xFFDDE8FF),
          accentC: const Color(0xFFF1F5FF),
          baseMixTop: 0.065,
          baseMixBottom: 0.125,
        );

      case CyclePhase.luteal:
        return _build(
          accentA: AppColors.luteal,
          accentB: const Color(0xFFF0E2FA),
          accentC: const Color(0xFFF8F0FD),
          baseMixTop: 0.065,
          baseMixBottom: 0.13,
        );

      case CyclePhase.late:
        return _build(
          accentA: AppColors.late,
          accentB: const Color(0xFFFFEFD7),
          accentC: const Color(0xFFFFF7EA),
          baseMixTop: 0.055,
          baseMixBottom: 0.11,
        );
    }
  }

  static _PhasePalette _build({
    required Color accentA,
    required Color accentB,
    required Color accentC,
    required double baseMixTop,
    required double baseMixBottom,
  }) {
    return _PhasePalette(
      baseTop: Color.lerp(AppColors.background, accentA, baseMixTop)!,
      baseBottom: Color.lerp(AppColors.background, accentB, baseMixBottom)!,
      blobA: accentA,
      blobB: accentB,
      blobC: accentC,
      highlight: Colors.white,
      overlay: Color.lerp(accentA, accentB, 0.45)!,
    );
  }
}