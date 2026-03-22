import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

import '../../data/logic/symptom_intelligence.dart';
import '../../data/models/cycle_model.dart';
import '../../data/logic/health_pattern_detector.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();

    final bool isTTC = cycleProvider.isTTCMode;
    final currentPhase = cycleProvider.currentData.phase;

    bool hasEnoughData = cycleProvider.history.length >= 2;
    List<MapEntry<String, int>> topSymptoms = _getTopSymptoms(wellnessProvider);

    final todayInsight = _getTodayIntelligence(context, wellnessProvider, cycleProvider);

    // 🔥 АНАЛИЗИРУЕМ КЛИНИЧЕСКИЕ ПАТТЕРНЫ
    final clinicalFlags = HealthPatternDetector.analyzePatterns(
        cycleProvider.history,
        wellnessProvider,
        isCocEnabled: cycleProvider.isCOCEnabled
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isTTC ? "F E R T I L I T Y   H U B" : "I N S I G H T S",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 14,
            color: isTTC ? Colors.purple : AppColors.textPrimary,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: LivePhaseBackground(
              phase: currentPhase,
              isCOC: cycleProvider.isCOCEnabled,
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [

                _buildSectionTitle(isTTC ? "Fertility Status" : "Health Analysis"),
                const SizedBox(height: 12),
                _buildAIAnalysisCard(cycleProvider),
                const SizedBox(height: 24),

                if (todayInsight != null) ...[
                  _buildSectionTitle("Today's Body Pattern"),
                  const SizedBox(height: 12),
                  _buildSymptomInsightCard(todayInsight, isTTC),
                  const SizedBox(height: 24),
                ],

                // 🔥 РЕНДЕРИМ СЕКЦИЮ ПАТТЕРНОВ, ЕСЛИ ОНИ НАЙДЕНЫ
                if (clinicalFlags.isNotEmpty) ...[
                  _buildSectionTitle("Clinical Patterns"),
                  const SizedBox(height: 12),
                  ...clinicalFlags.map((flag) => _buildClinicalFlagCard(context, flag)),
                  const SizedBox(height: 24),
                ],

                if (isTTC) ...[
                  _buildSectionTitle("Basal Body Temp (BBT)"),
                  const SizedBox(height: 16),
                  PremiumGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: SizedBox(
                      height: 260,
                      child: _buildBBTChart(context, cycleProvider, wellnessProvider),
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
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
                      height: 240,
                      child: hasEnoughData
                          ? _buildCycleBarChart(cycleProvider)
                          : _buildEmptyState("Log at least 2 complete cycles to see your history graph.", CupertinoIcons.chart_bar_alt_fill),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                _buildSectionTitle("Frequent Symptoms"),
                const SizedBox(height: 12),
                topSymptoms.isEmpty
                    ? PremiumGlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    child: _buildEmptyState("Log your daily symptoms to uncover your body's unique patterns.", CupertinoIcons.sparkles)
                )
                    : Column(
                  children: topSymptoms.map((entry) => _buildSymptomCard(entry.key, entry.value, isTTC)).toList(),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ВИДЖЕТ ДЛЯ КЛИНИЧЕСКИХ ПАТТЕРНОВ
  Widget _buildClinicalFlagCard(BuildContext context, HealthFlag flag) {
    Color cardColor;
    IconData icon;

    switch (flag.type) {
      case HealthFlagType.pcos:
        cardColor = Colors.orange;
        icon = CupertinoIcons.waveform_path_ecg;
        break;
      case HealthFlagType.endometriosis:
        cardColor = Colors.redAccent;
        icon = CupertinoIcons.drop_triangle_fill;
        break;
      case HealthFlagType.lutealDefect:
        cardColor = Colors.purple;
        icon = CupertinoIcons.graph_square_fill;
        break;
      case HealthFlagType.amenorrhea:
        cardColor = Colors.deepOrange;
        icon = CupertinoIcons.exclamationmark_shield_fill;
        break;
      case HealthFlagType.menorrhagia:
        cardColor = Colors.red;
        icon = CupertinoIcons.drop_fill;
        break;
      case HealthFlagType.pmdd:
        cardColor = Colors.indigo;
        icon = CupertinoIcons.cloud_bolt_rain_fill;
        break;
      case HealthFlagType.polymenorrhea:
        cardColor = Colors.teal;
        icon = CupertinoIcons.arrow_2_circlepath_circle_fill;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showFlagDetails(context, flag, cardColor, icon);
        },
        child: PremiumGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cardColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flag.title,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flag.description,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.info_circle, color: AppColors.textSecondary.withOpacity(0.5), size: 20),
            ],
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
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                flag.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                flag.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textSecondary.withOpacity(0.1))
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 ИСПРАВЛЕНА ИКОНКА ЗДЕСЬ
                    Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        flag.recommendation,
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Understood", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SymptomInsight? _getTodayIntelligence(BuildContext context, WellnessProvider wellness, CycleProvider cycle) {
    try {
      final todayLog = wellness.getLogForDate(DateTime.now());
      final allTodaySymptoms = [...todayLog.symptoms, ...todayLog.painSymptoms];

      if (allTodaySymptoms.isEmpty) return null;

      final currentPhase = cycle.currentData.phase;
      return SymptomIntelligence.getInsight(context, allTodaySymptoms, currentPhase, isTTCMode: cycle.isTTCMode);
    } catch (e) {
      if (kDebugMode) debugPrint("InsightsScreen Error getting today intelligence: $e");
      return null;
    }
  }

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
          Icon(icon, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
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

    if (cycle.isTTCMode) {
      if (cycle.isOvulationConfirmed) {
        title = "Ovulation Confirmed!";
        message = "Your ovulation has been detected. You are now in the Two Week Wait (TWW). Take care of yourself!";
        iconColor = Colors.purple;
        icon = CupertinoIcons.check_mark_circled_solid;
      } else if (cycle.conceptionChance == FertilityChance.peak || cycle.conceptionChance == FertilityChance.high) {
        title = "Fertile Window Open";
        message = "Your chances of conception are currently high. Log your BBT and OPK tests daily.";
        iconColor = Colors.pinkAccent;
        icon = CupertinoIcons.heart_circle_fill;
      } else {
        title = "Tracking Phase";
        message = "We are monitoring your daily inputs to predict your exact ovulation day. Keep logging BBT!";
        iconColor = Colors.teal;
        icon = CupertinoIcons.chart_pie_fill;
      }
    } else {
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

  Widget _buildSymptomInsightCard(SymptomInsight insight, bool isTTC) {
    Color alertColor = insight.isWarning ? Colors.orangeAccent : (isTTC ? Colors.purple : AppColors.luteal);
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
              if (insight.priority >= 80)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("Important", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
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

  Widget _buildBBTChart(BuildContext context, CycleProvider cycle, WellnessProvider wellness) {
    final cycleStart = cycle.currentData.cycleStartDate;
    final totalDays = cycle.currentData.totalCycleLength;

    List<FlSpot> spots = [];
    double minTemp = 36.2;
    double maxTemp = 37.2;

    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < totalDays; i++) {
      final date = cycleStart.add(Duration(days: i));
      final cleanDate = DateTime(date.year, date.month, date.day);

      if (cleanDate.isAfter(todayClean)) break;

      try {
        final log = wellness.getLogForDate(cleanDate);
        if (log.temperature != null && log.temperature! > 0) {
          spots.add(FlSpot(i.toDouble() + 1, log.temperature!));
          if (log.temperature! < minTemp) minTemp = log.temperature! - 0.2;
          if (log.temperature! > maxTemp) maxTemp = log.temperature! + 0.2;
        }
      } catch (e) {
        if (kDebugMode) debugPrint("InsightsScreen Chart Error: $e");
      }
    }

    if (spots.isEmpty) {
      return _buildEmptyState("Log your morning temperature (BBT) to see your thermal shift.", CupertinoIcons.thermometer);
    }

    final double ovDay = cycle.ovulationDay.toDouble();

    return LineChart(
      LineChartData(
        minY: minTemp,
        maxY: maxTemp,
        minX: 1,
        maxX: totalDays.toDouble(),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.purple.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  "${spot.y.toStringAsFixed(2)}°\nDay ${spot.x.toInt()}",
                  GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textSecondary.withOpacity(0.1), strokeWidth: 1, dashArray: [5, 5]),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("${value.toInt()}", style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 0.2,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(value.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),

        extraLinesData: ExtraLinesData(
          verticalLines: [
            if (cycle.isOvulationConfirmed)
              VerticalLine(
                x: ovDay,
                color: Colors.purple,
                strokeWidth: 2,
                dashArray: [4, 4],
                label: VerticalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 4, top: 0),
                  style: GoogleFonts.inter(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                  labelResolver: (_) => "Ovulation",
                ),
              )
          ],
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: Colors.purple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.purple,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.3), Colors.purple.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
    );
  }

  Widget _buildSymptomCard(String symptomName, int count, bool isTTC) {
    final activeColor = isTTC ? Colors.purple : AppColors.primary;

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
                  color: activeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(CupertinoIcons.waveform_path, size: 18, color: activeColor),
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
      } catch (e) {
        if (kDebugMode) debugPrint("InsightsScreen Error in _getTopSymptoms: $e");
      }
    }
    var sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(4).toList();
  }
}