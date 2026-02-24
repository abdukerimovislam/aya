import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Импорты по новой архитектуре Ayla
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/wellness_provider.dart';

// Общие виджеты
import '../../shared/widgets/cycle_timer_selector.dart';
import '../../shared/widgets/design_selector_sheet.dart';
import '../../shared/widgets/pill_widget.dart';

// Экраны из других фич
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

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    if (l10n == null) return const SizedBox.shrink();

    final data = provider.currentData;
    final bool isCOC = provider.isCOCEnabled;
    final bool isPremium = settings.isPremium;

    return Scaffold(
      backgroundColor: Colors.white, // Базовый фон
      body: Stack(
        children: [
          // 🔥 ИДЕЯ 1: ЖИВОЙ MESH-ФОН (Зависит от фазы цикла)
          Positioned.fill(
            child: _LivePhaseBackground(phase: data.phase, isCOC: isCOC),
          ),

          // Главный контент
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // HEADER: Дата и Бейдж PRO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDateWidget(l10n),
                        _buildPremiumBadge(context, isPremium, l10n),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CENTER PIECE: Таймер цикла с левитирующей кнопкой палитры
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.85,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CycleTimerSelector(data: data, isCOC: isCOC),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: _buildDesignButton(context),
                        ),
                      ],
                    ),
                  ),

                  if (isCOC) ...[
                    const SizedBox(height: 24),
                    const PillWidget(),
                  ],

                  const SizedBox(height: 32),

                  // УМНАЯ КНОПКА (Animated Edge)
                  _buildSmartActionBar(context, data, isCOC, l10n),

                  const SizedBox(height: 40),

                  // 🔥 ИДЕЯ 6: МИКРО-КАЛЕНДАРЬ НА АКРИЛОВОМ СТЕКЛЕ
                  if (!isCOC)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMicroCalendar(context, provider),
                    ),

                  const SizedBox(height: 20),

                  // 🔥 ИДЕЯ 4: ИНТЕРАКТИВНАЯ AI-КАРТОЧКА
                  if (!isCOC)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildInsightCard(context, data, l10n),
                    ),

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎨 UI WIDGETS ---

  Widget _buildDateWidget(AppLocalizations l10n) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE', l10n.localeName).format(now).toUpperCase(),
          style: GoogleFonts.inter(
            color: AppColors.textSecondary.withOpacity(0.9),
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('MMMM d', l10n.localeName).format(now),
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBadge(BuildContext context, bool isPremium, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => isPremium ? const SubscriptionStatusSheet() : const PremiumPaywallSheet());
      },
      child: _PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 30,
        child: Row(
          children: [
            Icon(isPremium ? Icons.verified_rounded : Icons.star_rounded, color: isPremium ? Colors.amber.shade800 : AppColors.textPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              isPremium ? l10n.badgePro : "PRO",
              style: GoogleFonts.inter(color: isPremium ? Colors.amber.shade900 : AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.0),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDesignButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => const DesignSelectorSheet());
      },
      child: _PremiumGlassCard(
        width: 48,
        height: 48,
        borderRadius: 24,
        child: Center(child: Icon(Icons.palette_outlined, size: 22, color: AppColors.textPrimary)),
      ),
    );
  }

  // 💎 МИКРО-КАЛЕНДАРЬ + ИДЕЯ 10: HERO АНИМАЦИИ
  Widget _buildMicroCalendar(BuildContext context, CycleProvider provider) {
    final wellnessProvider = context.watch<WellnessProvider>();
    final today = DateTime.now();
    final dates = List.generate(7, (index) => today.subtract(Duration(days: 3 - index)));
    final l10n = AppLocalizations.of(context)!;

    return _PremiumGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      borderRadius: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dates.map((date) {
          final isToday = date.day == today.day && date.month == today.month;
          final isFuture = date.isAfter(today);
          final phase = provider.getPhaseForDate(date);
          final isPeriod = phase == CyclePhase.menstruation;
          final hasLogs = wellnessProvider.hasLogForDate(date);

          final heroTag = 'day_circle_${date.toIso8601String()}';

          return GestureDetector(
            onLongPress: isFuture ? null : () async {
              HapticFeedback.heavyImpact();
              await provider.togglePeriodDay(date);
            },
            onTap: isFuture ? null : () {
              HapticFeedback.lightImpact();
              _openLoggerForDateWithHero(context, date, heroTag); // Вызываем новую Hero-навигацию
            },
            child: Opacity(
              opacity: isFuture ? 0.35 : 1.0,
              child: Column(
                children: [
                  Text(
                    DateFormat('E', l10n.localeName).format(date)[0].toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isToday ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 12),
                  // 🔥 HERO ВРАППЕР ДЛЯ БЕСШОВНОГО ПЕРЕХОДА
                  Hero(
                    tag: heroTag,
                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                      return DefaultTextStyle(
                        style: DefaultTextStyle.of(toHeroContext).style,
                        child: toHeroContext.widget,
                      );
                    },
                    child: Material(
                      type: MaterialType.transparency,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isPeriod ? AppColors.menstruation.withOpacity(0.15) : (isToday ? Colors.white.withOpacity(0.9) : Colors.transparent),
                          shape: BoxShape.circle,
                          border: Border.all(color: isPeriod ? AppColors.menstruation.withOpacity(0.6) : (isToday ? Colors.white : Colors.transparent), width: isToday ? 2 : 1.5),
                          boxShadow: isToday ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
                        ),
                        child: Center(
                          child: isPeriod
                              ? Icon(CupertinoIcons.drop_fill, color: AppColors.menstruation, size: 18)
                              : Text("${date.day}", style: GoogleFonts.inter(fontSize: 15, fontWeight: isToday ? FontWeight.w800 : FontWeight.w600, color: AppColors.textPrimary)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(color: hasLogs ? AppColors.textSecondary.withOpacity(0.6) : Colors.transparent, shape: BoxShape.circle),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🔥 ИДЕЯ 4: РАСШИРЯЕМАЯ КАРТОЧКА AI-ИНСАЙТОВ
  Widget _buildInsightCard(BuildContext context, CycleData data, AppLocalizations l10n) {
    String title, subtitle;
    switch (data.phase) {
      case CyclePhase.menstruation:
        title = "Rest & Reset"; subtitle = "Your hormones are at their lowest. Focus on hydration."; break;
      case CyclePhase.follicular:
        title = "Energy Rising"; subtitle = "Estrogen is climbing. Great time for complex tasks."; break;
      case CyclePhase.ovulation:
        title = "Peak Vitality"; subtitle = "You are glowing. Best time for high-intensity workouts."; break;
      case CyclePhase.luteal:
        title = "Wind Down"; subtitle = "Progesterone is high. Cravings and mood swings are normal."; break;
      case CyclePhase.late:
        title = "Cycle Delayed"; subtitle = "Your period is late. Stress could be a factor."; break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Открываем Deep Dive!
        showGeneralDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.4),
          barrierDismissible: true,
          barrierLabel: "Insight",
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => _ExpandedInsightDialog(data: data),
        );
      },
      child: _PremiumGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 32,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFE94057).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
              ),
              child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary.withOpacity(0.8), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right_circle_fill, color: AppColors.textSecondary.withOpacity(0.2), size: 28),
          ],
        ),
      ),
    );
  }

  // СМАРТ-КНОПКА
  Widget _buildSmartActionBar(BuildContext context, CycleData data, bool isCOC, AppLocalizations l10n) {
    String actionText;
    IconData actionIcon;
    Color actionColor;
    Color actionBg;
    VoidCallback actionTap;
    bool needsPulse = false;

    if (isCOC) {
      actionText = l10n.btnStartNewPack; actionIcon = CupertinoIcons.capsule_fill; actionColor = Colors.white; actionBg = AppColors.primary;
      actionTap = () async => await provider.setCOCMode(true);
    } else if (data.phase == CyclePhase.menstruation) {
      actionText = "Period is active"; actionIcon = CupertinoIcons.drop_fill; actionColor = Colors.white; actionBg = AppColors.menstruation;
      actionTap = () => _showActivePeriodSheet(context, provider, l10n);
    } else if (data.daysUntilNextPeriod <= 3 || data.phase == CyclePhase.late) {
      actionText = "Period started?"; actionIcon = CupertinoIcons.drop; actionColor = AppColors.menstruation; actionBg = Colors.white;
      needsPulse = true;
      actionTap = () => _showPeriodInterceptorSheet(context, provider, l10n);
    } else {
      actionText = l10n.logSymptoms; actionIcon = CupertinoIcons.add; actionColor = AppColors.textPrimary; actionBg = Colors.white;
      actionTap = () => _openLoggerForDateWithHero(context, DateTime.now(), 'main_log_btn'); // Можно без Hero, но используем тот же метод
    }

    return _AnimatedEdgeButton(
      text: actionText, icon: actionIcon, textColor: actionColor, bgColor: actionBg, onTap: actionTap, isPulsing: needsPulse,
    );
  }

  // --- 🪄 ЛОГИКА НАВИГАЦИИ С HERO (ИДЕЯ 10) ---

  void _openLoggerForDateWithHero(BuildContext context, DateTime date, String heroTag) {
    // Вместо showModalBottomSheet мы делаем красивый прозрачный PageRoute!
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false, // Фон остается виден
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
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
                    // Обертка с Hero, которая принимает отделившийся элемент
                    child: Stack(
                      children: [
                        SymptomLogScreen(date: date),
                        // Временный Hero-получатель в верхней части экрана (в реальном приложении он должен быть внутри SymptomLogScreen)
                        Positioned(
                          top: 24, left: 24,
                          child: Hero(
                            tag: heroTag,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Container(width: 38, height: 38, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent)),
                            ),
                          ),
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

  // (Методы _showPeriodInterceptorSheet и _showActivePeriodSheet остаются без изменений, они идеальны)
  void _showPeriodInterceptorSheet(BuildContext context, CycleProvider provider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24, top: 12),
        decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 28),
              Text("When did it start?", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 28),
              _buildSheetOption(icon: CupertinoIcons.calendar_today, title: "Today", subtitle: "Start cycle from today", color: AppColors.menstruation, onTap: () { Navigator.pop(ctx); provider.togglePeriodDay(DateTime.now()); }),
              _buildSheetOption(icon: CupertinoIcons.arrow_counterclockwise_circle_fill, title: "Yesterday", subtitle: "Retroactively start cycle", color: AppColors.textSecondary, onTap: () { Navigator.pop(ctx); provider.togglePeriodDay(DateTime.now().subtract(const Duration(days: 1))); }),
              _buildSheetOption(icon: CupertinoIcons.calendar, title: "Pick a date...", subtitle: "Choose from calendar", color: AppColors.textSecondary, isLast: true, onTap: () async {
                Navigator.pop(ctx);
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 60)), lastDate: DateTime.now(), builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppColors.menstruation, onPrimary: Colors.white, onSurface: AppColors.textPrimary)), child: child!));
                if (picked != null) { HapticFeedback.mediumImpact(); provider.togglePeriodDay(picked); }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivePeriodSheet(BuildContext context, CycleProvider provider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24, top: 12),
        decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 28),
              Text("Manage Period", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 28),
              _buildSheetOption(icon: CupertinoIcons.add_circled_solid, title: "Log flow & symptoms", subtitle: "Record today's details", color: AppColors.primary, onTap: () { Navigator.pop(ctx); _openLoggerForDateWithHero(context, DateTime.now(), 'log'); }),
              _buildSheetOption(icon: CupertinoIcons.check_mark_circled_solid, title: "Period ended today", subtitle: "Finish current bleeding", color: AppColors.textSecondary, isLast: true, onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(ctx); provider.endCurrentPeriod(); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        InkWell(
          onTap: () { HapticFeedback.lightImpact(); onTap(); },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 26)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 2), Text(subtitle, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary))])),
                Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary.withOpacity(0.4), size: 20),
              ],
            ),
          ),
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 🔥 ИДЕЯ 1: ЖИВОЙ MESH-ФОН (Дышащий градиент)
// -----------------------------------------------------------------------------
class _LivePhaseBackground extends StatefulWidget {
  final CyclePhase phase;
  final bool isCOC;

