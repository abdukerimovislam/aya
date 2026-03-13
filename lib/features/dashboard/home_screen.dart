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
import '../../shared/widgets/cycle_timer_selector.dart';
import '../../shared/widgets/design_selector_sheet.dart';
import '../../shared/widgets/pill_widget.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/live_phase_background.dart';

// 🔥 НОВЫЙ ИМПОРТ ДЛЯ БЛИСТЕРА
import '../../shared/widgets/pill_blister_card.dart';

// Фиче-виджеты
import 'widgets/dashboard_micro_calendar.dart';
import 'widgets/dashboard_insight_card.dart';
import 'widgets/dashboard_action_bar.dart';

import '../profile/premium_paywall_sheet.dart';
import '../profile/subscription_status_sheet.dart';
import '../logger/symptom_log_screen.dart';

// 🔥 ОПТИМИЗАЦИЯ 1: HomeScreen теперь StatelessWidget без лишней перерисовки
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 ОПТИМИЗАЦИЯ 2: Подписываемся ТОЛЬКО на флаг загрузки
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

  // Логика бесшовной Hero-навигации
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
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    // 🔥 ОПТИМИЗАЦИЯ 3: Точечные селекторы вместо context.watch!
    // Экран перерисуется, только если реально изменятся данные таймера, а не фоновая история.
    final data = context.select<CycleProvider, CycleData>((p) => p.currentData);
    final bool isCOC = context.select<CycleProvider, bool>((p) => p.isCOCEnabled);

    final String userName = context.select<SettingsProvider, String>((p) => p.userName);
    final bool isPremium = context.select<SettingsProvider, bool>((p) => p.isPremium);

    // 🔥 ОПТИМИЗАЦИЯ 4: Ссылка на провайдер без подписки (context.read)
    // Нужна только для передачи логики в кнопки (например, сохранить симптом),
    // чтобы кнопки не триггерили ребилд самого дашборда.
    final provider = context.read<CycleProvider>();

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
                          userName: userName,
                          phase: data.phase,
                        ),
                        _DashboardPremiumBadge(isPremium: isPremium, l10n: l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

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

                  // SMART ACTION BAR (Для логгирования симптомов в любом режиме)
                  DashboardActionBar(data: data, isCOC: isCOC, provider: provider, l10n: l10n, onOpenLogger: _openLoggerWithHero),
                  const SizedBox(height: 40),

                  // КОНТЕНТ МЕНЯЕТСЯ В ЗАВИСИМОСТИ ОТ РЕЖИМА
                  if (isCOC) ...[
                    // ПОЛНЫЙ ВИЗУАЛЬНЫЙ БЛИСТЕР В СТЕКЛЕ
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: PremiumGlassCard(
                        borderRadius: 32,
                        child: PillBlisterCard(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // КНОПКА СТАРТА ПАЧКИ
                    _COCPackControlCard(provider: provider, l10n: l10n),
                  ] else ...[
                    // ОБЫЧНЫЙ РЕЖИМ (Микрокалендарь + Инсайты)
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: DashboardMicroCalendar(provider: provider, onOpenLogger: _openLoggerWithHero)),
                    const SizedBox(height: 20),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: DashboardInsightCard(data: data, l10n: l10n)),
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
                    isBreak ? CupertinoIcons.drop_fill : CupertinoIcons
                        .shield_fill,
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
                color: isBreak ? AppColors.primary : AppColors.primary
                    .withOpacity(0.1),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
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

                  // 1. Обновляем ядро цикла
                  await provider.setCOCMode(
                      true, currentPillNumber: 1, packStartDate: now);

                  // 2. 🔥 Находим COCProvider и стираем историю таблеток
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

// ─── Вспомогательные микро-виджеты ──────────────────────────────────
class _DashboardDateWidget extends StatelessWidget {
  final AppLocalizations l10n;
  final String userName;
  final CyclePhase phase;

  const _DashboardDateWidget({required this.l10n, required this.userName, required this.phase});

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
      case CyclePhase.late: phaseVibe = "Take a deep breath."; break;
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