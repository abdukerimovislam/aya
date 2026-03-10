import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // 🔥 ДОБАВЛЕНО ДЛЯ ЛОКАЛЬНЫХ ДАННЫХ
import 'package:intl/intl.dart'; // 🔥 ДОБАВЛЕНО ДЛЯ ДАТЫ

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cycle_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/premium_glass_card.dart';
import '../../../core/services/ai_oracle_service.dart';
import '../../../data/providers/wellness_provider.dart'; // 🔥 ДОБАВЛЕНО ДЛЯ СИМПТОМОВ
import '../../../data/logic/symptom_intelligence.dart'; // 🔥 ДОБАВЛЕНО ДЛЯ ЛОКАЛЬНОГО ИИ

class DashboardInsightCard extends StatefulWidget {
  final CycleData data;
  final AppLocalizations l10n;

  const DashboardInsightCard({super.key, required this.data, required this.l10n});

  @override
  State<DashboardInsightCard> createState() => _DashboardInsightCardState();
}

class _DashboardInsightCardState extends State<DashboardInsightCard> {
  bool _isRefreshing = false;

  Future<void> _refreshInsight() async {
    if (_isRefreshing) return; // Защита от двойного клика

    HapticFeedback.mediumImpact();
    setState(() => _isRefreshing = true);

    // Вызов нашего облачного ИИ-сервиса (через Cloudflare Proxy)
    await AiOracleService.fetchDailyInsight(isManual: true);

    if (mounted) {
      setState(() => _isRefreshing = false);
      SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🛡 1. ГЕНЕРАЦИЯ ЛОКАЛЬНОГО ИНСАЙТА (НА СЛУЧАЙ ОФЛАЙНА ИЛИ ОШИБКИ)
    final wellness = context.watch<WellnessProvider>();
    List<String> todaySymptoms = [];
    try {
      final log = wellness.getLogForDate(DateTime.now());
      if (log != null) todaySymptoms = log.symptoms;
    } catch (_) {}

    String localTitle = "";
    String localSubtitle = "";
    String localType = "neutral";

    // Ищем совпадения симптомов и фазы через локальный движок
    final symptomInsight = SymptomIntelligence.getInsight(context, todaySymptoms, widget.data.phase);

    if (symptomInsight != null) {
      localTitle = symptomInsight.title;
      localSubtitle = symptomInsight.description;
      localType = symptomInsight.isWarning ? "warning" : "neutral";
    } else {
      // Дефолтные фразы по фазам, если симптомов сегодня нет
      switch (widget.data.phase) {
        case CyclePhase.menstruation: localTitle = "Rest & Reset"; localSubtitle = "Your hormones are at their lowest. Focus on hydration."; localType = "warning"; break;
        case CyclePhase.follicular: localTitle = "Energy Rising"; localSubtitle = "Estrogen is climbing. Great time for complex tasks."; localType = "positive"; break;
        case CyclePhase.ovulation: localTitle = "Peak Vitality"; localSubtitle = "You are glowing. Best time for high-intensity workouts."; localType = "positive"; break;
        case CyclePhase.luteal: localTitle = "Wind Down"; localSubtitle = "Progesterone is high. Cravings and mood swings are normal."; localType = "neutral"; break;
        case CyclePhase.late: localTitle = "Cycle Delayed"; localSubtitle = "Your period is late. Stress could be a factor."; localType = "warning"; break;
      }
    }

    // Безопасно открываем бокс ИИ
    return FutureBuilder<Box>(
        future: Hive.openBox('ai_insights'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CupertinoActivityIndicator()));

          final aiBox = snapshot.data!;

          return ValueListenableBuilder<Box>(
              valueListenable: aiBox.listenable(),
              builder: (context, box, _) {

                // 🛡 2. ПРОВЕРКА: ИСПОЛЬЗОВАТЬ ОБЛАКО ИЛИ ЛОКАЛЬНЫЙ ИНСАЙТ?
                final isOffline = box.get('is_offline', defaultValue: false) as bool;
                final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                final lastUpdate = box.get('last_update_date', defaultValue: '') as String;

                // Используем локальные данные, если была ошибка сети или облако сегодня еще не обновлялось
                final bool useLocalFallback = isOffline || lastUpdate != todayStr;

                // 🚀 ДИНАМИЧЕСКИЙ UI ДЛЯ СОСТОЯНИЯ ЗАГРУЗКИ (ОЖИДАНИЯ ИИ)
                final String displayBadge = _isRefreshing
                    ? "⏳ ANALYZING..."
                    : (useLocalFallback ? "⚡ LOCAL INSIGHT" : "✨ DAILY AI");

                final String displayTitle = _isRefreshing
                    ? "Ayla is thinking..."
                    : (useLocalFallback ? localTitle : box.get('current_insight_title', defaultValue: localTitle) as String);

                final String displaySubtitle = _isRefreshing
                    ? "Analyzing your latest cycle data and symptoms to generate a personalized insight..."
                    : (useLocalFallback ? localSubtitle : box.get('current_insight_body', defaultValue: localSubtitle) as String);

                final String displayType = _isRefreshing
                    ? "neutral"
                    : (useLocalFallback ? localType : box.get('current_insight_type', defaultValue: localType) as String);

                final Color badgeColor = _isRefreshing
                    ? AppColors.textSecondary
                    : (useLocalFallback ? AppColors.textSecondary : AppColors.primary);

                return GestureDetector(
                  // Блокируем нажатие на карточку, пока ИИ думает
                  onTap: _isRefreshing ? null : () {
                    HapticFeedback.lightImpact();
                    SystemSound.play(SystemSoundType.click);
                    showGeneralDialog(
                      context: context, barrierColor: Colors.black.withOpacity(0.4), barrierDismissible: true, barrierLabel: "Insight", transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (_, __, ___) => _ExpandedInsightDialog(
                        data: widget.data,
                        aiTitle: displayTitle,
                        aiBody: displaySubtitle,
                        isLocal: useLocalFallback,
                      ),
                    );
                  },
                  child: PremiumGlassCard(
                    padding: const EdgeInsets.all(20), borderRadius: 32,
                    child: Row(
                      children: [
                        // 🔥 Живая сфера энергии (становится нейтральной во время загрузки)
                        _EnergyOrb(phase: widget.data.phase, alertType: displayType),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      displayBadge,
                                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: badgeColor)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  displayTitle,
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  displaySubtitle,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary.withOpacity(0.8), height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 🔥 Кнопка ручного обновления ИИ
                        _isRefreshing
                            ? const CupertinoActivityIndicator(radius: 12)
                            : GestureDetector(
                          onTap: _refreshInsight,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(useLocalFallback ? CupertinoIcons.cloud_download : CupertinoIcons.refresh_thick, color: badgeColor, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}

// 🔥 ЖИВОЙ ОРБ ЭНЕРГИИ
class _EnergyOrb extends StatefulWidget {
  final CyclePhase phase;
  final String alertType; // neutral, warning, positive

  const _EnergyOrb({required this.phase, required this.alertType});

  @override
  State<_EnergyOrb> createState() => _EnergyOrbState();
}

class _EnergyOrbState extends State<_EnergyOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    int durationMs = widget.phase == CyclePhase.ovulation ? 1500 : (widget.phase == CyclePhase.menstruation ? 4000 : 2500);
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: durationMs))..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _EnergyOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      int durationMs = widget.phase == CyclePhase.ovulation ? 1500 : (widget.phase == CyclePhase.menstruation ? 4000 : 2500);
      _controller.duration = Duration(milliseconds: durationMs);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Меняем градиент сферы в зависимости от того, что сказал ИИ
    List<Color> orbColors = const [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)]; // Default / Neutral
    if (widget.alertType == 'warning') {
      orbColors = const [Color(0xFF8B0000), Color(0xFFE94057), Color(0xFFFF4500)]; // Красно-оранжевый
    } else if (widget.alertType == 'positive') {
      orbColors = const [Color(0xFF00C6FF), Color(0xFF0072FF), Color(0xFF00B4DB)]; // Энергичный голубой
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: orbColors,
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: orbColors[1].withOpacity(0.3 + (_controller.value * 0.4)),
                  blurRadius: 10 + (_controller.value * 15),
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
  final String aiTitle;
  final String aiBody;
  final bool isLocal;

  const _ExpandedInsightDialog({
    required this.data,
    required this.aiTitle,
    required this.aiBody,
    required this.isLocal,
  });

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
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(isLocal ? CupertinoIcons.bolt_fill : CupertinoIcons.sparkles, color: AppColors.primary, size: 32)),
                    const SizedBox(height: 24),
                    Text(aiTitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),

                    // Показываем подпись, если инсайт сгенерирован без интернета
                    if (isLocal)
                      Text("Generated offline using your recent symptoms.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),

                    const SizedBox(height: 24),

                    // Вывод анализа
                    _buildInsightSection(isLocal ? "Local Analysis" : "Today's Analytics", aiBody, CupertinoIcons.waveform_path),

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
        Icon(icon, color: AppColors.primary, size: 24), const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(desc, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.5))
        ]))
      ],
    );
  }
}