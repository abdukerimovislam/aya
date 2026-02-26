import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/wellness_provider.dart';

// 🔥 Обновленный импорт
import '../../shared/widgets/premium_glass_card.dart';

class SymptomLogScreen extends StatefulWidget {
  final DateTime date;

  const SymptomLogScreen({super.key, required this.date});

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  late SymptomLog _currentLog;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WellnessProvider>(context, listen: false);
    _currentLog = provider.getLogForDate(widget.date);
  }

  Future<void> _saveAndClose() async {
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final provider = Provider.of<WellnessProvider>(context, listen: false);
    await provider.saveLog(_currentLog);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _toggleSymptom(String symptom, bool isPain) {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click); // 🔥 АУДИО-КЛИК
    setState(() {
      if (isPain) {
        final list = List<String>.from(_currentLog.painSymptoms);
        list.contains(symptom) ? list.remove(symptom) : list.add(symptom);
        _currentLog = _currentLog.copyWith(painSymptoms: list);
      } else {
        final list = List<String>.from(_currentLog.symptoms);
        list.contains(symptom) ? list.remove(symptom) : list.add(symptom);
        _currentLog = _currentLog.copyWith(symptoms: list);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.clear, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DateFormat('MMMM d, yyyy', l10n.localeName).format(widget.date),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(child: CupertinoActivityIndicator()),
            )
          else
            TextButton(
              onPressed: _saveAndClose,
              child: Text(
                l10n.btnSave ?? "Save",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              l10n.logFlow.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 12),
            // 🔥 Заменили VisionCard на PremiumGlassCard
            PremiumGlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFlowButton(FlowIntensity.light, l10n.flowLight, l10n),
                  _buildFlowButton(FlowIntensity.medium, l10n.flowMedium, l10n),
                  _buildFlowButton(FlowIntensity.heavy, l10n.flowHeavy, l10n),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.logMood.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 12),
            // 🔥 Заменили VisionCard на PremiumGlassCard
            PremiumGlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoodEmoji(1, "😭"),
                  _buildMoodEmoji(2, "😟"),
                  _buildMoodEmoji(3, "😐"),
                  _buildMoodEmoji(4, "🙂"),
                  _buildMoodEmoji(5, "🤩"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.logPain.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSymptomChip('cramps', l10n.painCramps, true),
                _buildSymptomChip('headache', l10n.painHeadache, true),
                _buildSymptomChip('backache', l10n.painBack, true),
                _buildSymptomChip('tender_breasts', "Tender Breasts", true),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              l10n.logSymptoms.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSymptomChip('bloating', l10n.symptomBloating, false),
                _buildSymptomChip('acne', l10n.symptomAcne, false),
                _buildSymptomChip('nausea', l10n.symptomNausea, false),
                _buildSymptomChip('fatigue', "Fatigue", false),
                _buildSymptomChip('insomnia', "Insomnia", false),
              ],
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowButton(FlowIntensity flow, String label, AppLocalizations l10n) {
    final isSelected = _currentLog.flow == flow;
    final color = AppColors.menstruation;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        SystemSound.play(SystemSoundType.click); // 🔥 АУДИО-КЛИК
        setState(() {
          _currentLog = _currentLog.copyWith(
            flow: isSelected ? FlowIntensity.none : flow,
          );
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? color : AppColors.textSecondary.withOpacity(0.2), width: 2),
            ),
            child: Icon(
              CupertinoIcons.drop_fill,
              color: isSelected ? color : AppColors.textSecondary.withOpacity(0.5),
              size: flow == FlowIntensity.light ? 20 : (flow == FlowIntensity.medium ? 26 : 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEmoji(int level, String emoji) {
    final isSelected = _currentLog.mood == level;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        SystemSound.play(SystemSoundType.click); // 🔥 АУДИО-КЛИК
        setState(() {
          _currentLog = _currentLog.copyWith(
            mood: isSelected ? 3 : level,
          );
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: isSelected ? 32 : 24),
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String key, String label, bool isPain) {
    final isSelected = isPain ? _currentLog.painSymptoms.contains(key) : _currentLog.symptoms.contains(key);
    final activeColor = isPain ? Colors.redAccent : AppColors.primary;

    return GestureDetector(
      onTap: () => _toggleSymptom(key, isPain),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.5) : Colors.white,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? activeColor : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}