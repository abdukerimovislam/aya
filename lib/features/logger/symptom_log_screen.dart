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
  bool _initialLHPeak = false;

  late DateTime _selectedDate;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    // Инициализация выбранной даты (обрезаем время для точности)
    _selectedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);

    // Вычисляем смещение для рулетки
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int initialDiff = today.difference(_selectedDate).inDays;
    if (initialDiff < 0) initialDiff = 0; // Будущие даты фокусируем на "Сегодня"

    // Ширина карточки = 52, отступ = 12. Итого шаг 64.
    _scrollController = ScrollController(initialScrollOffset: initialDiff * 64.0);

    _loadLog(_selectedDate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLog(DateTime d) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final target = DateTime(d.year, d.month, d.day);
    _isFutureDate = target.isAfter(today);

    if (_isFutureDate) {
      setState(() {
        _selectedDate = target;
        _isLoaded = true;
      });
      return;
    }

    final wellness = context.read<WellnessProvider>();
    _log = wellness.getLogForDate(target);
    _initialFlow = _log.flow;
    _initialLHPeak = _log.symptoms.contains('LH: Peak');

    // 🔥 РЕШЕНИЕ "АМНЕЗИИ ГРАДУСНИКА": Ищем последнюю известную температуру
    if (_log.temperature == null || _log.temperature == 0.0) {
      double? lastKnownTemp;
      for (int i = 1; i <= 7; i++) {
        final pastLog = wellness.getLogForDate(target.subtract(Duration(days: i)));
        if (pastLog.temperature != null && pastLog.temperature! > 0.0) {
          lastKnownTemp = pastLog.temperature;
          break;
        }
      }
      if (lastKnownTemp != null) {
        _log = _log.copyWith(temperature: lastKnownTemp);
      }
    }

    setState(() {
      _selectedDate = target;
      _isLoaded = true;
    });
  }

  // Смена даты через Рулетку
  void _handleDateChange(DateTime newDate) {
    if (newDate.year == _selectedDate.year &&
        newDate.month == _selectedDate.month &&
        newDate.day == _selectedDate.day) {
      return;
    }

    // Сохраняем текущий день (с проверкой) перед переходом к следующему
    _handleSaveWithProtection(onSuccess: () {
      setState(() => _isSaving = false);
      _loadLog(newDate);
    });
  }

  // 🔥 МАТРИЦА ЗАЩИТЫ МУТАЦИЙ С ПОДДЕРЖКОЙ CALLBACK'ОВ
  Future<void> _handleSaveWithProtection({VoidCallback? onSuccess}) async {
    HapticFeedback.lightImpact();

    if (_isFutureDate) {
      if (onSuccess != null) onSuccess();
      else Navigator.of(context).pop();
      return;
    }

    final cycle = context.read<CycleProvider>();

    final bool isNowMenstruation = _log.flow != FlowIntensity.none;
    final bool wasMenstruation = _initialFlow != FlowIntensity.none;

    final bool flowChangedToBleeding = isNowMenstruation && !wasMenstruation;
    final bool flowRemoved = !isNowMenstruation && wasMenstruation;

    final bool isNowLHPeak = _log.symptoms.contains('LH: Peak');
    final bool lhPeakAdded = isNowLHPeak && !_initialLHPeak;
    final bool lhPeakRemoved = !isNowLHPeak && _initialLHPeak;

    bool shouldForceStartPeriod = false;
    bool shouldConfirmOvulation = false;

    // --- ПРОВЕРКА 1: КРОВЬ ---
    if (!cycle.isCOCEnabled) {
      if (flowChangedToBleeding) {
        final currentStart = cycle.currentData.cycleStartDate;
        final diff = _selectedDate.difference(currentStart).inDays;
        final ovDay = cycle.ovulationDay;

        if (diff > 0 && diff < 21) {
          if (diff >= (ovDay - 2) && diff <= (ovDay + 2)) {
            final confirm = await _showAsyncDialog(
              title: "Cycle Update Warning",
              message: "Light bleeding is common during ovulation. Logging this as a New Period will reset your entire cycle predictions. Do you want to start a new cycle, or log this as spotting?",
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.purple,
              confirmText: "Reset & Start New Cycle",
              cancelText: "Just Spotting",
            );
            if (confirm) {
              shouldForceStartPeriod = true;
            } else {
              _convertToSpotting();
            }
          } else {
            final confirm = await _showAsyncDialog(
              title: "Cycle Update Warning",
              message: "It's been less than 21 days since your last period. Logging this as a New Period will dramatically alter your cycle averages and predictions. Are you sure?",
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.orange,
              confirmText: "Reset & Start New Cycle",
              cancelText: "Just Spotting",
            );
            if (confirm) {
              shouldForceStartPeriod = true;
            } else {
              _convertToSpotting();
            }
          }
        } else {
          final currentPhase = cycle.getPhaseForDate(_selectedDate);
          if (currentPhase != CyclePhase.menstruation) {
            final confirm = await _showAsyncDialog(
              title: "Cycle Update Warning",
              message: "This input will end your current cycle and generate new predictions for your next phases. Are you sure you want to log a New Period today?",
              icon: CupertinoIcons.drop_fill,
              color: AppColors.menstruation,
              confirmText: "Yes, start new cycle",
              cancelText: "Cancel",
            );
            if (confirm) {
              shouldForceStartPeriod = true;
            } else {
              return;
            }
          }
        }
      }
      else if (flowRemoved) {
        final currentPhase = cycle.getPhaseForDate(_selectedDate);
        if (currentPhase == CyclePhase.menstruation) {
          final confirm = await _showAsyncDialog(
            title: "Cycle Update Warning",
            message: "Removing bleeding from a logged period day will recalculate your cycle history and future predictions. Are you sure?",
            icon: CupertinoIcons.drop,
            color: Colors.orangeAccent,
            confirmText: "Remove it",
            cancelText: "Cancel",
          );
          if (!confirm) return;
        }
      }
    }

    // --- ПРОВЕРКА 2: ПИК ЛГ (только в TTC) ---
    if (cycle.isTTCMode) {
      if (lhPeakAdded) {
        final confirm = await _showAsyncDialog(
          title: "Cycle Update Warning",
          message: "Logging an LH Peak will immediately shift your predicted ovulation day and adjust your fertile window. Proceed?",
          icon: CupertinoIcons.sparkles,
          color: Colors.purple,
          confirmText: "Confirm Shift",
          cancelText: "Cancel",
        );
        if (confirm) {
          shouldConfirmOvulation = true;
        } else {
          setState(() {
            final s = List<String>.from(_log.symptoms);
            s.remove('LH: Peak');
            _log = _log.copyWith(symptoms: s);
          });
        }
      } else if (lhPeakRemoved) {
        final confirm = await _showAsyncDialog(
          title: "Cycle Update Warning",
          message: "Removing the LH Peak will revert your ovulation predictions back to standard AI calculations. Are you sure?",
          icon: CupertinoIcons.xmark_circle_fill,
          color: Colors.orangeAccent,
          confirmText: "Remove it",
          cancelText: "Cancel",
        );
        if (!confirm) return;
      }
    }

    await _executeSaveAndClose(
        forceStartPeriod: shouldForceStartPeriod,
        confirmOvulation: shouldConfirmOvulation,
        onSuccess: onSuccess
    );
  }

  void _convertToSpotting() {
    setState(() {
      final s = List<String>.from(_log.symptoms);
      if (!s.contains('Spotting')) s.add('Spotting');
      _log = _log.copyWith(flow: FlowIntensity.none, symptoms: s);
    });
  }

  Future<void> _executeSaveAndClose({bool forceStartPeriod = false, bool confirmOvulation = false, VoidCallback? onSuccess}) async {
    setState(() => _isSaving = true);

    final wellness = context.read<WellnessProvider>();
    final cycle = context.read<CycleProvider>();

    await wellness.saveLog(_log);

    if (cycle.isTTCMode) {
      if (confirmOvulation || _log.symptoms.contains('LH: Peak')) {
        await cycle.confirmOvulation(_selectedDate.add(const Duration(days: 1)), source: 'lh');
      } else if (!_log.symptoms.contains('LH: Peak') && _initialLHPeak) {
        await cycle.clearOvulationIfMatchesLHTestDate(_selectedDate);
      }

      if (_log.temperature != null && _log.temperature! > 0.0) {
        final allLogs = wellness.getLogHistory();
        final tempHistory = allLogs
            .where((l) => l.temperature != null && l.temperature! > 0)
            .map((l) => MapEntry(l.date, l.temperature!))
            .toList();

        await cycle.tryAutoConfirmOvulationFromBBT(tempHistory);
      }
    }

    if (!cycle.isCOCEnabled) {
      if (forceStartPeriod) {
        await cycle.logActionStartPeriod(_selectedDate, isConfirmed: true);
      } else if (_log.flow != _initialFlow) {
        final currentPhase = cycle.getPhaseForDate(_selectedDate);
        final isCurrentlyPeriodDay = currentPhase == CyclePhase.menstruation;
        final isNowMenstruation = _log.flow != FlowIntensity.none;

        if (!isNowMenstruation && isCurrentlyPeriodDay) {
          await cycle.togglePeriodDay(_selectedDate);
        } else if (isNowMenstruation && isCurrentlyPeriodDay) {
          await cycle.togglePeriodDay(_selectedDate);
          await cycle.togglePeriodDay(_selectedDate);
        }
      }
    }

    if (onSuccess != null) {
      onSuccess();
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<bool> _showAsyncDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String confirmText,
    required String cancelText,
  }) async {
    HapticFeedback.heavyImpact();
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx, false);
            },
            child: Text(cancelText, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(ctx, true);
            },
            child: Text(confirmText, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showConflictWarning(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // 🔥 ГОРИЗОНТАЛЬНАЯ РУЛЕТКА ДАТ
  Widget _buildDateRoulette(bool isTTC, AppLocalizations? l10n) {
    final activeColor = isTTC ? Colors.purple : AppColors.primary;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return SizedBox(
      height: 76,
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // Сегодня будет справа
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 365, // Позволяем листать на год назад
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final date = today.subtract(Duration(days: index));
          final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () => _handleDateChange(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? activeColor : AppColors.textSecondary.withOpacity(0.15)),
                boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', l10n?.localeName).format(date).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${date.day}",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cycle = context.watch<CycleProvider>();
    final bool isTTC = cycle.appMode == AppMode.ttc;
    final dateStr = DateFormat('MMMM d, yyyy').format(_selectedDate);

    final List<String> physicalOptions = ['Cramps', 'Headache', 'Bloating', 'Acne', 'Tender Breasts', 'Backache', 'Nausea', 'Fatigue'];
    final List<String> mentalOptions = ['Anxious', 'Irritable', 'Crying Spells', 'Brain Fog', 'Happy', 'Focused', 'Calm'];
    final List<String> otherOptions = ['Spotting', 'Alcohol', 'Travel', 'High Stress', 'Sick', 'Exercise', 'Poor Diet'];

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
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 48, height: 5,
            decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isFutureDate ? "Future Prediction" : (l10n?.logSymptomsTitle ?? "Daily Log"), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text(dateStr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ],
                ),
                _isSaving
                    ? const Padding(padding: EdgeInsets.only(right: 16), child: CupertinoActivityIndicator())
                    : CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _handleSaveWithProtection(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: isTTC ? Colors.purple : AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: Text("Done", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildDateRoulette(isTTC, l10n),
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
                      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(CupertinoIcons.sparkles, size: 48, color: AppColors.primary)),
                      const SizedBox(height: 24),
                      Text("The Future is Bright", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Text("You cannot log symptoms for future dates. Select a past date to enter records.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5)),
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
                  if (isTTC) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.pink.shade50]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(CupertinoIcons.heart_circle_fill, color: Colors.purple)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("TTC AI Intelligence", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.purple.shade900)), Text("Log BBT and LH tests below to maximize conception chances.", style: GoogleFonts.inter(fontSize: 12, color: Colors.purple.shade900, height: 1.3))])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionTitle("Bleeding & Flow"), const SizedBox(height: 12), _buildFlowSelector(), const SizedBox(height: 32),
                  _buildSectionTitle("Basal Body Temp (BBT)"), const SizedBox(height: 12), _buildBBTInput(), const SizedBox(height: 32),

                  if (isTTC) ...[
                    _buildSectionTitle("Ovulation Tests (OPK)"), const SizedBox(height: 12), _buildSymptomGrid(lhTestOptions, false, isTTC: true, customColor: Colors.purple), const SizedBox(height: 32),
                    _buildSectionTitle("Cervical Mucus"), const SizedBox(height: 12), _buildSymptomGrid(mucusOptions, false, isTTC: true, customColor: Colors.teal), const SizedBox(height: 32),
                    _buildSectionTitle("Intercourse & Libido"), const SizedBox(height: 12), _buildSymptomGrid(sexOptions, false, isTTC: true, customColor: Colors.pinkAccent), const SizedBox(height: 32),
                  ],

                  _buildSectionTitle("Vitals"), const SizedBox(height: 12),
                  _buildVitalSlider("Mood", _log.mood, (v) => setState(() => _log = _log.copyWith(mood: v.toInt())), CupertinoIcons.smiley, isTTC),
                  _buildVitalSlider("Energy", _log.energy, (v) => setState(() => _log = _log.copyWith(energy: v.toInt())), CupertinoIcons.bolt_fill, isTTC),
                  _buildVitalSlider("Sleep", _log.sleep, (v) => setState(() => _log = _log.copyWith(sleep: v.toInt())), CupertinoIcons.moon_stars_fill, isTTC),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Physical Symptoms"), const SizedBox(height: 12), _buildSymptomGrid(physicalOptions, true, isTTC: false), const SizedBox(height: 32),
                  _buildSectionTitle("Mental & Emotional"), const SizedBox(height: 12), _buildSymptomGrid(mentalOptions, false, isTTC: false), const SizedBox(height: 32),
                  _buildSectionTitle("Other Factors"), const SizedBox(height: 12), _buildSymptomGrid(otherOptions, false, isTTC: false), const SizedBox(height: 60),
                ],
              ),
            )
          else
            const Expanded(child: Center(child: CupertinoActivityIndicator())),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) { return Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)); }

  Widget _buildFlowSelector() {
    final flows = [{'val': FlowIntensity.none, 'icon': CupertinoIcons.drop, 'label': 'None'}, {'val': FlowIntensity.light, 'icon': CupertinoIcons.drop_fill, 'label': 'Light'}, {'val': FlowIntensity.medium, 'icon': CupertinoIcons.drop_fill, 'label': 'Medium'}, {'val': FlowIntensity.heavy, 'icon': CupertinoIcons.drop_fill, 'label': 'Heavy'}];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
      child: Row(children: flows.map((f) {
        final isSelected = _log.flow == f['val'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _log = _log.copyWith(flow: f['val'] as FlowIntensity);

              if (_log.flow != FlowIntensity.none) {
                final s = List<String>.from(_log.symptoms);
                bool hasConflict = false;

                if (s.contains('LH: Peak')) {
                  s.remove('LH: Peak');
                  hasConflict = true;
                }

                if (s.any((e) => e.contains('Mucus'))) {
                  s.removeWhere((e) => e.contains('Mucus'));
                  hasConflict = true;
                }

                if (hasConflict) {
                  _log = _log.copyWith(symptoms: s);
                  _showConflictWarning("Menstruation logged. Incompatible symptoms (LH Peak / Mucus) removed.");
                }
              }
            });
          },
          child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isSelected ? AppColors.menstruation : AppColors.background, border: Border.all(color: isSelected ? AppColors.menstruation : AppColors.textSecondary.withOpacity(0.2)), borderRadius: BorderRadius.circular(20), boxShadow: isSelected ? [BoxShadow(color: AppColors.menstruation.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : []), child: Row(children: [Icon(f['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary), const SizedBox(width: 8), Text(f['label'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : AppColors.textPrimary))])),
        );
      }).toList()),
    );
  }

  Widget _buildBBTInput() {
    double currentTemp = _log.temperature ?? 36.60;
    if (currentTemp == 0.0) currentTemp = 36.60;
    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(CupertinoIcons.thermometer, color: Colors.redAccent, size: 24)), const SizedBox(width: 16), Text("${currentTemp.toStringAsFixed(2)} °C", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -1))]),
          Row(children: [
            GestureDetector(onTap: () { HapticFeedback.selectionClick(); setState(() => _log = _log.copyWith(temperature: (currentTemp - 0.05).clamp(35.0, 40.0))); }, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)), child: Icon(CupertinoIcons.minus, size: 20, color: AppColors.textSecondary))),
            const SizedBox(width: 12),
            GestureDetector(onTap: () { HapticFeedback.selectionClick(); setState(() => _log = _log.copyWith(temperature: (currentTemp + 0.05).clamp(35.0, 40.0))); }, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.purple.withOpacity(0.2))), child: const Icon(CupertinoIcons.add, size: 20, color: Colors.purple))),
          ])
        ],
      ),
    );
  }

  Widget _buildVitalSlider(String label, int value, Function(double) onChanged, IconData icon, bool isTTC) {
    final activeColor = isTTC ? Colors.purple : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), borderRadius: 20,
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: activeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: activeColor, size: 20)), const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)), Text("$value/5", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: activeColor, fontSize: 12))]), SliderTheme(data: SliderThemeData(trackHeight: 4, activeTrackColor: activeColor, inactiveTrackColor: AppColors.textSecondary.withOpacity(0.1), thumbColor: activeColor, overlayColor: activeColor.withOpacity(0.2), thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10)), child: Slider(value: value.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) { HapticFeedback.selectionClick(); onChanged(v); }))])),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomGrid(List<String> options, bool isPain, {required bool isTTC, Color? customColor}) {
    final selectedList = isPain ? _log.painSymptoms : _log.symptoms;
    final activeColor = customColor ?? (isTTC ? Colors.purple : AppColors.primary);
    return Wrap(
      spacing: 10, runSpacing: 10,
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
                if (symptom.startsWith("LH:")) list.removeWhere((e) => e.startsWith("LH:"));
                if (symptom.contains("Mucus")) list.removeWhere((e) => e.contains("Mucus"));
                list.add(symptom);

                if (symptom == 'LH: Peak' && _log.flow != FlowIntensity.none) {
                  _log = _log.copyWith(flow: FlowIntensity.none);
                  _showConflictWarning("Bleeding removed. Menstruation and ovulation cannot co-occur.");
                }

                if (symptom.contains('Mucus') && _log.flow != FlowIntensity.none) {
                  _log = _log.copyWith(flow: FlowIntensity.none);
                  _showConflictWarning("Bleeding removed. Cervical mucus is not tracked during menstruation.");
                }
              }
              if (isPain) _log = _log.copyWith(painSymptoms: list);
              else _log = _log.copyWith(symptoms: list);
            });
          },
          child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isSelected ? activeColor : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? activeColor : AppColors.textSecondary.withOpacity(0.2))), child: Text(symptom, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : AppColors.textPrimary))),
        );
      }).toList(),
    );
  }
}