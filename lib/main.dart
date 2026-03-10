import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Новая архитектура Ayla
import 'ayla_app.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/subscription_service.dart';
import 'core/theme/app_theme.dart';
import 'data/models/cycle_model.dart';
import 'data/models/personal_model.dart';
import 'data/providers/coc_provider.dart';
import 'data/providers/cycle_provider.dart';
import 'data/providers/prediction_provider.dart';
import 'data/providers/settings_provider.dart';
import 'data/providers/wellness_provider.dart';

// Экраны
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/profile/profile_screen.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // ✅ Global error handling (production sanity)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔥 FlutterError: ${details.exceptionAsString()}');
    debugPrint('📍 Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('🔥 Unhandled PlatformDispatcher error: $error');
    debugPrint('📍 Stack: $stack');
    return true; // handled
  };

  await runZonedGuarded(() async {
    // 🔥 ВАЖНО: Инициализация биндингов внутри зоны для избежания "Zone Mismatch"
    WidgetsFlutterBinding.ensureInitialized();

    // 1) Critical services
    await SubscriptionService.init();
    final storageService = SecureStorageService();

    // 2) System UI
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ));
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 3) Hive init
    await Hive.initFlutter();

    // 4) Register adapters (safe)
    try {
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CycleModelAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SymptomLogAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PersonalModelAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FlowIntensityAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CyclePhaseAdapter());
      if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(OvulationTestResultAdapter());
      if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(CervicalMucusTypeAdapter());
    } catch (e) {
      debugPrint("⚠️ Hive Adapter Registration Warning: $e");
    }

    // 5) Open boxes safely
    final settingsBox = await _openBoxSafely('settings');
    final cycleBox = await _openBoxSafely('cycles');
    final wellnessBox = await _openBoxSafely('symptom_logs');
    final cocBox = await _openBoxSafely('coc_settings');

    // 6) Notifications
    final notificationService = NotificationService();
    await notificationService.init(
      onNotificationTap: (payload) {
        debugPrint("🚀 Notification Payload: $payload");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (payload == NotificationService.payloadCOC) {
            navigatorKey.currentState?.pushNamed('/profile');
          } else if (payload == NotificationService.payloadCalendar) {
            navigatorKey.currentState?.pushNamed('/calendar');
          }
        });
      },
    );

    runApp(AylaAppRoot(
      settingsBox: settingsBox,
      cycleBox: cycleBox,
      wellnessBox: wellnessBox,
      cocBox: cocBox,
      storageService: storageService,
      notificationService: notificationService,
    ));
  }, (Object error, StackTrace stack) {
    debugPrint('🔥 Uncaught zoned error: $error');
    debugPrint('📍 Stack: $stack');
  });
}

/// Opens Hive box safely to prevent crash loops on corrupted data
Future<Box> _openBoxSafely(String name) async {
  try {
    return await Hive.openBox(name);
  } catch (e) {
    debugPrint("🔥 Hive openBox failed for '$name': $e");
    debugPrint("🧯 Attempting recovery: delete only '$name' box and reopen...");

    try {
      final exists = await Hive.boxExists(name);
      if (exists) {
        await Hive.deleteBoxFromDisk(name);
      }
      return await Hive.openBox(name);
    } catch (e2) {
      debugPrint("❌ Hive recovery failed for '$name': $e2");
      rethrow;
    }
  }
}

class AylaAppRoot extends StatelessWidget {
  final Box settingsBox;
  final Box cycleBox;
  final Box wellnessBox;
  final Box cocBox;
  final SecureStorageService storageService;
  final NotificationService notificationService;

  const AylaAppRoot({
    super.key,
    required this.settingsBox,
    required this.cycleBox,
    required this.wellnessBox,
    required this.cocBox,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SecureStorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),

        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsBox, storageService, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => CycleProvider(cycleBox, settingsBox, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => WellnessProvider(wellnessBox),
        ),
        ChangeNotifierProvider(
          create: (_) => COCProvider(cocBox, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => PredictionProvider()..init(),
        ),
      ],
      child: const AylaApp(),
    );
  }
}

class AylaApp extends StatelessWidget {
  const AylaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    try {
      Intl.defaultLocale = settings.locale.languageCode;
    } catch (e) {
      debugPrint("Locale error: $e");
    }

    return MaterialApp(
      title: 'Ayla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      locale: settings.locale,

      supportedLocales: const [
        Locale('en'), // English
        Locale('ru'), // Русский
        Locale('es'), // Español
        Locale('de'), // Deutsch
        Locale('pt'), // Português
        Locale('tr'), // Türkçe
        Locale('pl'), // Polski
      ],

      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return supportedLocales.first;
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode) {
            return locale;
          }
        }
        return supportedLocales.first;
      },

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      navigatorKey: navigatorKey,
      routes: {
        '/profile': (context) => const Scaffold(
          body: SafeArea(child: ProfileScreen()),
        ),
        // '/calendar' перенаправляет на корневую оболочку,
        // так как календарь теперь является частью плавающего меню в MainScreen
        '/calendar': (context) => const MainScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      // Точка входа в приложение закрыта проверкой биометрии (AuthGuard),
      // которая затем вызывает SplashScreen
      home: const AuthGuard(child: SplashScreen()),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});
  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();

    if (!settings.biometricsEnabled) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
      return;
    }

    final auth = AuthService();
    final bool canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      // Заменили название на Ayla
      final reason = "Scan to unlock Ayla";

      final bool success = await auth.authenticate(reason);

      if (mounted) {
        setState(() {
          _isAuthenticated = success;
          _isChecking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CupertinoActivityIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context);

    return _isAuthenticated
        ? widget.child
        : Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              l10n?.authLockedTitle ?? "Ayla Locked", // Заменили название на Ayla
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: _checkAuth,
              child: Text(
                l10n?.authUnlockBtn ?? "Unlock",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}