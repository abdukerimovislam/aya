import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  final CyclePhase? phase;
  final bool phaseAware;
  final double phaseTintStrength;

  final bool showAccentLine;
  final bool showAmbientGlow;
  final bool showAccentOrb;
  final bool elevated;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 28,
    this.phase,
    this.phaseAware = false,
    this.phaseTintStrength = 0.11,
    this.showAccentLine = false,
    this.showAmbientGlow = true,
    this.showAccentOrb = false,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool usePhaseTint = phaseAware && phase != null;
    final Color phaseColor =
    usePhaseTint ? AppColors.phaseTint(phase!) : AppColors.primary;

    final Color baseColor = Color.lerp(
      AppColors.tintedSurface,
      AppColors.secondaryBackground,
      0.55,
    ) ??
        AppColors.tintedSurface;

    final Color cardBackground = usePhaseTint
        ? Color.lerp(
      baseColor,
      phaseColor.withOpacity(0.16),
      phaseTintStrength,
    ) ??
        baseColor
        : baseColor;

    final Color deepLayer = usePhaseTint
        ? Color.lerp(
      AppColors.secondaryBackground,
      phaseColor.withOpacity(0.12),
      0.42,
    ) ??
        AppColors.secondaryBackground
        : AppColors.secondaryBackground;

    final Color outerBorder = usePhaseTint
        ? phaseColor.withOpacity(0.22)
        : AppColors.divider.withOpacity(0.85);

    final Color innerBorder = usePhaseTint
        ? phaseColor.withOpacity(0.10)
        : Colors.white.withOpacity(0.18);

    final Color ambientGlow = usePhaseTint
        ? phaseColor.withOpacity(0.14)
        : AppColors.primary.withOpacity(0.09);

    final Color accent = usePhaseTint ? phaseColor : AppColors.primary;

    final double r = borderRadius;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: elevated
            ? [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: ambientGlow.withOpacity(0.42),
            blurRadius: 28,
            offset: const Offset(0, 8),
            spreadRadius: -12,
          ),
        ]
            : [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          border: Border.all(
            color: outerBorder,
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(cardBackground, Colors.white, 0.10) ?? cardBackground,
              cardBackground,
              deepLayer,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r - 0.5),
          child: Stack(
            children: [
              if (showAmbientGlow)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.78, -0.92),
                          radius: 1.08,
                          colors: [
                            ambientGlow,
                            ambientGlow.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.34, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.95, 1.0),
                        radius: 1.0,
                        colors: [
                          Colors.white.withOpacity(0.07),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Верхний мягкий berry sheen
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: (height ?? 220) * 0.34,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.16),
                          accent.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Глубина снизу
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: (height ?? 220) * 0.42,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.textPrimary.withOpacity(0.025),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Внутренняя рамка не белая, а мягкая цветная
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.all(1.15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(r - 1.5),
                      border: Border.all(
                        color: innerBorder,
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              // Accent line
              if (showAccentLine)
                Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  child: IgnorePointer(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            accent.withOpacity(0.10),
                            accent.withOpacity(0.82),
                            accent.withOpacity(0.10),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.20),
                            blurRadius: 10,
                            spreadRadius: -3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (showAccentOrb)
                Positioned(
                  top: 14,
                  right: 14,
                  child: IgnorePointer(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.85),
                            accent.withOpacity(0.95),
                            accent.withOpacity(0.45),
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.28),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Silk tint texture
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.045,
                    child: CustomPaint(
                      painter: _SilkTintPainter(
                        color: accent,
                        borderRadius: r,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: padding ?? const EdgeInsets.all(18),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SilkTintPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  const _SilkTintPainter({
    required this.color,
    required this.borderRadius,
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

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withOpacity(0.16)
      ..strokeWidth = 0.75;

    const gap = 20.0;
    for (double x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SilkTintPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}