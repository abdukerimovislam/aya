import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class PackSelectionDialog extends StatefulWidget {
  final int currentSelection;
  final Function(int) onSelect;

  const PackSelectionDialog({
    super.key,
    required this.currentSelection,
    required this.onSelect,
  });

  @override
  State<PackSelectionDialog> createState() => _PackSelectionDialogState();
}

class _PackSelectionDialogState extends State<PackSelectionDialog> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    // Мы ожидаем коды пачек:
    // 21 -> 21 активная + 7 дней перерыва (21 слотов в блистере)
    // 28 -> 21 активная + 7 плацебо (28 слотов в блистере)
    // 24 -> 24 активные + 4 плацебо (28 слотов в блистере)
    // 0  -> 28 активных, без перерыва / Мини-пили (28 слотов в блистере)
    _selected = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Text(
                    l10n.dialogPackTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dialogPackSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 24),

                  // 1: Классика с перерывом (Ярина, Жанин)
                  _PackOptionCard(
                    title: "21 Pills",
                    subtitle: "21 Active + 7 Days Break",
                    icon: Icons.pause_circle_outline_rounded,
                    color: const Color(0xFFFF8A80),
                    isSelected: _selected == 21,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = 21);
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2: Классика с плацебо (Мидиана)
                  _PackOptionCard(
                    title: "28 Pills (21+7)",
                    subtitle: "21 Active + 7 Placebo",
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFF69F0AE),
                    isSelected: _selected == 28,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = 28);
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3: Укороченный перерыв (Джес, Yaz)
                  _PackOptionCard(
                    title: "28 Pills (24+4)",
                    subtitle: "24 Active + 4 Placebo",
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFF42A5F5), // Голубой акцент
                    isSelected: _selected == 24,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = 24);
                    },
                  ),
                  const SizedBox(height: 12),

                  // 🔥 4: Мини-пили / Непрерывный режим (Лактинет)
                  _PackOptionCard(
                    title: "Continuous / Mini-Pill",
                    subtitle: "28 Active (No Break)",
                    icon: Icons.all_inclusive_rounded,
                    color: Colors.deepPurpleAccent,
                    isSelected: _selected == 0, // 0 = специальный код для непрерывных
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = 0);
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onSelect(_selected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.btnSaveSettings,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PackOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Сделал чуть тоньше для экономии места
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.textSecondary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary.withOpacity(0.5),
                size: 20, // Уменьшил иконку, чтобы текст лучше влезал
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}