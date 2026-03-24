import 'package:flutter/foundation.dart';
import '../../core/services/ai_oracle_service.dart';
import 'cycle_provider.dart';
import 'wellness_provider.dart';

class ChatProvider extends ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  List<Map<String, String>> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void addMessage(String message, {bool isUser = true}) {
    _messages.add({
      'role': isUser ? 'user' : 'model',
      'content': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String text, CycleProvider cycleProvider, WellnessProvider wellnessProvider) async {
    if (text.trim().isEmpty) return;

    addMessage(text, isUser: true);
    _isLoading = true;
    notifyListeners();

    // Получаем свежие логи для контекста
    final logs = wellnessProvider.getLogHistory();
    logs.sort((a, b) => b.date.compareTo(a.date)); // Свежие первыми

    final response = await AiOracleService.chatWithAyla(
      userMessage: text,
      chatHistory: _messages.length > 5 ? _messages.sublist(_messages.length - 5) : _messages, // Передаем последние 5 сообщений
      currentPhase: cycleProvider.currentData.phase.toString().split('.').last,
      currentDay: cycleProvider.currentData.currentDay,
      recentLogs: logs,
      isCoc: cycleProvider.isCOCEnabled,
    );

    addMessage(response, isUser: false);
    _isLoading = false;
    notifyListeners();
  }
}