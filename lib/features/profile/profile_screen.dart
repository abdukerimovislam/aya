import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _LanguageSelectorSheet(),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditProfileSheet(),
    );
  }

  // 🔥 ИСПРАВЛЕННЫЙ ДИАЛОГ ВЫБОРА ЦЕЛИ (БЕЗ SHADOWING)
  void _showGoalSelector(BuildContext context) {
    final cycle = context.read<CycleProvider>();
    final currentMode = cycle.appMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // 🔥 Меняем имя переменной на sheetContext, чтобы не убить основной context
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(
                "My Goal",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              _GoalOption(
                title: "Track my cycle",
                subtitle: "Standard period and ovulation tracking",
                icon: CupertinoIcons.drop,
                color: AppColors.primary,
                isSelected: currentMode == AppMode.standard,
                onTap: () {
                  Navigator.pop(sheetContext);
                  cycle.setAppMode(AppMode.standard);
                },
              ),
              _GoalOption(
                title: "Prevent pregnancy",
                subtitle: "Track my birth control pill",
                icon: CupertinoIcons.shield,
                color: Colors.teal,
                isSelected: currentMode == AppMode.coc,
                onTap: () {
                  Navigator.pop(sheetContext); // Закрываем BottomSheet
                  showCOCStartDialog(context); // 🔥 Передаем живой context экрана!
                },
              ),
              _GoalOption(
                title: "Try to conceive",
                subtitle: "Maximized fertility predictions & BBT",
                icon: CupertinoIcons.heart_circle,
                color: Colors.purple,
                isSelected: currentMode == AppMode.ttc,
                onTap: () {
                  Navigator.pop(sheetContext);
                  cycle.setAppMode(AppMode.ttc);
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

    final bool isPremium = settings.isPremium;

    String goalText = "";
    IconData goalIcon = CupertinoIcons.drop;
    Color goalColor = AppColors.primary;

    switch (cycle.appMode) {
      case AppMode.standard:
        goalText = "Track my cycle";
        goalIcon = CupertinoIcons.drop;
        goalColor = AppColors.primary;
        break;
      case AppMode.coc:
        goalText = "Prevent pregnancy (Pill)";
        goalIcon = CupertinoIcons.shield;
        goalColor = Colors.teal;
        break;
      case AppMode.ttc:
        goalText = "Try to conceive";
        goalIcon = CupertinoIcons.heart_circle;
        goalColor = Colors.purple;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            elevation: 0,
            stretch: true,
            automaticallyImplyLeading: false,

            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),

                  title: Text(
                    settings.userName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),

                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _showEditProfileDialog(context),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _buildAvatar(settings.userAvatar, isPremium),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                                  ),
                                  child: Icon(Icons.edit, size: 14, color: AppColors.primary),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => _showEditProfileDialog(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  settings.userName,
                                  style: GoogleFonts.manrope(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.edit_rounded, size: 16, color: AppColors.textSecondary.withOpacity(0.5))
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          if (isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                                  ]
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    (l10n.badgePro ?? "PREMIUM").toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // MY GOAL
                _buildSectionHeader("My Goal"),
                _buildGlassGroup(
                  children: [
                    ProfileSettingsTile(
                      icon: goalIcon,
                      iconColor: goalColor,
                      title: goalText,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Change",
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
                        ],
                      ),
                      onTap: () => _showGoalSelector(context),
                    ),

                    if (cycle.appMode == AppMode.coc) ...[
                      _buildDivider(),
                      ProfileSettingsTile(
                        icon: Icons.grid_on_rounded,
                        title: l10n.settingsPackType,
                        trailing: _buildBadge(l10n.settingsPills(coc.pillCount)),
                        onTap: () => showPackTypePicker(context),
                      ),
                      _buildDivider(),
                      ProfileSettingsTile(
                        icon: Icons.access_alarm_rounded,
                        title: l10n.settingsReminder,
                        trailing: Text(
                            coc.reminderTime.format(context),
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                        ),
                        onTap: () async {
                          final newTime = await showTimePicker(context: context, initialTime: coc.reminderTime);
                          if (newTime != null) coc.setTime(newTime, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                        },
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 24),

                if (cycle.appMode != AppMode.coc) ...[
                  _buildSectionHeader(l10n.sectionCycle),
                  _buildGlassGroup(
                    children: [
                      ProfileSliderTile(
                        icon: Icons.loop_rounded,
                        title: l10n.insightAvgCycle,
                        value: cycle.cycleLength.toDouble().clamp(21.0, 45.0),
                        min: 21, max: 45,
                        onChanged: (val) => cycle.setCycleLength(val.toInt()),
                        suffix: l10n.daysUnit,
                      ),
                      _buildDivider(),
                      ProfileSliderTile(
                        icon: Icons.water_drop_rounded,
                        title: l10n.insightAvgPeriod,
                        value: cycle.periodDuration.toDouble().clamp(2.0, 10.0),
                        min: 2, max: 10,
                        onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt()),
                        suffix: l10n.daysUnit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                _buildSectionHeader(l10n.settingsGeneral),
                _buildGlassGroup(
                  children: [
                    ProfileSettingsTile(
                      icon: Icons.language,
                      title: l10n.settingsLanguage,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLanguageName(settings.locale.languageCode),
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
                        ],
                      ),
                      onTap: () => _showLanguageSelector(context),
                    ),
                    _buildDivider(),

                    ProfileSettingsTile(
                      icon: Icons.palette_rounded,
                      title: l10n.settingsTheme,
                      trailing: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4)]
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const ThemeSelectorSheet(),
                        );
                      },
                    ),
                    _buildDivider(),

                    ProfileSwitchTile(
                        icon: Icons.notifications_active_rounded,
                        title: l10n.settingsNotifs,
                        value: settings.notificationsEnabled,
                        onChanged: (val) async {
                          await settings.setNotificationsEnabled(val);
                          if (context.mounted && val) {
                            await context.read<CycleProvider>().rescheduleNotifications();
                          }
                        }
                    ),

                    if (settings.notificationsEnabled) ...[
                      _buildDivider(),
                      ProfileSwitchTile(
                        icon: Icons.nights_stay_rounded,
                        title: l10n.settingsDailyLog ?? "Daily Check-in",
                        value: settings.dailyLogEnabled,
                        onChanged: (val) async {
                          await settings.toggleDailyLogReminder(val);
                          if (context.mounted) {
                            await context.read<CycleProvider>().rescheduleNotifications();
                          }
                        },
                      ),
                    ],

                    _buildDivider(),
                    ProfileSettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: l10n.settingsSupport,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                        onTap: () => openSupportEmail(context)
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionHeader(l10n.settingsData),
                _buildGlassGroup(
                  children: [
                    ProfileSettingsTile(
                      icon: Icons.picture_as_pdf_rounded,
                      title: l10n.settingsExport,
                      trailing: isPremium
                          ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)
                          : const Icon(Icons.lock_outline, size: 20, color: Colors.amber),
                      onTap: () async {
                        if (!isPremium) {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const PremiumPaywallSheet(),
                          );
                          return;
                        }
                        _handleExport(context, wellness, l10n);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionHeader(l10n.sectionBackup),
                _buildGlassGroup(
                  children: [
                    Builder(builder: (ctx) => ProfileSettingsTile(
                        icon: Icons.cloud_upload_rounded,
                        title: l10n.btnSaveBackup,
                        trailing: Icon(Icons.save_alt, size: 20, color: AppColors.primary),
                        onTap: () async {
                          await _ensureBoxes();
                          if (ctx.mounted) await BackupService.createBackup(ctx);
                        }
                    )),
                    _buildDivider(),
                    ProfileSettingsTile(
                      icon: Icons.cloud_download_rounded,
                      title: l10n.btnRestoreBackup,
                      trailing: Icon(Icons.restore_page, size: 20, color: AppColors.primary),
                      onTap: () => showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: Text(l10n.dialogRestoreTitle), content: Text(l10n.dialogRestoreBody),
                          actions: [
                            CupertinoDialogAction(child: Text(l10n.btnCancel), onPressed: () => Navigator.pop(ctx)),
                            CupertinoDialogAction(isDestructiveAction: true, child: Text(l10n.btnRestore), onPressed: () async {
                              Navigator.pop(ctx);
                              await _ensureBoxes();
                              await BackupService.restoreBackup(context);
                              cycle.reload();
                              settings.reload();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Center(
                    child: TextButton(
                        onPressed: () => showDeleteDialog(context),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        child: Text(
                            l10n.settingsReset,
                            style: GoogleFonts.inter(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)
                        )
                    )
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru': return 'Русский';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      case 'pt': return 'Português (Brasil)';
      case 'tr': return 'Türkçe';
      case 'pl': return 'Polski';
      default: return 'English';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildGlassGroup({required List<Widget> children}) {
    return PremiumGlassCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: Colors.black12);
  }

  Widget _buildAvatar(String emoji, bool isPremium) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: isPremium
                ? [Colors.amber.shade300, Colors.orange.shade400]
                : [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? Colors.orange : AppColors.primary).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Future<void> _handleExport(BuildContext context, WellnessProvider wellness, AppLocalizations l10n) async {
    final allLogs = wellness.getLogHistory();

    final validLogs = allLogs.where((l) {
      bool hasFlow = l.flow != FlowIntensity.none;
      bool hasPain = l.painSymptoms.isNotEmpty;
      bool hasSymptoms = l.symptoms.isNotEmpty;
      bool hasNotes = l.notes != null && l.notes!.trim().isNotEmpty;
      bool hasTemp = l.temperature != null && l.temperature! > 0;
      bool hasTest = l.ovulationTest != OvulationTestResult.none;

      return hasFlow || hasPain || hasSymptoms || hasNotes || hasTemp || hasTest;
    }).toList();

    if (validLogs.length < 2) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.dialogDataInsufficientTitle),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(l10n.dialogDataInsufficientBody),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.btnOk),
                onPressed: () => Navigator.pop(ctx),
              )
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
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgExportError)));
      }
    }
  }
}

// --- ВНУТРЕННИЕ ВИДЖЕТЫ ---

class _GoalOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileSettingsTile({super.key, required this.icon, required this.title, this.trailing, this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
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

class _EditProfileSheet extends StatefulWidget {
  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  final List<String> _avatars = [
    "👩", "👩‍🦰", "👱‍♀️", "👩‍🦱", "🧕",
    "👵", "🦊", "🐱", "🦄", "🐰",
    "🦋", "🌸", "✨", "🌙", "🍓"
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController = TextEditingController(text: settings.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Edit Profile", style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final isSelected = settings.userAvatar == avatar;
                return GestureDetector(
                  onTap: () {
                    context.read<SettingsProvider>().setUserAvatar(avatar);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(avatar, style: const TextStyle(fontSize: 30))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Your Name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2)
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (val) {
              context.read<SettingsProvider>().setUserName(val.isEmpty ? "User" : val);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: Text("Done", style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}

class _LanguageSelectorSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentCode = settings.locale.languageCode;

    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'pt', 'name': 'Brasil', 'flag': '🇧🇷'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(
              "Select Language",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: languages.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = lang['code'] == currentCode;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      lang['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      await settings.setLocale(Locale(lang['code']!));

                      if (context.mounted) {
                        await context.read<CycleProvider>().rescheduleNotifications();
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}