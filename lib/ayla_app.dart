import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/providers/cycle_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';

// Общие виджеты
import 'shared/widgets/mesh_background.dart';

// Экраны (Фичи)
import 'features/dashboard/home_screen.dart';
import 'features/calendar/calendar_screen.dart';
// ВАЖНО: Если у тебя пока нет этих файлов или они выдают ошибку,
// просто закомментируй их импорты. Код ниже все равно не упадет!
import 'features/insights/insights_screen.dart';
import 'features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

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

    // 🔥 СПИСОК ЭКРАНОВ
    // Количество виджетов здесь должно строго равняться количеству табов (4).
    // Если какого-то экрана пока нет, используем безопасную заглушку _PlaceholderScreen.
    final List<Widget> screens = [
      const HomeScreen(),
      const CalendarScreen(),
      // Если InsightsScreen или ProfileScreen пока выдают ошибки,
      // замени их на: const _PlaceholderScreen(title: "Insights")
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    // Защита от краша (на случай, если в массиве screens меньше 4 элементов)
    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      extendBody: true, // Контент уходит под навигацию
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Единый живой фон
          MeshCycleBackground(
            phase: cycleProvider.currentData.phase,
            child: const SizedBox.expand(),
          ),

          // 2. Экраны (Используем IndexedStack для сохранения состояния)
          IndexedStack(
            index: safeIndex,
            children: screens,
          ),

          // 3. Плавающая стеклянная навигация
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

// Умная заглушка для экранов, которых пока нет в проекте
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "$title\n(Coming Soon)",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --- ВИДЖЕТЫ НАВИГАЦИИ ---

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
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TabBarItem(
                icon: CupertinoIcons.circle_grid_hex_fill,
                label: l10n.navHome,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _TabBarItem(
                icon: CupertinoIcons.calendar,
                label: l10n.navCalendar,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _TabBarItem(
                icon: CupertinoIcons.sparkles,
                label: l10n.tabInsights ?? "Insights",
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _TabBarItem(
                icon: CupertinoIcons.person_crop_circle,
                label: l10n.navProfile,
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(icon, color: color, size: 24),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}