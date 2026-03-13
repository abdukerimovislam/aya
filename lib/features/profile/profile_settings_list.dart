import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🔥 ИМПОРТ ДЛЯ УДАЛЕНИЯ БАЗЫ

import '../../core/services/backup_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/secure_storage_service.dart'; // 🔥 ИМПОРТ ДЛЯ ОЧИСТКИ КЛЮЧЕЙ
import '../../core/theme/app_theme.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/coc_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/pack_selection_dialog.dart';

class ProfileSettingsList extends StatelessWidget {
  const ProfileSettingsList({super.key});

  Future<void> _handleCOCToggle(BuildContext context, bool newValue, CycleProvider cycle, SettingsProvider settings) async {
    if (!newValue) {
      HapticFeedback.mediumImpact();
      await cycle.setCOCMode(false);
      return;
    }

    HapticFeedback.selectionClick();

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => const _COCStartDialog(),
    );

    if (result != null) {
      // По умолчанию включаем режим 21/7
      await settings.setCOCSettings(21, 7, packStartDate: result);
      await cycle.setCOCMode(true, packStartDate: result);
    }
  }

  void _showPackSelection(BuildContext context, COCProvider coc, SettingsProvider settings) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (ctx) => PackSelectionDialog(
        currentSelection: coc.pillCount,
        onSelect: (int selection) async {
          int activePills;
          int breakDays;

          if (selection == 21) {
            activePills = 21; breakDays = 7;
          } else if (selection == 24) {
            activePills = 24; breakDays = 4;
          } else if (selection == 28) {
            activePills = 21; breakDays = 7;
          } else {
            activePills = 28; breakDays = 0;
          }

          await settings.setCOCSettings(activePills, breakDays);
          await coc.setPackSize(selection);
        },
      ),
    );
  }

  // 🔥 Apple App Store Guideline 5.1.1 - Удаление аккаунта и данных
  Future<void> _showDeleteDataDialog(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Delete All Data?",
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          "This action cannot be undone. All your health logs, cycle history, and settings will be permanently deleted from this device.",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // 1. Очищаем ключи
      await SecureStorageService().clearAll();
      // 2. Жестко удаляем файлы баз данных с устройства
      await Hive.deleteBoxFromDisk('cycles');
      await Hive.deleteBoxFromDisk('settings');
      await Hive.deleteBoxFromDisk('symptom_logs');
      await Hive.deleteBoxFromDisk('coc_settings');

      // 3. Выкидываем пользователя на онбординг (перезапуск приложения)
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cycle = context.watch<CycleProvider>();
    final coc = context.watch<COCProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title: l10n.sectionGeneral),
        ProfileSettingsGroup(
          children: [
            ProfileSwitchTile(
              icon: CupertinoIcons.bell,
              title: l10n.prefNotifications,
              value: settings.notificationsEnabled,
              onChanged: (v) => settings.setNotificationsEnabled(v),
            ),
            const _Divider(),
            ProfileSwitchTile(
              icon: CupertinoIcons.lock_shield,
              title: l10n.prefBiometrics,
              value: settings.biometricsEnabled,
              onChanged: (v) => settings.setBiometricsEnabled(v),
            ),
            const _Divider(),
            ProfileSwitchTile(
              icon: Icons.medication_outlined,
              title: l10n.prefCOC,
              value: cycle.isCOCEnabled,
              onChanged: (v) => _handleCOCToggle(context, v, cycle, settings),
            ),
            if (cycle.isCOCEnabled) ...[
              const _Divider(),
              ProfileSettingsTile(
                icon: CupertinoIcons.capsule_fill,
                title: l10n.dialogPackTitle,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${coc.pillCount} Pills",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
                onTap: () => _showPackSelection(context, coc, settings),
              ),
            ]
          ],
        ),

        const SizedBox(height: 24),

        if (!cycle.isCOCEnabled) ...[
          const ProfileSectionTitle(title: "CYCLE CONFIGURATION"),
          ProfileSettingsGroup(
            children: [
              // 🔥 РЕЖИМ ПЛАНИРОВАНИЯ БЕРЕМЕННОСТИ (Показывается только если нет КОК)
              ProfileSwitchTile(
                icon: CupertinoIcons.heart_circle,
                title: "Pregnancy Planning (TTC)",
                value: cycle.isTTCMode,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  cycle.setTTCMode(v);
                },
              ),
              const _Divider(),
              ProfileSliderTile(
                icon: CupertinoIcons.arrow_2_circlepath,
                title: "Cycle Length",
                value: cycle.cycleLength.toDouble(),
                min: 12,
                max: 180,
                suffix: l10n.unitDays,
                onChanged: (val) => cycle.setCycleLength(val.toInt()),
              ),
              const _Divider(),
              ProfileSliderTile(
                icon: CupertinoIcons.drop,
                title: "Period Length",
                value: cycle.avgPeriodDuration.toDouble(),
                min: 2,
                max: 14,
                suffix: l10n.unitDays,
                onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt()),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        ProfileSectionTitle(title: l10n.sectionData),
        ProfileSettingsGroup(
          children: [
            ProfileSettingsTile(
              icon: CupertinoIcons.doc_text,
              title: l10n.btnExportPdf,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => PdfService.generateReport(context),
            ),
            const _Divider(),
            ProfileSettingsTile(
              icon: CupertinoIcons.cloud_upload,
              title: l10n.btnBackup,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => BackupService.createBackup(context),
            ),
            const _Divider(),
            ProfileSettingsTile(
              icon: CupertinoIcons.cloud_download,
              title: "Restore Data",
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => BackupService.restoreBackup(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        ProfileSectionTitle(title: l10n.sectionAbout),
        ProfileSettingsGroup(
          children: [
            ProfileSettingsTile(
              icon: CupertinoIcons.mail,
              title: l10n.btnContactSupport,
              onTap: () => launchUrl(Uri.parse('mailto:support@evimoon.com')),
            ),
            const _Divider(),
            ProfileSettingsTile(
              icon: CupertinoIcons.star,
              title: l10n.btnRateApp,
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 32),

        // 🔥 DANGER ZONE (APPLE REVIEW REQUIREMENT)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            onPressed: () => _showDeleteDataDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.trash, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Delete All Data",
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

// Диалог выбора даты старта пачки
class _COCStartDialog extends StatefulWidget {
  const _COCStartDialog();

  @override
  State<_COCStartDialog> createState() => _COCStartDialogState();
}

class _COCStartDialogState extends State<_COCStartDialog> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.medication, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Start Pill Pack",
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "When did you take the first pill of your current pack?",
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (DateTime newDate) {
                setState(() => _selectedDate = newDate);
              },
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text("Cancel", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context, _selectedDate);
          },
          child: Text("Start", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 50, color: Colors.black12);
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}

class ProfileSettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const ProfileSettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PremiumGlassCard(
        padding: EdgeInsets.zero,
        child: Column(children: children),
      ),
    );
  }
}

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ProfileSettingsTile({super.key, required this.icon, required this.title, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: trailing,
    );
  }
}

class ProfileSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const ProfileSwitchTile({super.key, required this.icon, required this.title, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return ProfileSettingsTile(
      icon: icon,
      title: title,
      onTap: () => onChanged(!value),
      trailing: CupertinoSwitch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }
}

class ProfileSliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String suffix;

  const ProfileSliderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          trailing: Text("${value.toInt()} $suffix", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}