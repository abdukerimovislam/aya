import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';
import '../models/timer_design.dart';


class SettingsProvider extends ChangeNotifier {
  final Box _box;
  final SecureStorageService _storageService;
  final NotificationService _notificationService;

  static const String _keyOnboarding = 'has_seen_onboarding';
  static const String _keyDailyLog = 'daily_log_enabled';
  static const String _keyDesign = 'timer_design_index';
  static const String _keyPremium = 'is_premium';
  static const String _keyTheme = 'app_theme_type';
  static const String _keyLanguage = 'language_code';

  // Новые ключи для профиля
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';

  // 🔥 Ключи для синхронизации с COCProvider и CycleProvider
  static const String _keyCOCActive = 'coc_active_count';
  static const String _keyCOCBreak = 'coc_break_days';

  SecureStorageService get storageService => _storageService;

  Locale _locale = const Locale('en');

  bool _notificationsEnabled = false;
  bool _biometricsEnabled = false;
  bool _isTTCMode = false;
  bool _dailyLogEnabled = false;

  TimerDesign _currentDesign = TimerDesign.classic;
  bool _isPremium = false;

  // ✅ ИСПРАВЛЕНО: Тема по умолчанию - Oceanic
  AppThemeType _currentTheme = AppThemeType.digital;

  String _userName = "User";
  String _userAvatar = "👩";

  // --- Геттеры ---
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get dailyLogEnabled => _dailyLogEnabled;
  TimerDesign get currentDesign => _currentDesign;
  bool get isPremium => _isPremium;
  AppThemeType get currentTheme => _currentTheme;

  String get userName => _userName;
  String get userAvatar => _userAvatar;

  // Геттеры для КОК (чтобы UI настроек мог их читать)
  int get cocActivePills => _box.get(_keyCOCActive, defaultValue: 21);
  int get cocBreakDays => _box.get(_keyCOCBreak, defaultValue: 7);

  // 🔥 ВАЖНО: Проверка, выбрал ли пользователь язык явно
  // Используется в SplashScreen для навигации
  bool get isLanguageExplicitlySet => _box.containsKey(_keyLanguage);

  SettingsProvider(this._box, this._storageService, this._notificationService) {
    _loadSettings();
  }

  bool get hasSeenOnboarding {
    return _box.get(_keyOnboarding, defaultValue: false);
  }

  Future<void> completeOnboarding() async {
    await _box.put(_keyOnboarding, true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await _box.put(_keyOnboarding, false);
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final bool appWasReset = !_box.containsKey(_keyOnboarding);

    if (appWasReset) {
      await _storageService.clearAll();
      _isTTCMode = false;
      _notificationsEnabled = false;
      _biometricsEnabled = false;
      _dailyLogEnabled = false;
      _currentDesign = TimerDesign.classic;
      _isPremium = false;
      // ✅ ИСПРАВЛЕНО: Сброс на Oceanic
      _currentTheme = AppThemeType.oceanic;
      _userName = "User";
      _userAvatar = "👩";
    } else {
      _notificationsEnabled = await _storageService.getNotificationsEnabled();
      _biometricsEnabled = await _storageService.getBiometricsEnabled();
      _isTTCMode = await _storageService.getTTCMode();

      _dailyLogEnabled = _box.get(_keyDailyLog, defaultValue: false);
      _isPremium = _box.get(_keyPremium, defaultValue: false);

      _userName = _box.get(_keyUserName, defaultValue: "User");
      _userAvatar = _box.get(_keyUserAvatar, defaultValue: "👩");

      final savedDesignIndex = _box.get(_keyDesign);
      if (savedDesignIndex != null && savedDesignIndex is int) {
        if (savedDesignIndex >= 0 && savedDesignIndex < TimerDesign.values.length) {
          _currentDesign = TimerDesign.values[savedDesignIndex];
        }
      }

      final themeIndex = _box.get(_keyTheme, defaultValue: 0);
      if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
        _currentTheme = AppThemeType.values[themeIndex];
        AppTheme.setPalette(_currentTheme);
      }
    }

    // 1. Пытаемся загрузить язык из Hive
    final savedLang = _box.get(_keyLanguage) as String?;

    if (savedLang != null) {
      _locale = Locale(savedLang);
    } else {
      // 2. Если в Hive нет, пробуем SecureStorage (миграция старых пользователей)
      final secureLang = await _storageService.getLanguage();
      if (secureLang != null) {
        _locale = Locale(secureLang);
        await _box.put(_keyLanguage, secureLang); // Мигрируем в Hive
      } else {
        // 3. Авто-определение языка системы (только для дефолта, пока юзер не выберет)
        try {
          final sysLocales = WidgetsBinding.instance.platformDispatcher.locales;
          if (sysLocales.isNotEmpty) {
            final sysCode = sysLocales.first.languageCode;

            // ✅ ИСПРАВЛЕНО: 'br' -> 'pt' (код языка португальский)
            if (['ru', 'es', 'de', 'pt', 'tr', 'pl'].contains(sysCode)) {
              _locale = Locale(sysCode);
            } else {
              _locale = const Locale('en');
            }
          }
        } catch (e) {
          debugPrint("Locale auto-detect error: $e");
          _locale = const Locale('en');
        }
      }
    }

    notifyListeners();
    _verifyPremiumStatus();
  }

