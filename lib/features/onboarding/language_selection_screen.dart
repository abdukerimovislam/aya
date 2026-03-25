import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';


class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    final languages = [
      {'code': 'en', 'name': l10n.languageNameEnglish, 'flag': '🇺🇸'},
      {'code': 'ru', 'name': l10n.languageNameRussian, 'flag': '🇷🇺'},
      {'code': 'es', 'name': l10n.languageNameSpanish, 'flag': '🇪🇸'},
      {'code': 'de', 'name': l10n.languageNameGerman, 'flag': '🇩🇪'},
      {'code': 'pt', 'name': l10n.languageNamePortugueseBrazil, 'flag': '🇧🇷'},
      {'code': 'tr', 'name': l10n.languageNameTurkish, 'flag': '🇹🇷'},
      {'code': 'pl', 'name': l10n.languageNamePolish, 'flag': '🇵🇱'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Заголовок
            Text(
              l10n.languageSelectionTitle,
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.languageSelectionSubtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const Spacer(flex: 1),

            // Список языков
            Expanded(
              flex: 6,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: languages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final code = lang['code']!;
                  final name = lang['name']!;
                  final flag = lang['flag']!;
                  final isSelected = settings.locale.languageCode == code;

                  return GestureDetector(
                    onTap: () {
                      // Мгновенно меняем язык приложения
                      context.read<SettingsProvider>().setLocale(Locale(code));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.black12,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Флаг
                          Text(
                            flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 16),

                          // Название языка
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // Галочка
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(flex: 1),

            // Кнопка продолжить
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Переход к Онбордингу
                    Navigator.of(context).pushReplacementNamed('/onboarding');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    l10n.btnNext,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
