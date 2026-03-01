import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';

import '../../shared/widgets/live_phase_background.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../logger/symptom_log_screen.dart';

enum InsightTab { cycle, mood, flow }

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightTab _activeTab = InsightTab.cycle;

  static const int requiredLogsForAI = 5;

  int _calculateLogsCount(WellnessProvider wellness) {
    int count = 0;
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      if (wellness.hasLogForDate(today.subtract(Duration(days: i)))) {
        count++;
      }
    }
    return count;
  }

  bool _isTabUnlocked(InsightTab tab, CycleProvider cycle, int logsCount) {
    if (tab == InsightTab.cycle) {
      return cycle.isCOCEnabled || cycle.history.isNotEmpty;
    }
    return logsCount >= requiredLogsForAI;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();

    final int logsCount = _calculateLogsCount(wellnessProvider);
    final bool isUnlocked = _isTabUnlocked(_activeTab, cycleProvider, logsCount);

    return Stack(
      children: [
        // 1. Анимированный фон фазы
        Positioned.fill(
          child: LivePhaseBackground(
            phase: cycleProvider.currentData.phase,
            isCOC: cycleProvider.isCOCEnabled,
          ),
        ),

        // 2. Легкое размытие для глубины пространства
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              "B I O R H Y T H M",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                // КАПСУЛА ПЕРЕКЛЮЧЕНИЯ (Spatial Capsule)
                _buildSpatialTabs(l10n),
                const SizedBox(height: 24),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      PremiumGlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChartHeader(l10n, cycleProvider),
                            const SizedBox(height: 32),

                            // ЗОНА УНИКАЛЬНОГО ГРАФИКА
                            SizedBox(
                              height: 320,
                              child: isUnlocked
                                  ? _buildDeltaChart(cycleProvider, wellnessProvider)
                                  : _buildLearningPhaseOverlay(logsCount, context),
                            ),

                            if (isUnlocked) ...[
                              const SizedBox(height: 32),
                              Divider(color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                              const SizedBox(height: 24),
                              _SmartOracleText(tab: _activeTab, cycle: cycleProvider, wellness: wellnessProvider),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── ПЛАВАЮЩИЕ ТАБЫ (SPATIAL CAPSULE) ───────────────────────────────────────
  Widget _buildSpatialTabs(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            _buildTabItem(InsightTab.cycle, "Cycle"),
            _buildTabItem(InsightTab.mood, l10n.logMood),
            _buildTabItem(InsightTab.flow, l10n.logFlow),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(InsightTab tab, String label) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _activeTab = tab);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader(AppLocalizations l10n, CycleProvider cycle) {
    String title = "";
    String value = "";

    switch (_activeTab) {
      case InsightTab.cycle:
        title = "Cycle Delta";
        value = cycle.isCOCEnabled ? "Locked" : "${cycle.cycleLength}d avg";
        break;
      case InsightTab.mood:
        title = "Emotional Delta";
        value = "Last 28 days";
        break;
      case InsightTab.flow:
        title = "Flow Intensity";
        value = "${cycle.avgPeriodDuration}d length";
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text("Your Data", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.textSecondary), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text("Baseline", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            )
          ],
        ),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
      ],
    );
  }

  // 🔥 ХОЛОДНЫЙ СТАРТ С АДАПТИВНОЙ КНОПКОЙ
  Widget _buildLearningPhaseOverlay(int currentLogs, BuildContext context) {
    final double progress = (currentLogs / requiredLogsForAI).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: _buildFakeChart(),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(CupertinoIcons.waveform_path, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text("Calibrating AI", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _activeTab == InsightTab.cycle
                      ? "Log your period to establish your cycle baseline."
                      : "The algorithm needs a few more days of data to build your personalized delta wave.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),

              if (_activeTab != InsightTab.cycle) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress, minHeight: 8, backgroundColor: Colors.grey.withOpacity(0.15), valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text("$currentLogs / $requiredLogsForAI logs collected", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 24),
              ],

              // Адаптивная кнопка!
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: AppColors.textPrimary.withOpacity(0.3),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (_) => ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), child: SizedBox(height: MediaQuery.of(context).size.height * 0.9, child: SymptomLogScreen(date: DateTime.now()))),
                    );
                  },
                  child: Text("Sync Data Today", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16, letterSpacing: 0.5)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ─── THE DELTA CHART (УНИКАЛЬНЫЙ ГРАФИК С БАЗОВОЙ ЛИНИЕЙ) ──────────────────
  Widget _buildDeltaChart(CycleProvider cycle, WellnessProvider wellness) {
    List<FlSpot> userSpots = [];
    List<FlSpot> baseSpots = [];
    double minY = 0; double maxY = 10;
    Color glowColor = AppColors.primary;

    if (_activeTab == InsightTab.cycle) {
      minY = 15; maxY = 45; glowColor = AppColors.follicular;
      double baselineY = 28.0; // Идеальный медицинский цикл

      if (cycle.isCOCEnabled) {
        userSpots = [const FlSpot(0, 28), const FlSpot(1, 28), const FlSpot(2, 28), const FlSpot(3, 28)];
        baseSpots = userSpots;
      } else {
        final history = cycle.history.reversed.toList();
        for (int i = 0; i < history.length; i++) {
          if (history[i].length != null) {
            userSpots.add(FlSpot(i.toDouble(), history[i].length!.toDouble()));
            baseSpots.add(FlSpot(i.toDouble(), baselineY));
          }
        }
        if (userSpots.length == 1) {
          userSpots.add(FlSpot(1.0, userSpots.first.y)); baseSpots.add(FlSpot(1.0, baselineY));
        }
      }
    } else if (_activeTab == InsightTab.mood) {
      minY = 1; maxY = 5.5; glowColor = Colors.orangeAccent;
      double baselineY = 3.5; // Базовое хорошее настроение
      final moodValues = wellness.calculateWaveData();
      for (int i = 0; i < moodValues.length; i++) {
        userSpots.add(FlSpot(i.toDouble(), moodValues[i]));
        baseSpots.add(FlSpot(i.toDouble(), baselineY));
      }
    } else if (_activeTab == InsightTab.flow) {
      minY = 0; maxY = 3.5; glowColor = Colors.redAccent;
      double baselineY = 1.5; // Средняя обильность
      for (int i = 0; i < 7; i++) {
        userSpots.add(FlSpot(i.toDouble(), i < cycle.avgPeriodDuration ? (3.0 - (i * 0.4)) : 0));
        baseSpots.add(FlSpot(i.toDouble(), i < 5 ? baselineY : 0)); // Базовые выделения идут 5 дней
      }
    }

    if (userSpots.isEmpty) {
      userSpots = const [FlSpot(0, 0), FlSpot(1, 0)]; baseSpots = const [FlSpot(0, 0), FlSpot(1, 0)];
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.5), strokeWidth: 1)),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (userSpots.length - 1).toDouble() > 0 ? (userSpots.length - 1).toDouble() : 1,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          // 1. БАЗОВАЯ ЛИНИЯ (Идеал) - Индекс 0
          LineChartBarData(
            spots: baseSpots,
            isCurved: true,
            color: AppColors.textSecondary.withOpacity(0.3),
            barWidth: 3,
            isStrokeCapRound: true,
            dashArray: [6, 6], // Пунктир
            dotData: const FlDotData(show: false),
          ),
          // 2. ВОЛНА ПОЛЬЗОВАТЕЛЯ - Индекс 1
          LineChartBarData(
            spots: userSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: glowColor,
            barWidth: 5,
            isStrokeCapRound: true,
            shadow: Shadow(color: glowColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
            dotData: FlDotData(
              show: _activeTab == InsightTab.cycle,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.white, strokeWidth: 3, strokeColor: glowColor),
            ),
          ),
        ],
        // 🔥 МАГИЯ: ЗАЛИВКА ОТКЛОНЕНИЙ (Дельта) между индексом 0 и 1
        betweenBarsData: [
          BetweenBarsData(
            fromIndex: 0,
            toIndex: 1,
            color: glowColor.withOpacity(0.15),
          )
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white.withOpacity(0.95),
            tooltipRoundedRadius: 12,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              if (spot.barIndex == 0) return null; // Не показываем тултип для базовой линии
              return LineTooltipItem(
                  spot.y.toInt().toString(),
                  TextStyle(color: glowColor, fontWeight: FontWeight.w900, fontSize: 18)
              );
            }).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCirc,
    );
  }

  Widget _buildFakeChart() {
    return LineChart(
        LineChartData(
          gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
          minY: 0, maxY: 10,
          lineBarsData: [
            LineChartBarData(spots: const [FlSpot(0, 5), FlSpot(1, 5), FlSpot(2, 5)], color: Colors.grey.withOpacity(0.5), barWidth: 2, dashArray: [5,5], dotData: const FlDotData(show: false)),
            LineChartBarData(spots: const [FlSpot(0, 3), FlSpot(1, 8), FlSpot(2, 4)], isCurved: true, color: AppColors.primary, barWidth: 4, dotData: const FlDotData(show: false)),
          ],
          betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 1, color: AppColors.primary.withOpacity(0.2))],
        )
    );
  }
}

