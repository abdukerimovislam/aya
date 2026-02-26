import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../shared/widgets/premium_glass_card.dart';

class DashboardInsightCard extends StatelessWidget {
  final CycleData data;
  final AppLocalizations l10n;

  const DashboardInsightCard({super.key, required this.data, required this.l10n});

  @override
  Widget build(BuildContext context) {
    String title, subtitle;
    switch (data.phase) {
      case CyclePhase.menstruation: title = "Rest & Reset"; subtitle = "Your hormones are at their lowest. Focus on hydration."; break;
      case CyclePhase.follicular: title = "Energy Rising"; subtitle = "Estrogen is climbing. Great time for complex tasks."; break;
      case CyclePhase.ovulation: title = "Peak Vitality"; subtitle = "You are glowing. Best time for high-intensity workouts."; break;
      case CyclePhase.luteal: title = "Wind Down"; subtitle = "Progesterone is high. Cravings and mood swings are normal."; break;
      case CyclePhase.late: title = "Cycle Delayed"; subtitle = "Your period is late. Stress could be a factor."; break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click); // Аудио-отклик
        showGeneralDialog(
          context: context, barrierColor: Colors.black.withOpacity(0.4), barrierDismissible: true, barrierLabel: "Insight", transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => _ExpandedInsightDialog(data: data),
        );
      },
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(20), borderRadius: 32,
        child: Row(
          children: [
            // 🔥 Живая сфера энергии вместо иконки
            _EnergyOrb(phase: data.phase),
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
}

// 🔥 ЖИВОЙ ОРБ ЭНЕРГИИ
class _EnergyOrb extends StatefulWidget {
  final CyclePhase phase;
  const _EnergyOrb({required this.phase});

  @override
  State<_EnergyOrb> createState() => _EnergyOrbState();
}

class _EnergyOrbState extends State<_EnergyOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Скорость пульсации зависит от фазы (Овуляция = быстро, Месячные = медленно)
    int durationMs = widget.phase == CyclePhase.ovulation ? 1500 : (widget.phase == CyclePhase.menstruation ? 4000 : 2500);
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: durationMs))..repeat(reverse: true);
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
        return Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE94057).withOpacity(0.3 + (_controller.value * 0.4)), // Пульсация света
                  blurRadius: 10 + (_controller.value * 15), // Пульсация радиуса
                  spreadRadius: _controller.value * 4,
                )
              ]
          ),
        );
      },
    );
  }
}

class _ExpandedInsightDialog extends StatelessWidget {
  final CycleData data;
  const _ExpandedInsightDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(milliseconds: 300), curve: Curves.easeOutBack,
          builder: (context, val, child) => Transform.scale(
            scale: 0.9 + (0.1 * val),
            child: Opacity(
              opacity: val.clamp(0.0, 1.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(CupertinoIcons.sparkles, color: AppColors.primary, size: 32)),
                    const SizedBox(height: 24),
                    Text("Ayla Daily Insight", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    _buildInsightSection("🧠 Hormones", "Estrogen and Progesterone are fluctuating. You might feel a bit sensitive today.", CupertinoIcons.waveform_path),
                    const SizedBox(height: 16),
                    _buildInsightSection("🥑 Nutrition", "Focus on iron-rich foods and complex carbs to sustain energy.", CupertinoIcons.leaf_arrow_circlepath),
                    const SizedBox(height: 16),
                    _buildInsightSection("🏃‍♀️ Activity", "Keep it light. Yoga or stretching is highly recommended.", CupertinoIcons.heart_circle),
                    const SizedBox(height: 32),
                    SizedBox(width: double.infinity, child: CupertinoButton(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(20), onPressed: () => Navigator.pop(context), child: Text("Got it", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white))))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightSection(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 4), Text(desc, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4))]))
      ],
    );
  }
}