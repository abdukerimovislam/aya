import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/intimacy_logging.dart';
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
  double? _suggestedTemperature;

  FlowIntensity _initialFlow = FlowIntensity.none;
  bool _initialLHPeak = false;

  late DateTime _selectedDate;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int initialDiff = today.difference(_selectedDate).inDays;
    if (initialDiff < 0) initialDiff = 0;

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
    _suggestedTemperature = null;

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
        _suggestedTemperature = lastKnownTemp;
      }
    }

    setState(() {
      _selectedDate = target;
      _isLoaded = true;
    });
  }

  void _handleDateChange(DateTime newDate) {
    if (newDate.year == _selectedDate.year &&
        newDate.month == _selectedDate.month &&
        newDate.day == _selectedDate.day) {
      return;
    }

    _handleSaveWithProtection(onSuccess: () {
      setState(() => _isSaving = false);
      _loadLog(newDate);
    });
  }

  Future<void> _handleSaveWithProtection({VoidCallback? onSuccess}) async {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;

    if (_isFutureDate) {
      if (onSuccess != null) {
        onSuccess();
      } else {
        Navigator.of(context).pop();
      }
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

    if (!cycle.isCOCEnabled) {
      if (flowChangedToBleeding) {
        final currentStart = cycle.currentData.cycleStartDate;
        final diff = _selectedDate.difference(currentStart).inDays;
        final ovDay = cycle.ovulationDay;

        if (diff > 0 && diff < 21) {
          if (diff >= (ovDay - 2) && diff <= (ovDay + 2)) {
            final confirm = await _showAsyncDialog(
              title: l10n.symptomLogCycleWarningTitle,
              message: l10n.symptomLogOvulationSpottingWarningBody,
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.purple,
              confirmText: l10n.symptomLogResetStartCycleAction,
              cancelText: l10n.symptomLogJustSpottingAction,
            );
            if (confirm) {
              shouldForceStartPeriod = true;
            } else {
              _convertToSpotting();
            }
          } else {
            final confirm = await _showAsyncDialog(
              title: l10n.symptomLogCycleWarningTitle,
              message: l10n.symptomLogShortCycleWarningBody,
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.orange,
              confirmText: l10n.symptomLogResetStartCycleAction,
              cancelText: l10n.symptomLogJustSpottingAction,
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
              title: l10n.symptomLogCycleWarningTitle,
              message: l10n.symptomLogNewPeriodWarningBody,
              icon: CupertinoIcons.drop_fill,
              color: AppColors.menstruation,
              confirmText: l10n.symptomLogStartNewCycleAction,
              cancelText: l10n.btnCancel,
            );
            if (confirm) {
              shouldForceStartPeriod = true;
            } else {
              return;
            }
          }
        }
      } else if (flowRemoved) {
        final currentPhase = cycle.getPhaseForDate(_selectedDate);
        if (currentPhase == CyclePhase.menstruation) {
          final confirm = await _showAsyncDialog(
            title: l10n.symptomLogCycleWarningTitle,
            message: l10n.symptomLogRemoveBleedingWarningBody,
            icon: CupertinoIcons.drop,
            color: Colors.orangeAccent,
            confirmText: l10n.symptomLogRemoveAction,
            cancelText: l10n.btnCancel,
          );
          if (!confirm) return;
        }
      }
    }

    if (cycle.isTTCMode) {
      if (lhPeakAdded) {
        final confirm = await _showAsyncDialog(
          title: l10n.symptomLogCycleWarningTitle,
          message: l10n.symptomLogLhPeakAddedWarningBody,
          icon: CupertinoIcons.sparkles,
          color: Colors.purple,
          confirmText: l10n.symptomLogConfirmShiftAction,
          cancelText: l10n.btnCancel,
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
          title: l10n.symptomLogCycleWarningTitle,
          message: l10n.symptomLogLhPeakRemovedWarningBody,
          icon: CupertinoIcons.xmark_circle_fill,
          color: Colors.orangeAccent,
          confirmText: l10n.symptomLogRemoveAction,
          cancelText: l10n.btnCancel,
        );
        if (!confirm) return;
      }
    }

    await _executeSaveAndClose(
      forceStartPeriod: shouldForceStartPeriod,
      confirmOvulation: shouldConfirmOvulation,
      onSuccess: onSuccess,
    );
  }

  void _convertToSpotting() {
    setState(() {
      final s = List<String>.from(_log.symptoms);
      if (!s.contains('Spotting')) s.add('Spotting');
      _log = _log.copyWith(flow: FlowIntensity.none, symptoms: s);
    });
  }

  Future<void> _executeSaveAndClose({
    bool forceStartPeriod = false,
    bool confirmOvulation = false,
    VoidCallback? onSuccess,
  }) async {
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
        backgroundColor: AppColors.tintedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx, false);
            },
            child: Text(
              cancelText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(ctx, true);
            },
            child: Text(
              confirmText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showConflictWarning(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFB86A22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildDateRoulette(bool isTTC, AppLocalizations? l10n) {
    final activeColor = isTTC ? Colors.purple : AppColors.primary;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return SizedBox(
      height: 84,
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 365,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final date = today.subtract(Duration(days: index));
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return GestureDetector(
            onTap: () => _handleDateChange(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 58,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor
                    : isToday
                    ? activeColor.withValues(alpha: 0.08)
                    : AppColors.tintedSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? activeColor
                      : isToday
                      ? activeColor.withValues(alpha: 0.28)
                      : AppColors.divider,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.26),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  )
                ]
                    : [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: -4,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday
                        ? (l10n?.btnToday ?? 'Today').toUpperCase()
                        : DateFormat('E', l10n?.localeName).format(date).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: isToday ? 9 : 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.92)
                          : isToday
                          ? activeColor
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${date.day}",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
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
    final l10n = AppLocalizations.of(context)!;
    final cycle = context.watch<CycleProvider>();
    final bool isTTC = cycle.appMode == AppMode.ttc;
    final dateStr = DateFormat('MMMM d, yyyy').format(_selectedDate);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final List<String> physicalOptions = [
      'Cramps',
      'Headache',
      'Bloating',
      'Acne',
      'Tender Breasts',
      'Backache',
      'Nausea',
      'Fatigue',
    ];

    final List<String> mentalOptions = [
      'Anxious',
      'Irritable',
      'Crying Spells',
      'Brain Fog',
      'Happy',
      'Focused',
      'Calm',
    ];

    final List<String> otherOptions = [
      'Spotting',
      'Alcohol',
      'Travel',
      'High Stress',
      'Sick',
      'Exercise',
      'Poor Diet',
    ];

    final List<String> mucusOptions = [
      'Dry Mucus',
      'Sticky Mucus',
      'Creamy Mucus',
      'Egg-white Mucus',
    ];

    final List<String> lhTestOptions = [
      'LH: Negative',
      'LH: High',
      'LH: Peak',
    ];

    final List<String> sexOptions = [
      'Intimacy',
      'High Libido',
    ];

    final Color accent = isTTC ? Colors.purple : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            width: 52,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: PremiumGlassCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              borderRadius: 26,
              showAmbientGlow: true,
              showAccentLine: false,
              phaseAware: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.18)),
                    ),
                    child: Icon(
                      _isFutureDate ? CupertinoIcons.sparkles : CupertinoIcons.waveform_path_ecg,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFutureDate
                              ? l10n.symptomLogFuturePredictionTitle
                              : l10n.logSymptomsTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isSaving
                      ? const Padding(
                    padding: EdgeInsets.only(top: 10, right: 6),
                    child: CupertinoActivityIndicator(),
                  )
                      : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _handleSaveWithProtection(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Text(
                        l10n.profileDoneAction,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildDateRoulette(isTTC, l10n),
          const SizedBox(height: 14),

          Divider(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.08)),

          if (_isFutureDate)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: PremiumGlassCard(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 28,
                    showAmbientGlow: true,
                    showAccentOrb: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
                          ),
                          child: Icon(
                            CupertinoIcons.sparkles,
                            size: 46,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          l10n.symptomLogFutureTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.symptomLogFutureBody,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_isLoaded)
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18, 18, 18, 28 + bottomInset),
                children: [
                  if (isTTC) ...[
                    PremiumGlassCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: 24,
                      showAmbientGlow: true,
                      showAccentLine: true,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.purple.withValues(alpha: 0.18)),
                            ),
                            child: const Icon(
                              CupertinoIcons.heart_circle_fill,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.symptomLogTtcAiTitle,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.symptomLogTtcAiBody,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],

                  _buildSectionBlock(
                    title: l10n.symptomLogSectionBleedingTitle,
                    subtitle: l10n.symptomLogSectionBleedingBody,
                    icon: CupertinoIcons.drop_fill,
                    accent: AppColors.menstruation,
                    child: _buildFlowSelector(),
                  ),
                  const SizedBox(height: 18),

                  _buildSectionBlock(
                    title: l10n.symptomLogSectionBbtTitle,
                    subtitle: l10n.symptomLogSectionBbtBody,
                    icon: CupertinoIcons.thermometer,
                    accent: Colors.redAccent,
                    child: _buildBBTInput(),
                  ),
                  const SizedBox(height: 18),

                  if (isTTC) ...[
                    _buildSectionBlock(
                      title: l10n.symptomLogSectionOpkTitle,
                      subtitle: l10n.symptomLogSectionOpkBody,
                      icon: CupertinoIcons.sparkles,
                      accent: Colors.purple,
                      child: _buildSymptomGrid(
                        lhTestOptions,
                        false,
                        isTTC: true,
                        customColor: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildSectionBlock(
                      title: l10n.symptomLogSectionMucusTitle,
                      subtitle: l10n.symptomLogSectionMucusBody,
                      icon: CupertinoIcons.drop_triangle_fill,
                      accent: Colors.teal,
                      child: _buildSymptomGrid(
                        mucusOptions,
                        false,
                        isTTC: true,
                        customColor: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // 🔥 ИНТИМНЫЙ КАЛЕНДАРЬ ТЕПЕРЬ ДОСТУПЕН ВСЕМ (Вынесен из блока if (isTTC))
                  _buildSectionBlock(
                    title: l10n.symptomLogSectionIntimacyTitle,
                    subtitle: isTTC
                        ? l10n.symptomLogSectionIntimacyTtcBody
                        : l10n.symptomLogSectionIntimacyBody,
                    icon: CupertinoIcons.heart_fill,
                    accent: Colors.pinkAccent,
                    child: _buildSymptomGrid(
                      sexOptions,
                      false,
                      isTTC: isTTC,
                      customColor: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildSectionBlock(
                    title: l10n.symptomLogSectionVitalsTitle,
                    subtitle: l10n.symptomLogSectionVitalsBody,
                    icon: CupertinoIcons.waveform_path_ecg,
                    accent: accent,
                    child: Column(
                      children: [
                        _buildVitalSlider(
                          l10n.lblMood,
                          _log.mood,
                              (v) => setState(() => _log = _log.copyWith(mood: v.toInt())),
                          CupertinoIcons.smiley,
                          isTTC,
                        ),
                        _buildVitalSlider(
                          l10n.lblEnergy,
                          _log.energy,
                              (v) => setState(() => _log = _log.copyWith(energy: v.toInt())),
                          CupertinoIcons.bolt_fill,
                          isTTC,
                        ),
                        _buildVitalSlider(
                          l10n.catSleep,
                          _log.sleep,
                              (v) => setState(() => _log = _log.copyWith(sleep: v.toInt())),
                          CupertinoIcons.moon_stars_fill,
                          isTTC,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildSectionBlock(
                    title: l10n.symptomLogSectionPhysicalTitle,
                    subtitle: l10n.symptomLogSectionPhysicalBody,
                    icon: CupertinoIcons.bandage_fill,
                    accent: AppColors.primary,
                    child: _buildSymptomGrid(
                      physicalOptions,
                      true,
                      isTTC: false,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildSectionBlock(
                    title: l10n.symptomLogSectionMentalTitle,
                    subtitle: l10n.symptomLogSectionMentalBody,
                    icon: CupertinoIcons.person_crop_circle,
                    accent: const Color(0xFF8E71C7),
                    child: _buildSymptomGrid(
                      mentalOptions,
                      false,
                      isTTC: false,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildSectionBlock(
                    title: l10n.symptomLogSectionOtherTitle,
                    subtitle: l10n.symptomLogSectionOtherBody,
                    icon: CupertinoIcons.square_grid_2x2_fill,
                    accent: const Color(0xFF9A7B73),
                    child: _buildSymptomGrid(
                      otherOptions,
                      false,
                      isTTC: false,
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(
              child: Center(child: CupertinoActivityIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionBlock({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Widget child,
  }) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      showAmbientGlow: true,
      showAccentLine: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.16)),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
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
                    _showConflictWarning(
                      AppLocalizations.of(context)!.symptomLogMenstruationConflictRemoved,
                    );
                  }
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.menstruation
                    : AppColors.secondaryBackground.withValues(alpha: 0.7),
                border: Border.all(
                  color: isSelected
                      ? AppColors.menstruation
                      : AppColors.textSecondary.withValues(alpha: 0.16),
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: AppColors.menstruation.withValues(alpha: 0.26),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -3,
                  )
                ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    f['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBBTInput() {
    final l10n = AppLocalizations.of(context)!;
    final hasLoggedTemperature = _log.temperature != null && _log.temperature! > 0.0;
    double currentTemp = hasLoggedTemperature
        ? _log.temperature!
        : (_suggestedTemperature ?? 36.60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.16)),
                ),
                child: const Icon(
                  CupertinoIcons.thermometer,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${currentTemp.toStringAsFixed(2)} °C",
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    hasLoggedTemperature
                        ? l10n.symptomLogBbtMeasuredLabel
                        : (_suggestedTemperature != null
                            ? l10n.symptomLogBbtSuggestedLabel
                            : l10n.symptomLogBbtMeasuredLabel),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildStepperButton(
                icon: CupertinoIcons.minus,
                background: AppColors.tintedSurface,
                borderColor: AppColors.divider,
                iconColor: AppColors.textSecondary,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _suggestedTemperature = null;
                    _log = _log.copyWith(
                      temperature: (currentTemp - 0.05).clamp(35.0, 40.0),
                    );
                  });
                },
              ),
              const SizedBox(width: 10),
              _buildStepperButton(
                icon: CupertinoIcons.add,
                background: Colors.redAccent.withValues(alpha: 0.10),
                borderColor: Colors.redAccent.withValues(alpha: 0.18),
                iconColor: Colors.redAccent,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _suggestedTemperature = null;
                    _log = _log.copyWith(
                      temperature: (currentTemp + 0.05).clamp(35.0, 40.0),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required Color background,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  Widget _buildVitalSlider(
      String label,
      int value,
      Function(double) onChanged,
      IconData icon,
      bool isTTC,
      ) {
    final activeColor = isTTC ? Colors.purple : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activeColor.withValues(alpha: 0.12)),
              ),
              child: Icon(icon, color: activeColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "$value/5",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: activeColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: activeColor,
                      inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.12),
                      thumbColor: activeColor,
                      overlayColor: activeColor.withValues(alpha: 0.16),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
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

  Widget _buildSymptomGrid(
      List<String> options,
      bool isPain, {
        required bool isTTC,
        Color? customColor,
      }) {
    final selectedList = isPain ? _log.painSymptoms : _log.symptoms;
    final activeColor = customColor ?? (isTTC ? Colors.purple : AppColors.primary);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((symptom) {
        final isSelected = symptom == genericIntimacySymptom
            ? _log.hasAnyIntimacy
            : selectedList.contains(symptom);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              final list = List<String>.from(selectedList);

              if (isSelected) {
                if (symptom == genericIntimacySymptom) {
                  list.removeWhere(isIntimacySymptom);
                } else {
                  list.remove(symptom);
                }
              } else {
                if (symptom.startsWith("LH:")) {
                  list.removeWhere((e) => e.startsWith("LH:"));
                }
                if (symptom.contains("Mucus")) {
                  list.removeWhere((e) => e.contains("Mucus"));
                }
                if (symptom == genericIntimacySymptom) {
                  list.removeWhere(isIntimacySymptom);
                  list.add(genericIntimacySymptom);
                } else {
                  list.add(symptom);
                }

                if (symptom == 'LH: Peak' && _log.flow != FlowIntensity.none) {
                  _log = _log.copyWith(flow: FlowIntensity.none);
                  _showConflictWarning(
                    AppLocalizations.of(context)!.symptomLogBleedingRemovedOvulationConflict,
                  );
                }

                if (symptom.contains('Mucus') && _log.flow != FlowIntensity.none) {
                  _log = _log.copyWith(flow: FlowIntensity.none);
                  _showConflictWarning(
                    AppLocalizations.of(context)!.symptomLogBleedingRemovedMucusConflict,
                  );
                }
              }

              if (isPain) {
                _log = _log.copyWith(painSymptoms: list);
              } else {
                _log = _log.copyWith(symptoms: list);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor
                  : AppColors.secondaryBackground.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : AppColors.textSecondary.withValues(alpha: 0.14),
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                )
              ]
                  : [],
            ),
            child: Text(
              symptom,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
