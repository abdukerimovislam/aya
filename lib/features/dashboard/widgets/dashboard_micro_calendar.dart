import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/providers/cycle_provider.dart';
import '../../../data/providers/wellness_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/premium_glass_card.dart';

class DashboardMicroCalendar extends StatelessWidget {
  final CycleProvider provider;
  final void Function(BuildContext context, DateTime date, String heroTag) onOpenLogger;

  const DashboardMicroCalendar({super.key, required this.provider, required this.onOpenLogger});

  @override
  Widget build(BuildContext context) {
    final wellnessProvider = context.watch<WellnessProvider>();
    final today = DateTime.now();
    final dates = List.generate(7, (index) => today.subtract(Duration(days: 3 - index)));
    final l10n = AppLocalizations.of(context)!;

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      borderRadius: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dates.map((date) {
          final isToday = date.day == today.day && date.month == today.month;
          final isFuture = date.isAfter(today);
          final phase = provider.getPhaseForDate(date);
          final isPeriod = phase == CyclePhase.menstruation;
          final hasLogs = wellnessProvider.hasLogForDate(date);
          final heroTag = 'day_circle_${date.toIso8601String()}';

          return GestureDetector(
            onLongPress: isFuture ? null : () async {
              HapticFeedback.heavyImpact();
              await provider.togglePeriodDay(date);
            },
            onTap: isFuture ? null : () {
              HapticFeedback.lightImpact();
              onOpenLogger(context, date, heroTag);
            },
            child: Opacity(
              opacity: isFuture ? 0.35 : 1.0,
              child: Column(
                children: [
                  Text(DateFormat('E', l10n.localeName).format(date)[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isToday ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.7))),
                  const SizedBox(height: 12),
                  Hero(
                    tag: heroTag,
                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => DefaultTextStyle(style: DefaultTextStyle.of(toHeroContext).style, child: toHeroContext.widget),
                    child: Material(
                      type: MaterialType.transparency,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300), width: 38, height: 38,
                        decoration: BoxDecoration(color: isPeriod ? AppColors.menstruation.withOpacity(0.15) : (isToday ? Colors.white.withOpacity(0.9) : Colors.transparent), shape: BoxShape.circle, border: Border.all(color: isPeriod ? AppColors.menstruation.withOpacity(0.6) : (isToday ? Colors.white : Colors.transparent), width: isToday ? 2 : 1.5), boxShadow: isToday ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : []),
                        child: Center(child: isPeriod ? Icon(CupertinoIcons.drop_fill, color: AppColors.menstruation, size: 18) : Text("${date.day}", style: GoogleFonts.inter(fontSize: 15, fontWeight: isToday ? FontWeight.w800 : FontWeight.w600, color: AppColors.textPrimary))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 5, height: 5, decoration: BoxDecoration(color: hasLogs ? AppColors.textSecondary.withOpacity(0.6) : Colors.transparent, shape: BoxShape.circle))
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}