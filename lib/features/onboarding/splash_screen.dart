import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_navigation.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_screen.dart';
import '../../ayla_app.dart';

class SplashScreen extends StatefulWidget {
  static bool isActive = false;

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // --- КОНТРОЛЛЕРЫ ---
  late AnimationController _entranceController; // Для появления текста
  late AnimationController _floatingController; // Для летящих частиц и ауры

  // --- АНИМАЦИИ ---
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  final List<_AirParticle> _particles = [];
  final int _particleCount = 40;
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    SplashScreen.isActive = true;

    _generateParticles();

    // 1. Плавное проявление (2.5 секунды)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 2. Вечное, медленное течение (10 секунд на полный цикл)
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _setupAnimations();
    _startSequence();
    _initializeApp();
  }

  void _setupAnimations() {
    // Текст: Прозрачность (очень плавный фейд)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    // Текст: Слайд снизу вверх (невесомый подъем)
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart)),
    );

    _entranceController.addListener(() {
      if (_entranceController.value > 0.5 && !_hasVibrated) {
        HapticFeedback.lightImpact();
        _hasVibrated = true;
      }
    });
  }

  void _generateParticles() {
    final rng = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_AirParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 3.0 + 1.0, // От 1 до 4 пикселей
        speed: rng.nextDouble() * 0.0015 + 0.0005, // Очень медленно вверх
        seed: rng.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _entranceController.forward();
  }

  Future<void> _initializeApp() async {
    final minTime = Future.delayed(const Duration(milliseconds: 3500));

    final logic = Future(() async {
      if (!mounted) return;
      try {
        await context.read<CycleProvider>().reload();
        if (!mounted) return;
        context.read<WellnessProvider>().reload();
        await context.read<SettingsProvider>().reload();
      } catch (e) {
        debugPrint("Splash init error: $e");
      }
    });

    await Future.wait([minTime, logic]);
    if (mounted) _navigateToNext();
  }

  void _navigateToNext() {
    final settings = context.read<SettingsProvider>();
    final queuedRoute = settings.hasSeenOnboarding ? takeQueuedNotificationRoute() : null;
    final Widget nextScreen = settings.hasSeenOnboarding
        ? buildScreenForRoute(queuedRoute, fallback: const MainScreen())
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    SplashScreen.isActive = false;
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Максимально легкий, чистый фон
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. АМОРФНАЯ АУРА (Дышащие акварельные пятна)
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              final t = _floatingController.value * 2 * math.pi;

              return Stack(
                children: [
                  // Пятно 1: Нежный фиолетовый
                  Positioned(
                    left: size.width * 0.1 + math.cos(t) * 40,
                    top: size.height * 0.2 + math.sin(t) * 50,
                    child: _buildAuraBlob(AppColors.primary.withValues(alpha: 0.25), size.width * 0.7),
                  ),
                  // Пятно 2: Пудрово-розовый
                  Positioned(
                    right: size.width * 0.05 + math.sin(t + math.pi / 2) * 40,
                    bottom: size.height * 0.3 + math.cos(t) * 60,
                    child: _buildAuraBlob(const Color(0xFFFFB3C6).withValues(alpha: 0.25), size.width * 0.8),
                  ),
                  // Пятно 3: Легкий персиковый
                  Positioned(
                    left: size.width * 0.3 + math.cos(t + math.pi) * 30,
                    bottom: size.height * 0.1 + math.sin(t * 1.5) * 40,
                    child: _buildAuraBlob(const Color(0xFFFFD6A5).withValues(alpha: 0.2), size.width * 0.6),
                  ),
                ],
              );
            },
          ),

          // 2. СИЛЬНОЕ РАЗМЫТИЕ (Смешивает пятна в единое облако)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          // 3. ЛЕТЯЩИЕ ЧАСТИЦЫ (Эффект легкого бриза вверх)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AirParticlePainter(_particles),
                );
              },
            ),
          ),

          // 4. ВОЗДУШНАЯ ТИПОГРАФИКА
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.splashBrand,
                    style: GoogleFonts.outfit(
                      fontSize: 52,
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                      letterSpacing: 16.0, // Огромный интервал дает легкость
                      fontWeight: FontWeight.w200, // Очень тонкий шрифт (воздушность)
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Тончайшая декоративная линия
                  Container(
                      width: 30,
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.2)
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.splashTagline,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      letterSpacing: 6.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Генератор мягкого пятна
  Widget _buildAuraBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// --- ЛОГИКА ЛЕТЯЩИХ ЧАСТИЦ ---
class _AirParticle {
  double x, y, size, speed, seed;
  _AirParticle({required this.x, required this.y, required this.size, required this.speed, required this.seed});
}

class _AirParticlePainter extends CustomPainter {
  final List<_AirParticle> particles;

  _AirParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      // Движение вверх
      p.y -= p.speed;

      // Легкое покачивание влево-вправо (как пылинка на ветру)
      p.x += math.sin(p.y * 20 + p.seed) * 0.0005;

      // Если частица улетела наверх, возвращаем её вниз
      if (p.y < -0.1) {
        p.y = 1.1;
        p.x = math.Random().nextDouble();
      }

      // Плавное исчезновение у краев экрана (сверху и снизу)
      double edgeFade = 1.0;
      if (p.y < 0.2) edgeFade = p.y / 0.2;
      if (p.y > 0.8) edgeFade = (1.0 - p.y) / 0.2;

      paint.color = AppColors.primary.withValues(alpha: (0.3 * edgeFade).clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AirParticlePainter oldDelegate) => true; // Всегда перерисовываем
}
