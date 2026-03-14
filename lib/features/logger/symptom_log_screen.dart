import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../shared/widgets/premium_glass_card.dart';

class SymptomLogScreen extends StatefulWidget {
  final DateTime date;

  const SymptomLogScreen({super.key, required this.date});

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  late SymptomLog _log;
  bool _isLoaded = false;
  bool _isFutureDate = false;
  bool _isSaving = false;

  FlowIntensity _initialFlow = FlowIntensity.none;

  @override
  void initState() {
    super.initState();
    _checkFutureDate();
    if (!_isFutureDate) {
      _loadLog();
    }
  }

  void _checkFutureDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(widget.date.year, widget.date.month, widget.date.day);

    if (target.isAfter(today)) {
      _isFutureDate = true;
    }
  }

  void _loadLog() {
    final wellness = context.read<WellnessProvider>();
    _log = wellness.getLogForDate(widget.date);
    _initialFlow = _log.flow;
    setState(() => _isLoaded = true);
  }

  Future<void> _saveAndClose() async {
    HapticFeedback.lightImpact();

    if (_isFutureDate) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);

    final wellness = context.read<WellnessProvider>();
    final cycle = context.read<CycleProvider>();

    await wellness.saveLog(_log);

    if (_log.flow != _initialFlow) {
      final currentPhase = cycle.getPhaseForDate(widget.date);
      final isCurrentlyPeriodDay = currentPhase == CyclePhase.menstruation;

      final isNowMenstruation = _log.flow == FlowIntensity.light ||
          _log.flow == FlowIntensity.medium ||
          _log.flow == FlowIntensity.heavy;

      if (isNowMenstruation && !isCurrentlyPeriodDay) {
        final result = await cycle.logActionStartPeriod(widget.date);

        if (result == CycleLogResult.suspiciouslyEarly || result == CycleLogResult.ovulationBleeding) {
          setState(() => _isSaving = false);
          if (mounted) _showMedicalInterceptorDialog(context, widget.date, result, cycle);
          return;
        }
      }
      else if (!isNowMenstruation && isCurrentlyPeriodDay) {
        await cycle.togglePeriodDay(widget.date);
      }
    }

    if (mounted) Navigator.of(context).pop();
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
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)
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
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.lightImpact();

              final wellness = context.read<WellnessProvider>();
              final updatedSymptoms = List<String>.from(_log.symptoms);
              if (!updatedSymptoms.contains('Spotting')) {
                updatedSymptoms.add('Spotting');
              }

              wellness.saveLog(_log.copyWith(
                flow: FlowIntensity.none,
                symptoms: updatedSymptoms,
              ));

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
              await provider.logActionStartPeriod(date, isConfirmed: true);
              if (mounted) Navigator.pop(context);
            },
            child: Text("New Period", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cycle = context.watch<CycleProvider>();
    final bool isTTC = cycle.appMode == AppMode.ttc;
    final dateStr = DateFormat('MMMM d, yyyy').format(widget.date);

    final List<String> physicalOptions = ['Cramps', 'Headache', 'Bloating', 'Acne', 'Tender Breasts', 'Backache', 'Nausea', 'Fatigue'];
    final List<String> mentalOptions = ['Anxious', 'Irritable', 'Crying Spells', 'Brain Fog', 'Happy', 'Focused', 'Calm'];
    final List<String> otherOptions = ['Spotting', 'Alcohol', 'Travel', 'High Stress', 'Sick', 'Exercise', 'Poor Diet'];

    // TTC Specific Options
    final List<String> mucusOptions = ['Dry Mucus', 'Sticky Mucus', 'Creamy Mucus', 'Egg-white Mucus'];
    final List<String> lhTestOptions = ['LH: Negative', 'LH: High', 'LH: Peak'];
    final List<String> sexOptions = ['Unprotected Sex', 'Protected Sex', 'High Libido'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isFutureDate ? "Future Prediction" : (l10n?.logSymptomsTitle ?? "Daily Log"),
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                _isSaving
                    ? const Padding(padding: EdgeInsets.only(right: 16), child: CupertinoActivityIndicator())
                    : CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _saveAndClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isTTC ? Colors.purple : AppColors.primary, // Premium TTC Color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Done",
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.1)),

          if (_isFutureDate)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.sparkles, size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "The Future is Bright",
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You cannot log symptoms for future dates. Check your calendar to see predictions for your upcoming phases.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_isLoaded)
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [

                  // 🔥 PREMIUM TTC BANNER
                  if (isTTC) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.pink.shade50]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(CupertinoIcons.heart_circle_fill, color: Colors.purple),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("TTC AI Intelligence", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
                                Text("Log BBT and LH tests below to maximize conception chances.", style: GoogleFonts.inter(fontSize: 12, color: Colors.purple.shade900, height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Месячные
                  _buildSectionTitle("Bleeding & Flow"),
                  const SizedBox(height: 12),
                  _buildFlowSelector(),
                  const SizedBox(height: 32),

                  // 🔥 СПЕЦИАЛЬНЫЕ TTC ИНСТРУМЕНТЫ
                  if (isTTC) ...[
                    _buildSectionTitle("Basal Body Temp (BBT)"),
                    const SizedBox(height: 12),
                    _buildBBTInput(),
                    const SizedBox(height: 32),

                    _buildSectionTitle("Ovulation Tests (OPK)"),
                    const SizedBox(height: 12),
                    _buildSymptomGrid(lhTestOptions, false, isTTC: true, customColor: Colors.purple),
                    const SizedBox(height: 32),

                    _buildSectionTitle("Cervical Mucus"),
                    const SizedBox(height: 12),
                    _buildSymptomGrid(mucusOptions, false, isTTC: true, customColor: Colors.teal),
                    const SizedBox(height: 32),

                    _buildSectionTitle("Intercourse & Libido"),
                    const SizedBox(height: 12),
                    _buildSymptomGrid(sexOptions, false, isTTC: true, customColor: Colors.pinkAccent),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionTitle("Vitals"),
                  const SizedBox(height: 12),
                  _buildVitalSlider("Mood", _log.mood, (v) => setState(() => _log = _log.copyWith(mood: v.toInt())), CupertinoIcons.smiley, isTTC),
                  _buildVitalSlider("Energy", _log.energy, (v) => setState(() => _log = _log.copyWith(energy: v.toInt())), CupertinoIcons.bolt_fill, isTTC),
                  _buildVitalSlider("Sleep", _log.sleep, (v) => setState(() => _log = _log.copyWith(sleep: v.toInt())), CupertinoIcons.moon_stars_fill, isTTC),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Physical Symptoms"),
                  const SizedBox(height: 12),
                  _buildSymptomGrid(physicalOptions, true, isTTC: false),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Mental & Emotional"),
                  const SizedBox(height: 12),
                  _buildSymptomGrid(mentalOptions, false, isTTC: false),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Other Factors"),
                  const SizedBox(height: 12),
                  _buildSymptomGrid(otherOptions, false, isTTC: false),

                  const SizedBox(height: 60),
                ],
              ),
            )
          else
            const Expanded(child: Center(child: CupertinoActivityIndicator())),
        ],
      ),
    );
  }

  // --- UI Builders ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    );
  }

  Widget _buildFlowSelector() {
    final flows = [
      {'val': FlowIntensity.none, 'icon': CupertinoIcons.drop, 'label': 'None'},
      {'val': FlowIntensity.light, 'icon': CupertinoIcons.drop_fill, 'label': 'Light'},
      {'val': FlowIntensity.medium, 'icon': CupertinoIcons.drop_fill, 'label': 'Medium'},
      {'val': FlowIntensity.heavy, 'icon': CupertinoIcons.drop_fill, 'label': 'Heavy'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: flows.map((f) {
          final isSelected = _log.flow == f['val'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _log = _log.copyWith(flow: f['val'] as FlowIntensity));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.menstruation : AppColors.background,
                border: Border.all(color: isSelected ? AppColors.menstruation : AppColors.textSecondary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.menstruation.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Row(
                children: [
                  Icon(f['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    f['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🔥 КОМПОНЕНТ ВВОДА БАЗАЛЬНОЙ ТЕМПЕРАТУРЫ
  Widget _buildBBTInput() {
    double currentTemp = _log.temperature ?? 36.60;
    if (currentTemp == 0.0) currentTemp = 36.60;

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.thermometer, color: Colors.redAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                "${currentTemp.toStringAsFixed(2)} °C",
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -1),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _log = _log.copyWith(temperature: (currentTemp - 0.05).clamp(35.0, 40.0)));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
                  child: Icon(CupertinoIcons.minus, size: 20, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _log = _log.copyWith(temperature: (currentTemp + 0.05).clamp(35.0, 40.0)));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.purple.withOpacity(0.2))),
                  child: const Icon(CupertinoIcons.add, size: 20, color: Colors.purple),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVitalSlider(String label, int value, Function(double) onChanged, IconData icon, bool isTTC) {
    final activeColor = isTTC ? Colors.purple : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: activeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: activeColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text("$value/5", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: activeColor, fontSize: 12)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: activeColor,
                      inactiveTrackColor: AppColors.textSecondary.withOpacity(0.1),
                      thumbColor: activeColor,
                      overlayColor: activeColor.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: 1, max: 5, divisions: 4,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        onChanged(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomGrid(List<String> options, bool isPain, {required bool isTTC, Color? customColor}) {
    final selectedList = isPain ? _log.painSymptoms : _log.symptoms;
    final activeColor = customColor ?? (isTTC ? Colors.purple : AppColors.primary);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((symptom) {
        final isSelected = selectedList.contains(symptom);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              final list = List<String>.from(selectedList);
              if (isSelected) {
                list.remove(symptom);
              } else {
                // Эксклюзивный выбор для специфичных групп TTC (чтобы нельзя было выбрать "Peak" и "Negative" одновременно)
                if (symptom.startsWith("LH:")) {
                  list.removeWhere((e) => e.startsWith("LH:"));
                }
                if (symptom.contains("Mucus")) {
                  list.removeWhere((e) => e.contains("Mucus"));
                }
                list.add(symptom);
              }

              if (isPain) {
                _log = _log.copyWith(painSymptoms: list);
              } else {
                _log = _log.copyWith(symptoms: list);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? activeColor : AppColors.textSecondary.withOpacity(0.2)),
            ),
            child: Text(
              symptom,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}