// ─── УМНЫЙ МЕДИЦИНСКИЙ ДЕКОДЕР (ОРАКУЛ) ───────────────────────────────────────

class _SmartOracleText extends StatelessWidget {
  final InsightTab tab;
  final CycleProvider cycle;
  final WellnessProvider wellness;

  const _SmartOracleText({required this.tab, required this.cycle, required this.wellness});

  @override
  Widget build(BuildContext context) {
    String text = "";

    if (tab == InsightTab.cycle) {
      if (cycle.isCOCEnabled) {
        text = "You are on the Pill. Your hormones are maintained at a stable level, effectively suppressing natural ovulation. The straight line represents your fixed pill rhythm.";
      } else {
        if (cycle.isAmenorrhea) {
          text = "Alert: Your period is significantly delayed. The gap between your data and the baseline is widening. Missing periods for over 2 months requires medical attention.";
        } else if (cycle.cycleLength < 21 || cycle.cycleLength > 35) {
          text = "Your cycle deviates from the 28-day medical baseline. Irregularities can be normal, but consistent large deltas might indicate hormonal shifts.";
        } else {
          text = "Your cycle closely hugs the healthy medical baseline. Your body is maintaining a highly stable and predictable rhythm.";
        }
      }
    } else if (tab == InsightTab.mood) {
      text = "The filled area shows how far your mood deviates from a neutral baseline. It's perfectly natural to see a drop toward the end of your cycle due to decreasing progesterone.";
    } else if (tab == InsightTab.flow) {
      if (cycle.hasProlongedBleeding) {
        text = "Warning: Your recent bleeding has lasted longer than typical baselines (8+ days). Prolonged heavy flow can lead to fatigue. Stay hydrated.";
      } else {
        text = "Your flow intensity matches a textbook healthy pattern, peaking early and tapering off cleanly. The delta is well within normal bounds.";
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CupertinoIcons.sparkles, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
        )
      ],
    );
  }
}