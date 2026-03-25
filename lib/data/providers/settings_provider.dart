import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 🔥 ИМПОРТ FCM ДЛЯ ТОПИКОВ

import '../../core/services/notification_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/subscription_service.dart';

class SettingsProvider extends ChangeNotifier {
  final Box _box;
  final SecureStorageService _storageService;
  final NotificationService _notificationService;

  static const String _keyOnboarding = 'has_seen_onboarding';
  static const String _keyDailyLog = 'daily_log_enabled';
  static const String _keyPremium = 'is_premium';
  static const String _keyLanguage = 'language_code';

  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';

  static const String _keyCOCActive = 'coc_active_count';
  static const String _keyCOCBreak = 'coc_break_days';
  static const String _keyCOCPackStart = 'coc_pack_start_date';

  SecureStorageService get storageService => _storageService;

  Locale _locale = const Locale('en');

  bool _notificationsEnabled = false;
  bool _biometricsEnabled = false;
  bool _dailyLogEnabled = false;

  bool _isPremium = false;

  String _userName = "";
  String _userAvatar = "👩";

  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get dailyLogEnabled => _dailyLogEnabled;
  bool get isPremium => _isPremium;

  String get userName => _userName;
  String get userAvatar => _userAvatar;

  int get cocActivePills => _box.get(_keyCOCActive, defaultValue: 21);
  int get cocBreakDays => _box.get(_keyCOCBreak, defaultValue: 7);

  DateTime? get cocPackStartDate {
    final ms = _box.get(_keyCOCPackStart);
    if (ms != null && ms is int) {
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }

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
      _notificationsEnabled = false;
      _biometricsEnabled = false;
      _dailyLogEnabled = false;
      _isPremium = false;
      _userName = "";
      _userAvatar = "👩";
    } else {
      _notificationsEnabled = await _storageService.getNotificationsEnabled();
      _biometricsEnabled = await _storageService.getBiometricsEnabled();

      _dailyLogEnabled = _box.get(_keyDailyLog, defaultValue: false);
      _isPremium = _box.get(_keyPremium, defaultValue: false);

      _userName = _box.get(_keyUserName, defaultValue: "");
      _userAvatar = _box.get(_keyUserAvatar, defaultValue: "👩");
    }

    final savedLang = _box.get(_keyLanguage) as String?;

    if (savedLang != null) {
      _locale = Locale(savedLang);
    } else {
      final secureLang = await _storageService.getLanguage();
      if (secureLang != null) {
        _locale = Locale(secureLang);
        await _box.put(_keyLanguage, secureLang);
      } else {
        try {
          final sysLocales = WidgetsBinding.instance.platformDispatcher.locales;
          if (sysLocales.isNotEmpty) {
            final sysCode = sysLocales.first.languageCode;
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

  Future<void> _verifyPremiumStatus() async {
    try {
      final bool actualStatus = await SubscriptionService.checkPremium();

      if (actualStatus != _isPremium) {
        _isPremium = actualStatus;
        await _box.put(_keyPremium, _isPremium);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ SettingsProvider: Error verifying premium: $e");
    }
  }

  Future<void> refreshPremium() async {
    await _verifyPremiumStatus();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    // 🔥 Отписываемся от старого топика, чтобы не дублировать языки!
    final oldCode = _locale.languageCode;

    _locale = locale;
    await _box.put(_keyLanguage, locale.languageCode);
    await _storageService.saveLanguage(locale.languageCode);

    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('lang_$oldCode');
      await FirebaseMessaging.instance.subscribeToTopic('lang_${locale.languageCode}');
    } catch (_) {}

    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _storageService.saveNotificationsEnabled(value);

    if (!value) {
      await _notificationService.cancelAll();
    }
    notifyListeners();
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _biometricsEnabled = value;
    await _storageService.saveBiometricsEnabled(value);
    notifyListeners();
  }

  Future<void> setCOCSettings(int active, int brk, {DateTime? packStartDate}) async {
    await _box.put(_keyCOCActive, active);
    await _box.put(_keyCOCBreak, brk);
    if (packStartDate != null) {
      final normalizedDate = DateTime.utc(packStartDate.year, packStartDate.month, packStartDate.day, 12, 0, 0);
      await _box.put(_keyCOCPackStart, normalizedDate.millisecondsSinceEpoch);
    }
    notifyListeners();
  }

  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    await _box.put(_keyPremium, status);
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

  Future<void> wipeData() async {
    await _box.clear();

    // 🔥 Очищаем Secure Storage
    await _storageService.saveBiometricsEnabled(false);
    await _storageService.saveNotificationsEnabled(false);

    _notificationsEnabled = false;
    _biometricsEnabled = false;
    _dailyLogEnabled = false;
    _isPremium = false;
    _userName = "";
    _userAvatar = "👩";

    await _loadSettings();
    notifyListeners();
  }
}
