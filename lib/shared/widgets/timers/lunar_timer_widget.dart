import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../data/models/cycle_model.dart';
import '../../../l10n/app_localizations.dart';


/// EviMoon — Premium Lunar Timer
/// Uses the Exact Geometric Engine from Splash Screen
class LunarTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const LunarTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
  });

  @override
  State<LunarTimerWidget> createState() => _LunarTimerWidgetState();
}

class _LunarTimerWidgetState extends State<LunarTimerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _loopCtrl;
  late final AnimationController _introCtrl;

  // Плавная смена фазы при обновлении данных
  late final AnimationController _phaseAnimCtrl;
  late Animation<double> _phaseAnim;
  double _targetPhase = -1.0;

  @override
  void initState() {
    super.initState();

    // Вращение звезд
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();

    // Появление (Intro)
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Анимация фазы
    _phaseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _targetPhase = _calculatePhase(widget.data);

    // При старте сразу ставим нужную фазу
    _phaseAnim = Tween<double>(begin: _targetPhase, end: _targetPhase).animate(_phaseAnimCtrl);
    _phaseAnimCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant LunarTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPhase = _calculatePhase(widget.data);

    if ((newPhase - _targetPhase).abs() > 0.01) {
      _phaseAnim = Tween<double>(begin: _targetPhase, end: newPhase).animate(
          CurvedAnimation(parent: _phaseAnimCtrl, curve: Curves.easeInOutCubic)
      );
      _targetPhase = newPhase;
      _phaseAnimCtrl
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _loopCtrl.dispose();
    _introCtrl.dispose();
    _phaseAnimCtrl.dispose();
    super.dispose();
  }

  /// Расчет фазы: -1.0 (New) -> 0.0 (Full) -> 1.0 (New)
  double _calculatePhase(CycleData data) {
    final total = (data.totalCycleLength <= 0 ? 28 : data.totalCycleLength).clamp(21, 60);
    final day = data.currentDay.clamp(1, total);

    // Нормализуем день от 0.0 до 1.0
    final double t = (day - 1) / (total - 1);

    // Преобразуем в диапазон -1..1 для геометрического движка
    return (t * 2) - 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Используем расширение .color из модели
    final accentRaw = widget.data.phase.color;
    final accent = _softenAccent(accentRaw);

    return LayoutBuilder(
      builder: (context, c) {
        final size = math.min(c.maxWidth, c.maxHeight).clamp(280.0, 400.0);
        final moonSize = size * 0.58;

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_loopCtrl, _introCtrl, _phaseAnimCtrl]),
            builder: (_, __) {
              final t = _loopCtrl.value;
              final intro = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack).value;
              final currentPhase = _phaseAnim.value; // -1..1

              // Параметры для эффектов
              final fullness = 1.0 - currentPhase.abs(); // 0 (New) .. 1 (Full)

              return Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Фон (Звездное поле внутри круга)
                  Transform.scale(
                    scale: intro,
                    child: ClipOval(
                      child: Container(
                        width: size, height: size,
                        decoration: const BoxDecoration(
                          color: Color(0xFF080C10), // Глубокий космос
                          shape: BoxShape.circle,
                        ),
                        child: CustomPaint(
                          painter: _StarFieldPainter(rotation: t * 2 * math.pi),
                        ),
                      ),
                    ),
                  ),

                  // 2. Свечение (Атмосфера)
                  Opacity(
                    opacity: (0.3 + (fullness * 0.4)) * intro,
                    child: Container(
                      width: moonSize * 1.4,
                      height: moonSize * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.4),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                          const BoxShadow(
                            color: Color(0xFFD0E0FF),
                            blurRadius: 30,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),

                  // 3. ЛУНА (Та самая геометрия со Сплэша)
                  Transform.scale(
                    scale: intro,
                    child: CustomPaint(
                      size: Size.square(moonSize),
                      painter: _ExactGeometricMoonPainter(
                        phase: currentPhase, // -1..1
                      ),
                    ),
                  ),

                  // 4. Текстовый оверлей
                  _InfoOverlay(
                    day: widget.data.currentDay,
                    label: l10n.dayTitle.toUpperCase(),
                    phaseName: _getPhaseName(currentPhase, l10n, widget.isCOC),
                    accent: accent,
                    opacity: _introCtrl.value, // Линейный intro для текста
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _getPhaseName(double phase, AppLocalizations l10n, bool isCOC) {
    if (isCOC) return phase < 0 ? l10n.cocActivePhase : l10n.cocBreakPhase;

    // phase is -1..1
    if (phase < -0.9) return l10n.phaseNewMoon;
    if (phase < -0.4) return l10n.phaseWaxingCrescent;
    if (phase < -0.1) return l10n.phaseFirstQuarter;
    if (phase < 0.1) return l10n.phaseFullMoon;
    if (phase < 0.4) return l10n.phaseWaningGibbous;
    if (phase < 0.9) return l10n.phaseWaningCrescent;
    return l10n.phaseNewMoon;
  }
}

// ============================ PAINTERS ============================

/// 🔥 ТОТ САМЫЙ ХУДОЖНИК СО СПЛЭШ-ЭКРАНА
class _ExactGeometricMoonPainter extends CustomPainter {
  final double phase; // -1.0 (New) ... 0.0 (Full) ... 1.0 (New)

  _ExactGeometricMoonPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // 1. Тень (Подложка)
    final darkPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF181B26), Color(0xFF0A0C12)],
        center: Alignment.center,
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawCircle(center, r, darkPaint);

    // Тонкий ободок тени
    canvas.drawCircle(center, r, Paint()..color=Colors.white.withOpacity(0.05)..style=PaintingStyle.stroke..strokeWidth=1);

    // 2. Светлая часть (Геометрия)
    Path lightPath = Path();
    lightPath.moveTo(center.dx, center.dy - r);

    bool isWaxing = phase < 0;
    double fullness = 1.0 - phase.abs();

    if (isWaxing) {
      // Свет справа
      lightPath.addArc(Rect.fromCircle(center: center, radius: r), -math.pi/2, math.pi);
      double w = r * (fullness - 0.5) * 2;
      lightPath.arcTo(
          Rect.fromCenter(center: center, width: w.abs() * 2, height: r * 2),
          math.pi/2,
          math.pi,
          false
      );
    } else {
      // Свет слева
      lightPath.addArc(Rect.fromCircle(center: center, radius: r), math.pi/2, math.pi);
      double w = r * (fullness - 0.5) * 2;
      lightPath.arcTo(
          Rect.fromCenter(center: center, width: w.abs() * 2, height: r * 2),
          -math.pi/2,
          -math.pi,
          false
      );
    }
    lightPath.close();

    // 3. Рисуем светлую часть
    canvas.save();
    canvas.clipPath(lightPath);

    final surfacePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 1.2,
        colors: [Color(0xFFFFFFFF), Color(0xFFE4E9F2), Color(0xFFD7DEEB)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), surfacePaint);

    _drawCraters(canvas, center, r);

    canvas.restore();

    // 4. Свечение по краю терминатора
    if (fullness > 0.05 && fullness < 0.95) {
      canvas.drawPath(lightPath, Paint()..color=Colors.white.withOpacity(0.2)..style=PaintingStyle.stroke..strokeWidth=1.5..maskFilter=const MaskFilter.blur(BlurStyle.normal, 2));
    }
  }

  void _drawCraters(Canvas canvas, Offset c, double r) {
    final craterPaint = Paint()..color = Colors.black.withOpacity(0.1);
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.05);

    final pts = [
      const Offset(-0.2, -0.1), const Offset(0.3, -0.2),
      const Offset(0.1, 0.4), const Offset(-0.4, 0.2),
      const Offset(0.0, -0.5), const Offset(0.5, 0.3)
    ];

    for (var pt in pts) {
      canvas.drawCircle(Offset(c.dx + pt.dx * r + 1, c.dy + pt.dy * r + 1), r * 0.12, shadowPaint);
      canvas.drawCircle(Offset(c.dx + pt.dx * r, c.dy + pt.dy * r), r * 0.12, craterPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExactGeometricMoonPainter old) => old.phase != phase;
}

class _StarFieldPainter extends CustomPainter {
  final double rotation;
  _StarFieldPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final random = math.Random(42);
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 100; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double r = 0.5 + random.nextDouble() * 1.5;
      double opacity = random.nextDouble() * 0.8;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _StarFieldPainter old) => old.rotation != rotation;
}

class _InfoOverlay extends StatelessWidget {
  final int day;
  final String label;
  final String phaseName;
  final Color accent;
  final double opacity;

  const _InfoOverlay({required this.day, required this.label, required this.phaseName, required this.accent, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // День
          Text(
            "$day",
            style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 2)),
                  Shadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 5)),
                ]
            ),
          ),

          // Подпись "DAY"
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white.withOpacity(0.9),
                shadows: const [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1))]
            ),
          ),

          const SizedBox(height: 12),

          // Фаза (Chip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Text(
              phaseName,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.9)
              ),
            ),
          )
        ],
      ),
    );
  }
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;
Color _softenAccent(Color c) => _mix(c, Colors.white, 0.2);