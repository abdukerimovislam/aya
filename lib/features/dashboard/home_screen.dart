import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/coc_provider.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';

// Общие виджеты
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/timers/nebula_timer_widget.dart';
import '../../shared/widgets/pill_widget.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../shared/widgets/pill_blister_card.dart';

// Фиче-виджеты
import 'widgets/dashboard_micro_calendar.dart';
import 'widgets/dashboard_insight_card.dart';
import 'widgets/dashboard_action_bar.dart';

import '../profile/premium_paywall_sheet.dart';
import '../profile/subscription_status_sheet.dart';
import '../logger/symptom_log_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoaded = context.select<CycleProvider, bool>((p) => p.isLoaded);

    if (!isLoaded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CupertinoActivityIndicator(color: AppColors.primary)),
      );
    }

    return const _BuildUltraModernScreen();
  }
}

class _BuildUltraModernScreen extends StatelessWidget {
  const _BuildUltraModernScreen({super.key});

  void _openLoggerWithHero(BuildContext context, DateTime date, String heroTag) {
    HapticFeedback.mediumImpact();
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: SizedBox(
          height: screenHeight * 0.92,
          child: SymptomLogScreen(date: date),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    final data = context.select<CycleProvider, CycleData>((p) => p.currentData);
    final bool isCOC = context.select<CycleProvider, bool>((p) => p.isCOCEnabled);
    final bool isTTC = context.select<CycleProvider, bool>((p) => p.isTTCMode);
    final bool isPremium = context.select<SettingsProvider, bool>((p) => p.isPremium);

    final provider = context.read<CycleProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      // 🔥 Настоящий прозрачный AppBar наверху
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          "A Y L A",
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: false,
        actions: [
          Center(child: _DashboardPremiumBadge(isPremium: isPremium, l10n: l10n)),
          const SizedBox(width: 24),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: LivePhaseBackground(phase: data.phase, isCOC: isCOC)),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // 🔥 Наш новый нежный микро-календарь теперь прямо под AppBar
                  if (!isCOC) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardMicroCalendar(provider: provider, onOpenLogger: _openLoggerWithHero),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // CENTER TIMER
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.85,
                    child: NebulaTimerWidget(
                      data: data,
                      isCOC: isCOC,
                      isTTC: isTTC,
                    ),
                  ),

                  if (isCOC) ...[const SizedBox(height: 24), const PillWidget()],
                  const SizedBox(height: 32),

                  // SMART ACTION BAR
                  DashboardActionBar(data: data, isCOC: isCOC, provider: provider, l10n: l10n, onOpenLogger: _openLoggerWithHero),
                  const SizedBox(height: 40),

                  if (isCOC) ...[
                    // РЕЖИМ КОК
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: PremiumGlassCard(
                        borderRadius: 32,
                        child: PillBlisterCard(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _COCPackControlCard(provider: provider, l10n: l10n),
                  ]
                  else ...[
                    // ОБЫЧНЫЙ РЕЖИМ И TTC (Инсайты ИИ)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DashboardInsightCard(data: data, l10n: l10n)
                    ),
                  ],

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── БЛОК УПРАВЛЕНИЯ ПАЧКОЙ КОК ─────────────────────────────────────
class _COCPackControlCard extends StatelessWidget {
  final CycleProvider provider;
  final AppLocalizations l10n;

  const _COCPackControlCard({required this.provider, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final data = provider.currentData;
    final currentDay = data.dayOfCycle;
    final totalDays = data.totalCycleLength;

    final isBreak = data.phase == CyclePhase.menstruation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBreak
                        ? Colors.orangeAccent.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBreak ? CupertinoIcons.drop_fill : CupertinoIcons.shield_fill,
                    color: isBreak ? Colors.orangeAccent : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBreak ? l10n.cocBreakPhase : l10n.cocActivePhase,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Day $currentDay of $totalDays",
                        style: GoogleFonts.inter(fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: isBreak ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                onPressed: () => _showStartNewPackDialog(context, provider),
                child: Text(
                  l10n.btnStartNewPack,
                  style: GoogleFonts.inter(
                    color: isBreak ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartNewPackDialog(BuildContext context, CycleProvider provider) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Icon(CupertinoIcons.arrow_2_circlepath_circle_fill,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text("Start New Pack?",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary))),
              ],
            ),
            content: Text(
              "This will reset your tracker, clear previous pill history, and start a new pack today.",
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.4),
            ),
            actionsPadding: const EdgeInsets.only(
                bottom: 16, right: 16, left: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancel", style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();

                  final now = DateTime.now();

                  await provider.setCOCMode(
                      true, currentPillNumber: 1, packStartDate: now);

                  if (context.mounted) {
                    final coc = Provider.of<COCProvider>(
                        context, listen: false);
                    await coc.startNewPack(startDate: now);
                  }
                },
                child: Text("Start Today", style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
    );
  }
}

class _DashboardPremiumBadge extends StatelessWidget {
  final bool isPremium;
  final AppLocalizations l10n;
  const _DashboardPremiumBadge({required this.isPremium, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => isPremium ? const SubscriptionStatusSheet() : const PremiumPaywallSheet()
        );
      },
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 30,
        child: Row(
          children: [
            Icon(isPremium ? Icons.verified_rounded : Icons.star_rounded, color: isPremium ? Colors.amber.shade800 : AppColors.textPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
                isPremium ? l10n.badgePro : "PRO",
                style: GoogleFonts.inter(
                    color: isPremium ? Colors.amber.shade900 : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.0
                )
            )
          ],
        ),
      ),
    );
  }
}