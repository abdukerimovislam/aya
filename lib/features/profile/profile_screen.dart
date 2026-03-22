import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import 'premium_paywall_sheet.dart';
import 'theme_selector_sheet.dart';
import 'profile_logic_mixin.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/coc_provider.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/mode_transition_overlay.dart';
import '../../shared/widgets/premium_glass_card.dart';

class ProfileScreen extends StatelessWidget with ProfileLogicMixin {
  const ProfileScreen({super.key});

  Future<void> _ensureBoxes() async {
    if (!Hive.isBoxOpen('cycles')) await Hive.openBox('cycles');
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => child);
  }

  void _showGoalSelector(BuildContext context) {
    final cycle = context.read<CycleProvider>();
    final currentMode = cycle.appMode;

    _showSheet(context, Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.28), borderRadius: BorderRadius.circular(999))),
            const SizedBox(height: 20),
            Text("My Goal", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 18),
            _GoalOption(title: "Track my cycle", subtitle: "Standard period and ovulation tracking", icon: CupertinoIcons.drop, color: AppColors.primary, isSelected: currentMode == AppMode.standard, onTap: () {
              Navigator.pop(context);
              if (currentMode != AppMode.standard) ModeTransitionOverlay.show(context, TransitionMode.tracking, "Setting up cycle tracking...", onComplete: () { cycle.setAppMode(AppMode.standard); if (context.mounted) goToHome(context); });
            }),
            _GoalOption(title: "Prevent pregnancy", subtitle: "Track my birth control pill", icon: CupertinoIcons.shield, color: Colors.teal, isSelected: currentMode == AppMode.coc, onTap: () {
              Navigator.pop(context);
              if (currentMode != AppMode.coc) showCOCStartDialog(context);
            }),
            _GoalOption(title: "Try to conceive", subtitle: "Maximized fertility predictions & BBT", icon: CupertinoIcons.heart_circle, color: Colors.purple, isSelected: currentMode == AppMode.ttc, onTap: () {
              Navigator.pop(context);
              if (currentMode == AppMode.ttc) return;
              HapticFeedback.heavyImpact();
              final msg = currentMode == AppMode.coc ? "Congratulations on this beautiful decision!\n\nSwitching from birth control to pregnancy planning means your natural hormones will restart. We will clear your pill history and begin a completely fresh cycle starting today. Are you ready?" : "Congratulations on this beautiful decision!\n\nWe will now optimize your AI predictions to pinpoint your exact fertile window and activate advanced tools like Basal Body Temperature tracking. Are you ready?";
              showDialog(context: context, builder: (ctx) => AlertDialog(
                backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.10), shape: BoxShape.circle), child: const Icon(CupertinoIcons.sparkles, color: Colors.purple)), const SizedBox(width: 12), Expanded(child: Text("Exciting Journey! 🎉", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary)))]),
                content: Text(msg, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.45)),
                actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () { Navigator.pop(ctx); ModeTransitionOverlay.show(context, TransitionMode.ttc, "Setting up pregnancy planning...", onComplete: () { cycle.setAppMode(AppMode.ttc); if (context.mounted) goToHome(context); }); }, child: Text("Yes, I'm ready", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white))),
                ],
              ));
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ));
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
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.06), Colors.white, const Color(0xFFF8F4FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter)))),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent, expandedHeight: 290, pinned: true, stretch: true, automaticallyImplyLeading: false,
                title: Text("Profile", style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
                flexibleSpace: FlexibleSpaceBar(collapseMode: CollapseMode.pin, background: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), child: _buildProfileHero(context: context, userName: safeName, avatar: settings.userAvatar, isPremium: isPremium, goalText: goalText, goalColor: goalColor)))),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader("My Goal"),
                    _buildGlassGroup([
                      ProfileSettingsTile(icon: goalIcon, iconColor: goalColor, title: goalText, trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text("Change", style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)), const SizedBox(width: 6), Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.45))]), onTap: () => _showGoalSelector(context)),
                      if (cycle.appMode == AppMode.coc) ...[
                        _buildDivider(), ProfileSettingsTile(icon: Icons.grid_on_rounded, title: l10n.settingsPackType, trailing: _buildBadge(l10n.settingsPills(coc.pillCount)), onTap: () => showPackTypePicker(context)),
                        _buildDivider(), ProfileSettingsTile(icon: Icons.access_alarm_rounded, title: l10n.settingsReminder, trailing: Text(coc.reminderTime.format(context), style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)), onTap: () async { final t = await showTimePicker(context: context, initialTime: coc.reminderTime); if (t != null) coc.setTime(t, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody); }),
                      ],
                    ]),
                    const SizedBox(height: 24),
                    if (cycle.appMode != AppMode.coc) ...[
                      _buildSectionHeader(l10n.sectionCycle),
                      _buildGlassGroup([
                        ProfileSliderTile(icon: Icons.loop_rounded, title: l10n.insightAvgCycle, value: cycle.cycleLength.toDouble().clamp(21.0, 45.0), min: 21, max: 45, suffix: l10n.daysUnit, onChanged: (val) => cycle.setCycleLength(val.toInt())),
                        _buildDivider(), ProfileSliderTile(icon: Icons.water_drop_rounded, title: l10n.insightAvgPeriod, value: cycle.periodDuration.toDouble().clamp(2.0, 10.0), min: 2, max: 10, suffix: l10n.daysUnit, onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt())),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader(l10n.settingsGeneral),
                    _buildGlassGroup([
                      ProfileSettingsTile(icon: Icons.language, title: l10n.settingsLanguage, trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(_getLanguageName(settings.locale.languageCode), style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)), const SizedBox(width: 6), Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.45))]), onTap: () => _showSheet(context, const _LanguageSelectorSheet())),
                      _buildDivider(), ProfileSettingsTile(icon: Icons.palette_rounded, title: l10n.settingsTheme, trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.30), blurRadius: 8)])), onTap: () => _showSheet(context, const ThemeSelectorSheet())),
                      _buildDivider(), ProfileSwitchTile(icon: Icons.notifications_active_rounded, title: l10n.settingsNotifs, value: settings.notificationsEnabled, onChanged: (val) async { await settings.setNotificationsEnabled(val); if (context.mounted && val) await context.read<CycleProvider>().rescheduleNotifications(); }),
                      if (settings.notificationsEnabled) ...[_buildDivider(), ProfileSwitchTile(icon: Icons.nights_stay_rounded, title: l10n.settingsDailyLog ?? "Daily Check-in", value: settings.dailyLogEnabled, onChanged: (val) async { await settings.toggleDailyLogReminder(val); if (context.mounted) await context.read<CycleProvider>().rescheduleNotifications(); })],
                      _buildDivider(), ProfileSettingsTile(icon: Icons.mail_outline_rounded, title: l10n.settingsSupport, trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey), onTap: () => openSupportEmail(context)),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.settingsData),
                    _buildGlassGroup([
                      ProfileSettingsTile(icon: Icons.picture_as_pdf_rounded, title: l10n.settingsExport, trailing: Icon(isPremium ? Icons.arrow_forward_ios_rounded : Icons.lock_outline, size: isPremium ? 16 : 20, color: isPremium ? Colors.grey : Colors.amber), onTap: () async { if (!isPremium) { _showSheet(context, const PremiumPaywallSheet()); return; } _handleExport(context, wellness, l10n); }),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.sectionBackup),
                    _buildGlassGroup([
                      Builder(builder: (ctx) => ProfileSettingsTile(icon: Icons.cloud_upload_rounded, title: l10n.btnSaveBackup, trailing: Icon(Icons.save_alt, size: 20, color: AppColors.primary), onTap: () async { await _ensureBoxes(); if (ctx.mounted) await BackupService.createBackup(ctx); })),
                      _buildDivider(), ProfileSettingsTile(icon: Icons.cloud_download_rounded, title: l10n.btnRestoreBackup, trailing: Icon(Icons.restore_page, size: 20, color: AppColors.primary), onTap: () => showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: Text(l10n.dialogRestoreTitle), content: Text(l10n.dialogRestoreBody), actions: [CupertinoDialogAction(child: Text(l10n.btnCancel), onPressed: () => Navigator.pop(ctx)), CupertinoDialogAction(isDestructiveAction: true, child: Text(l10n.btnRestore), onPressed: () async { Navigator.pop(ctx); await _ensureBoxes(); await BackupService.restoreBackup(context); cycle.reload(); settings.reload(); })]))),
                    ]),
                    const SizedBox(height: 32),
                    Center(child: TextButton(onPressed: () => showDeleteDialog(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), backgroundColor: Colors.red.withOpacity(0.08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(l10n.settingsReset, style: GoogleFonts.inter(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w800)))),
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
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxHeight < 210;
      return PremiumGlassCard(
        borderRadius: 30, padding: EdgeInsets.fromLTRB(20, compact ? 16 : 20, 20, compact ? 14 : 18),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(onTap: () => _showSheet(context, const _EditProfileSheet()), child: Stack(alignment: Alignment.bottomRight, children: [
                _buildAvatarSized(avatar, isPremium, compact ? 82 : 104),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))]), child: Icon(Icons.edit_rounded, size: compact ? 14 : 15, color: AppColors.primary)),
              ])),
              SizedBox(height: compact ? 10 : 14),
              GestureDetector(onTap: () => _showSheet(context, const _EditProfileSheet()), child: Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: Text(userName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.manrope(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: compact ? 22 : 26, height: 1.05))), const SizedBox(width: 6), Icon(Icons.edit_rounded, size: compact ? 14 : 16, color: AppColors.textSecondary.withOpacity(0.45))])),
              SizedBox(height: compact ? 6 : 8),
              Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: goalColor.withOpacity(0.10), borderRadius: BorderRadius.circular(999), border: Border.all(color: goalColor.withOpacity(0.10))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(CupertinoIcons.sparkles, size: 14, color: goalColor), const SizedBox(width: 6), Text(goalText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: goalColor))])))),
              if (isPremium) ...[
                SizedBox(height: compact ? 8 : 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400]), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified, color: Colors.white, size: 12), const SizedBox(width: 5), Text("PREMIUM", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1))])),
              ],
            ],
          ),
        ),
      );
    });
  }

  String _getLanguageName(String code) => const {'ru': 'Русский', 'es': 'Español', 'de': 'Deutsch', 'pt': 'Português', 'tr': 'Türkçe', 'pl': 'Polski'}[code] ?? 'English';
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(left: 12, bottom: 8), child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)));
  Widget _buildGlassGroup(List<Widget> children) => PremiumGlassCard(padding: EdgeInsets.zero, borderRadius: 24, child: Column(children: children));
  Widget _buildDivider() => Divider(height: 1, indent: 60, endIndent: 16, color: Colors.black.withOpacity(0.05));
  Widget _buildBadge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(10)), child: Text(text, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)));

  Widget _buildAvatarSized(String emoji, bool isPremium, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: isPremium ? [Colors.amber.shade300, Colors.orange.shade400] : [AppColors.primary.withOpacity(0.24), AppColors.primary.withOpacity(0.10)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: (isPremium ? Colors.orange : AppColors.primary).withOpacity(0.22), blurRadius: 22, offset: const Offset(0, 10))]),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.48))),
    );
  }

  Future<void> _handleExport(BuildContext context, WellnessProvider wellness, AppLocalizations l10n) async {
    final validLogs = wellness.getLogHistory().where((l) => l.flow != FlowIntensity.none || l.painSymptoms.isNotEmpty || l.symptoms.isNotEmpty || (l.notes?.trim().isNotEmpty ?? false) || (l.temperature ?? 0) > 0 || l.ovulationTest != OvulationTestResult.none).toList();
    if (validLogs.length < 2) {
      if (context.mounted) showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: Text(l10n.dialogDataInsufficientTitle), content: Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.dialogDataInsufficientBody)), actions: [CupertinoDialogAction(child: Text(l10n.btnOk), onPressed: () => Navigator.pop(ctx))]));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
    try {
      await PdfService.generateReport(context);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgExportError))); }
    }
  }
}

