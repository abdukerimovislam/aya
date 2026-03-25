import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/partner_sync_service.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/cycle_model.dart'; // Для CyclePhase

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.partnerDashboardTitle, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: PartnerSyncService.partnerDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildDisconnectedState(context);
          }

          final data = snapshot.data!.data()!;
          final state = data['shared_state'] as Map<String, dynamic>? ?? {};

          // Безопасное извлечение данных
          final phaseStr = state['phase'] ?? 'none';
          final CyclePhase phase = CyclePhase.values.firstWhere(
                (e) => e.toString().split('.').last == phaseStr,
            orElse: () => CyclePhase.follicular, // 🔥 Исправлено на follicular
          );          final int cycleDay = state['cycle_day'] ?? 1;
          final int daysUntil = state['days_until_next_period'] ?? 0;
          final bool isCoc = state['is_coc'] ?? false;
          final int? mood = state['mood'];
          final String? fertility = state['fertility_chance'];

          return Stack(
            children: [
              Positioned.fill(child: LivePhaseBackground(phase: phase, isCOC: isCoc)),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMainStatusCard(l10n, phase, cycleDay, daysUntil, isCoc),
                    const SizedBox(height: 24),
                    _buildAICompanionCard(l10n, phase, mood),
                    if (fertility != null) ...[
                      const SizedBox(height: 24),
                      _buildFertilityCard(l10n, fertility),
                    ],
                    const SizedBox(height: 40),
                    _buildActionButton(context, l10n),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainStatusCard(AppLocalizations l10n, CyclePhase phase, int day, int daysUntil, bool isCoc) {
    String phaseName = l10n.partnerStatusTracking;
    Color phaseColor = AppColors.primary;

    switch (phase) {
      case CyclePhase.menstruation: phaseName = l10n.partnerPhaseMenstruation; phaseColor = AppColors.menstruation; break;
      case CyclePhase.follicular: phaseName = l10n.partnerPhaseFollicular; phaseColor = AppColors.follicular; break;
      case CyclePhase.ovulation: phaseName = l10n.partnerPhaseOvulation; phaseColor = const Color(0xFFE85D75); break;
      case CyclePhase.luteal: phaseName = l10n.partnerPhaseLuteal; phaseColor = AppColors.luteal; break;
      default: break;
    }

    if (isCoc) phaseName = l10n.partnerPhasePill;

    return PremiumGlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: phaseColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(phaseName.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: phaseColor, letterSpacing: 1.0)),
          ),
          const SizedBox(height: 24),
          Text(l10n.dayOfCycle(day), style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.0)),
          const SizedBox(height: 8),
          Text(
            isCoc
                ? l10n.cocActivePhase
                : (daysUntil == 0 ? l10n.partnerPeriodExpectedToday : l10n.partnerNextPeriodInDays(daysUntil)),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAICompanionCard(AppLocalizations l10n, CyclePhase phase, int? mood) {
    String advice = l10n.partnerAdviceDefault;
    String title = l10n.partnerCompanionTitle;

    if (phase == CyclePhase.menstruation) {
      advice = l10n.partnerAdviceMenstruation;
    } else if (phase == CyclePhase.follicular) {
      advice = l10n.partnerAdviceFollicular;
    } else if (phase == CyclePhase.luteal) {
      advice = l10n.partnerAdviceLuteal;
    }

    if (mood != null && mood <= 2) {
      title = l10n.partnerCompanionLowMoodTitle;
      advice = l10n.partnerAdviceLowMood;
    }

    return PremiumGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: const Color(0xFF8E71C7).withValues(alpha: 0.6), width: 4)), borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.sparkles, color: Color(0xFF8E71C7), size: 20),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            Text(advice, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilityCard(AppLocalizations l10n, String fertility) {
    bool isHigh = fertility == 'high' || fertility == 'peak';

    return PremiumGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isHigh ? Colors.redAccent.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(CupertinoIcons.heart_circle_fill, color: isHigh ? Colors.redAccent : Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.partnerFertilityTitle, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  isHigh ? l10n.partnerFertilityHigh : l10n.partnerFertilityLow,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        onPressed: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.partnerHugSent)));
          // TODO: В будущем можно привязать к реальному пушу через Firebase Cloud Messaging
        },
        child: Text(l10n.partnerSendHug, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildDisconnectedState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.link_circle, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.partnerDisconnectedTitle, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(l10n.partnerDisconnectedBody, style: GoogleFonts.inter(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.primary,
            child: Text(l10n.partnerGoBack),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
