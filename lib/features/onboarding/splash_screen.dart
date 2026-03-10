import 'dart:math' as math;
import 'dart:ui'; // Для ImageFilter
import 'package:evimoon/features/onboarding/splash/realistic_moon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../ayla_app.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_screen.dart';
import 'language_selection_screen.dart'; // 🔥 Импорт экрана выбора языка

// L10n

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // --- КОНТРОЛЛЕРЫ ---
  late AnimationController _entranceController;
  late AnimationController _breathingController;
  late AnimationController _textController;
  late AnimationController _syncController; // Для фазы луны

  // --- АНИМАЦИИ ---
  late Animation<double> _phaseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  final List<Star> _stars = [];
  final int _starCount = 90; // Количество звезд
  double _targetPhase = 0.0; // Целевая фаза (зависит от дня цикла)
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _generateStars();

    // 1. Вход (Появление луны) - 3.5 сек
    _entranceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3500)
    );

    // 2. Дыхание (Вечное пульсирование) - 6 сек
    _breathingController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6)
    );

    // 3. Текст (Появление) - 1.5 сек
    _textController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500)
    );

    // 4. Синхронизация (Морфинг фазы) - 2 сек
    _syncController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000)
    );

    _setupAnimations();
    _startSequence();
    _initializeApp();
  }

  void _setupAnimations() {
    // Луна: Масштаб 0.8 -> 1.0 (плавный выход)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic)
    );

    // Луна: Прозрачность 0 -> 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeIn)
    );

    // Текст: Прозрачность
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut)
    );

    // Текст: Слайд снизу вверх
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOutQuart)
        );

    // Фаза: По умолчанию 0.0 (Серп), потом анимируется к _targetPhase
    _phaseAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_syncController);

    // Вибрация в момент "раскрытия" (на 60% анимации)
    _entranceController.addListener(() {
      if (_entranceController.value > 0.6 && !_hasVibrated) {
        HapticFeedback.lightImpact();
        _hasVibrated = true;
      }
    });
  }

  void _generateStars() {
    final rng = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2.0 + 0.5,
        offset: rng.nextDouble() * 2 * math.pi,
        speed: rng.nextDouble() * 0.8 + 0.2,
      ));
    }
  }

  void _startSequence() async {
    _breathingController.repeat(reverse: true);
    await _entranceController.forward();
    // Вибрация перед текстом
    HapticFeedback.selectionClick();
    _textController.forward();
  }

  Future<void> _initializeApp() async {
    // Минимальное время показа (чтобы успеть насладиться анимацией)
    final minTime = Future.delayed(const Duration(milliseconds: 3500));

    final logic = Future(() async {
      if (!mounted) return;
      try {
        final cycleProvider = context.read<CycleProvider>();
        // Загружаем данные, но ошибки не крашат сплеш
        await cycleProvider.reload();

        if (!mounted) return;

        // Перезагружаем остальные провайдеры
        context.read<WellnessProvider>().reload();
        await context.read<SettingsProvider>().reload(); // Ждем настройки

        // Рассчитываем фазу, чтобы луна соответствовала реальному циклу
        if (mounted) _calculateTargetPhase(cycleProvider);
      } catch (e) {
        debugPrint("Splash init error: $e");
      }
    });

    await Future.wait([minTime, logic]);

    // Если анимация фазы еще идет, ждем её
    if (_syncController.isAnimating) await _syncController.forward();

    if (mounted) _navigateToNext();
  }

  void _calculateTargetPhase(CycleProvider provider) {
    if (!provider.isLoaded || provider.history.isEmpty) return;

    final data = provider.currentData;

    // Формула:
    // День 1 (Начало) -> 0.0 (Серп)
    // Середина цикла -> 1.0 (Полная)
    // Конец цикла -> 0.0 (Серп)
    double progress = data.currentDay / data.totalCycleLength;
    double phase = math.sin(progress * math.pi); // Синусоида 0 -> 1 -> 0

    setState(() {
      _targetPhase = phase;
      // Переназначаем анимацию к новой цели
      _phaseAnimation = Tween<double>(begin: 0.0, end: _targetPhase).animate(
          CurvedAnimation(parent: _syncController, curve: Curves.easeInOutCubic)
      );
    });
    _syncController.forward();
  }

  void _navigateToNext() {
    final settings = context.read<SettingsProvider>();

    // 🔥 ЛОГИКА НАВИГАЦИИ (Язык -> Онбординг -> Главная)
    Widget nextScreen;

    if (!settings.isLanguageExplicitlySet) {
      // 1. Если язык не выбран -> Выбор языка
      nextScreen = const LanguageSelectionScreen();
    } else if (!settings.hasSeenOnboarding) {
      // 2. Если язык есть, но онбординг не пройден -> Онбординг
      nextScreen = const OnboardingScreen();
    } else {
      // 3. Иначе -> Главный экран
      nextScreen = const MainScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, anim, __, child) {
          // Плавное исчезновение (Fade + Scale)
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOut)
                ),
                child: child
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathingController.dispose();
    _textController.dispose();
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Прозрачный статус-бар
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final double moonContainerSize = (size.width * 0.55).clamp(160.0, 280.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // Фон на весь экран
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.6,
              colors: [
                Color(0xFF312E81), // Indigo 900
                Color(0xFF1E1B4B), // Indigo 950
                Color(0xFF0F172A), // Slate 900
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. ФОН И ЗВЕЗДЫ
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: StarPainter(_stars, _breathingController.value),
                    );
                  },
                ),
              ),

              // 2. ЦЕНТРАЛЬНАЯ КОМПОЗИЦИЯ
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _breathingController,
                      _syncController
                    ]),
                    builder: (context, child) {
                      double breath = _breathingController.value;
                      double breathScale = 1.0 + (math.sin(breath * 2 * math.pi) * 0.02);
                      double opacity = _fadeAnimation.value;
                      double currentPhase = _phaseAnimation.value;

                      return Transform.scale(
                        scale: _scaleAnimation.value * breathScale,
                        child: Opacity(
                          opacity: opacity,
                          child: SizedBox(
                            width: moonContainerSize,
                            height: moonContainerSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // A. Задний ореол
                                Container(
                                  width: moonContainerSize * 1.4,
                                  height: moonContainerSize * 1.4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.12 * opacity),
                                        const Color(0xFF818CF8).withOpacity(0.05 * opacity),
                                        Colors.transparent
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                                // B. Ближнее свечение
                                Container(
                                  width: moonContainerSize * 0.8,
                                  height: moonContainerSize * 0.8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFFA5B4FC).withOpacity(0.3 * opacity),
                                          blurRadius: 60,
                                          spreadRadius: -5),
                                      BoxShadow(color: Colors.white.withOpacity(0.15 * opacity),
                                          blurRadius: 30,
                                          spreadRadius: -10),
                                    ],
                                  ),
                                ),
                                // C. Реалистичная луна (Виджет)
                                Hero(
                                  tag: 'moon_hero',
                                  child: RealisticMoon(
                                      size: moonContainerSize * 0.65,
                                      progress: currentPhase),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // ТЕКСТ
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                              l10n.splashTitle.toUpperCase(),
                              style: GoogleFonts.cormorantGaramond(
                                  fontSize: 42,
                                  color: Colors.white,
                                  letterSpacing: 6.0,
                                  fontWeight: FontWeight.w300,
                                  height: 1.0,
                                  shadows: [
                                    Shadow(color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ]
                              )
                          ),
                          const SizedBox(height: 16),
                          Container(width: 30, height: 1, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            l10n.splashSlogan,
                            style: GoogleFonts.inter(fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 3.0,
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ХУДОЖНИК ПО ЗВЕЗДАМ ---
class Star {
  final double x, y, size, offset, speed;
  Star({required this.x, required this.y, required this.size, required this.offset, required this.speed});
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var star in stars) {
      double flicker = math.sin((animationValue * 2 * math.pi * star.speed) + star.offset);
      double opacity = 0.45 + (flicker * 0.35);

      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));

      canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.size,
          paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}