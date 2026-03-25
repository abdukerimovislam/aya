import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';

class PartnerSyncService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const int _maxInviteCodeAttempts = 10;

  static Future<User> _ensureAuthenticated() async {
    User? user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) debugPrint("🔒 Signing in anonymously...");
      final userCredential = await _auth.signInAnonymously();
      user = userCredential.user;
    }
    if (user == null) throw Exception("Failed to authenticate anonymously.");
    return user;
  }

  static Box _settingsBox() => Hive.box('settings');

  static String _normalizeInviteCode(String code) {
    final digits = code.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 6) return code.trim();
    return '${digits.substring(0, 3)}-${digits.substring(3)}';
  }

  static String _randomInviteCode(Random rng) {
    return "${rng.nextInt(900) + 100}-${rng.nextInt(900) + 100}";
  }

  static Future<String> _generateUniqueInviteCode() async {
    final rng = Random.secure();

    for (int attempt = 0; attempt < _maxInviteCodeAttempts; attempt++) {
      final code = _randomInviteCode(rng);
      final existing = await _db.collection('couples')
          .where('invite_code', isEqualTo: code)
          .where('code_expires_at', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        return code;
      }
    }

    throw Exception("Failed to generate a unique invite code.");
  }

  static Future<int?> _readTodayMoodFromLocalLog() async {
    if (!Hive.isBoxOpen('symptom_logs')) return null;

    final logsBox = Hive.box('symptom_logs');
    final now = DateTime.now();
    final key = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final log = logsBox.get(key);

    if (log is SymptomLog) {
      return log.mood;
    }

    return null;
  }

  // --- 1. ГЕНЕРАЦИЯ КОДА ПРИГЛАШЕНИЯ (ДЛЯ ДЕВУШКИ) ---

  static Future<String?> generateInviteCode() async {
    try {
      final user = await _ensureAuthenticated();
      final code = await _generateUniqueInviteCode();
      final expiresAt = DateTime.now().add(const Duration(hours: 24));

      final query = await _db.collection('couples').where('female_uid', isEqualTo: user.uid).get();

      String coupleId;
      if (query.docs.isNotEmpty) {
        coupleId = query.docs.first.id;
        await _db.collection('couples').doc(coupleId).update({
          'invite_code': code,
          'code_expires_at': Timestamp.fromDate(expiresAt),
        });
      } else {
        final docRef = await _db.collection('couples').add({
          'female_uid': user.uid,
          'partner_uid': null,
          'invite_code': code,
          'code_expires_at': Timestamp.fromDate(expiresAt),
          'permissions': {
            'share_mood': true,
            'share_ttc': false,
          },
          'shared_state': {},
          'created_at': FieldValue.serverTimestamp(),
        });
        coupleId = docRef.id;
      }

      final box = _settingsBox();
      await box.put('couple_id', coupleId);

      return code;
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 Error generating invite code: $e");
      return null;
    }
  }

  // --- 2. ВВОД КОДА (ДЛЯ ПАРТНЕРА) ---

  static Future<bool> linkPartner(String inviteCode) async {
    try {
      final user = await _ensureAuthenticated();
      final normalizedCode = _normalizeInviteCode(inviteCode);

      final query = await _db.collection('couples')
          .where('invite_code', isEqualTo: normalizedCode)
          .where('code_expires_at', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Invalid or expired invite code.");
      }

      final coupleDoc = query.docs.first;
      final coupleRef = _db.collection('couples').doc(coupleDoc.id);

      await _db.runTransaction((transaction) async {
        final freshDoc = await transaction.get(coupleRef);
        final data = freshDoc.data();

        if (!freshDoc.exists || data == null) {
          throw Exception("Invite code is no longer valid.");
        }

        final currentCode = data['invite_code'] as String?;
        final partnerUid = data['partner_uid'] as String?;
        final femaleUid = data['female_uid'] as String?;
        final expiresAt = data['code_expires_at'] as Timestamp?;

        if (currentCode != normalizedCode || expiresAt == null || expiresAt.toDate().isBefore(DateTime.now())) {
          throw Exception("Invite code is no longer valid.");
        }
        if (femaleUid == user.uid) {
          throw Exception("You cannot link to your own invite code.");
        }
        if (partnerUid != null && partnerUid != user.uid) {
          throw Exception("This invite code has already been used.");
        }

        transaction.update(coupleRef, {
          'partner_uid': user.uid,
          'invite_code': null,
          'linked_at': FieldValue.serverTimestamp(),
        });
      });

      final box = _settingsBox();
      await box.put('couple_id', coupleDoc.id);
      await box.put('is_partner_mode', true);

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 Error linking partner: $e");
      return false;
    }
  }

  // --- 3. СИНХРОНИЗАЦИЯ ДАННЫХ (ВЫЗЫВАЕТСЯ ТИХО В ФОНЕ) ---

  static Future<void> syncStateToCloud({
    required CyclePhase phase,
    required int cycleDay,
    required int daysUntilNextPeriod,
    required bool isCoc,
    FertilityChance? fertilityChance,
    int? todayMood,
  }) async {
    try {
      final box = _settingsBox();
      final coupleId = box.get('couple_id');

      if (coupleId == null) return;

      await _ensureAuthenticated();

      final coupleDoc = await _db.collection('couples').doc(coupleId).get();
      if (!coupleDoc.exists) return;

      final data = coupleDoc.data()!;
      final permissions = data['permissions'] as Map<String, dynamic>? ?? {};
      final shareMood = permissions['share_mood'] ?? false;
      final shareTtc = permissions['share_ttc'] ?? false;
      final effectiveMood = todayMood ?? (shareMood ? await _readTodayMoodFromLocalLog() : null);

      final Map<String, dynamic> safeState = {
        'phase': phase.toString().split('.').last,
        'cycle_day': cycleDay,
        'days_until_next_period': daysUntilNextPeriod,
        'is_coc': isCoc,
        'last_updated': FieldValue.serverTimestamp(),
      };

      if (shareMood && effectiveMood != null) {
        safeState['mood'] = effectiveMood;
      }
      if (shareTtc && fertilityChance != null) {
        safeState['fertility_chance'] = fertilityChance.toString().split('.').last;
      }

      await _db.collection('couples').doc(coupleId).update({
        'shared_state': safeState,
      });

    } catch (e) {
      if (kDebugMode) debugPrint("🔥 Error syncing state to cloud: $e");
    }
  }

  // --- 4. ПОЛУЧЕНИЕ ДАННЫХ ДЛЯ ПАРТНЕРА (STREAM) ---

  static Stream<DocumentSnapshot<Map<String, dynamic>>> partnerDataStream() {
    final coupleId = _settingsBox().get('couple_id');
    if (coupleId == null) throw Exception("Not linked to any couple.");

    return _db.collection('couples').doc(coupleId).snapshots();
  }

  // --- 5. ОБНОВЛЕНИЕ ПРАВ ДОСТУПА ---
  static Future<void> updatePermissions(bool shareMood, bool shareTtc) async {
    try {
      final coupleId = _settingsBox().get('couple_id');
      if (coupleId == null) return;

      await _ensureAuthenticated();

      await _db.collection('couples').doc(coupleId).update({
        'permissions.share_mood': shareMood,
        'permissions.share_ttc': shareTtc,
      });
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 Error updating permissions: $e");
    }
  }

  // --- 6. ОТКЛЮЧЕНИЕ ПАРТНЕРА ---
  static Future<void> unlinkPartner() async {
    try {
      final box = _settingsBox();
      final coupleId = box.get('couple_id');

      if (coupleId != null) {
        await _ensureAuthenticated();

        // Удаляем связку из облака (оборачиваем в try-catch на случай, если второй уже удалил)
        try {
          await _db.collection('couples').doc(coupleId).delete();
        } catch (_) {}

        // 🔥 ИСПРАВЛЕНИЕ: Тотальная зачистка локальных ключей для обоих (и девушки, и парня)
        await box.delete('couple_id');
        await box.put('is_partner_mode', false); // Выключаем режим партнера, чтобы UI вернулся к нормальному виду
      }
    } catch (e) {
      if (kDebugMode) debugPrint("🔥 Error unlinking partner: $e");
    }
  }
}
