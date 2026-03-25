import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/medication_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/premium_glass_card.dart';

class DailyMedicationsCard extends StatelessWidget {
  final DateTime selectedDate;

  const DailyMedicationsCard({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medProvider = context.watch<MedicationProvider>();
    if (!medProvider.isLoaded) {
      return PremiumGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.medicationsLoading,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final meds = medProvider.activeMedications;

    if (meds.isEmpty) {
      return PremiumGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.capsule_fill,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicationsTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.medicationsEmptyBody,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _showAddMedicationDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.medicationsAdd,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final takenToday = medProvider.getTakenForDay(selectedDate);
    final totalCount = meds.length;
    final takenCount = takenToday.length;
    final double progress = totalCount == 0 ? 0 : takenCount / totalCount;

    String progressLabel;
    if (takenCount == 0) {
      progressLabel = l10n.medicationsProgressNone;
    } else if (takenCount == totalCount) {
      progressLabel = l10n.medicationsProgressAll;
    } else {
      progressLabel = l10n.medicationsProgressSome(takenCount, totalCount);
    }

    return PremiumGlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.capsule_fill,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.medicationsDailyIntake,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        progressLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddMedicationDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.medicationsManage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1
                            ? const Color(0xFF76C893)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$takenCount/$totalCount',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          ...meds.map((med) {
            final isTaken = takenToday.contains(med.id);
            return _buildMedicationTile(
              context,
              medProvider,
              med,
              isTaken,
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMedicationTile(
      BuildContext context,
      MedicationProvider provider,
      MedicationItem med,
      bool isTaken,
      ) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.toggleMedication(med.id, selectedDate);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isTaken
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isTaken
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isTaken ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isTaken
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.28),
                  width: 2,
                ),
              ),
              child: isTaken
                  ? const Icon(
                Icons.check_rounded,
                size: 18,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 14),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                med.iconStr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isTaken ? FontWeight.w600 : FontWeight.w800,
                      color: isTaken
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration:
                      isTaken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (med.dosage.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      med.dosage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isTaken
                  ? Container(
                key: const ValueKey('taken'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF76C893).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.medicationsTakenBadge,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              )
                  : const SizedBox(
                key: ValueKey('empty'),
                width: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ManageMedicationsSheet(),
    );
  }
}

class _ManageMedicationsSheet extends StatefulWidget {
  const _ManageMedicationsSheet();

  @override
  State<_ManageMedicationsSheet> createState() => _ManageMedicationsSheetState();
}

class _ManageMedicationsSheetState extends State<_ManageMedicationsSheet> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _selectedIcon = '💊';

  final List<String> _icons = [
    '💊',
    '💧',
    '🌿',
    '☀️',
    '💉',
    '🧪',
    '🍎',
    '⚡',
    '🩸',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medProvider = context.watch<MedicationProvider>();

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.tintedSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.medicationsManageTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                l10n.medicationsManageBody,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 22),

              if (medProvider.activeMedications.isNotEmpty) ...[
                Text(
                  l10n.medicationsCurrent,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ...medProvider.activeMedications.map(
                      (med) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            med.iconStr,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (med.dosage.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  med.dosage,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.trash,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            medProvider.removeMedication(med.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Text(
                l10n.medicationsAddNew,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    final isSelected = icon == _selectedIcon;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 10),
                        width: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.16)
                              : Colors.grey.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: l10n.medicationsNameLabel,
                  hintText: l10n.medicationsNameHint,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _dosageController,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: l10n.medicationsDosageLabel,
                  hintText: l10n.medicationsDosageHint,
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) return;

                    HapticFeedback.mediumImpact();
                    medProvider.addMedication(
                      _nameController.text.trim(),
                      _dosageController.text.trim(),
                      _selectedIcon,
                    );

                    _nameController.clear();
                    _dosageController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: Text(
                    l10n.medicationsAddButton,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
