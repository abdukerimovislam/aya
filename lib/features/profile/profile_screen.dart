import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ayla_app.dart';
import '../../l10n/app_localizations.dart';
import 'premium_paywall_sheet.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/coc_provider.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/mode_transition_overlay.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/pack_selection_dialog.dart';
import '../../shared/widgets/coc_start_dialog.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _goToHome(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          reverseTransitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
            return FadeTransition(opacity: curvedAnimation, child: child);
          },
        ),
            (route) => false,
      );
    });
  }

  Future<void> _openSupportEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    const String supportEmail = "evimoon.app@proton.me";
    final String subject = Uri.encodeComponent(l10n.emailSubject);
    final String platformName = Platform.isIOS ? "iOS" : "Android";
    final String body = Uri.encodeComponent("${l10n.emailBody} $platformName");
    final Uri emailLaunchUri = Uri.parse("mailto:$supportEmail?subject=$subject&body=$body");

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.msgEmailError(supportEmail))),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }

  Future<void> _handleBiometrics(BuildContext context, bool val) async {
    final settings = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (val) {
      final auth = AuthService();
      if (await auth.canCheckBiometrics) {
        if (await auth.authenticate(l10n.authBiometricsReason)) {
          settings.setBiometricsEnabled(true);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.msgBiometricsError)),
          );
        }
      }
    } else {
      settings.setBiometricsEnabled(false);
    }
  }

  Future<void> _showDeleteDataDialog(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.tintedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.dialogResetTitle,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          "This action cannot be undone. All your health logs, cycle history, and settings will be permanently deleted from this device.",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dialogResetConfirm, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final storage = context.read<SettingsProvider>().storageService;
        await storage.clearAll();
        await SecureStorageService().clearAll();
        await Hive.deleteFromDisk();
      } catch (e) {
        debugPrint("Error clearing data: $e");
      }

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              (route) => false,
        );
      }
    }
  }

  void _showPackTypePicker(BuildContext context) {
    final coc = context.read<COCProvider>();
    final cycle = context.read<CycleProvider>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, __) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: FadeTransition(
          opacity: anim,
          child: PackSelectionDialog(
            currentSelection: coc.pillCount,
            onSelect: (newCount) {
              coc.setPillCount(newCount);
              cycle.setAveragePeriodDuration(newCount == 21 ? 7 : 4);
            },
          ),
        ),
      ),
    );
  }

  void _showCOCStartDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coc = context.read<COCProvider>();
    final cycle = context.read<CycleProvider>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, __) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: FadeTransition(
          opacity: anim,
          child: COCStartDialog(
            onFreshStart: () {
              Navigator.pop(ctx);
              ModeTransitionOverlay.show(
                context,
                TransitionMode.coc,
                l10n.transitionCOC,
                onComplete: () async {
                  final now = DateTime.now();
                  coc.toggleCOC(true, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                  await coc.startNewPack(startDate: now);
                  await cycle.setCOCMode(true, packStartDate: now);
                  if (context.mounted) _goToHome(context);
                },
              );
            },
            onContinue: () async {
              Navigator.pop(ctx);
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
                  child: child!,
                ),
              );
              if (picked != null) {
                ModeTransitionOverlay.show(
                  context,
                  TransitionMode.coc,
                  l10n.transitionCOC,
                  onComplete: () async {
                    coc.toggleCOC(true, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                    await coc.startNewPack(startDate: picked);
                    await cycle.setCOCMode(true, packStartDate: picked);
                    if (context.mounted) _goToHome(context);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, WellnessProvider wellness, AppLocalizations l10n) async {
    final validLogs = wellness.getLogHistory().where((l) {
      return l.flow != FlowIntensity.none ||
          l.painSymptoms.isNotEmpty ||
          l.symptoms.isNotEmpty ||
          (l.notes?.trim().isNotEmpty ?? false) ||
          (l.temperature ?? 0) > 0 ||
          l.ovulationTest != OvulationTestResult.none;
    }).toList();

    if (validLogs.length < 2) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.dialogDataInsufficientTitle),
            content: Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.dialogDataInsufficientBody)),
            actions: [
              CupertinoDialogAction(child: Text(l10n.btnOk), onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await PdfService.generateReport(context);
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgExportError)));
      }
    }
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  void _showGoalSelector(BuildContext context) {
    final cycle = context.read<CycleProvider>();
    final currentMode = cycle.appMode;

    _showSheet(
      context,
      Container(
        decoration: BoxDecoration(
          color: AppColors.tintedSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.28), borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 20),
              Text("My Goal", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 18),
              _GoalOption(
                title: "Track my cycle",
                subtitle: "Standard period and ovulation tracking",
                icon: CupertinoIcons.drop,
                color: AppColors.primary,
                isSelected: currentMode == AppMode.standard,
                onTap: () {
                  Navigator.pop(context);
                  if (currentMode != AppMode.standard) {
                    ModeTransitionOverlay.show(
                      context, TransitionMode.tracking, "Setting up cycle tracking...",
                      onComplete: () { cycle.setAppMode(AppMode.standard); if (context.mounted) _goToHome(context); },
                    );
                  }
                },
              ),
              _GoalOption(
                title: "Prevent pregnancy",
                subtitle: "Track my birth control pill",
                icon: CupertinoIcons.shield,
                color: Colors.teal,
                isSelected: currentMode == AppMode.coc,
                onTap: () {
                  Navigator.pop(context);
                  if (currentMode != AppMode.coc) _showCOCStartDialog(context);
                },
              ),
              _GoalOption(
                title: "Try to conceive",
                subtitle: "Maximized fertility predictions & BBT",
                icon: CupertinoIcons.heart_circle,
                color: Colors.purple,
                isSelected: currentMode == AppMode.ttc,
                onTap: () {
                  Navigator.pop(context);
                  if (currentMode == AppMode.ttc) return;

                  HapticFeedback.heavyImpact();
                  final msg = currentMode == AppMode.coc
                      ? "Congratulations on this beautiful decision!\n\nSwitching from birth control to pregnancy planning means your natural hormones will restart. We will clear your pill history and begin a completely fresh cycle starting today. Are you ready?"
                      : "Congratulations on this beautiful decision!\n\nWe will now optimize your AI predictions to pinpoint your exact fertile window and activate advanced tools like Basal Body Temperature tracking. Are you ready?";

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.tintedSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.10), shape: BoxShape.circle), child: const Icon(CupertinoIcons.sparkles, color: Colors.purple)),
                          const SizedBox(width: 12),
                          Expanded(child: Text("Exciting Journey! 🎉", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary))),
                        ],
                      ),
                      content: Text(msg, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.45)),
                      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ModeTransitionOverlay.show(
                              context, TransitionMode.ttc, "Setting up pregnancy planning...",
                              onComplete: () { cycle.setAppMode(AppMode.ttc); if (context.mounted) _goToHome(context); },
                            );
                          },
                          child: Text("Yes, I'm ready", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final cycle = context.watch<CycleProvider>();
    final wellness = context.watch<WellnessProvider>();
    final coc = context.watch<COCProvider>();

    final isPremium = settings.isPremium;
    final String goalText = cycle.appMode == AppMode.standard ? "Track my cycle" : cycle.appMode == AppMode.coc ? "Prevent pregnancy (Pill)" : "Try to conceive";
    final IconData goalIcon = cycle.appMode == AppMode.standard ? CupertinoIcons.drop : cycle.appMode == AppMode.coc ? CupertinoIcons.shield : CupertinoIcons.heart_circle;
    final Color goalColor = cycle.appMode == AppMode.standard ? AppColors.primary : cycle.appMode == AppMode.coc ? Colors.teal : Colors.purple;
    final safeName = settings.userName.trim().isEmpty ? "User" : settings.userName.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background,
                    AppColors.secondaryBackground.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.10), blurRadius: 90, spreadRadius: 10)],
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8E71C7).withOpacity(0.06),
                boxShadow: [BoxShadow(color: const Color(0xFF8E71C7).withOpacity(0.08), blurRadius: 80, spreadRadius: 8)],
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 340,
                pinned: true,
                stretch: true,
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text("Profile", style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                      child: _buildProfileHero(context: context, userName: safeName, avatar: settings.userAvatar, isPremium: isPremium, goalText: goalText, goalColor: goalColor),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader("My Goal"),
                    _buildGlassGroup([
                      ProfileSettingsTile(
                        icon: goalIcon, iconColor: goalColor, title: goalText, subtitle: "Your current tracking mode",
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Text("Change", style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(width: 8), Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary.withOpacity(0.45))],
                        ),
                        onTap: () => _showGoalSelector(context),
                      ),
                      if (cycle.appMode == AppMode.coc) ...[
                        const _Divider(),
                        ProfileSettingsTile(icon: Icons.grid_on_rounded, title: l10n.settingsPackType, subtitle: "Choose pill pack format", trailing: _buildBadge(l10n.settingsPills(coc.pillCount)), onTap: () => _showPackTypePicker(context)),
                        const _Divider(),
                        ProfileSettingsTile(
                          icon: Icons.access_alarm_rounded, title: l10n.settingsReminder, subtitle: "Daily pill reminder time",
                          trailing: Text(coc.reminderTime.format(context), style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: coc.reminderTime);
                            if (t != null) coc.setTime(t, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                          },
                        ),
                      ],
                    ]),
                    const SizedBox(height: 24),
                    if (cycle.appMode != AppMode.coc) ...[
                      _buildSectionHeader(l10n.sectionCycle),
                      _buildGlassGroup([
                        ProfileSliderTile(icon: Icons.loop_rounded, title: l10n.insightAvgCycle, subtitle: "Average cycle length", value: cycle.cycleLength.toDouble().clamp(21.0, 45.0), min: 21, max: 45, suffix: l10n.daysUnit, onChanged: (val) => cycle.setCycleLength(val.toInt())),
                        const _Divider(),
                        ProfileSliderTile(icon: Icons.water_drop_rounded, title: l10n.insightAvgPeriod, subtitle: "Average bleeding duration", value: cycle.periodDuration.toDouble().clamp(2.0, 10.0), min: 2, max: 10, suffix: l10n.daysUnit, onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt())),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader(l10n.settingsGeneral),
                    _buildGlassGroup([
                      ProfileSettingsTile(
                        icon: Icons.language, title: l10n.settingsLanguage, subtitle: "App language",
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Text(_getLanguageName(settings.locale.languageCode), style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)), const SizedBox(width: 8), Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary.withOpacity(0.45))],
                        ),
                        onTap: () => _showSheet(context, const _LanguageSelectorSheet()),
                      ),
                      const _Divider(),
                      ProfileSwitchTile(
                        icon: Icons.notifications_active_rounded, title: l10n.settingsNotifs, subtitle: "Cycle reminders and alerts", value: settings.notificationsEnabled,
                        onChanged: (val) async { await settings.setNotificationsEnabled(val); if (context.mounted && val) await context.read<CycleProvider>().rescheduleNotifications(); },
                      ),
                      if (settings.notificationsEnabled) ...[
                        const _Divider(),
                        ProfileSwitchTile(icon: Icons.nights_stay_rounded, title: l10n.settingsDailyLog ?? "Daily Check-in", subtitle: "Evening symptom reminder", value: settings.dailyLogEnabled, onChanged: (val) async { await settings.toggleDailyLogReminder(val); if (context.mounted) await context.read<CycleProvider>().rescheduleNotifications(); }),
                      ],
                      const _Divider(),
                      ProfileSwitchTile(icon: CupertinoIcons.lock_shield_fill, title: "Face ID / PIN", subtitle: "Protect your private health data", value: settings.biometricsEnabled, onChanged: (val) => _handleBiometrics(context, val)),
                      const _Divider(),
                      ProfileSettingsTile(icon: Icons.mail_outline_rounded, title: l10n.settingsSupport, subtitle: "Contact support team", trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary.withOpacity(0.45)), onTap: () => _openSupportEmail(context)),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.settingsData),
                    _buildGlassGroup([
                      ProfileSettingsTile(icon: Icons.picture_as_pdf_rounded, title: l10n.settingsExport, subtitle: "Export health report as PDF", trailing: Icon(isPremium ? Icons.arrow_forward_ios_rounded : Icons.lock_outline, size: isPremium ? 14 : 20, color: isPremium ? AppColors.textSecondary.withOpacity(0.45) : Colors.amber), onTap: () async { if (!isPremium) { _showSheet(context, const PremiumPaywallSheet()); return; } _handleExport(context, wellness, l10n); }),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.sectionBackup),
                    _buildGlassGroup([
                      ProfileSettingsTile(icon: Icons.cloud_upload_rounded, title: l10n.btnSaveBackup, subtitle: "Create local backup copy", trailing: Icon(Icons.save_alt, size: 20, color: AppColors.primary), onTap: () async { if (!Hive.isBoxOpen('cycles')) await Hive.openBox('cycles'); if (context.mounted) await BackupService.createBackup(context); }),
                      const _Divider(),
                      ProfileSettingsTile(
                        icon: Icons.cloud_download_rounded, title: l10n.btnRestoreBackup, subtitle: "Restore previously saved backup", trailing: Icon(Icons.restore_page, size: 20, color: AppColors.primary),
                        onTap: () => showCupertinoDialog(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: Text(l10n.dialogRestoreTitle), content: Text(l10n.dialogRestoreBody),
                            actions: [
                              CupertinoDialogAction(child: Text(l10n.btnCancel), onPressed: () => Navigator.pop(ctx)),
                              CupertinoDialogAction(isDestructiveAction: true, child: Text(l10n.btnRestore), onPressed: () async { Navigator.pop(ctx); if (!Hive.isBoxOpen('cycles')) await Hive.openBox('cycles'); await BackupService.restoreBackup(context); cycle.reload(); settings.reload(); }),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 28),
                    PremiumGlassCard(
                      borderRadius: 24, padding: const EdgeInsets.all(14), showAmbientGlow: false,
                      child: Center(
                        child: TextButton(
                          onPressed: () => _showDeleteDataDialog(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), backgroundColor: Colors.red.withOpacity(0.08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(CupertinoIcons.trash, color: Colors.red, size: 18), const SizedBox(width: 8), Text("Delete All Data", style: GoogleFonts.inter(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w800))]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero({required BuildContext context, required String userName, required String avatar, required bool isPremium, required String goalText, required Color goalColor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 240;

        return PremiumGlassCard(
          borderRadius: 36, // 🔥 Более мягкое и современное скругление
          padding: EdgeInsets.fromLTRB(
            20,
            compact ? 20 : 26,
            20,
            compact ? 20 : 26,
          ),
          showAmbientGlow: true,
          showAccentOrb: isPremium,
          child: Stack(
            clipBehavior: Clip.none, // Позволяет декору слегка выходить за рамки
            children: [
              // Декоративный фоновый круг (Орб)
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goalColor.withOpacity(0.06), // Чуть прозрачнее для мягкости
                  ),
                ),
              ),

              // Основной контент
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. АВАТАР
                  GestureDetector(
                    onTap: () => _showSheet(context, const _EditProfileSheet()),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildAvatarSized(avatar, isPremium, compact ? 86 : 106),

                        // Иконка редактирования
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.tintedSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: compact ? 13 : 15,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 18),

                  // 2. ИМЯ ПОЛЬЗОВАТЕЛЯ
                  GestureDetector(
                    onTap: () => _showSheet(context, const _EditProfileSheet()),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 22 : 28,
                              height: 1.0, // Плотная строка
                              letterSpacing: -0.5, // Делает шрифт визуально дороже
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: AppColors.textSecondary.withOpacity(0.35), // Сделали иконку мягче
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 3. ПОДЗАГОЛОВОК
                  Text(
                    isPremium
                        ? "Premium member"
                        : "Your personal health space",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500, // Чуть тоньше, чтобы не спорить с именем
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. ТЕГИ (CHIPS)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _heroChip(
                        icon: CupertinoIcons.sparkles,
                        label: goalText,
                        color: goalColor,
                      ),
                      _heroChip(
                        icon: CupertinoIcons.lock_shield_fill, // Закрашенная иконка смотрится лучше
                        label: "Private",
                        color: const Color(0xFF8E71C7),
                      ),
                      if (isPremium)
                        _heroChip(
                          icon: Icons.verified_rounded,
                          label: "Premium",
                          color: Colors.amber.shade700,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔥 ОБНОВЛЕННЫЙ ДИЗАЙН ТЕГОВ
  Widget _heroChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), // Чуть светлее фон
        borderRadius: BorderRadius.circular(12), // Скругленный прямоугольник вместо овала
        border: Border.all(color: color.withOpacity(0.15)), // Легкая рамка
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2, // Чуть больше воздуха между буквами
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) => const {'ru': 'Русский', 'es': 'Español', 'de': 'Deutsch', 'pt': 'Português', 'tr': 'Türkçe', 'pl': 'Polski', 'ky': 'Кыргызча'}[code] ?? 'English';

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 10),
      child: Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.75), shape: BoxShape.circle)), const SizedBox(width: 8), Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.1))]),
    );
  }

  Widget _buildGlassGroup(List<Widget> children) {
    return PremiumGlassCard(padding: const EdgeInsets.symmetric(vertical: 4), borderRadius: 26, showAmbientGlow: true, child: Column(children: children));
  }

  Widget _buildBadge(String text) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.12))), child: Text(text, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)));
  }

  Widget _buildAvatarSized(String emoji, bool isPremium, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: isPremium ? [Colors.amber.shade300, Colors.orange.shade400] : [AppColors.primary.withOpacity(0.24), AppColors.primary.withOpacity(0.10)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: (isPremium ? Colors.orange : AppColors.primary).withOpacity(0.22), blurRadius: 22, offset: const Offset(0, 10))]),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.48))),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override Widget build(BuildContext context) => Divider(height: 1, indent: 68, endIndent: 18, color: AppColors.textPrimary.withOpacity(0.05));
}

