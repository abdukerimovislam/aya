import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
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
      duration: const Duration(seconds: 18),
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

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;

          return IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base gradient
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.baseTop,
                        palette.baseBottom,
                      ],
                    ),
                  ),
                ),

                // Soft central light wash
                Align(
                  alignment: const Alignment(0.0, -0.15),
                  child: Container(
                    width: 420,
                    height: 420,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.38, 1.0],
                      ),
                    ),
                  ),
                ),

                // Large floating blobs
                _MovingBlob(
                  size: 320,
                  dx: 42 * math.cos(t * 0.95),
                  dy: 34 * math.sin(t * 0.80),
                  alignment: const Alignment(-0.95, -0.82),
                  color: palette.blobA,
                  opacity: 0.42,
                ),
                _MovingBlob(
                  size: 420,
                  dx: 28 * math.sin(t * 0.72),
                  dy: 44 * math.cos(t * 0.88),
                  alignment: const Alignment(1.00, -0.10),
                  color: palette.blobB,
                  opacity: 0.34,
                ),
                _MovingBlob(
                  size: 280,
                  dx: 24 * math.cos(t * 1.12),
                  dy: 36 * math.sin(t * 0.64),
                  alignment: const Alignment(-0.10, 1.05),
                  color: palette.blobC,
                  opacity: 0.28,
                ),

                // Extra soft highlight for depth
                Align(
                  alignment: const Alignment(0.7, 0.75),
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.highlight.withOpacity(0.18),
                    ),
                  ),
                ),

                // Heavy blur to get that modern glass/wellness look
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: Container(color: Colors.transparent),
                ),

                // Subtle tint overlay to unify the composition
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.04),
                        palette.overlay.withOpacity(0.08),
                        palette.overlay.withOpacity(0.14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                color.withOpacity(opacity * 0.55),
                color.withOpacity(0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
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
      return const _PhasePalette(
        baseTop: Color(0xFFF8FBFF),
        baseBottom: Color(0xFFF3F8F7),
        blobA: Color(0xFFAEDFF2),
        blobB: Color(0xFFCDECCF),
        blobC: Color(0xFFE3D9FF),
        highlight: Color(0xFFFFFFFF),
        overlay: Color(0xFFDCEFF1),
      );
    }

    switch (phase) {
      case CyclePhase.menstruation:
        return const _PhasePalette(
          baseTop: Color(0xFFFFF7F9),
          baseBottom: Color(0xFFFFEEF2),
          blobA: Color(0xFFFF8FA8),
          blobB: Color(0xFFFFC2CF),
          blobC: Color(0xFFFFD9E2),
          highlight: Color(0xFFFFFFFF),
          overlay: Color(0xFFFFD6E0),
        );

      case CyclePhase.follicular:
        return const _PhasePalette(
          baseTop: Color(0xFFF7FFF9),
          baseBottom: Color(0xFFF1FBF7),
          blobA: Color(0xFFA8E6CF),
          blobB: Color(0xFFCDEFD9),
          blobC: Color(0xFFBFE7E3),
          highlight: Color(0xFFFFFFFF),
          overlay: Color(0xFFD7F3E7),
        );

      case CyclePhase.ovulation:
        return const _PhasePalette(
          baseTop: Color(0xFFFFFCF6),
          baseBottom: Color(0xFFFFF5EC),
          blobA: Color(0xFFFFD6A5),
          blobB: Color(0xFFFFE6BF),
          blobC: Color(0xFFFFD9C8),
          highlight: Color(0xFFFFFFFF),
          overlay: Color(0xFFFFE7C9),
        );

      case CyclePhase.luteal:
        return const _PhasePalette(
          baseTop: Color(0xFFFAF7FF),
          baseBottom: Color(0xFFF4F0FF),
          blobA: Color(0xFFD8B4FE),
          blobB: Color(0xFFC7D2FE),
          blobC: Color(0xFFE4D7FF),
          highlight: Color(0xFFFFFFFF),
          overlay: Color(0xFFE5DEFF),
        );

      case CyclePhase.late:
        return const _PhasePalette(
          baseTop: Color(0xFFF8FAFC),
          baseBottom: Color(0xFFF1F5F9),
          blobA: Color(0xFFD7DEE7),
          blobB: Color(0xFFC7D2DA),
          blobC: Color(0xFFE5EAF0),
          highlight: Color(0xFFFFFFFF),
          overlay: Color(0xFFDDE5EC),
        );
    }
  }
}