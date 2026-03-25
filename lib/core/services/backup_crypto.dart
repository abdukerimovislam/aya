import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Encrypted backup envelope (version 2):
/// {
///   "version": 2,
///   "alg": "AES-GCM-256",
///   "kdf": "PBKDF2-HMAC-SHA256",
///   "iter": 200000,
///   "salt": "base64-string",
///   "nonce": "base64-string",
///   "ciphertext": "base64-string",
///   "mac": "base64-string"
/// }
class BackupCrypto {
  static const int currentVersion = 2; // 🔥 Добавлена версия для миграций
  static const int _saltBytes = 16;
  static const int _nonceBytes = 12;
  static const int _keyBytes = 32;
  static const int _iterations = 200000;

  static final AesGcm _cipher = AesGcm.with256bits();

  // 🔥 ОПТИМИЗАЦИЯ 1: Только честные асинхронные методы (никаких фейковых синхронных)
  static Future<String> encryptToEnvelopeJsonAsync({
    required String plaintext,
    required String password,
  }) async {
    final envelope = await encryptEnvelopeAsync(
      plaintext: plaintext,
      password: password,
    );
    return jsonEncode(envelope);
  }

  static Future<Map<String, dynamic>> encryptEnvelopeAsync({
    required String plaintext,
    required String password,
  }) async {
    final rnd = Random.secure();
    final salt = Uint8List.fromList(List<int>.generate(_saltBytes, (_) => rnd.nextInt(256)));
    final nonce = Uint8List.fromList(List<int>.generate(_nonceBytes, (_) => rnd.nextInt(256)));

    final secretKey = await _deriveKey(password: password, salt: salt, iterations: _iterations);

    final secretBox = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    return <String, dynamic>{
      'version': currentVersion,
      'alg': 'AES-GCM-256',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iter': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  static Future<String> decryptEnvelopeJsonToPlaintextAsync({
    required String envelopeJson,
    required String password,
  }) async {
    final Map<String, dynamic> env = jsonDecode(envelopeJson);
    return await decryptEnvelopeAsyncToPlaintext(envelope: env, password: password);
  }

  static Future<String> decryptEnvelopeAsyncToPlaintext({
    required Map<String, dynamic> envelope,
    required String password,
  }) async {
    final version = envelope['version'];

    // 🔥 ОПТИМИЗАЦИЯ 2: Безопасная проверка версий для будущих миграций
    if (version == null || version > currentVersion) {
      throw const FormatException('Unsupported encrypted backup version.');
    }

    if (envelope['alg'] != 'AES-GCM-256' || envelope['kdf'] != 'PBKDF2-HMAC-SHA256') {
      throw const FormatException('Invalid encrypted backup format or algorithm.');
    }

    final int iter = (envelope['iter'] is int) ? envelope['iter'] as int : _iterations;

    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final cipherText = base64Decode(envelope['ciphertext'] as String);
    final macBytes = base64Decode(envelope['mac'] as String);

    final secretKey = await _deriveKey(
      password: password,
      salt: Uint8List.fromList(salt),
      iterations: iter,
    );

    final secretBox = SecretBox(
      Uint8List.fromList(cipherText),
      nonce: Uint8List.fromList(nonce),
      mac: Mac(Uint8List.fromList(macBytes)),
    );

    final clearBytes = await _cipher.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearBytes);
  }

  static Future<SecretKey> _deriveKey({
    required String password,
    required Uint8List salt,
    required int iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _keyBytes * 8,
    );

    final baseKey = SecretKey(utf8.encode(password));
    return pbkdf2.deriveKey(secretKey: baseKey, nonce: salt);
  }
}