class _GoalOption extends StatelessWidget {
  final String title, subtitle; final IconData icon; final Color color; final bool isSelected; final VoidCallback onTap;
  const _GoalOption({required this.title, required this.subtitle, required this.icon, required this.color, required this.isSelected, required this.onTap});
  @override Widget build(BuildContext context) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)), title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)), trailing: isSelected ? Icon(Icons.check_circle, color: color) : null, onTap: () { HapticFeedback.selectionClick(); onTap(); });
}

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon; final Color? iconColor; final String title; final Widget? trailing; final VoidCallback? onTap;
  const ProfileSettingsTile({super.key, required this.icon, required this.title, this.trailing, this.onTap, this.iconColor});
  @override Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), leading: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 21)), title: Text(title, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), trailing: trailing);
  }
}

class ProfileSwitchTile extends StatelessWidget {
  final IconData icon; final String title; final bool value; final ValueChanged<bool> onChanged;
  const ProfileSwitchTile({super.key, required this.icon, required this.title, required this.value, required this.onChanged});
  @override Widget build(BuildContext context) => ProfileSettingsTile(icon: icon, title: title, onTap: () => onChanged(!value), trailing: CupertinoSwitch(value: value, onChanged: onChanged, activeColor: AppColors.primary));
}

class ProfileSliderTile extends StatelessWidget {
  final IconData icon; final String title; final double value, min, max; final ValueChanged<double> onChanged; final String suffix;
  const ProfileSliderTile({super.key, required this.icon, required this.title, required this.value, required this.min, required this.max, required this.onChanged, required this.suffix});
  @override Widget build(BuildContext context) => Column(children: [ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), leading: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 21)), title: Text(title, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), trailing: Text("${value.toInt()} $suffix", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15))), Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: SliderTheme(data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), overlayShape: const RoundSliderOverlayShape(overlayRadius: 20), activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.primary.withOpacity(0.2), thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.1)), child: Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), onChanged: onChanged)))]);
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
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
    final languages = [{'code': 'en', 'name': 'English', 'flag': '🇺🇸'}, {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'}, {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'}, {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'}, {'code': 'pt', 'name': 'Brasil', 'flag': '🇧🇷'}, {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'}, {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'}];

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12), Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.28), borderRadius: BorderRadius.circular(999))), const SizedBox(height: 20),
            Text("Select Language", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), const SizedBox(height: 18),
            Flexible(child: ListView.separated(shrinkWrap: true, physics: const BouncingScrollPhysics(), itemCount: languages.length, separatorBuilder: (_, __) => Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black.withOpacity(0.05)), itemBuilder: (context, index) {
              final lang = languages[index]; final isSelected = lang['code'] == currentCode;
              return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4), leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)), title: Text(lang['name']!, style: GoogleFonts.inter(fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textPrimary)), trailing: isSelected ? Icon(Icons.check_circle_rounded, color: AppColors.primary) : null, onTap: () async { await settings.setLocale(Locale(lang['code']!)); if (context.mounted) { await context.read<CycleProvider>().rescheduleNotifications(); Navigator.pop(context); } });
            })),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}