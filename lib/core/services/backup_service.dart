import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/medication_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';
import 'auth_service.dart';
import 'backup_crypto.dart';

class BackupService {
  static const Set<String> _encryptedBoxes = {
    'settings',
    'cycles',
    'symptom_logs',
    'coc_settings',
  };

  static AppLocalizations get _l10n =>
      lookupAppLocalizations(const Locale('en'));

  static Future<Box> _getBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box(name);
    if (_encryptedBoxes.contains(name)) {
      throw StateError(_l10n.backupEncryptedBoxMustBeOpen(name));
    }
    return Hive.openBox(name);
  }

  static Future<void> _showSnack(
      BuildContext context, {
        required String message,
        required bool success,
      }) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  static Future<bool> _confirmSensitiveAction(
      BuildContext context, {
        required AppLocalizations l10n,
        required String title,
        required String body,
        required String confirm,
      }) async {
    if (!context.mounted) return false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirm),
            ),
          ],
        );
      },
    );

    return ok ?? false;
  }

  static Future<bool> _requireAuthIfEnabled(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.biometricsEnabled) return true;

    final reason = AppLocalizations.of(context)?.authReason ?? _l10n.authReason;

    final auth = AuthService();
    final canCheck = await auth.canCheckBiometrics;
    if (!canCheck) return true;

    return auth.authenticate(reason);
  }

  static Future<String?> _askPassword(
      BuildContext context, {
        required bool confirm,
        required AppLocalizations l10n,
        required String title,
        required String hint,
      }) async {
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    bool obscure = true;
    String? error;

    Future<void> showError(StateSetter setState, String msg) async {
      setState(() => error = msg);
    }

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller1,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: hint,
                      errorText: error,
                    ),
                  ),
                  if (confirm) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller2,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: l10n.backupConfirmPasswordHint,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: !obscure,
                        onChanged: (v) => setState(() => obscure = !(v ?? false)),
                      ),
                      Text(l10n.backupShowPassword),
                    ],
                  ),
                  Text(
                    l10n.backupPasswordLostWarning,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.btnCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final p1 = controller1.text.trim();
                    if (p1.length < 6) {
                      await showError(setState, l10n.backupPasswordTooShort);
                      return;
                    }
                    if (confirm) {
                      final p2 = controller2.text.trim();
                      if (p1 != p2) {
                        await showError(setState, l10n.backupPasswordsDoNotMatch);
                        return;
                      }
                    }
                    Navigator.of(ctx).pop(p1);
                  },
                  child: Text(l10n.backupContinueAction),
                ),
              ],
            );
          },
        );
      },
    );

    controller1.dispose();
    controller2.dispose();
    return result;
  }

  /// 📤 CREATE BACKUP
  static Future<void> createBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context) ?? _l10n;
    final authFailedMessage = l10n.backupAuthFailed;
    final backupSubject = l10n.backupSubject;

    final confirmed = await _confirmSensitiveAction(
      context,
      l10n: l10n,
      title: l10n.backupExportTitle,
      body: l10n.backupExportBody,
      confirm: l10n.backupContinueAction,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final authed = await _requireAuthIfEnabled(context);
    if (!authed) {
      if (!context.mounted) return;
      await _showSnack(context, message: authFailedMessage, success: false);
      return;
    }
    if (!context.mounted) return;

    final password = await _askPassword(
      context,
      confirm: true,
      l10n: l10n,
      title: l10n.backupSetPasswordTitle,
      hint: l10n.backupPasswordHint,
    );
    if (password == null) return;

    try {
      final cycleBox = await _getBox('cycles');
      final settingsBox = await _getBox('settings');
      final wellnessBox = await _getBox('symptom_logs');
      final medicationRegistryBox = await _getBox('medications_registry');
      final medicationLogsBox = await _getBox('medications_logs');

      // 1. Бэкап Циклов (для обратной совместимости)
      final List<Map<String, dynamic>> cyclesJson = cycleBox.values.map((e) {
        final cycle = e as CycleModel;
        return {
          'startDate': cycle.startDate.millisecondsSinceEpoch,
          'endDate': cycle.endDate?.millisecondsSinceEpoch,
          'length': cycle.length,
          'ovulationOverrideDate': cycle.ovulationOverrideDate?.millisecondsSinceEpoch,
        };
      }).toList();

      // 2. Бэкап настроек и массива кровотечений (Source of Truth)
      final keysToBackup = [
        'app_mode', 'coc_enabled', 'ttc_mode_enabled',
        'avg_cycle_len', 'avg_period_len',
        'bleeding_days', 'manual_cycle_starts',
        'current_period_ended', 'fallback_start_date',
        'current_ovulation_override', 'current_ovulation_override_source',
        'ttc_strategy', 'coc_active_count', 'coc_break_days'
      ];

      final Map<String, dynamic> settingsJson = {};
      for (var k in keysToBackup) {
        if (settingsBox.containsKey(k)) settingsJson[k] = settingsBox.get(k);
      }

      // 3. Бэкап логов симптомов (Крайне важно для TTC!)
      final Map<String, dynamic> logsJson = {};
      for (var key in wellnessBox.keys) {
        final log = wellnessBox.get(key) as SymptomLog;
        logsJson[key.toString()] = {
          'date': log.date.millisecondsSinceEpoch,
          'flow': log.flow.index,
          'mood': log.mood,
          'energy': log.energy,
          'sleep': log.sleep,
          'skin': log.skin,
          'libido': log.libido,
          'painSymptoms': log.painSymptoms,
          'moodSymptoms': log.moodSymptoms,
          'symptoms': log.symptoms,
          'ovulationTest': log.ovulationTest.index,
          'mucus': log.mucus.index, // 🔥 ИСПРАВЛЕНО: Правильное имя переменной
          'temperature': log.temperature,
          'weight': log.weight,
          'notes': log.notes,
        };
      }

      final List<dynamic> medicationsRegistryJson = List<dynamic>.from(
        medicationRegistryBox.get('items', defaultValue: const <dynamic>[]),
      );

      final Map<String, dynamic> medicationsLogsJson = {};
      for (var key in medicationLogsBox.keys) {
        final taken = medicationLogsBox.get(key, defaultValue: const <String>[]);
        medicationsLogsJson[key.toString()] = List<String>.from(taken as List);
      }

      final Map<String, dynamic> backupData = {
        'version': 3,
        'app': 'EviMoon',
        'timestamp': DateTime.now().toIso8601String(),
        'cycles': cyclesJson,
        'settings': settingsJson,
        'symptom_logs': logsJson,
        'medications_registry': medicationsRegistryJson,
        'medications_logs': medicationsLogsJson,
      };

      final innerJson = jsonEncode(backupData);

      // ✅ Encrypt into envelope
      final envelope = await BackupCrypto.encryptEnvelopeAsync(plaintext: innerJson, password: password);
      final envelopeJson = jsonEncode(envelope);

      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/EviMoon_Backup_$dateStr.enc.json');
      await file.writeAsString(envelopeJson);
      if (!context.mounted) return;

      final box = context.findRenderObject() as RenderBox?;
      Rect? shareOrigin;
      if (box != null) {
        shareOrigin = box.localToGlobal(Offset.zero) & box.size;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: backupSubject,
        text: l10n.backupEncryptedCreated(dateStr),
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      debugPrint("Backup Error: $e");
      if (!context.mounted) return;
      await _showSnack(
        context,
        message: l10n.backupFailed(e.toString()),
        success: false,
      );
    }
  }

  /// 📥 RESTORE FROM BACKUP
  static Future<void> restoreBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context) ?? _l10n;
    final authFailedMessage = l10n.backupAuthFailed;
    final emptyPathMessage = l10n.backupPathEmpty;
    final wrongPasswordMessage = l10n.backupWrongPassword;
    final invalidBackupMessage = l10n.backupInvalidFileFormat;
    final invalidFileMessage = l10n.backupRestoreFailed;
    final successMessage = l10n.msgRestoreSuccess;

    final confirmed = await _confirmSensitiveAction(
      context,
      l10n: l10n,
      title: l10n.backupRestoreTitle,
      body: l10n.backupRestoreBody,
      confirm: l10n.btnRestore,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final authed = await _requireAuthIfEnabled(context);
    if (!authed) {
      if (!context.mounted) return;
      await _showSnack(context, message: authFailedMessage, success: false);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null) return;

      final path = result.files.single.path;
      if (path == null || path.isEmpty) throw Exception(emptyPathMessage);

      final file = File(path);
      final raw = await file.readAsString();
      final dynamic top = jsonDecode(raw);
      Map<String, dynamic> appData;

      final isEncryptedEnvelope = top is Map && top['version'] != null && top['version'] <= BackupCrypto.currentVersion && top['alg'] == 'AES-GCM-256' && top['ciphertext'] != null && top['mac'] != null;

      if (isEncryptedEnvelope) {
        if (!context.mounted) return;
        final password = await _askPassword(
          context,
          confirm: false,
          l10n: l10n,
          title: l10n.backupEnterPasswordTitle,
          hint: l10n.backupPasswordHint,
        );
        if (password == null) return;

        try {
          final plaintext = await BackupCrypto.decryptEnvelopeAsyncToPlaintext(envelope: Map<String, dynamic>.from(top), password: password);
          final decoded = jsonDecode(plaintext);
          if (decoded is! Map<String, dynamic>) throw const FormatException('Inner JSON is not a map');
          appData = decoded;
        } catch (e) {
          if (!context.mounted) return;
          await _showSnack(context, message: wrongPasswordMessage, success: false);
          return;
        }
      } else {
        if (top is! Map<String, dynamic>) throw Exception(invalidBackupMessage);
        appData = top;
      }

      if (appData['app'] != 'EviMoon' || !appData.containsKey('cycles') || !appData.containsKey('settings')) {
        throw Exception(invalidBackupMessage);
      }

      final cycleBox = await _getBox('cycles');
      final settingsBox = await _getBox('settings');
      final wellnessBox = await _getBox('symptom_logs');
      final medicationRegistryBox = await _getBox('medications_registry');
      final medicationLogsBox = await _getBox('medications_logs');

      await cycleBox.clear();

      // 1. Восстанавливаем циклы
      final List<dynamic> cyclesList = (appData['cycles'] as List<dynamic>);
      for (final c in cyclesList) {
        if (c is! Map) continue;
        final startMs = c['startDate'];
        if (startMs == null) continue;

        await cycleBox.add(CycleModel(
          startDate: DateTime.fromMillisecondsSinceEpoch(startMs),
          endDate: c['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(c['endDate']) : null,
          length: c['length'],
          ovulationOverrideDate: c['ovulationOverrideDate'] != null ? DateTime.fromMillisecondsSinceEpoch(c['ovulationOverrideDate']) : null,
        ));
      }

      // 2. Восстанавливаем логи
      if (appData.containsKey('symptom_logs')) {
        await wellnessBox.clear();
        final Map<String, dynamic> logsMap = Map<String, dynamic>.from(appData['symptom_logs']);
        for (var entry in logsMap.entries) {
          final v = entry.value as Map<String, dynamic>;
          final log = SymptomLog(
            date: DateTime.fromMillisecondsSinceEpoch(v['date']),
            flow: FlowIntensity.values[v['flow'] ?? 0],
            mood: v['mood'] ?? 3,
            energy: v['energy'] ?? 3,
            sleep: v['sleep'] ?? 3,
            skin: v['skin'] ?? 3,
            libido: v['libido'] ?? 3,
            painSymptoms: List<String>.from(v['painSymptoms'] ?? []),
            moodSymptoms: List<String>.from(v['moodSymptoms'] ?? []),
            symptoms: List<String>.from(v['symptoms'] ?? []),
            ovulationTest: OvulationTestResult.values[v['ovulationTest'] ?? 0],
            mucus: v['mucus'] != null ? CervicalMucusType.values[v['mucus']] : CervicalMucusType.none, // 🔥 ИСПРАВЛЕНО
            temperature: v['temperature'],
            weight: v['weight'],
            notes: v['notes'],
          );
          await wellnessBox.put(entry.key, log);
        }
      }

      await medicationRegistryBox.clear();
      await medicationLogsBox.clear();

      if (appData.containsKey('medications_registry')) {
        final registry = List<dynamic>.from(appData['medications_registry']);
        await medicationRegistryBox.put(
          'items',
          registry.map((item) => Map<String, dynamic>.from(item as Map)).toList(),
        );
      }

      if (appData.containsKey('medications_logs')) {
        final Map<String, dynamic> medsLogMap = Map<String, dynamic>.from(appData['medications_logs']);
        for (var entry in medsLogMap.entries) {
          await medicationLogsBox.put(entry.key, List<String>.from(entry.value as List));
        }
      }

      // 3. Восстанавливаем настройки и триггеры
      final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(appData['settings']);
      final keysToBackup = [
        'app_mode', 'coc_enabled', 'ttc_mode_enabled', 'avg_cycle_len', 'avg_period_len',
        'bleeding_days', 'manual_cycle_starts', 'current_period_ended', 'fallback_start_date',
        'current_ovulation_override', 'current_ovulation_override_source',
        'ttc_strategy', 'coc_active_count', 'coc_break_days'
      ];

      await settingsBox.deleteAll(keysToBackup);

      for (var k in keysToBackup) {
        if (settingsMap.containsKey(k)) {
          // Приводим списки к List<int>
          if (k == 'bleeding_days' || k == 'manual_cycle_starts') {
            await settingsBox.put(k, (settingsMap[k] as List).cast<int>());
          } else {
            await settingsBox.put(k, settingsMap[k]);
          }
        }
      }

      if (context.mounted) {
        context.read<CycleProvider>().reload();
        context.read<WellnessProvider>().reload(); // Обновляем логи на UI
        context.read<SettingsProvider>().reload();
        context.read<MedicationProvider>().reload();

        await _showSnack(context, message: successMessage, success: true);
      }
    } catch (e) {
      debugPrint("Restore Error: $e");
      if (!context.mounted) return;
      await _showSnack(context, message: invalidFileMessage, success: false);
    }
  }
}
