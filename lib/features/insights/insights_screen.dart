import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../core/services/pdf_service.dart';

// 🔥 Подключаем логику ИИ и модели
import '../../data/logic/symptom_intelligence.dart';
import '../../data/models/cycle_model.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();
    // final l10n = AppLocalizations.of(context)!;

    bool hasEnoughData = cycleProvider.history.length >= 2;
    List<MapEntry<String, int>> topSymptoms = _getTopSymptoms(wellnessProvider);

    // Получаем ИИ-инсайт на сегодня
    final todayInsight = _getTodayIntelligence(context, wellnessProvider, cycleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "I N S I G H T S",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.doc_text_viewfinder, color: AppColors.primary),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await PdfService.generateReport(context);
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [

            // ─── БЛОК 1: ГЛОБАЛЬНЫЙ AI-АНАЛИЗ ЦИКЛА ───
            _buildSectionTitle("Health Analysis"),
            const SizedBox(height: 12),
            _buildAIAnalysisCard(cycleProvider),
            const SizedBox(height: 24),

            // ─── БЛОК 2: УМНЫЙ ИНСАЙТ НА СЕГОДНЯ (Из SymptomIntelligence) ───
            if (todayInsight != null) ...[
              _buildSectionTitle("Today's Body Pattern"),
              const SizedBox(height: 12),
              _buildSymptomInsightCard(todayInsight),
              const SizedBox(height: 24),
            ],

            // ─── БЛОК 3: КЛЮЧЕВЫЕ МЕТРИКИ ───
            _buildSectionTitle("Cycle Vitals"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildVitalCard(
                  title: "Cycle Length",
                  value: cycleProvider.cycleLength.toString(),
                  unit: "days",
                  subtitle: "Normal: 21-35d",
                  isAnomalous: cycleProvider.cycleLength < 21 || cycleProvider.cycleLength > 35,
                  icon: CupertinoIcons.arrow_2_circlepath,
                  color: AppColors.follicular,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildVitalCard(
                  title: "Period Duration",
                  value: cycleProvider.avgPeriodDuration.toString(),
                  unit: "days",
                  subtitle: "Normal: 3-7d",
                  isAnomalous: cycleProvider.hasProlongedBleeding,
                  icon: CupertinoIcons.drop_fill,
                  color: AppColors.menstruation,
                )),
              ],
            ),
            const SizedBox(height: 32),

            // ─── БЛОК 4: ПРЕМИАЛЬНЫЙ ГРАФИК ЦИКЛОВ ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSectionTitle("Cycle History"),
                if (hasEnoughData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Avg: ${cycleProvider.cycleLength}d",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 16),
            PremiumGlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 24,
              child: SizedBox(
                height: 240, // Чуть увеличили высоту для красоты
                child: hasEnoughData
                    ? _buildCycleBarChart(cycleProvider)
                    : _buildEmptyState("Log at least 2 complete cycles to see your history graph.", CupertinoIcons.chart_bar_alt_fill),
              ),
            ),
            const SizedBox(height: 32),

            // ─── БЛОК 5: ПАТТЕРНЫ ОРГАНИЗМА ───
            _buildSectionTitle("Frequent Symptoms"),
            const SizedBox(height: 12),
            topSymptoms.isEmpty
                ? PremiumGlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: _buildEmptyState("Log your daily symptoms to uncover your body's unique patterns.", CupertinoIcons.sparkles)
            )
                : Column(
              children: topSymptoms.map((entry) => _buildSymptomCard(entry.key, entry.value)).toList(),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ─── ЛОГИКА ИНТЕГРАЦИИ С SYMPTOM INTELLIGENCE ─────────────────────────────

  SymptomInsight? _getTodayIntelligence(BuildContext context, WellnessProvider wellness, CycleProvider cycle) {
    try {
      final todayLog = wellness.getLogForDate(DateTime.now());
      final allTodaySymptoms = [...todayLog.symptoms, ...todayLog.painSymptoms];

      if (allTodaySymptoms.isEmpty) return null;

      // 🔥 ИСПРАВЛЕНО: Берем фазу из currentData
      final currentPhase = cycle.currentData.phase;

      return SymptomIntelligence.getInsight(context, allTodaySymptoms, currentPhase);
    } catch (e) {
      return null;
    }
  }

  // ─── КОМПОНЕНТЫ UI ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
        title,
        style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5
        )
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(CycleProvider cycle) {
    String title = "Analyzing...";
    String message = "Log more cycles to unlock personalized insights.";
    Color iconColor = AppColors.primary;
    IconData icon = CupertinoIcons.sparkles;

    if (cycle.isCOCEnabled) {
      title = "Contraceptive Mode";
      message = "Your cycles are currently managed by oral contraceptives. Keep taking your pills on time.";
      iconColor = AppColors.follicular;
      icon = CupertinoIcons.shield_fill;
    } else if (cycle.isAmenorrhea) {
      title = "Action Required";
      message = "Your cycle is delayed by over 60 days. If you've been sexually active, consider taking a pregnancy test or consulting a doctor.";
      iconColor = Colors.orangeAccent;
      icon = CupertinoIcons.exclamationmark_triangle_fill;
    } else if (cycle.hasProlongedBleeding) {
      title = "Irregular Bleeding";
      message = "We noticed your recent period lasted longer than 8 days. Keep monitoring this, and consult a doctor if it persists.";
      iconColor = Colors.redAccent;
      icon = CupertinoIcons.drop_triangle_fill;
    } else if (cycle.history.length >= 3) {
      title = "Stable Rhythm";
      message = "Great news! Your hormonal rhythm is highly stable. Your body is following a predictable pattern.";
      iconColor = Colors.green;
      icon = CupertinoIcons.checkmark_seal_fill;
    } else if (cycle.history.isNotEmpty) {
      title = "Learning your rhythm";
      message = "We are currently learning your unique hormonal patterns. Keep logging!";
      iconColor = AppColors.primary;
    }

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(message, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Новый виджет для вывода инсайтов из SymptomIntelligence
  Widget _buildSymptomInsightCard(SymptomInsight insight) {
    final Color alertColor = insight.isWarning ? Colors.orangeAccent : AppColors.luteal;
    final IconData alertIcon = insight.isWarning ? CupertinoIcons.exclamationmark_circle_fill : CupertinoIcons.lightbulb_fill;

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
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
              if (insight.priority >= 80) // Высший приоритет
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("High Priority", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                )
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

  Widget _buildVitalCard({required String title, required String value, required String unit, required String subtitle, required bool isAnomalous, required IconData icon, required Color color}) {
    final displayColor = isAnomalous ? Colors.orangeAccent : color;

    return PremiumGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: displayColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                Text(unit, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: isAnomalous ? Colors.orangeAccent : AppColors.textSecondary.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildCycleBarChart(CycleProvider cycle) {
    final history = cycle.history.reversed.take(6).toList().reversed.toList();
    final avgCycle = cycle.cycleLength.toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event.isInterestedForInteractions) {
              HapticFeedback.selectionClick();
            }
          },
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.textPrimary.withOpacity(0.9),
            tooltipRoundedRadius: 12,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                  "${rod.toY.toInt()} days",
                  GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("C${value.toInt() + 1}", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: avgCycle,
              color: AppColors.primary.withOpacity(0.4),
              strokeWidth: 2,
              dashArray: [6, 6],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 0, bottom: 6),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary.withOpacity(0.8)),
                labelResolver: (line) => "AVG",
              ),
            ),
          ],
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(history.length, (index) {
          final cycleLength = history[index].length?.toDouble() ?? avgCycle;
          final isAnomalous = cycleLength < 21 || cycleLength > 35;
          final Color mainColor = isAnomalous ? Colors.orangeAccent : AppColors.primary;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: cycleLength,
                gradient: LinearGradient(
                  colors: [mainColor.withOpacity(0.6), mainColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 18,
                borderRadius: BorderRadius.circular(8),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 50,
                    color: AppColors.textSecondary.withOpacity(0.06)
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 850),
      swapAnimationCurve: Curves.easeOutQuart,
    );
  }

  Widget _buildSymptomCard(String symptomName, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(CupertinoIcons.waveform_path, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                symptomName[0].toUpperCase() + symptomName.substring(1).toLowerCase(),
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.1))
              ),
              child: Text("$count days", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _getTopSymptoms(WellnessProvider wellness) {
    Map<String, int> counts = {};
    final today = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final log = wellness.getLogForDate(date);
        if (log.symptoms.isNotEmpty || log.painSymptoms.isNotEmpty) {
          for (var sym in [...log.symptoms, ...log.painSymptoms]) {
            counts[sym] = (counts[sym] ?? 0) + 1;
          }
        }
      } catch (_) {}
    }
    var sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(4).toList();
  }
}