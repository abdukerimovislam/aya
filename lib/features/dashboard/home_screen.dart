import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';

// Общие виджеты
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/cycle_timer_selector.dart';
import '../../shared/widgets/design_selector_sheet.dart';
import '../../shared/widgets/pill_widget.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/live_phase_background.dart';

// Фиче-виджеты
import 'widgets/dashboard_micro_calendar.dart';
import 'widgets/dashboard_insight_card.dart';
import 'widgets/dashboard_action_bar.dart';

import '../profile/premium_paywall_sheet.dart';
import '../profile/subscription_status_sheet.dart';
import '../logger/symptom_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();

    if (!cycleProvider.isLoaded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CupertinoActivityIndicator(color: AppColors.primary)),
      );
    }

    return _BuildUltraModernScreen(provider: cycleProvider);
  }
}

class _BuildUltraModernScreen extends StatelessWidget {
  final CycleProvider provider;

  const _BuildUltraModernScreen({required this.provider});

  // Логика бесшовной Hero-навигации передается во вложенные виджеты
  void _openLoggerWithHero(BuildContext context, DateTime date, String heroTag) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false, barrierDismissible: true, barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.92,
                    child: Stack(
                      children: [
                        SymptomLogScreen(date: date),
                        Positioned(
                          top: 24, left: 24,
                          child: Hero(tag: heroTag, child: Material(type: MaterialType.transparency, child: Container(width: 38, height: 38, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent)))),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    final data = provider.currentData;
    final bool isCOC = provider.isCOCEnabled;
    final bool isPremium = settings.isPremium;
    final int daysLate = provider.daysLate;
    final bool isAmenorrhea = provider.isAmenorrhea; // 🔥 Достаем статус "Пропажа цикла"

    return Scaffold(
      backgroundColor: Colors.white,
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
                  const SizedBox(height: 16),

                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _DashboardDateWidget(
                          l10n: l10n,
                          userName: settings.userName,
                          phase: data.phase,
                          daysLate: daysLate,
                          isAmenorrhea: isAmenorrhea, // 🔥 Передаем для приветствия
                        ),
                        _DashboardPremiumBadge(isPremium: isPremium, l10n: l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🔥 SMART LATE ALERT BANNER (С учетом Аменореи)
                  if (!isCOC && daysLate > 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _LateAlertBanner(
                          daysLate: daysLate,
                          isAmenorrhea: isAmenorrhea,
                          l10n: l10n
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // CENTER TIMER
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85, height: MediaQuery.of(context).size.width * 0.85,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CycleTimerSelector(data: data, isCOC: isCOC),
                        const Positioned(right: 0, top: 0, child: _DesignButton()),
                      ],
                    ),
                  ),
                  if (isCOC) ...[const SizedBox(height: 24), const PillWidget()],
                  const SizedBox(height: 32),

                  // SMART ACTION BAR
                  DashboardActionBar(data: data, isCOC: isCOC, provider: provider, l10n: l10n, onOpenLogger: _openLoggerWithHero),
                  const SizedBox(height: 40),

                  // MICRO CALENDAR
                  if (!isCOC) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: DashboardMicroCalendar(provider: provider, onOpenLogger: _openLoggerWithHero)),
                  const SizedBox(height: 20),

                  // INSIGHT CARD
                  if (!isCOC) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: DashboardInsightCard(data: data, l10n: l10n)),

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

// ─────────────────────────────────────────────────────────────────────────────
// 🔥 УМНЫЙ ВИДЖЕТ: БАННЕР ЗАДЕРЖКИ (С ТРЕМЯ УРОВНЯМИ)
// ─────────────────────────────────────────────────────────────────────────────
class _LateAlertBanner extends StatelessWidget {
  final int daysLate;
  final bool isAmenorrhea;
  final AppLocalizations l10n;

  const _LateAlertBanner({
    required this.daysLate,
    required this.isAmenorrhea,
    required this.l10n
  });

  @override
  Widget build(BuildContext context) {
    // 3 уровня: Базовая (1-4 дня), Критическая (5-59 дней), Аменорея (60+ дней)
    final isCritical = daysLate >= 5 && !isAmenorrhea;

    String title;
    String subtitle;
    Color primaryColor;
    Color bgColor;
    IconData icon;

    if (isAmenorrhea) {
      // Уровень 3: Аменорея
      title = "Cycle paused for $daysLate days";
      subtitle = "Missing periods for more than 2 months can be a sign of PCOS or hormonal imbalance. Consider seeing a doctor.";
      primaryColor = Colors.deepPurple;
      bgColor = Colors.deepPurple.withOpacity(0.1);
      icon = CupertinoIcons.heart_slash_circle_fill;
    } else if (isCritical) {
      // Уровень 2: Возможная беременность
      title = "Your period is $daysLate days late";
      subtitle = "If you've been sexually active, you might want to take a pregnancy test just to be sure.";
      primaryColor = Colors.redAccent.shade700;
      bgColor = Colors.redAccent.withOpacity(0.1);
      icon = CupertinoIcons.drop_triangle_fill;
    } else {
      // Уровень 1: Обычная задержка
      title = daysLate == 1 ? "Your period is 1 day late" : "Your period is $daysLate days late";
      subtitle = "A slight delay can be normal due to stress, travel, or lifestyle changes.";
      primaryColor = Colors.orange.shade800;
      bgColor = Colors.orangeAccent.withOpacity(0.1);
      icon = CupertinoIcons.clock_fill;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// МИКРО-ВИДЖЕТЫ ХЕДЕРА
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardDateWidget extends StatelessWidget {
  final AppLocalizations l10n;
  final String userName;
  final CyclePhase phase;
  final int daysLate;
  final bool isAmenorrhea;

  const _DashboardDateWidget({
    required this.l10n,
    required this.userName,
    required this.phase,
    required this.daysLate,
    required this.isAmenorrhea,
  });

  String _getContextualGreeting() {
    final hour = DateTime.now().hour;
    String timeOfDay = "Hello";

    if (hour >= 5 && hour < 12) {
      timeOfDay = "Good morning";
    } else if (hour >= 12 && hour < 18) {
      timeOfDay = "Good afternoon";
    } else if (hour >= 18 && hour < 22) {
      timeOfDay = "Good evening";
    } else {
      timeOfDay = "Time to rest";
    }

    final firstName = userName.split(' ').first;

    String phaseVibe = "";
    switch (phase) {
      case CyclePhase.menstruation: phaseVibe = "Be gentle with yourself today."; break;
      case CyclePhase.follicular: phaseVibe = "Your energy is rising."; break;
      case CyclePhase.ovulation: phaseVibe = "You are glowing today ✨"; break;
      case CyclePhase.luteal: phaseVibe = "Listen to your body's needs."; break;
      case CyclePhase.late:
        if (isAmenorrhea) {
          phaseVibe = "Health first. Remember to take care of yourself.";
        } else if (daysLate > 0) {
          phaseVibe = "You are $daysLate ${daysLate == 1 ? 'day' : 'days'} late. Take a deep breath.";
        } else {
          phaseVibe = "Take a deep breath.";
        }
        break;
    }

    return "$timeOfDay, $firstName.\n$phaseVibe";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getContextualGreeting(),
          style: GoogleFonts.inter(color: AppColors.textSecondary.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('MMMM d', l10n.localeName).format(DateTime.now()),
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.0),
        ),
      ],
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
      onTap: () { HapticFeedback.lightImpact(); showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => isPremium ? const SubscriptionStatusSheet() : const PremiumPaywallSheet()); },
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), borderRadius: 30,
        child: Row(
          children: [
            Icon(isPremium ? Icons.verified_rounded : Icons.star_rounded, color: isPremium ? Colors.amber.shade800 : AppColors.textPrimary, size: 16),
            const SizedBox(width: 6),
            Text(isPremium ? l10n.badgePro : "PRO", style: GoogleFonts.inter(color: isPremium ? Colors.amber.shade900 : AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.0))
          ],
        ),
      ),
    );
  }
}

class _DesignButton extends StatelessWidget {
  const _DesignButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.mediumImpact(); showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => const DesignSelectorSheet()); },
      child: PremiumGlassCard(width: 48, height: 48, borderRadius: 24, child: Center(child: Icon(Icons.palette_outlined, size: 22, color: AppColors.textPrimary))),
    );
  }
}