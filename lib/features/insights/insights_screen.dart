import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/dna_comparison.dart';
import 'widgets/liquid_mood_chart.dart';
import 'widgets/neural_radar.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';

// 🔥 Обновленный импорт
import '../../shared/widgets/live_phase_background.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();

    final radarData = wellnessProvider.calculateRadarData(cycleProvider);
    final fValues = radarData['follicular'] ?? [0, 0, 0, 0, 0];
    final lValues = radarData['luteal'] ?? [0, 0, 0, 0, 0];

    // 🔥 ИСПОЛЬЗУЕМ НОВЫЙ ФОН В STACK
    return Stack(
      children: [
        Positioned.fill(
          child: LivePhaseBackground(
            phase: cycleProvider.currentData.phase,
            isCOC: cycleProvider.isCOCEnabled,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              l10n.tabInsights,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 10),
                NeuralRadarChart(
                  fValues: fValues,
                  lValues: lValues,
                  l10n: l10n,
                ),
                const SizedBox(height: 24),
                LiquidMoodChart(
                  wellness: wellnessProvider,
                  l10n: l10n,
                ),
                const SizedBox(height: 24),
                DnaComparisonCard(
                  fValues: fValues,
                  lValues: lValues,
                  l10n: l10n,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }
}