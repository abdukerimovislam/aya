import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/providers/cycle_provider.dart';
import 'core/theme/app_theme.dart';

// 🔥 Обновленный импорт
import 'l10n/app_localizations.dart';
import 'shared/widgets/live_phase_background.dart';

// Экраны (Фичи)
import 'features/dashboard/home_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  // 🔥 ИСПРАВЛЕНИЕ: Теперь экран поддерживает старт с любого таба
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // Инициализируем стартовый индекс из параметра
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context);

    if (l10n == null) return const SizedBox.shrink();

    final List<Widget> screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 🔥 Использование нового фона
          Positioned.fill(
            child: LivePhaseBackground(
              phase: cycleProvider.currentData.phase,
              isCOC: cycleProvider.isCOCEnabled,
            ),
          ),

          // Экраны
          IndexedStack(
            index: safeIndex,
            children: screens,
          ),

          // Плавающая навигация
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: _FloatingTabBar(
                currentIndex: safeIndex,
                onTap: _onTabTapped,
                l10n: l10n,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final AppLocalizations l10n;

  const _FloatingTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))
            ],
          ),
          // 🔥 ИСПОЛЬЗУЕМ LAYOUT BUILDER ДЛЯ ЖИДКОЙ АНИМАЦИИ
          child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 4;

                return Stack(
                  children: [
                    // ЖИДКИЙ ПУЗЫРЬ АКТИВНОГО ТАБА
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack, // Эффект пружинки при перекатывании
                      left: currentIndex * tabWidth + (tabWidth * 0.15), // Центрируем пузырь
                      top: 10,
                      bottom: 10,
                      width: tabWidth * 0.7,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // САМИ ИКОНКИ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TabBarItem(icon: CupertinoIcons.circle_grid_hex_fill, isSelected: currentIndex == 0, width: tabWidth, onTap: () => onTap(0)),
                        _TabBarItem(icon: CupertinoIcons.calendar, isSelected: currentIndex == 1, width: tabWidth, onTap: () => onTap(1)),
                        _TabBarItem(icon: CupertinoIcons.sparkles, isSelected: currentIndex == 2, width: tabWidth, onTap: () => onTap(2)),
                        _TabBarItem(icon: CupertinoIcons.person_crop_circle, isSelected: currentIndex == 3, width: tabWidth, onTap: () => onTap(3)),
                      ],
                    ),
                  ],
                );
              }
          ),
        ),
      ),
    );
  }
}

class _TabBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  const _TabBarItem({required this.icon, required this.isSelected, required this.width, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemSound.play(SystemSoundType.click); // Звук при смене таба
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.15 : 1.0, // Иконка слегка "подпрыгивает"
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.5),
                size: 26
            ),
          ),
        ),
      ),
    );
  }
}
