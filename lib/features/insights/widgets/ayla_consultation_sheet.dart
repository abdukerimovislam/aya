import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/ai_aura_visualizer.dart';

class AylaConsultationSheet extends StatefulWidget {
  final String insightText; // Текст ответа от нейросети

  const AylaConsultationSheet({
    super.key,
    required this.insightText,
  });

  @override
  State<AylaConsultationSheet> createState() => _AylaConsultationSheetState();
}

class _AylaConsultationSheetState extends State<AylaConsultationSheet> {
  String _displayedText = "";
  int _currentIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    // Начинаем печатать текст через полсекунды после открытия окна
    Future.delayed(const Duration(milliseconds: 500), () {
      _startTyping();
    });
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) return;

      if (_currentIndex < widget.insightText.length) {
        setState(() {
          _displayedText += widget.insightText[_currentIndex];
          _currentIndex++;
        });

        // Каждые 4 символа делаем легкий тактильный отклик (эффект печати)
        if (_currentIndex % 4 == 0) {
          HapticFeedback.selectionClick();
        }
      } else {
        _typingTimer?.cancel(); // Текст закончился
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Сделаем окно высоким, чтобы магии было больше места
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: Stack(
          children: [
            // 1. ЗАДНИЙ ФОН: Безграничная живая Аура Ayla
            // Больше не передаем 'size', так как она заполняет весь Stack
            Positioned.fill(
              child: AiAuraVisualizer(
                isThinking: _displayedText.length < widget.insightText.length,
              ),
            ),

            // 2. ПЕРЕДНИЙ ПЛАН: Текст и элементы управления
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Хэндл (светлый, так как фон теперь темный неоновый)
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Пустое пространство, чтобы центральная пульсирующая искра была видна
                    const Spacer(),

                    // Текстовый блок (с легким затемнением градиентом снизу, чтобы текст идеально читался поверх неоновых вспышек)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 40,
                        bottom: 32,
                        left: 24,
                        right: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF120E18).withOpacity(0.8),
                            const Color(0xFF120E18),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ayla's Advice",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Текст ответа
                          Text(
                            _displayedText + (_displayedText.length < widget.insightText.length ? " ▎" : ""),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Кнопка "Got it" (Стеклянная, чтобы не перебивать неон)
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Got it, Ayla",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}