  Future<void> reload() async {
    await _loadSettings();
  }

  // --- ПРОФИЛЬ ---

  Future<void> setUserName(String name) async {
    _userName = name;
    await _box.put(_keyUserName, name);
    notifyListeners();
  }

  Future<void> setUserAvatar(String avatar) async {
    _userAvatar = avatar;
    await _box.put(_keyUserAvatar, avatar);
    notifyListeners();
  }

  // --- ЛОГИКА ТЕМ ---

  Future<void> setTheme(AppThemeType theme) async {
    if (_currentTheme == theme) return;
    _currentTheme = theme;
    AppTheme.setPalette(theme);
    await _box.put(_keyTheme, theme.index);
    notifyListeners();
  }

  // --- ЛОГИКА ПОДПИСОК ---

  Future<void> _verifyPremiumStatus() async {
    try {
      final bool actualStatus = await SubscriptionService.checkPremium();

      if (actualStatus != _isPremium) {
        debugPrint("💎 SettingsProvider: Premium status changed: $_isPremium -> $actualStatus");
        _isPremium = actualStatus;
        await _box.put(_keyPremium, _isPremium);

        if (!_isPremium && _currentDesign.isPremium) {
          debugPrint("⚠️ SettingsProvider: Premium lost, resetting design to Classic");
          _currentDesign = TimerDesign.classic;
          await _box.put(_keyDesign, TimerDesign.classic.index);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ SettingsProvider: Error verifying premium: $e");
    }
  }

  Future<void> refreshPremium() async {
    await _verifyPremiumStatus();
  }

  // --- НАСТРОЙКИ ---

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;

    // Сохраняем в Hive (это делает isLanguageExplicitlySet = true)
    await _box.put(_keyLanguage, locale.languageCode);
    // И в SecureStorage для надежности
    await _storageService.saveLanguage(locale.languageCode);

    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _storageService.saveNotificationsEnabled(value);

    if (!value) {
      await _notificationService.cancelAll();
    }
    // Если включили - UI должен вызвать CycleProvider.rescheduleNotifications()

    notifyListeners();
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _biometricsEnabled = value;
    await _storageService.saveBiometricsEnabled(value);
    notifyListeners();
  }

  Future<void> setTTCMode(bool value) async {
    if (_isTTCMode == value) return;
    _isTTCMode = value;
    await _storageService.saveTTCMode(value);
    notifyListeners();
  }

  // 🔥 Новое: Настройка таблеток через глобальные настройки
  Future<void> setCOCSettings(int active, int brk) async {
    await _box.put(_keyCOCActive, active);
    await _box.put(_keyCOCBreak, brk);
    notifyListeners();
  }

  Future<bool> setDesign(TimerDesign design) async {
    if (!design.isPremium) {
      _currentDesign = design;
      await _box.put(_keyDesign, design.index);
      notifyListeners();
      return true;
    }

    if (design.isPremium && _isPremium) {
      _currentDesign = design;
      await _box.put(_keyDesign, design.index);
      notifyListeners();
      return true;
    }

    debugPrint("🔒 Design locked. Show Paywall.");
    return false;
  }

  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    await _box.put(_keyPremium, status);

    if (!status && _currentDesign.isPremium) {
      _currentDesign = TimerDesign.classic;
      await _box.put(_keyDesign, TimerDesign.classic.index);
    }

    notifyListeners();
  }

  Future<void> toggleDailyLogReminder(bool value) async {
    _dailyLogEnabled = value;
    await _box.put(_keyDailyLog, value);
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('ru'));
    } else {
      setLocale(const Locale('en'));
    }
  }

  // 🔥 Новое: Полный сброс данных (Danger Zone)
  Future<void> wipeData() async {
    await _box.clear();
    await _storageService.clearAll();

    // Сбрасываем переменные в памяти
    _isTTCMode = false;
    _notificationsEnabled = false;
    _biometricsEnabled = false;
    _dailyLogEnabled = false;
    _currentDesign = TimerDesign.classic;
    _isPremium = false;
    _userName = "User";
    _userAvatar = "👩";

    await _loadSettings(); // Перезагружаем дефолты
    notifyListeners();
  }
}