  const _LivePhaseBackground({required this.phase, required this.isCOC});

  @override
  State<_LivePhaseBackground> createState() => _LivePhaseBackgroundState();
}

class _LivePhaseBackgroundState extends State<_LivePhaseBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Цвета зависят от фазы
    Color color1, color2;
    if (widget.isCOC) {
      color1 = const Color(0xFFE0F7FA); color2 = const Color(0xFFF1F8E9);
    } else {
      switch (widget.phase) {
        case CyclePhase.menstruation: color1 = const Color(0xFFFFEBEE); color2 = const Color(0xFFFFCDD2); break;
        case CyclePhase.follicular: color1 = const Color(0xFFE8F5E9); color2 = const Color(0xFFE0F2F1); break;
        case CyclePhase.ovulation: color1 = const Color(0xFFFFF3E0); color2 = const Color(0xFFFBE9E7); break;
        case CyclePhase.luteal: color1 = const Color(0xFFF3E5F5); color2 = const Color(0xFFE8EAF6); break;
        case CyclePhase.late: color1 = const Color(0xFFECEFF1); color2 = const Color(0xFFCFD8DC); break;
      }
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Пятно 1 (Движется по кругу)
            Positioned(
              left: 50 * math.cos(_controller.value * 2 * math.pi),
              top: 100 * math.sin(_controller.value * 2 * math.pi),
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color1.withOpacity(0.8)),
              ),
            ),
            // Пятно 2 (Движется в противофазе)
            Positioned(
              right: 20 * math.cos(_controller.value * 2 * math.pi),
              bottom: 150 * math.sin(_controller.value * 2 * math.pi),
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color2.withOpacity(0.8)),
              ),
            ),
            // Глубокий блюр, который смешивает пятна в единый Mesh
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 🔥 ИДЕЯ 6: НАСТОЯЩЕЕ МАТОВОЕ СТЕКЛО (С эффектом шума и блика)
// -----------------------------------------------------------------------------
class _PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const _PremiumGlassCard({required this.child, this.width, this.height, this.padding, this.borderRadius = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // Экстремальный блюр для премиальности
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(borderRadius),
              // Диагональный градиент имитирует падение света на фаску стекла
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.0)],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
              ]
          ),
          child: child,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔥 ИДЕЯ 4: ВСПЛЫВАЮЩИЙ DEEP DIVE ИНСАЙТ (Модальное окно)
