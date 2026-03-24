import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/partner_sync_service.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/live_phase_background.dart';
import '../../data/models/cycle_model.dart'; // Для CyclePhase

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Ayla for Partners", style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
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
                    _buildMainStatusCard(phase, cycleDay, daysUntil, isCoc),
                    const SizedBox(height: 24),
                    _buildAICompanionCard(phase, mood),
                    if (fertility != null) ...[
                      const SizedBox(height: 24),
                      _buildFertilityCard(fertility),
                    ],
                    const SizedBox(height: 40),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainStatusCard(CyclePhase phase, int day, int daysUntil, bool isCoc) {
    String phaseName = "Tracking...";
    Color phaseColor = AppColors.primary;

    switch (phase) {
      case CyclePhase.menstruation: phaseName = "Menstruation (Period)"; phaseColor = AppColors.menstruation; break;
      case CyclePhase.follicular: phaseName = "Follicular Phase"; phaseColor = AppColors.follicular; break;
      case CyclePhase.ovulation: phaseName = "Ovulation Phase"; phaseColor = const Color(0xFFE85D75); break;
      case CyclePhase.luteal: phaseName = "Luteal Phase (PMS)"; phaseColor = AppColors.luteal; break;
      default: break;
    }

    if (isCoc) phaseName = "Pill Cycle";

    return PremiumGlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: phaseColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(phaseName.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: phaseColor, letterSpacing: 1.0)),
          ),
          const SizedBox(height: 24),
          Text("Day $day", style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.0)),
          const SizedBox(height: 8),
          Text(
            isCoc ? "Active Pill Phase" : (daysUntil == 0 ? "Period expected today" : "Next period in ~$daysUntil days"),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAICompanionCard(CyclePhase phase, int? mood) {
    String advice = "Support your partner today!";
    String title = "AI Companion";

    if (phase == CyclePhase.menstruation) {
      advice = "Energy levels might be low today. It's a great time to offer a heating pad, order her favorite comfort food, and keep plans low-key.";
    } else if (phase == CyclePhase.follicular) {
      advice = "Estrogen is rising! She likely has more energy and feels social. Great time for a date night or outdoor activities.";
    } else if (phase == CyclePhase.luteal) {
      advice = "Progesterone is high, which can cause fatigue or PMS. Be extra patient, offer a massage, and don't take mood swings personally.";
    }

    if (mood != null && mood <= 2) {
      title = "Low Mood Detected";
      advice = "She logged a low mood today. Send a sweet message or bring her a small treat to brighten her day! 🍫";
    }

    return PremiumGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: const Color(0xFF8E71C7).withOpacity(0.6), width: 4)), borderRadius: BorderRadius.circular(24)),
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

  Widget _buildFertilityCard(String fertility) {
    bool isHigh = fertility == 'high' || fertility == 'peak';

    return PremiumGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isHigh ? Colors.redAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(CupertinoIcons.heart_circle_fill, color: isHigh ? Colors.redAccent : Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fertility Window", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  isHigh ? "Chance of conception is currently HIGH. 👶" : "Chance of conception is low right now.",
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        onPressed: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digital hug sent! 💖")));
          // TODO: В будущем можно привязать к реальному пушу через Firebase Cloud Messaging
        },
        child: Text("Send a Digital Hug 💖", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildDisconnectedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.link_circle, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text("Connection Lost", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text("Your partner has unlinked the connection.", style: GoogleFonts.inter(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.primary,
            child: const Text("Go Back"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}