import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AnimatedEdgeButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color textColor;
  final Color bgColor;
  final VoidCallback onTap;
  final bool isPulsing;

  const AnimatedEdgeButton({super.key, required this.text, required this.icon, required this.textColor, required this.bgColor, required this.onTap, this.isPulsing = false});

  @override
  State<AnimatedEdgeButton> createState() => _AnimatedEdgeButtonState();
}

class _AnimatedEdgeButtonState extends State<AnimatedEdgeButton> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.isPulsing ? widget.bgColor : (widget.bgColor == Colors.white || widget.bgColor.opacity < 1 ? AppColors.primary : widget.bgColor);
    const double buttonHeight = 68.0;
    const double borderWidth = 2.5;
    final outerRadius = BorderRadius.circular(buttonHeight / 2);
    final innerRadius = BorderRadius.circular((buttonHeight / 2) - borderWidth);

    return Container(
      height: buttonHeight,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: outerRadius,
        boxShadow: [BoxShadow(color: glowColor.withOpacity(widget.isPulsing ? 0.6 : 0.2), blurRadius: widget.isPulsing ? 30 : 15, spreadRadius: widget.isPulsing ? 4 : 0, offset: const Offset(0, 8))],
      ),
      child: GestureDetector(
        onTap: () { HapticFeedback.mediumImpact(); widget.onTap(); },
        child: ClipRRect(
          borderRadius: outerRadius,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) => Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Transform.scale(
                      scale: 3.0,
                      child: Container(decoration: BoxDecoration(gradient: SweepGradient(colors: [glowColor.withOpacity(0.0), glowColor, glowColor.withOpacity(0.0)], stops: const [0.35, 0.5, 0.65]))),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: borderWidth, bottom: borderWidth, left: borderWidth, right: borderWidth,
                child: Container(
                  decoration: BoxDecoration(color: widget.bgColor, borderRadius: innerRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(widget.icon, color: widget.textColor, size: 24), const SizedBox(width: 14), Text(widget.text, style: GoogleFonts.inter(color: widget.textColor, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}