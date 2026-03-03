import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();
    final l10n = AppLocalizations.of(context);

    // Логика данных
    List<MapEntry<String, int>> topSymptoms = _getTopSymptoms(wellnessProvider);
    bool hasEnoughData = cycleProvider.history.length >= 2;

    return Stack(
      children: [
        // 🔥 Живой Атмосферный Фон
        Positioned.fill(
          child: Container(color: AppColors.background),
        ),
        // Мягкие цветовые пятна для глубины (Blobs)
        Positioned(top: -100, right: -50, child: _Blob(color: AppColors.primary.withOpacity(0.15), size: 300)),
        Positioned(bottom: 100, left: -100, child: _Blob(color: Colors.redAccent.withOpacity(0.08), size: 400)),

        // Матовое стекло поверх пятен
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent, // Прозрачный для фона Stack
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "B I O R H Y T H M",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // Акцентный заголовок
                      _buildSectionHeader("Hormonal Statisics"),
                      const SizedBox(height: 20),

                      // Новые высокие карточки
                      _buildMetricsGrid(cycleProvider),
                      const SizedBox(height: 32),

                      // Шапка графика
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader("Cycle Trends"),
                          if (hasEnoughData)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                  "Last ${cycleProvider.history.length > 6 ? 6 : cycleProvider.history.length}",
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Глянцевый график
                      PremiumGlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 30,
                        child: SizedBox(
                          height: 240,
                          child: hasEnoughData
                              ? _buildCycleBarChart(cycleProvider)
                              : _buildEmptyState("Log at least 2 cycles to establish your hormonal baseline."),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // БЛОК 3: ПАТТЕРНЫ
                      _buildSectionHeader("Body Patterns"),
                      const SizedBox(height: 16),

                      // Глянцевые чипы симптомов
                      topSymptoms.isEmpty
                          ? PremiumGlassCard(borderRadius: 24, padding: const EdgeInsets.all(24), child: _buildEmptyState("Track daily symptoms to unlock personalized AI patterns."))
                          : Column(
                        children: topSymptoms.map((entry) => _buildSymptomCard(entry.key, entry.value)).toList(),
                      ),

                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── ОБЩИЕ ЭЛЕМЕНТЫ УЛУЧШЕНИЯ ──────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
        title,
        style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5
        )
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.lock_shield, size: 40, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
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

  // ─── УЛУЧШЕНИЕ: МЕТРИКИ (ВЫСОКИЕ БАШНИ) ──────────────────────────────────────

  Widget _buildMetricsGrid(CycleProvider cycle) {
    return Row(
      children: [
        Expanded(
          child: _MetricTowerCard(
            title: "Cycle Length",
            value: "${cycle.cycleLength}",
            unit: "days",
            icon: CupertinoIcons.arrow_2_circlepath,
            mainColor: AppColors.follicular,
            isAnomalous: cycle.cycleLength < 21 || cycle.cycleLength > 35,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricTowerCard(
            title: "Period Duration",
            value: "${cycle.avgPeriodDuration}",
            unit: "days",
            icon: CupertinoIcons.drop_fill,
            mainColor: Colors.redAccent,
            isAnomalous: cycle.hasProlongedBleeding,
          ),
        ),
      ],
    );
  }

  // ─── УЛУЧШЕНИЕ: ГРАФИК ЦИКЛОВ (СОЧНЫЕ КОЛБЫ) ───────────────────────────

  Widget _buildCycleBarChart(CycleProvider cycle) {
    final history = cycle.history.reversed.take(6).toList().reversed.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 45, minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.textPrimary.withOpacity(0.9),
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "${rod.toY.toInt()} days",
                GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
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
                // Прячем C1, C2, оставляем только точки
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), shape: BoxShape.circle)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true, drawVerticalLine: false, horizontalInterval: 14,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textSecondary.withOpacity(0.06), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(history.length, (index) {
          final cycleLength = history[index].length?.toDouble() ?? 28.0;
          final isAnomalous = cycleLength < 21 || cycleLength > 35;
          final Color barColor = isAnomalous ? Colors.orangeAccent : AppColors.primary;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: cycleLength,
                // Вертикальный градиент
                gradient: LinearGradient(
                  colors: [barColor.withOpacity(0.5), barColor],
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                ),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)),
                // Глянцевая подложка
                backDrawRodData: BackgroundBarChartRodData(
                  show: true, toY: 45, color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 1000), // Исправлено с 'duration'
      swapAnimationCurve: Curves.easeOutQuint,                   // Исправлено с 'curve'
    );
  }

  // ─── УЛУЧШЕНИЕ: ПАТТЕРНЫ (ГЛЯНЦЕВЫЕ ЧИПЫ) ──────────────────────────────────

  Widget _buildSymptomCard(String symptomName, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: 20,
        child: Row(
          children: [
            // Иконка в градиентном круге
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.02)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(CupertinoIcons.waveform_path, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                symptomName[0].toUpperCase() + symptomName.substring(1).toLowerCase(),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
              ),
            ),
            // Счётчик как футуристичный бабл
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.textPrimary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
              ),
              child: Text(
                "$count",
                style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Логика
  List<MapEntry<String, int>> _getTopSymptoms(WellnessProvider wellness) {
    Map<String, int> counts = {};
    final today = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final log = wellness.getLogForDate(date);
        if (log != null && log.symptoms.isNotEmpty) {
          for (var sym in log.symptoms) {
            counts[sym] = (counts[sym] ?? 0) + 1;
          }
        }
      } catch (_) {}
    }
    var sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }
}

// ─── НОВЫЙ КОМПОНЕНТ: МЕТРИКА-БАШНЯ (TOWER CARD) ──────────────────────────

class _MetricTowerCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color mainColor;
  final bool isAnomalous;

  const _MetricTowerCard({
    required this.title, required this.value, required this.unit,
    required this.icon, required this.mainColor, required this.isAnomalous
  });

  @override
  Widget build(BuildContext context) {
    final Color displayColor = isAnomalous ? Colors.orangeAccent : mainColor;

    return PremiumGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D-подобная иконка в круге
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: displayColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: displayColor.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: displayColor, size: 22),
          ),
          const SizedBox(height: 32),
          // Большое, футуристичное число
          Text(
              value,
              style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                  letterSpacing: -1
              )
          ),
          const SizedBox(height: 4),
          // Единица измерения
          Text(
              unit.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: displayColor, letterSpacing: 1.0)
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.textSecondary.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          // Описание
          Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.3)
          ),
        ],
      ),
    );
  }
}

// ─── ВСПОМОГАТЕЛЬНЫЙ: АНИМИРОВАННЫЙ БЛОБ (BLOB) ───────────────────────────

class _Blob extends StatefulWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  State<_Blob> createState() => _BlobState();
}

class _BlobState extends State<_Blob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Медленная анимация дыхания
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1.0 + (_controller.value * 0.2);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}