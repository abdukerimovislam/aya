import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../core/services/pdf_service.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../core/services/ai_oracle_service.dart';
import '../../l10n/app_localizations.dart';

import '../../data/logic/symptom_intelligence.dart';
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
  final Map<int, List<String>> _dailySymptomsMap = {};

  final List<FlSpot> _bbtSpots = [];
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
    final cycleProvider = context.read<CycleProvider>();
    final wellnessProvider = context.read<WellnessProvider>();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final aiBox = await Hive.openBox('ai_insights');
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (aiBox.get('cached_advice_date') == todayStr && aiBox.get('cached_advice_text') != null) {
      _hasCachedAdvice = true;
    }

    _topSymptoms = _getTopSymptoms(wellnessProvider);
    _clinicalFlags = await HealthPatternDetector.analyzePatterns(
      cycleProvider.history,
      wellnessProvider,
      isCocEnabled: cycleProvider.isCOCEnabled,
    );
    if (!mounted) return;
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
    final l10n = AppLocalizations.of(context)!;
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
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
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
                  title: isTTC ? l10n.insightsFertilityStatusTitle : l10n.insightsCycleAnalysisTitle,
                  subtitle: l10n.insightsKeySignalsSubtitle,
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: Column(
          children: [
            const CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(
              l10n.insightsLoadingHistoryPatterns,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader(
          title: l10n.insightsHormonalRhythmTitle,
          subtitle: l10n.insightsHormonalRhythmBody,
        ),
        const SizedBox(height: 12),
        HormonalRhythmCard(
          data: cycleProvider.currentData,
          dailySymptoms: _dailySymptomsMap,
        ),

        if (_todayInsight != null) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            title: l10n.insightsHormonalContextTitle,
            subtitle: l10n.insightsHormonalContextBody,
          ),
          const SizedBox(height: 12),
          _buildSymptomInsightCard(_todayInsight!, isTTC),
        ],

        if (_clinicalFlags.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            title: l10n.insightsMedicalInsightsTitle,
            subtitle: l10n.insightsMedicalInsightsBody,
          ),
          const SizedBox(height: 12),
          ..._clinicalFlags.map((flag) => _buildClinicalFlagCard(context, flag)),
        ],

        if (isTTC) ...[
          const SizedBox(height: 32),
          _buildSectionHeader(
            title: l10n.insightsThermalShiftTitle,
            subtitle: l10n.insightsThermalShiftBody,
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
          title: l10n.insightsFrequentSymptomsTitle,
          subtitle: l10n.insightsFrequentSymptomsBody,
        ),
        const SizedBox(height: 12),

        _topSymptoms.isEmpty
            ? PremiumGlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(24),
          child: _buildEmptyState(l10n.insightsEmptySymptomsBody, CupertinoIcons.sparkles),
        )
            : _buildSymptomsFeed(_topSymptoms, isTTC),
      ],
    );
  }

  Widget _buildTopBarTitle(bool isTTC) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTTC ? l10n.insightsTopBarFertilityHubTitle : l10n.tabInsights,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isTTC
              ? l10n.insightsTopBarFertilityHubSubtitle
              : l10n.insightsTopBarDefaultSubtitle,
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
    final l10n = AppLocalizations.of(context)!;
    String title;
    String subtitle;
    IconData icon;
    Color accentColor;

    if (cycle.isCOCEnabled) {
      title = l10n.insightsHeroContraceptiveModeTitle;
      subtitle = l10n.insightsHeroContraceptiveModeBody;
      icon = CupertinoIcons.shield_fill;
      accentColor = AppColors.follicular;
    } else if (isTTC) {
      if (cycle.isOvulationConfirmed) {
        title = l10n.insightsHeroOvulationConfirmedTitle;
        subtitle = l10n.insightsHeroOvulationConfirmedBody;
        icon = CupertinoIcons.check_mark_circled_solid;
        accentColor = AppColors.luteal;
      } else if (cycle.conceptionChance == FertilityChance.high || cycle.conceptionChance == FertilityChance.peak) {
        title = l10n.insightsHeroFertileWindowActiveTitle;
        subtitle = l10n.insightsHeroFertileWindowActiveBody;
        icon = CupertinoIcons.heart_circle_fill;
        accentColor = const Color(0xFFE85D75);
      } else {
        title = l10n.insightsHeroTrackingFertilityTitle;
        subtitle = l10n.insightsHeroTrackingFertilityBody;
        icon = CupertinoIcons.sparkles;
        accentColor = AppColors.follicular;
      }
    } else {
      title = l10n.insightsHeroCycleIntelligenceTitle;
      subtitle = cycle.history.isEmpty
          ? l10n.insightsHeroCycleIntelligenceEmptyBody
          : l10n.insightsHeroCycleIntelligenceReadyBody;
      icon = CupertinoIcons.waveform_path_ecg;
      accentColor = AppColors.primary;
    }

    final List<_HeroMiniStat> stats = isTTC
        ? [
      _HeroMiniStat(
        label: l10n.insightsHeroStatusLabel,
        value: cycle.isOvulationConfirmed
            ? l10n.ttcOvulationConfirmedManual
            : _fertilityLabel(cycle.conceptionChance),
      ),
      _HeroMiniStat(
        label: l10n.insightsHeroPhaseLabel,
        value: _formatPhase(cycle.currentData.phase),
      ),
      _HeroMiniStat(label: l10n.insightsHeroLogsLabel, value: "${cycle.history.length}"),
    ]
        : [
      _HeroMiniStat(label: l10n.insightsHeroCycleLabel, value: "${cycle.cycleLength}${l10n.unitDaysShort}"),
      _HeroMiniStat(label: l10n.insightsHeroPeriodLabel, value: "${cycle.avgPeriodDuration}${l10n.unitDaysShort}"),
      _HeroMiniStat(
        label: l10n.insightsHeroPhaseLabel,
        value: _formatPhase(cycle.currentData.phase),
      ),
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
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
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
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
            color: AppColors.textSecondary.withValues(alpha: 0.8),
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

  Widget _buildAIOperatingCenter(CycleProvider cycle, WellnessProvider wellness, bool isTTC) {
    final l10n = AppLocalizations.of(context)!;
    return PremiumGlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.follicular.withValues(alpha: 0.05),
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
                    l10n.insightsAylaEngineTitle,
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
                        color: AppColors.primary.withValues(alpha: 0.1),
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
                  ? l10n.insightsAylaReadyBody
                  : l10n.insightsAylaPromptBody,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

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
                      color: AppColors.primary.withValues(alpha: 0.3),
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
                      l10n.insightsChatWithAylaAction,
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

            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: AppColors.primary.withValues(alpha: 0.12),
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
                      _hasCachedAdvice
                          ? l10n.insightsViewTodaysReportAction
                          : l10n.insightsGenerateDailyReportAction,
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
    final l10n = AppLocalizations.of(context)!;
    String title = l10n.insightsAnalysisDataInsufficientTitle;
    String message = l10n.insightsAnalysisDataInsufficientBody;
    Color iconColor = AppColors.textSecondary;
    IconData icon = CupertinoIcons.chart_pie;

    if (cycle.isTTCMode) {
      if (cycle.isOvulationConfirmed) {
        title = l10n.insightsAnalysisOvulationConfirmedTitle;
        message = l10n.insightsAnalysisOvulationConfirmedBody;
        iconColor = AppColors.luteal;
        icon = CupertinoIcons.check_mark_circled_solid;
      } else if (cycle.conceptionChance == FertilityChance.peak || cycle.conceptionChance == FertilityChance.high) {
        title = l10n.insightsAnalysisFertileWindowOpenTitle;
        message = l10n.insightsAnalysisFertileWindowOpenBody;
        iconColor = const Color(0xFFE85D75);
        icon = CupertinoIcons.heart_circle_fill;
      } else {
        title = l10n.insightsAnalysisTrackingPhaseTitle;
        message = l10n.insightsAnalysisTrackingPhaseBody;
        iconColor = AppColors.follicular;
        icon = CupertinoIcons.chart_pie_fill;
      }
    } else {
      if (cycle.isCOCEnabled) {
        title = l10n.insightsAnalysisContraceptiveModeTitle;
        message = l10n.insightsAnalysisContraceptiveModeBody;
        iconColor = AppColors.follicular;
        icon = CupertinoIcons.shield_fill;
      } else if (cycle.isAmenorrhea) {
        title = l10n.insightsAnalysisDelayedCycleTitle;
        message = l10n.insightsAnalysisDelayedCycleBody;
        iconColor = AppColors.late;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
      } else if (cycle.hasProlongedBleeding) {
        title = l10n.insightsAnalysisIrregularBleedingTitle;
        message = l10n.insightsAnalysisIrregularBleedingBody;
        iconColor = AppColors.menstruation;
        icon = CupertinoIcons.drop_triangle_fill;
      } else if (cycle.history.length >= 3) {
        title = l10n.insightsAnalysisStableRhythmTitle;
        message = l10n.insightsAnalysisStableRhythmBody;
        iconColor = const Color(0xFF81C784);
        icon = CupertinoIcons.checkmark_seal_fill;
      } else if (cycle.history.isNotEmpty) {
        title = l10n.insightsAnalysisLearningRhythmTitle;
        message = l10n.insightsAnalysisLearningRhythmBody;
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
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildMetricCapsule(
            label: l10n.insightsMetricCycleLength,
            value: "${cycle.cycleLength}",
            suffix: l10n.unitDays,
            icon: CupertinoIcons.arrow_2_circlepath,
            color: AppColors.follicular,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCapsule(
            label: l10n.insightsMetricPeriod,
            value: "${cycle.avgPeriodDuration}",
            suffix: l10n.unitDays,
            icon: CupertinoIcons.drop_fill,
            color: AppColors.menstruation,
          ),
        ),
      ],
    );
  }

  Widget _buildFertilityStatusStrip(CycleProvider cycle) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildMetricCapsule(
            label: l10n.insightsMetricFertility,
            value: _fertilityLabel(cycle.conceptionChance),
            icon: CupertinoIcons.heart_circle_fill,
            color: const Color(0xFFE85D75),
            compactValue: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCapsule(
            label: l10n.insightsMetricOvulation,
            value: cycle.isOvulationConfirmed
                ? l10n.insightsMetricYes
                : l10n.insightsMetricPending,
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
    final l10n = AppLocalizations.of(context)!;
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
              border: Border(left: BorderSide(color: cardColor.withValues(alpha: 0.6), width: 4)),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: cardColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: cardColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flag.title(l10n), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        flag.description(l10n),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFlagDetails(BuildContext context, HealthFlag flag, Color color, IconData icon) {
    final l10n = AppLocalizations.of(context)!;
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)),
              const SizedBox(height: 16),
              Text(flag.title(l10n), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(flag.description(l10n), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(flag.recommendation(l10n), style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: CupertinoButton(color: AppColors.primary, borderRadius: BorderRadius.circular(16), onPressed: () => Navigator.pop(context), child: Text(l10n.btnOk, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)))),
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
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: AppColors.textSecondary.withValues(alpha: 0.4)),
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

    // 🔥 ИСПРАВЛЕНИЕ: Инициализируем экстремальными значениями для правильного масштаба
    _minTemp = 999.0;
    _maxTemp = 0.0;
    bool hasValidData = false;

    final todayClean = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (int i = 0; i < totalDays; i++) {
      final date = cycleStart.add(Duration(days: i));
      final cleanDate = DateTime(date.year, date.month, date.day);
      if (cleanDate.isAfter(todayClean)) break;

      try {
        final log = wellness.getLogForDate(cleanDate);
        if (log.temperature != null && log.temperature! > 0) {
          hasValidData = true;
          _bbtSpots.add(FlSpot(i.toDouble() + 1, log.temperature!));
          if (log.temperature! < _minTemp) _minTemp = log.temperature!;
          if (log.temperature! > _maxTemp) _maxTemp = log.temperature!;
        }
      } catch (_) {}
    }

    // Даем отступы для красоты графика (и для Цельсия, и для Фаренгейта)
    if (hasValidData) {
      _minTemp -= 0.2;
      _maxTemp += 0.2;
      if (_minTemp == _maxTemp) {
        _minTemp -= 0.5;
        _maxTemp += 0.5;
      }
    } else {
      _minTemp = 36.2;
      _maxTemp = 37.2;
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
    final l10n = AppLocalizations.of(context)!;
    if (_bbtSpots.isEmpty) {
      return _buildEmptyState(l10n.insightsBbtEmptyBody, CupertinoIcons.thermometer);
    }

    final double ovDay = cycle.ovulationDay.toDouble();
    const Color chartColor = Color(0xFFBCAAA4);

    return LineChart(
      LineChartData(
        minY: _minTemp, maxY: _maxTemp, minX: 1, maxX: cycle.currentData.totalCycleLength.toDouble(),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white.withValues(alpha: 0.9),
            tooltipRoundedRadius: 12,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (spot) => LineTooltipItem(
                  "${spot.y.toStringAsFixed(2)}°\n${l10n.dayOfCycle(spot.x.toInt())}",
                  GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ).toList();
            },
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textSecondary.withValues(alpha: 0.10), strokeWidth: 1, dashArray: [4, 4])),
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
              VerticalLine(
                x: ovDay,
                color: chartColor,
                strokeWidth: 1.5,
                dashArray: const [4, 4],
                label: VerticalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 4),
                  style: GoogleFonts.inter(
                    color: chartColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  labelResolver: (_) => l10n.legendOvulation,
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _bbtSpots,
            isCurved: _bbtSpots.length > 2, // 🔥 ИСПРАВЛЕНИЕ КРАША FL_CHART
            curveSmoothness: 0.35, color: chartColor, barWidth: 2.5, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3.5, color: Colors.white, strokeWidth: 1.5, strokeColor: chartColor)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [chartColor.withValues(alpha: 0.2), chartColor.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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
                Divider(height: 1, indent: 56, color: AppColors.textPrimary.withValues(alpha: 0.05)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomListTile(String symptomName, int count, bool isTTC) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = isTTC ? const Color(0xFFBCAAA4) : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: activeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
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
            "$count ${l10n.unitDaysShort}",
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

  String _formatPhase(CyclePhase phase) {
    final l10n = AppLocalizations.of(context)!;
    switch (phase) {
      case CyclePhase.menstruation:
        return l10n.phaseMenstruation;
      case CyclePhase.follicular:
        return l10n.phaseFollicular;
      case CyclePhase.ovulation:
        return l10n.phaseOvulation;
      case CyclePhase.luteal:
        return l10n.phaseLuteal;
      case CyclePhase.late:
        return l10n.phaseLate;
    }
  }

  String _fertilityLabel(FertilityChance chance) {
    final l10n = AppLocalizations.of(context)!;
    switch (chance) {
      case FertilityChance.peak:
        return l10n.ttcChancePeak;
      case FertilityChance.high:
        return l10n.ttcChanceHigh;
      case FertilityChance.low:
        return l10n.ttcChanceLow;
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
