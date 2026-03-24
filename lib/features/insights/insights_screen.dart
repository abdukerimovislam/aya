import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../core/services/pdf_service.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../core/services/ai_oracle_service.dart';

import '../../data/logic/symptom_intelligence.dart';
import '../../data/models/cycle_model.dart';
import '../../data/logic/health_pattern_detector.dart';

import 'widgets/hormonal_rhythm_card.dart';
import 'widgets/ayla_consultation_sheet.dart';
import '../chat/chat_screen.dart'; // 🔥 Импорт экрана чата

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isGeneratingAI = false;
  bool _hasCachedAdvice = false;

  bool _isCalculating = true;

  List<MapEntry<String, int>> _topSymptoms = [];
  SymptomInsight? _todayInsight;
  List<HealthFlag> _clinicalFlags = [];
  Map<int, List<String>> _dailySymptomsMap = {};

  List<FlSpot> _bbtSpots = [];
  double _minTemp = 36.2;
  double _maxTemp = 37.2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runHeavyAnalyticsBackground();
    });
  }

  Future<void> _runHeavyAnalyticsBackground() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final aiBox = await Hive.openBox('ai_insights');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (aiBox.get('cached_advice_date') == todayStr && aiBox.get('cached_advice_text') != null) {
      _hasCachedAdvice = true;
    }

    final cycleProvider = context.read<CycleProvider>();
    final wellnessProvider = context.read<WellnessProvider>();

    _topSymptoms = _getTopSymptoms(wellnessProvider);
    _clinicalFlags = await HealthPatternDetector.analyzePatterns(
      cycleProvider.history,
      wellnessProvider,
      isCocEnabled: cycleProvider.isCOCEnabled,
    );
    _prepareBBTData(cycleProvider, wellnessProvider);
    _prepareDailySymptomsMap(cycleProvider, wellnessProvider);
    _todayInsight = _getTodayIntelligence(context, wellnessProvider, cycleProvider);

    if (mounted) {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();

    final bool isTTC = cycleProvider.isTTCMode;
    final currentPhase = cycleProvider.currentData.phase;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: _buildTopBarTitle(isTTC),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await PdfService.generateReport(context);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: Icon(
                  CupertinoIcons.square_arrow_up,
                  color: isTTC ? const Color(0xFFBCAAA4) : AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LivePhaseBackground(
              phase: currentPhase,
              isCOC: cycleProvider.isCOCEnabled,
            ),
          ),
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _buildHeroDashboard(context, cycleProvider, wellnessProvider, isTTC),
                const SizedBox(height: 24),
                _buildAIOperatingCenter(cycleProvider, wellnessProvider, isTTC),
                const SizedBox(height: 32),

                _buildSectionHeader(
                  title: isTTC ? "Fertility Status" : "Cycle Analysis",
                  subtitle: "Key signals from your body",
                ),
                const SizedBox(height: 12),
                _buildAIAnalysisCard(cycleProvider),
                const SizedBox(height: 16),

                if (!isTTC)
                  _buildCompactVitalsStrip(cycleProvider)
                else
                  _buildFertilityStatusStrip(cycleProvider),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isCalculating
                      ? _buildLoadingSkeleton()
                      : _buildHeavyAnalyticsContent(cycleProvider, isTTC),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: Column(
          children: [
            const CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(
              "Analyzing history and patterns...",
              style: GoogleFonts.inter(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeavyAnalyticsContent(CycleProvider cycleProvider, bool isTTC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader(
          title: "Hormonal Rhythm",
          subtitle: "Your symptoms correlated with estimated hormone levels",
        ),
        const SizedBox(height: 12),
        HormonalRhythmCard(
          data: cycleProvider.currentData,
          dailySymptoms: _dailySymptomsMap,
        ),

        if (_todayInsight != null) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            title: "Hormonal Context",
            subtitle: "Why you might be feeling this way today",
          ),
          const SizedBox(height: 12),
          _buildSymptomInsightCard(_todayInsight!, isTTC),
        ],

        if (_clinicalFlags.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            title: "Medical Insights",
            subtitle: "Patterns detected from your historical logs",
          ),
          const SizedBox(height: 12),
          ..._clinicalFlags.map((flag) => _buildClinicalFlagCard(context, flag)),
        ],

        if (isTTC) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            title: "Thermal Shift",
            subtitle: "Your temperature pattern across this cycle",
          ),
          const SizedBox(height: 12),
          PremiumGlassCard(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            borderRadius: 28,
            child: SizedBox(
              height: 220,
              child: _buildBBTChart(cycleProvider),
            ),
          ),
        ],

        const SizedBox(height: 32),
        _buildSectionHeader(
          title: "Frequent Symptoms",
          subtitle: "Most repeated symptoms from your recent logs",
        ),
        const SizedBox(height: 12),

        _topSymptoms.isEmpty
            ? PremiumGlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(24),
          child: _buildEmptyState("Log your daily symptoms to uncover your body's unique patterns.", CupertinoIcons.sparkles),
        )
            : _buildSymptomsFeed(_topSymptoms, isTTC),
      ],
    );
  }

  Widget _buildTopBarTitle(bool isTTC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTTC ? "Fertility Hub" : "Insights",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isTTC ? "Personalized fertility intelligence" : "Your body's intelligence",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDashboard(BuildContext context, CycleProvider cycle, WellnessProvider wellness, bool isTTC) {
    String title;
    String subtitle;
    IconData icon;
    Color accentColor;

    if (cycle.isCOCEnabled) {
      title = "Contraceptive Mode";
      subtitle = "Tracking is adapted for pill-based cycles";
      icon = CupertinoIcons.shield_fill;
      accentColor = AppColors.follicular;
    } else if (isTTC) {
      if (cycle.isOvulationConfirmed) {
        title = "Ovulation Confirmed";
        subtitle = "You are now in the two-week wait phase";
        icon = CupertinoIcons.check_mark_circled_solid;
        accentColor = AppColors.luteal;
      } else if (cycle.conceptionChance == FertilityChance.high || cycle.conceptionChance == FertilityChance.peak) {
        title = "Fertile Window Active";
        subtitle = "Conception probability is elevated";
        icon = CupertinoIcons.heart_circle_fill;
        accentColor = const Color(0xFFE85D75);
      } else {
        title = "Tracking Fertility";
        subtitle = "Log BBT and symptoms for precision";
        icon = CupertinoIcons.sparkles;
        accentColor = AppColors.follicular;
      }
    } else {
      title = "Cycle Intelligence";
      subtitle = cycle.history.isEmpty
          ? "Start logging to unlock analysis"
          : "Trends updated from recent logs";
      icon = CupertinoIcons.waveform_path_ecg;
      accentColor = AppColors.primary;
    }

    final List<_HeroMiniStat> stats = isTTC
        ? [
      _HeroMiniStat(label: "Status", value: cycle.isOvulationConfirmed ? "Confirmed" : _fertilityLabel(cycle.conceptionChance)),
      _HeroMiniStat(label: "Phase", value: _formatPhase(cycle.currentData.phase)),
      _HeroMiniStat(label: "Logs", value: "${cycle.history.length}"),
    ]
        : [
      _HeroMiniStat(label: "Cycle", value: "${cycle.cycleLength}d"),
      _HeroMiniStat(label: "Period", value: "${cycle.avgPeriodDuration}d"),
      _HeroMiniStat(label: "Phase", value: _formatPhase(cycle.currentData.phase)),
    ];

    return PremiumGlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              children: stats.map((stat) => Expanded(child: _buildHeroMiniStat(stat))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMiniStat(_HeroMiniStat stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // 🔥 ОБНОВЛЕННАЯ ПАНЕЛЬ ИИ С ИНТЕГРАЦИЕЙ ЧАТА
  Widget _buildAIOperatingCenter(CycleProvider cycle, WellnessProvider wellness, bool isTTC) {
    return PremiumGlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.follicular.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.sparkles, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ayla AI Engine",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_hasCachedAdvice)
                  GestureDetector(
                    onTap: _isGeneratingAI ? null : () async {
                      HapticFeedback.lightImpact();
                      setState(() => _isGeneratingAI = true);

                      final response = await AiOracleService.generateDailyAdvice(
                        phase: cycle.currentData.phase,
                        logs: [wellness.getLogForDate(DateTime.now())],
                        isCoc: cycle.isCOCEnabled,
                        forceRefresh: true,
                      );

                      if (mounted) {
                        setState(() => _isGeneratingAI = false);
                        _showAylaSheet(response);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _isGeneratingAI
                          ? const CupertinoActivityIndicator(radius: 8)
                          : const Icon(CupertinoIcons.refresh_thick, size: 16, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              _hasCachedAdvice
                  ? "Your daily hormonal analysis is ready. You can also chat with Ayla anytime for personalized guidance."
                  : "Wondering why you feel a certain way today? Chat with Ayla or generate your daily hormone report.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 1. ГЛАВНАЯ КНОПКА: ЧАТ С АЙЛОЙ
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E71C7), AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.chat_bubble_2_fill, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Chat with Ayla",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 2. ВТОРИЧНАЯ КНОПКА: ГЕНЕРАЦИЯ ДНЕВНОГО ОТЧЕТА (Кэшированного)
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: AppColors.primary.withOpacity(0.12), // Стеклянный эффект
                borderRadius: BorderRadius.circular(16),
                onPressed: _isGeneratingAI ? null : () async {
                  HapticFeedback.lightImpact();

                  if (!_hasCachedAdvice) {
                    setState(() => _isGeneratingAI = true);
                  }

                  final response = await AiOracleService.generateDailyAdvice(
                    phase: cycle.currentData.phase,
                    logs: [wellness.getLogForDate(DateTime.now())],
                    isCoc: cycle.isCOCEnabled,
                  );

                  if (mounted) {
                    setState(() {
                      _isGeneratingAI = false;
                      _hasCachedAdvice = true;
                    });
                    _showAylaSheet(response);
                  }
                },
                child: _isGeneratingAI && !_hasCachedAdvice
                    ? const CupertinoActivityIndicator(color: AppColors.primary)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        _hasCachedAdvice ? CupertinoIcons.doc_text_search : CupertinoIcons.wand_rays,
                        size: 18,
                        color: AppColors.primary
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasCachedAdvice ? "View Today's Report" : "Generate Daily Report",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAylaSheet(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => AylaConsultationSheet(
        insightText: text,
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(CycleProvider cycle) {
    String title = "Data insufficient";
    String message = "Log more cycles to unlock insights.";
    Color iconColor = AppColors.textSecondary;
    IconData icon = CupertinoIcons.chart_pie;

    if (cycle.isTTCMode) {
      if (cycle.isOvulationConfirmed) {
        title = "Ovulation confirmed";
        message = "You are now in the two-week wait. Keep routines stable.";
        iconColor = AppColors.luteal;
        icon = CupertinoIcons.check_mark_circled_solid;
      } else if (cycle.conceptionChance == FertilityChance.peak || cycle.conceptionChance == FertilityChance.high) {
        title = "Fertile window open";
        message = "Chance of conception is high. Log BBT daily.";
        iconColor = const Color(0xFFE85D75);
        icon = CupertinoIcons.heart_circle_fill;
      } else {
        title = "Tracking phase";
        message = "Monitoring inputs to predict ovulation day.";
        iconColor = AppColors.follicular;
        icon = CupertinoIcons.chart_pie_fill;
      }
    } else {
      if (cycle.isCOCEnabled) {
        title = "Contraceptive mode";
        message = "Cycle managed by oral contraceptives. Keep taking pills.";
        iconColor = AppColors.follicular;
        icon = CupertinoIcons.shield_fill;
      } else if (cycle.isAmenorrhea) {
        title = "Delayed cycle";
        message = "Cycle delayed >60 days. Consider clinical consultation.";
        iconColor = AppColors.late;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
      } else if (cycle.hasProlongedBleeding) {
        title = "Irregular bleeding";
        message = "Recent period was longer than typical. Monitor closely.";
        iconColor = AppColors.menstruation;
        icon = CupertinoIcons.drop_triangle_fill;
      } else if (cycle.history.length >= 3) {
        title = "Stable rhythm";
        message = "Your recent cycles look highly consistent.";
        iconColor = const Color(0xFF81C784);
        icon = CupertinoIcons.checkmark_seal_fill;
      } else if (cycle.history.isNotEmpty) {
        title = "Learning your rhythm";
        message = "App is building a reliable model. Keep logging.";
        iconColor = AppColors.primary;
        icon = CupertinoIcons.sparkles;
      }
    }

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(message, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactVitalsStrip(CycleProvider cycle) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCapsule(
            label: "Cycle length",
            value: "${cycle.cycleLength}",
            suffix: "days",
            icon: CupertinoIcons.arrow_2_circlepath,
            color: AppColors.follicular,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCapsule(
            label: "Period",
            value: "${cycle.avgPeriodDuration}",
            suffix: "days",
            icon: CupertinoIcons.drop_fill,
            color: AppColors.menstruation,
          ),
        ),
      ],
    );
  }

  Widget _buildFertilityStatusStrip(CycleProvider cycle) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCapsule(
            label: "Fertility",
            value: _fertilityLabel(cycle.conceptionChance),
            icon: CupertinoIcons.heart_circle_fill,
            color: const Color(0xFFE85D75),
            compactValue: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCapsule(
            label: "Ovulation",
            value: cycle.isOvulationConfirmed ? "Yes" : "Pending",
            icon: CupertinoIcons.check_mark_circled_solid,
            color: AppColors.luteal,
            compactValue: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCapsule({
    required String label,
    required String value,
    String? suffix,
    required IconData icon,
    required Color color,
    bool compactValue = false,
  }) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: compactValue ? 20 : 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomInsightCard(SymptomInsight insight, bool isTTC) {
    final Color alertColor = insight.isWarning ? AppColors.late : (isTTC ? const Color(0xFFBCAAA4) : AppColors.luteal);
    final IconData alertIcon = insight.isWarning ? CupertinoIcons.exclamationmark_circle_fill : CupertinoIcons.lightbulb_fill;

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alertIcon, color: alertColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.description,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalFlagCard(BuildContext context, HealthFlag flag) {
    Color cardColor;
    IconData icon;

    switch (flag.type) {
      case HealthFlagType.pcos: cardColor = AppColors.late; icon = CupertinoIcons.waveform_path_ecg; break;
      case HealthFlagType.endometriosis: cardColor = AppColors.menstruation; icon = CupertinoIcons.drop_triangle_fill; break;
      case HealthFlagType.lutealDefect: cardColor = AppColors.luteal; icon = CupertinoIcons.graph_square_fill; break;
      case HealthFlagType.amenorrhea: cardColor = AppColors.late; icon = CupertinoIcons.exclamationmark_shield_fill; break;
      case HealthFlagType.menorrhagia: cardColor = AppColors.menstruation; icon = CupertinoIcons.drop_fill; break;
      case HealthFlagType.pmdd: cardColor = AppColors.primary; icon = CupertinoIcons.cloud_bolt_rain_fill; break;
      case HealthFlagType.polymenorrhea: cardColor = AppColors.follicular; icon = CupertinoIcons.arrow_2_circlepath_circle_fill; break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showFlagDetails(context, flag, cardColor, icon);
        },
        child: PremiumGlassCard(
          padding: const EdgeInsets.all(0),
          borderRadius: 24,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: cardColor.withOpacity(0.6), width: 4)),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: cardColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: cardColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flag.title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        flag.description,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary.withOpacity(0.3), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFlagDetails(BuildContext context, HealthFlag flag, Color color, IconData icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)),
              const SizedBox(height: 16),
              Text(flag.title, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(flag.description, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.textSecondary.withOpacity(0.1))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(flag.recommendation, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: CupertinoButton(color: AppColors.primary, borderRadius: BorderRadius.circular(16), onPressed: () => Navigator.pop(context), child: Text("Understood", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: AppColors.textSecondary.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _prepareBBTData(CycleProvider cycle, WellnessProvider wellness) {
    final cycleStart = cycle.currentData.cycleStartDate;
    final totalDays = cycle.currentData.totalCycleLength;
    _bbtSpots.clear();
    _minTemp = 36.2;
    _maxTemp = 37.2;

    final todayClean = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (int i = 0; i < totalDays; i++) {
      final date = cycleStart.add(Duration(days: i));
      final cleanDate = DateTime(date.year, date.month, date.day);
      if (cleanDate.isAfter(todayClean)) break;

      try {
        final log = wellness.getLogForDate(cleanDate);
        if (log.temperature != null && log.temperature! > 0) {
          _bbtSpots.add(FlSpot(i.toDouble() + 1, log.temperature!));
          if (log.temperature! < _minTemp) _minTemp = log.temperature! - 0.2;
          if (log.temperature! > _maxTemp) _maxTemp = log.temperature! + 0.2;
        }
      } catch (_) {}
    }
  }

  void _prepareDailySymptomsMap(CycleProvider cycle, WellnessProvider wellness) {
    _dailySymptomsMap.clear();
    final cycleStart = cycle.currentData.cycleStartDate;
    final totalDays = cycle.currentData.totalCycleLength;
    final todayClean = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (int i = 0; i < totalDays; i++) {
      final date = cycleStart.add(Duration(days: i));
      final cleanDate = DateTime(date.year, date.month, date.day);
      if (cleanDate.isAfter(todayClean)) break;

      try {
        final log = wellness.getLogForDate(cleanDate);
        final List<String> daySymptoms = [];
        daySymptoms.addAll(log.symptoms);
        daySymptoms.addAll(log.painSymptoms);

        if (daySymptoms.isNotEmpty) {
          _dailySymptomsMap[i + 1] = daySymptoms;
        }
      } catch (_) {}
    }
  }

  Widget _buildBBTChart(CycleProvider cycle) {
    if (_bbtSpots.isEmpty) return _buildEmptyState("Log your morning temperature to see your thermal shift.", CupertinoIcons.thermometer);

    final double ovDay = cycle.ovulationDay.toDouble();
    const Color chartColor = Color(0xFFBCAAA4);

    return LineChart(
      LineChartData(
        minY: _minTemp, maxY: _maxTemp, minX: 1, maxX: cycle.currentData.totalCycleLength.toDouble(),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white.withOpacity(0.9),
            tooltipRoundedRadius: 12,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) => LineTooltipItem("${spot.y.toStringAsFixed(2)}°\nDay ${spot.x.toInt()}", GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12))).toList();
            },
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textSecondary.withOpacity(0.10), strokeWidth: 1, dashArray: [4, 4])),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 5, getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8), child: Text("${value.toInt()}", style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600))))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 0.2, getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(right: 8), child: Text(value.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600))))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            if (cycle.isOvulationConfirmed)
              VerticalLine(x: ovDay, color: chartColor, strokeWidth: 1.5, dashArray: [4, 4], label: VerticalLineLabel(show: true, alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 4), style: GoogleFonts.inter(color: chartColor, fontSize: 10, fontWeight: FontWeight.w700), labelResolver: (_) => "Ovulation")),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _bbtSpots, isCurved: true, curveSmoothness: 0.35, color: chartColor, barWidth: 2.5, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3.5, color: Colors.white, strokeWidth: 1.5, strokeColor: chartColor)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [chartColor.withOpacity(0.2), chartColor.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsFeed(List<MapEntry<String, int>> topSymptoms, bool isTTC) {
    return PremiumGlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: topSymptoms.asMap().entries.map((entry) {
          final isLast = entry.key == topSymptoms.length - 1;
          return Column(
            children: [
              _buildSymptomListTile(entry.value.key, entry.value.value, isTTC),
              if (!isLast)
                Divider(height: 1, indent: 56, color: AppColors.textPrimary.withOpacity(0.05)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomListTile(String symptomName, int count, bool isTTC) {
    final activeColor = isTTC ? const Color(0xFFBCAAA4) : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: activeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(CupertinoIcons.waveform_path, size: 16, color: activeColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              symptomName[0].toUpperCase() + symptomName.substring(1).toLowerCase(),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Text(
            "$count d",
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, int>> _getTopSymptoms(WellnessProvider wellness) {
    final Map<String, int> counts = {};
    final today = DateTime.now();

    for (int i = 0; i < 60; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final log = wellness.getLogForDate(date);
        if (log.symptoms.isNotEmpty || log.painSymptoms.isNotEmpty) {
          for (final sym in [...log.symptoms, ...log.painSymptoms]) {
            counts[sym] = (counts[sym] ?? 0) + 1;
          }
        }
      } catch (_) {}
    }

    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(4).toList();
  }

  String _formatPhase(dynamic phase) {
    final raw = phase.toString().split('.').last;
    if (raw.isEmpty) return "Unknown";
    return raw.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim().split(' ').map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}').join(' ');
  }

  String _fertilityLabel(FertilityChance chance) {
    switch (chance) {
      case FertilityChance.peak: return "Peak";
      case FertilityChance.high: return "High";
      case FertilityChance.low: return "Low";
    }
  }

  SymptomInsight? _getTodayIntelligence(
      BuildContext context,
      WellnessProvider wellness,
      CycleProvider cycle,
      ) {
    try {
      final todayLog = wellness.getLogForDate(DateTime.now());
      final allTodaySymptoms = [
        ...todayLog.symptoms,
        ...todayLog.painSymptoms,
      ];

      if (allTodaySymptoms.isEmpty) return null;

      final currentPhase = cycle.currentData.phase;
      return SymptomIntelligence.getInsight(
        context,
        allTodaySymptoms,
        currentPhase,
        isTTCMode: cycle.isTTCMode,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("InsightsScreen Error getting today intelligence: $e");
      }
      return null;
    }
  }
}

class _HeroMiniStat {
  final String label;
  final String value;
  const _HeroMiniStat({required this.label, required this.value});
}