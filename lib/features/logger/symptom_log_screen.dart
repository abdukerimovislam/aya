import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/wellness_provider.dart';
import '../../data/providers/cycle_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/premium_glass_card.dart';

class SymptomLogScreen extends StatefulWidget {
  final DateTime date;

  const SymptomLogScreen({super.key, required this.date});

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  late SymptomLog _currentLog;
  late FlowIntensity _initialFlow;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WellnessProvider>(context, listen: false);
    _currentLog = provider.getLogForDate(widget.date);
    _initialFlow = _currentLog.flow;
  }

  // 🔥 ИСПРАВЛЕННАЯ МЕДИЦИНСКАЯ СИНХРОНИЗАЦИЯ
  Future<void> _saveAndClose() async {
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final wellnessProvider = Provider.of<WellnessProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    await wellnessProvider.saveLog(_currentLog);

    // Если пользователь ИЗМЕНИЛ статус выделений
    if (_currentLog.flow != _initialFlow) {
      final currentPhase = cycleProvider.getPhaseForDate(widget.date);
      final isCurrentlyPeriodDay = currentPhase == CyclePhase.menstruation;

      // Сценарий 1: Добавили выделения (а их не было)
      if (_currentLog.flow != FlowIntensity.none && _initialFlow == FlowIntensity.none) {

        // ВАЖНО: Если этот день И ТАК считается днем месячных (например, юзер уже нажал кнопку на главном экране),
        // нам НЕ НУЖНО стартовать новый цикл. Просто сохраняем интенсивность (что мы уже сделали выше).
        if (!isCurrentlyPeriodDay) {
          // Если это НЕ день месячных, пытаемся начать новый цикл
          final result = await cycleProvider.logActionStartPeriod(widget.date);

          // Если алгоритм выявил аномалию (рано или овуляция), спрашиваем юзера
          if (result == CycleLogResult.suspiciouslyEarly || result == CycleLogResult.ovulationBleeding) {
            setState(() => _isSaving = false);
            if (mounted) _showMedicalInterceptorDialog(context, widget.date, result, cycleProvider);
            return; // Ждем ответа, не закрываем экран
          }
        }
      }
      // Сценарий 2: Убрали выделения (поставили None, а раньше было)
      else if (_currentLog.flow == FlowIntensity.none && _initialFlow != FlowIntensity.none) {
        // Если день сейчас считается днем крови, отключаем его
        if (isCurrentlyPeriodDay) {
          await cycleProvider.togglePeriodDay(widget.date);
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showMedicalInterceptorDialog(BuildContext context, DateTime date, CycleLogResult result, CycleProvider provider) {
    HapticFeedback.heavyImpact();
    final isOvulation = result == CycleLogResult.ovulationBleeding;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: isOvulation ? Colors.purple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(
                  isOvulation ? CupertinoIcons.sparkles : CupertinoIcons.exclamationmark_triangle_fill,
                  color: isOvulation ? Colors.purple : Colors.orange
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  isOvulation ? "Ovulation Bleeding?" : "Are you sure?",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)
              ),
            ),
          ],
        ),
        content: Text(
          isOvulation
              ? "Light bleeding can occur during ovulation. Are you sure you want to start a completely new cycle here?"
              : "It's been less than 21 days since your last cycle started. Is this a new period, or just spotting?",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.lightImpact();
              await provider.togglePeriodDay(date); // Просто мазня, не начинаем новый цикл
              if (mounted) Navigator.pop(context);
            },
            child: Text("Just Spotting", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.menstruation, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await provider.logActionStartPeriod(date, isConfirmed: true); // Принудительно начинаем цикл
              if (mounted) Navigator.pop(context);
            },
            child: Text("New Period", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleSymptom(String symptom, bool isPain) {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
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
        SystemSound.play(SystemSoundType.click);
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
        SystemSound.play(SystemSoundType.click);
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