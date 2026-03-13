import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  late final FlutterSecureStorage _storage;

  // 🔥 Флаг миграции/сброса ключей
  bool _wasHiveKeyReset = false;

  /// Возвращает true, если ключ Hive был пересоздан (например, из-за сброса Keystore на Android).
  /// Это сигнал для `main.dart` о том, что старые зашифрованные базы Hive нужно удалить перед открытием!
  bool get wasHiveKeyReset => _wasHiveKeyReset;

  SecureStorageService._internal() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // ✅ Сброс при ошибке ключей (Защита от битых MAC после сброса пинкода телефона)
        resetOnError: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // --- KEYS ---
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyBiometrics = 'biometrics_enabled';
  static const String _keyLanguage = 'language_code';
  static const String _keyTTC = 'ttc_mode_enabled';

  // 🔐 Hive encryption key (base64 of 32 bytes)
  static const String _keyHiveCipher = 'hive_cipher_key_v1';

  // --- GENERIC HELPERS (С защитой от ошибок) ---

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint("❌ SecureStorage Write Error: $e");
      // Если запись не удалась, пробуем удалить и записать снова
      try {
        await _storage.delete(key: key);
        await _storage.write(key: key, value: value);
      } catch (e2) {
        debugPrint("❌ CRITICAL Storage Error: $e2");
      }
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint("❌ SecureStorage Read Error: $e");
      return null;
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint("❌ SecureStorage Delete Error: $e");
    }
  }

  // --- PUBLIC API ---

  Future<void> saveNotificationsEnabled(bool enabled) async => await _write(_keyNotifications, enabled.toString());
  Future<bool> getNotificationsEnabled() async => (await _read(_keyNotifications)) == 'true';

  Future<void> saveBiometricsEnabled(bool enabled) async => await _write(_keyBiometrics, enabled.toString());
  Future<bool> getBiometricsEnabled() async => (await _read(_keyBiometrics)) == 'true';

  Future<void> saveLanguage(String langCode) async => await _write(_keyLanguage, langCode);
  Future<String?> getLanguage() async => await _read(_keyLanguage);

  Future<void> saveTTCMode(bool enabled) async => await _write(_keyTTC, enabled.toString());
  Future<bool> getTTCMode() async => (await _read(_keyTTC)) == 'true';

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint("❌ Error clearing storage: $e");
    }
  }

  // --- Hive encryption key management & Migration ---

  /// Возвращает стабильный 32-байтный ключ для HiveAesCipher.
  /// Если ключ поврежден или удален (resetOnError), генерирует новый и поднимает флаг `wasHiveKeyReset`.
  Future<Uint8List> getOrCreateHiveCipherKey() async {
    try {
      final existing = await _read(_keyHiveCipher);
      if (existing != null && existing.isNotEmpty) {
        final bytes = base64Decode(existing);
        if (bytes.length == 32) {
          return Uint8List.fromList(bytes);
        } else {
          debugPrint("⚠️ Внимание: Неверный размер ключа Hive (${bytes.length}). Требуется миграция.");
        }
      }
    } catch (e) {
      debugPrint("❌ Ошибка при чтении ключа шифрования Hive: $e");
    }

    // Если мы дошли сюда, значит ключа нет (первый запуск) или он был сброшен системой.
    debugPrint("🔄 Генерация нового 32-байтного ключа для Hive...");

    // Поднимаем флаг, чтобы основное приложение знало, что старые базы не откроются
    _wasHiveKeyReset = true;

    final rnd = Random.secure();
    final keyBytes = Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));

    try {
      await _write(_keyHiveCipher, base64Encode(keyBytes));
    } catch (e) {
      debugPrint("❌ КРИТИЧЕСКАЯ ОШИБКА: Не удалось сохранить ключ Hive: $e");
      rethrow;
    }

    return keyBytes;
  }
}