class _GoalOption extends StatelessWidget {
  final String title, subtitle; final IconData icon; final Color color; final bool isSelected; final VoidCallback onTap;
  const _GoalOption({required this.title, required this.subtitle, required this.icon, required this.color, required this.isSelected, required this.onTap});
  @override Widget build(BuildContext context) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)), title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)), trailing: isSelected ? Icon(Icons.check_circle, color: color) : null, onTap: () { HapticFeedback.selectionClick(); onTap(); });
}

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon; final Color? iconColor; final String title; final String? subtitle; final Widget? trailing; final VoidCallback? onTap;
  const ProfileSettingsTile({super.key, required this.icon, required this.title, this.subtitle, this.trailing, this.onTap, this.iconColor});
  @override Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.12))), child: Icon(icon, color: color, size: 20)), title: Text(title, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), subtitle: subtitle == null ? null : Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.25))), trailing: trailing);
  }
}

class ProfileSwitchTile extends StatelessWidget {
  final IconData icon; final String title; final String? subtitle; final bool value; final ValueChanged<bool> onChanged;
  const ProfileSwitchTile({super.key, required this.icon, required this.title, this.subtitle, required this.value, required this.onChanged});
  @override Widget build(BuildContext context) => ProfileSettingsTile(icon: icon, title: title, subtitle: subtitle, onTap: () => onChanged(!value), trailing: CupertinoSwitch(value: value, onChanged: onChanged, activeColor: AppColors.primary));
}

