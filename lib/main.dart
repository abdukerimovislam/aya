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

// 🔥 ИМПОРТЫ FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'data/providers/chat_provider.dart';
import 'data/providers/medication_provider.dart';
import 'firebase_options.dart';

// 🔥 Импорты для фоновой работы ИИ
import 'package:workmanager/workmanager.dart';
import 'core/services/ai_oracle_service.dart';

// 🔥 Инструменты надежности (Оффлайн + Аналитика + Пуши)
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/navigation/app_navigation.dart';
import 'core/services/fcm_service.dart';

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
import 'l10n/app_localizations.dart';

// --- ГЛОБАЛЬНЫЙ СЕРВИС СЕТИ (OFFLINE-FIRST) ---
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static bool hasInternet = true;

  static void init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      hasInternet = !results.contains(ConnectivityResult.none);
      if (!hasInternet) {
        debugPrint("📴 Ayla is offline. Cloud features suspended.");
      } else {
        debugPrint("📶 Internet connection restored.");
      }
    });
  }
}

// 🔥 Точка входа для фоновых задач
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await Hive.initFlutter();

      final storageService = SecureStorageService();
      final encryptionKey = await storageService.getOrCreateHiveCipherKey();

      try {
        if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CycleModelAdapter());
        if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SymptomLogAdapter());
        if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PersonalModelAdapter());
        if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FlowIntensityAdapter());
        if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CyclePhaseAdapter());
        if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(OvulationTestResultAdapter());
        if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(CervicalMucusTypeAdapter());
      } catch (e) {
        debugPrint("Background adapters already registered");
      }

      if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings', encryptionCipher: HiveAesCipher(encryptionKey));
      if (!Hive.isBoxOpen('cycles')) await Hive.openBox('cycles', encryptionCipher: HiveAesCipher(encryptionKey));
      if (!Hive.isBoxOpen('symptom_logs')) await Hive.openBox('symptom_logs', encryptionCipher: HiveAesCipher(encryptionKey));

      await AiOracleService.fetchDailyInsight(isManual: false);

      return Future.value(true);
    } catch (err, stack) {
      debugPrint("🔥 Background task error: $err");
      FirebaseCrashlytics.instance.recordError(err, stack, fatal: false);
      return Future.value(false);
    }
  });
}

