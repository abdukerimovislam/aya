import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class PremiumGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  State<PremiumGlassCard> createState() => _PremiumGlassCardState();
}

class _PremiumGlassCardState extends State<PremiumGlassCard> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  @override
  void initState() {
    super.initState();
    // Слушаем гироскоп/акселерометр для создания эффекта параллакса блика
    _accelSubscription = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen((event) {
      if (!mounted) return;
      setState(() {
        // Ограничиваем значения, чтобы блик не улетал слишком далеко
        _tiltX = (event.x / 10).clamp(-1.0, 1.0);
        _tiltY = (event.y / 10).clamp(-1.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
              // 🔥 Гироскопический блик! Он смещается при наклоне телефона
              gradient: LinearGradient(
                begin: Alignment(-1.0 - _tiltX, -1.0 + _tiltY),
                end: Alignment(1.0 - _tiltX, 1.0 + _tiltY),
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.6), // Сам луч света
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
          ),
          child: widget.child,
        ),
      ),
    );
  }
}