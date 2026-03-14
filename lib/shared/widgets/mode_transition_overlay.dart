import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

enum TransitionMode { tracking, coc, ttc }

class ModeTransitionOverlay extends StatefulWidget {
  final TransitionMode mode;
  final String message;
  final VoidCallback onComplete;

  const ModeTransitionOverlay({
    super.key,
    required this.mode,
    required this.message,
    required this.onComplete,
  });

  static void show(BuildContext context, TransitionMode mode, String message, {required VoidCallback onComplete}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: ModeTransitionOverlay(
            mode: mode,
            message: message,
            onComplete: onComplete,
          ),
        ),
      ),
    );
  }

  @override
  State<ModeTransitionOverlay> createState() => _ModeTransitionOverlayState();
}

class _ModeTransitionOverlayState extends State<ModeTransitionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _bgOpacity;
  late Animation<double> _circleScale;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200), // Оптимальное время
    );

    // 1. Фон затемняется быстро
    _bgOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 90),
    ]).animate(_controller);

    // 2. Анимация круга (Появление -> Пульс -> Взрыв на весь экран)
    _circleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20, // 0-20% времени: Прыжок
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50, // 20-70% времени: Дыхание
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 35.0).chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 30, // 70-100% времени: Расширение на весь экран!
      ),
    ]).animate(_controller);

    // 3. Анимация контента (Иконка и Текст исчезают перед взрывом)
    _contentOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10), // Исчезают быстро
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color bgColor;
    List<Color> gradientColors;

    switch (widget.mode) {
      case TransitionMode.tracking:
        icon = CupertinoIcons.drop_fill;
        bgColor = AppColors.menstruation;
        gradientColors = [AppColors.menstruation, Colors.pinkAccent];
        break;
      case TransitionMode.coc:
        icon = CupertinoIcons.shield_fill;
        bgColor = Colors.teal;
        gradientColors = [Colors.teal, Colors.tealAccent.shade700];
        break;
      case TransitionMode.ttc:
        icon = CupertinoIcons.heart_circle_fill;
        bgColor = Colors.purple;
        gradientColors = [Colors.purple, Colors.pinkAccent];
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            // Затемнение фона
            color: AppColors.background.withOpacity(_bgOpacity.value * 0.95),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [

                  // 🔥 СЛОЙ 1: Расширяющийся круг
                  Transform.scale(
                    scale: _circleScale.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: bgColor.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),

                  // 🔥 СЛОЙ 2: Иконка и Текст (растворяются)
                  Opacity(
                    opacity: _contentOpacity.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Icon(icon, size: 56, color: Colors.white),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}