class ProfileSliderTile extends StatefulWidget {
  final IconData icon; final String title; final String? subtitle; final double value, min, max; final ValueChanged<double> onChanged; final String suffix;
  const ProfileSliderTile({super.key, required this.icon, required this.title, this.subtitle, required this.value, required this.min, required this.max, required this.onChanged, required this.suffix});

  @override
  State<ProfileSliderTile> createState() => _ProfileSliderTileState();
}

class _ProfileSliderTileState extends State<ProfileSliderTile> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant ProfileSliderTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
        decoration: BoxDecoration(color: AppColors.secondaryBackground.withOpacity(0.42), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider.withOpacity(0.9))),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withOpacity(0.12))), child: Icon(widget.icon, color: AppColors.primary, size: 20)),
              title: Text(widget.title, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              subtitle: widget.subtitle == null ? null : Text(widget.subtitle!, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary)),
              trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(10)), child: Text("${_currentValue.toInt()} ${widget.suffix}", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9), overlayShape: const RoundSliderOverlayShape(overlayRadius: 18), activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.primary.withOpacity(0.16), thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.10)),
                child: Slider(
                  value: _currentValue, min: widget.min, max: widget.max, divisions: (widget.max - widget.min).toInt(),
                  onChanged: (val) {
                    setState(() => _currentValue = val);
                  },
                  onChangeEnd: (val) {
                    widget.onChanged(val); // Сохраняем в провайдер только когда юзер отпустил палец
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();
  @override State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  final List<String> _avatars = ["👩", "👩‍🦰", "👱‍♀️", "👩‍🦱", "🧕", "👵", "🦊", "🐱", "🦄", "🐰", "🦋", "🌸", "✨", "🌙", "🍓"];

  @override void initState() { super.initState(); _nameController = TextEditingController(text: context.read<SettingsProvider>().userName); }
  @override void dispose() { _nameController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24), decoration: BoxDecoration(color: AppColors.tintedSurface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Edit Profile", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), const SizedBox(height: 24),
          SizedBox(height: 60, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _avatars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (context, index) {
            final avatar = _avatars[index]; final isSelected = settings.userAvatar == avatar;
            return GestureDetector(onTap: () => context.read<SettingsProvider>().setUserAvatar(avatar), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 60, height: 60, decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.18) : Colors.grey.withOpacity(0.08), shape: BoxShape.circle, border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null), child: Center(child: Text(avatar, style: const TextStyle(fontSize: 30)))));
          })),
          const SizedBox(height: 24),
          TextField(controller: _nameController, decoration: InputDecoration(labelText: "Your Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 2))), textCapitalization: TextCapitalization.words, onChanged: (val) => context.read<SettingsProvider>().setUserName(val.trim().isEmpty ? "User" : val.trim())),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("Done", style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)))),
        ],
      ),
    );
  }
}