// -----------------------------------------------------------------------------
class _ExpandedInsightDialog extends StatelessWidget {
  final CycleData data;

  const _ExpandedInsightDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, val, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * val),
              child: Opacity(
                opacity: val,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(CupertinoIcons.sparkles, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(height: 24),
                      Text("Ayla Daily Insight", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 24),
                      _buildInsightSection("🧠 Hormones", "Estrogen and Progesterone are fluctuating. You might feel a bit sensitive today.", CupertinoIcons.waveform_path),
                      const SizedBox(height: 16),
                      _buildInsightSection("🥑 Nutrition", "Focus on iron-rich foods and complex carbs to sustain energy.", CupertinoIcons.leaf_arrow_circlepath),
                      const SizedBox(height: 16),
                      _buildInsightSection("🏃‍♀️ Activity", "Keep it light. Yoga or stretching is highly recommended.", CupertinoIcons.heart_circle),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(20),
                          child: Text("Got it", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInsightSection(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(desc, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4)),
            ],
          ),
        )
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 🔥 КНОПКА С ИДЕАЛЬНО ПРИЛЕГАЮЩИМ ВРАЩАЮЩИМСЯ СВЕЧЕНИЕМ
// -----------------------------------------------------------------------------
class _AnimatedEdgeButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color textColor;
  final Color bgColor;
  final VoidCallback onTap;
  final bool isPulsing;

  const _AnimatedEdgeButton({
    required this.text, required this.icon, required this.textColor,
    required this.bgColor, required this.onTap, this.isPulsing = false,
  });

  @override
  State<_AnimatedEdgeButton> createState() => _AnimatedEdgeButtonState();
}