void main() async {
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('🔥 Unhandled PlatformDispatcher error: $error');
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        debugPrint('🔥 FlutterError: ${errorDetails.exceptionAsString()}');
      };
    } catch (e) {
      debugPrint("🔥 Ошибка инициализации Firebase: $e");
    }

    await SubscriptionService.init();
    final storageService = SecureStorageService();

    ConnectivityService.init();

    final encryptionKey = await storageService.getOrCreateHiveCipherKey();

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

    await Hive.initFlutter();

    if (storageService.wasHiveKeyReset) {
      debugPrint("🚨 ВНИМАНИЕ: Зафиксирован сброс ключа шифрования! Удаляем старые нечитаемые базы...");
      try {
        await Hive.deleteBoxFromDisk('settings');
        await Hive.deleteBoxFromDisk('cycles');
        await Hive.deleteBoxFromDisk('symptom_logs');
        await Hive.deleteBoxFromDisk('coc_settings');
        debugPrint("✅ Старые базы успешно удалены. Приложение спасено от краш-лупа.");
      } catch (e, stack) {
        debugPrint("❌ Ошибка при удалении старых баз: $e");
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to delete corrupted boxes');
      }
    }

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

    final settingsBox = await _openBoxSafely('settings', encryptionKey);
    final cycleBox = await _openBoxSafely('cycles', encryptionKey);
    final wellnessBox = await _openBoxSafely('symptom_logs', encryptionKey);
    final cocBox = await _openBoxSafely('coc_settings', encryptionKey);

    final notificationService = NotificationService();
    await notificationService.init(
      onNotificationTap: (payload) {
        debugPrint("🚀 Notification Payload: $payload");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (SplashScreen.isActive) {
            queueNotificationNavigation(payload);
            return;
          }
          navigateToNotificationPayload(payload);
        });
      },
    );
    queueNotificationNavigation(await notificationService.getLaunchPayload());

    await FCMService.init();

    try {
      Workmanager().initialize(
        callbackDispatcher,
      );

      Workmanager().registerPeriodicTask(
        "daily_ai_insight_task",
        "fetchDailyInsight",
        frequency: const Duration(hours: 24),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
    } catch (e, stack) {
      debugPrint("⚠️ Workmanager init failed: $e");
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Workmanager Init Failure');
    }

    runApp(AylaAppRoot(
      settingsBox: settingsBox,
      cycleBox: cycleBox,
      wellnessBox: wellnessBox,
      cocBox: cocBox,
      storageService: storageService,
      notificationService: notificationService,
      encryptedBoxOpener: (name) => _openBoxSafely(name, encryptionKey),
    ));
  }, (Object error, StackTrace stack) {
    debugPrint('🔥 Uncaught zoned error: $error');
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

Future<Box> _openBoxSafely(String name, Uint8List key) async {
  try {
    return await Hive.openBox(name, encryptionCipher: HiveAesCipher(key));
  } catch (e) {
    debugPrint("🔥 Hive openBox failed for '$name': $e");
    debugPrint("🧯 Attempting recovery: delete only '$name' box and reopen...");

    try {
      final exists = await Hive.boxExists(name);
      if (exists) {
        await Hive.deleteBoxFromDisk(name);
      }
      return await Hive.openBox(name, encryptionCipher: HiveAesCipher(key));
    } catch (e2, stack) {
      debugPrint("❌ Hive recovery failed for '$name': $e2");
      FirebaseCrashlytics.instance.recordError(e2, stack, fatal: true, reason: 'Hive box total corruption');
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
  final Future<Box> Function(String name)? encryptedBoxOpener;

  const AylaAppRoot({
    super.key,
    required this.settingsBox,
    required this.cycleBox,
    required this.wellnessBox,
    required this.cocBox,
    required this.storageService,
    required this.notificationService,
    this.encryptedBoxOpener,
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
          create: (_) => CycleProvider(
            cycleBox,
            settingsBox,
            notificationService,
            encryptedBoxOpener,
          ),
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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
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
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ??
          lookupAppLocalizations(const Locale('en')).appTitle,
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('es'),
        Locale('de'),
        Locale('pt'),
        Locale('tr'),
        Locale('pl'),
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

      builder: (context, child) {
        return AuthGuard(child: child ?? const SizedBox.shrink());
      },

      routes: {
        '/home': (context) => const MainScreen(initialIndex: 0),
        '/calendar': (context) => const MainScreen(initialIndex: 1),
        '/insights': (context) => const MainScreen(initialIndex: 2),
        '/profile': (context) => const MainScreen(initialIndex: 3),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      home: const SplashScreen(),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});
  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final settings = context.read<SettingsProvider>();
      if (settings.biometricsEnabled) {
        setState(() {
          _isAuthenticated = false;
        });
      }
    }
    else if (state == AppLifecycleState.resumed) {
      debugPrint("🔄 Приложение развернуто. Проверяем данные и авторизацию...");

      try {
        context.read<CycleProvider>().reload();
      } catch (e) {
        debugPrint("Ошибка при фоновом обновлении данных: $e");
      }

      final settings = context.read<SettingsProvider>();
      if (settings.biometricsEnabled && !_isAuthenticated) {
        _checkAuth();
      }
    }
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();
    final unlockReason = AppLocalizations.of(context)?.authUnlockShortReason ??
        lookupAppLocalizations(const Locale('en')).authUnlockShortReason;

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
      final bool success = await auth.authenticate(unlockReason);

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
    // 🔥 ИСПРАВЛЕНИЕ: Используем Stack, чтобы навигатор ВСЕГДА оставался в дереве!
    // Мы просто накрываем его экраном блокировки сверху, не уничтожая стейт.
    return Stack(
      children: [
        widget.child, // Оригинальный навигатор (всегда живой)

        if (_isChecking || !_isAuthenticated)
          Positioned.fill(
            child: _buildLockScreen(context),
          ),
      ],
    );
  }

  Widget _buildLockScreen(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CupertinoActivityIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              l10n?.authLockedTitle ?? lookupAppLocalizations(const Locale('en')).authLockedTitle,
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
                l10n?.authUnlockBtn ?? lookupAppLocalizations(const Locale('en')).authUnlockBtn,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
