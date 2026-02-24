import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../../ayla_app.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/coc_provider.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../shared/widgets/coc_start_dialog.dart';
import '../../shared/widgets/mode_transition_overlay.dart';
import '../../shared/widgets/pack_selection_dialog.dart';
import '../onboarding/onboarding_screen.dart';



mixin ProfileLogicMixin {

  // 🔥 SMOOTH FADE TRANSITION TO HOME
  void goToHome(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            reverseTransitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const curve = Curves.easeInOut;
              var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
              return FadeTransition(opacity: curvedAnimation, child: child);
            },
          ),
              (route) => false,
        );
      }
    });
  }

  // --- SUPPORT ---
  Future<void> openSupportEmail(BuildContext context) async {
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgEmailError(supportEmail))));
        }
      }
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }

  // --- DIALOGS ---
  void showPackTypePicker(BuildContext context) {
    final coc = Provider.of<COCProvider>(context, listen: false);
    final cycle = Provider.of<CycleProvider>(context, listen: false);

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

  void showCOCStartDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coc = Provider.of<COCProvider>(context, listen: false);
    final cycle = Provider.of<CycleProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false); // Needed to force-disable TTC

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
              ModeTransitionOverlay.show(context, TransitionMode.coc, l10n.transitionCOC, onComplete: () {
                // 🔥 Ensure TTC is OFF when enabling COC
                settings.setTTCMode(false);
                cycle.setTTCMode(false);

                coc.toggleCOC(true, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                cycle.setCOCMode(true);
                cycle.startNewCycle();
                goToHome(context);
              });
            },
            onContinue: () async {
              Navigator.pop(ctx);
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                // 🔥 Expanded range to 90 days
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)), child: child!),
              );
              if (picked != null) {
                ModeTransitionOverlay.show(context, TransitionMode.coc, l10n.transitionCOC, onComplete: () {
                  // 🔥 Ensure TTC is OFF when enabling COC
                  settings.setTTCMode(false);
                  cycle.setTTCMode(false);

                  coc.toggleCOC(true, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                  cycle.setCOCMode(true);
                  cycle.setSpecificCycleStartDate(picked);
                  goToHome(context);
                });
              }
            },
          ),
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storage = Provider.of<SettingsProvider>(context, listen: false).storageService;

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.dialogResetTitle),
        content: Text(l10n.dialogResetBody),
        actions: [
          CupertinoDialogAction(child: Text(l10n.dialogCancel), onPressed: () => Navigator.pop(ctx)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.dialogResetConfirm),
            onPressed: () async {
              Navigator.pop(ctx);
              await Hive.deleteFromDisk();
              await storage.clearAll();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  // --- ACTIONS ---

  Future<void> handleBiometrics(BuildContext context, bool val) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (val) {
      final auth = AuthService();
      if (await auth.canCheckBiometrics) {
        if (await auth.authenticate(l10n.authBiometricsReason)) {
          settings.setBiometricsEnabled(true); // ✅ Fixed Method Name
        }
      } else {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgBiometricsError)));
      }
    } else {
      settings.setBiometricsEnabled(false); // ✅ Fixed Method Name
    }
  }
}