class _LanguageSelectorSheet extends StatelessWidget {
  const _LanguageSelectorSheet();
  @override Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentCode = settings.locale.languageCode;
    final languages = [{'code': 'en', 'name': 'English'}, {'code': 'ru', 'name': 'Русский'}, {'code': 'ky', 'name': 'Кыргызча'}, {'code': 'es', 'name': 'Español'}, {'code': 'de', 'name': 'Deutsch'}, {'code': 'pt', 'name': 'Português'}, {'code': 'tr', 'name': 'Türkçe'}, {'code': 'pl', 'name': 'Polski'}];

    return Container(
      decoration: BoxDecoration(color: AppColors.tintedSurface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.28), borderRadius: BorderRadius.circular(999))), const SizedBox(height: 18),
              Text("Language", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), const SizedBox(height: 18),
              PremiumGlassCard(
                borderRadius: 24, padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(children: languages.map((item) {
                  final code = item["code"]!; final label = item["name"]!; final isSelected = currentCode == code;
                  return ListTile(
                    onTap: () { HapticFeedback.selectionClick(); settings.setLocale(Locale(code)); Navigator.pop(context); },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.secondaryBackground.withOpacity(0.55), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.language_rounded, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20)),
                    title: Text(label, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.primary) : null,
                  );
                }).toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}