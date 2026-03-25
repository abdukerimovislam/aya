import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../core/services/ai_oracle_service.dart';
import '../../l10n/app_localizations.dart';
import 'cycle_provider.dart';
import 'wellness_provider.dart';

class ChatProvider with ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String text, CycleProvider cycle, WellnessProvider wellness, AppLocalizations l10n) async {
    if (text.trim().isEmpty) return;

    _messages.add({'role': 'user', 'content': text.trim()});
    _isLoading = true;
    notifyListeners();

    try {
      // 🔥 ИСПРАВЛЕНИЕ 1: Ищем логи СТРОГО за сегодняшний день, чтобы избежать галлюцинаций ИИ
      final today = DateTime.now();
      final todayLogs = wellness.getLogHistory().where((l) =>
      l.date.year == today.year && l.date.month == today.month && l.date.day == today.day
      ).toList();

      // 🔥 ИСПРАВЛЕНИЕ 2: Безопасно берем последние 5 сообщений из истории (не включая текущий запрос)
      final history = _messages.length > 1
          ? _messages.sublist(math.max(0, _messages.length - 6), _messages.length - 1)
          : <Map<String, String>>[];

      final response = await AiOracleService.chatWithAyla(
        userMessage: text.trim(),
        chatHistory: history,
        currentPhase: cycle.currentData.phase.toString().split('.').last,
        currentDay: cycle.currentData.dayOfCycle,
        recentLogs: todayLogs,
        isCoc: cycle.isCOCEnabled,
      );

      _messages.add({'role': 'model', 'content': response});
    } catch (e) {
      _messages.add({
        'role': 'model',
        'content': l10n.chatConnectionIssue,
      });
    } finally {
      // 🔥 ИСПРАВЛЕНИЕ: Гарантированное снятие блокировки UI при любых сбоях сети!
      _isLoading = false;
      notifyListeners();
    }
  }
}
