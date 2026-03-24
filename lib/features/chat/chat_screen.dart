import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/chat_provider.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // 🔥 Добавлены переменные для отслеживания состояния скролла
  int _lastMessageCount = 0;
  bool _wasLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    final cycleProvider = context.read<CycleProvider>();
    final wellnessProvider = context.read<WellnessProvider>();

    chatProvider.sendMessage(text, cycleProvider, wellnessProvider);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;
    final currentLoading = chatProvider.isLoading;

    // 🔥 ОПТИМИЗАЦИЯ: Скроллим только если добавилось новое сообщение или изменился статус загрузки
    if (messages.length != _lastMessageCount || currentLoading != _wasLoading) {
      _lastMessageCount = messages.length;
      _wasLoading = currentLoading;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      // 🔥 ИСПРАВЛЕНИЕ: Отключаем автоматический сдвиг Scaffold, чтобы избежать двойного прыжка
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ФОНОВЫЕ СВЕЧЕНИЯ (Орбы)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8E71C7).withOpacity(0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF8E71C7).withOpacity(0.2), blurRadius: 100)],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 120)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // КАСТОМНЫЙ APPBAR
                _buildHeader(context),

                // СПИСОК СООБЩЕНИЙ
                Expanded(
                  child: messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length + (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && chatProvider.isLoading) {
                        return _buildTypingIndicator();
                      }
                      final msg = messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildMessageBubble(msg['content']!, isUser);
                    },
                  ),
                ),

                // ПОЛЕ ВВОДА
                _buildInputArea(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.6),
            border: Border(bottom: BorderSide(color: AppColors.textPrimary.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.textPrimary.withOpacity(0.05), shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF8E71C7), Color(0xFFB59EE6)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF8E71C7).withOpacity(0.4), blurRadius: 8)],
                    ),
                    child: const Center(child: Text("✨", style: TextStyle(fontSize: 20))),
                  ),
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ayla AI", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  Text("Online • Cycle Intelligence Assistant", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(CupertinoIcons.trash, size: 20, color: AppColors.textSecondary.withOpacity(0.5)),
                onPressed: () => context.read<ChatProvider>().clearChat(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8E71C7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text("✨", style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text(
              "Hi, I'm Ayla!",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              "I analyze your cycle, logs, and symptoms in real-time. Ask me anything about your current well-being, hormones, or fertility.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.tintedSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            if (isUser) BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: isUser ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.tintedSurface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8E71C7))),
            const SizedBox(width: 12),
            Text("Ayla is typing...", style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: Border(top: BorderSide(color: AppColors.textPrimary.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.textPrimary.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Ask Ayla...",
                  hintStyle: GoogleFonts.inter(color: AppColors.textSecondary.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: context.watch<ChatProvider>().isLoading ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: context.watch<ChatProvider>().isLoading ? [Colors.grey, Colors.grey] : [const Color(0xFF8E71C7), AppColors.primary]),
                shape: BoxShape.circle,
                boxShadow: [
                  if (!context.watch<ChatProvider>().isLoading)
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}