class _AnimatedEdgeButtonState extends State<_AnimatedEdgeButton> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.isPulsing ? widget.bgColor : (widget.bgColor == Colors.white || widget.bgColor.opacity < 1 ? AppColors.primary : widget.bgColor);

    const double buttonHeight = 68.0;
    const double borderWidth = 2.5;

    final outerRadius = BorderRadius.circular(buttonHeight / 2);
    final innerRadius = BorderRadius.circular((buttonHeight / 2) - borderWidth);

    return Container(
      height: buttonHeight,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: outerRadius,
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(widget.isPulsing ? 0.6 : 0.2), blurRadius: widget.isPulsing ? 30 : 15, spreadRadius: widget.isPulsing ? 4 : 0, offset: const Offset(0, 8))
        ],
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: ClipRRect(
          borderRadius: outerRadius,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Transform.scale(
                        scale: 3.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: SweepGradient(
                              colors: [glowColor.withOpacity(0.0), glowColor, glowColor.withOpacity(0.0)],
                              stops: const [0.35, 0.5, 0.65],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: borderWidth, bottom: borderWidth, left: borderWidth, right: borderWidth,
                child: Container(
                  decoration: BoxDecoration(color: widget.bgColor, borderRadius: innerRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: widget.textColor, size: 24),
                      const SizedBox(width: 14),
                      Text(widget.text, style: GoogleFonts.inter(color: widget.textColor, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}