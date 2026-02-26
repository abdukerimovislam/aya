import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/cycle_model.dart';

class LivePhaseBackground extends StatefulWidget {
  final CyclePhase phase;
  final bool isCOC;

  const LivePhaseBackground({super.key, required this.phase, required this.isCOC});

  @override
  State<LivePhaseBackground> createState() => _LivePhaseBackgroundState();
}

class _LivePhaseBackgroundState extends State<LivePhaseBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color1, color2;
    if (widget.isCOC) {
      color1 = const Color(0xFFE0F7FA); color2 = const Color(0xFFF1F8E9);
    } else {
      switch (widget.phase) {
        case CyclePhase.menstruation: color1 = const Color(0xFFFFEBEE); color2 = const Color(0xFFFFCDD2); break;
        case CyclePhase.follicular: color1 = const Color(0xFFE8F5E9); color2 = const Color(0xFFE0F2F1); break;
        case CyclePhase.ovulation: color1 = const Color(0xFFFFF3E0); color2 = const Color(0xFFFBE9E7); break;
        case CyclePhase.luteal: color1 = const Color(0xFFF3E5F5); color2 = const Color(0xFFE8EAF6); break;
        case CyclePhase.late: color1 = const Color(0xFFECEFF1); color2 = const Color(0xFFCFD8DC); break;
      }
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(left: 50 * math.cos(_controller.value * 2 * math.pi), top: 100 * math.sin(_controller.value * 2 * math.pi), child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: color1.withOpacity(0.8)))),
            Positioned(right: 20 * math.cos(_controller.value * 2 * math.pi), bottom: 150 * math.sin(_controller.value * 2 * math.pi), child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: color2.withOpacity(0.8)))),
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
          ],
        );
      },
    );
  }
}