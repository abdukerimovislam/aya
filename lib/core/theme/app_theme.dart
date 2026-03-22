import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/cycle_model.dart';

enum AppThemeType { oceanic, nature, velvet, digital }

abstract class ColorPalette {
  Color get primary;
  Color get background;
  Color get surface;
  Color get textPrimary;
  Color get textSecondary;
  Color get textAccent;

  // Cycle colors
  Color get menstruation;
  Color get follicular;
  Color get ovulation;
  Color get luteal;

  // Chart colors
  Color get chartMenstruation;
  Color get chartFollicular;
  Color get chartOvulation;
  Color get chartLuteal;

  // Glass system
  Color get glassBase;
  Color get glassSecondary;
  Color get glassHighlight;
  Color get glassBorder;
  Color get glassShadow;
}

class OceanicPalette implements ColorPalette {
  @override
  Color get primary => const Color(0xFF2B7A78);

  @override
  Color get background => const Color(0xFFF4FBFB);

  @override
  Color get surface => const Color(0xFFFFFFFF);

  @override
  Color get textPrimary => const Color(0xFF183B4A);

  @override
  Color get textSecondary => const Color(0xFF5E8290);

  @override
  Color get textAccent => const Color(0xFFA9D8D6);

  @override
  Color get menstruation => const Color(0xFFE87A92);

  @override
  Color get follicular => const Color(0xFF9EDFD8);

  @override
  Color get ovulation => const Color(0xFFFFC98B);

  @override
  Color get luteal => const Color(0xFF7E8CE0);

  @override
  Color get chartMenstruation => const Color(0xFFD95B78);

  @override
  Color get chartFollicular => const Color(0xFF49AFA5);

  @override
  Color get chartOvulation => const Color(0xFFF2A65A);

  @override
  Color get chartLuteal => const Color(0xFF6177D6);

  @override
  Color get glassBase => const Color(0xFFFFFFFF);

  @override
  Color get glassSecondary => const Color(0xFFF3FBFB);

  @override
  Color get glassHighlight => const Color(0xFFE7F7F6);

  @override
  Color get glassBorder => const Color(0xFFFFFFFF);

  @override
  Color get glassShadow => const Color(0xFF8DC9C6);
}

class NaturePalette implements ColorPalette {
  @override
  Color get primary => const Color(0xFF6B8E62);

  @override
  Color get background => const Color(0xFFFAF8F2);

  @override
  Color get surface => const Color(0xFFFFFEFB);

  @override
  Color get textPrimary => const Color(0xFF334036);

  @override
  Color get textSecondary => const Color(0xFF758271);

  @override
  Color get textAccent => const Color(0xFFC6D1B5);

  @override
  Color get menstruation => const Color(0xFFD97C8F);

  @override
  Color get follicular => const Color(0xFFA7C7A1);

  @override
  Color get ovulation => const Color(0xFFE3B47A);

  @override
  Color get luteal => const Color(0xFF8E83C9);

  @override
  Color get chartMenstruation => const Color(0xFFC85A71);

  @override
  Color get chartFollicular => const Color(0xFF6B9D74);

  @override
  Color get chartOvulation => const Color(0xFFD89A52);

  @override
  Color get chartLuteal => const Color(0xFF7668B4);

  @override
  Color get glassBase => const Color(0xFFFFFEFB);

  @override
  Color get glassSecondary => const Color(0xFFF8F6EE);

  @override
  Color get glassHighlight => const Color(0xFFF1F3E8);

  @override
  Color get glassBorder => const Color(0xFFFFFFFF);

  @override
  Color get glassShadow => const Color(0xFFC8D6B7);
}

class VelvetPalette implements ColorPalette {
  @override
  Color get primary => const Color(0xFFE06C86);

  @override
  Color get background => const Color(0xFFFFF7F9);

  @override
  Color get surface => const Color(0xFFFFFFFF);

  @override
  Color get textPrimary => const Color(0xFF402D35);

  @override
  Color get textSecondary => const Color(0xFF8E727C);

  @override
  Color get textAccent => const Color(0xFFF2CAD5);

  @override
  Color get menstruation => const Color(0xFFE85D75);

  @override
  Color get follicular => const Color(0xFFFFA8BA);

  @override
  Color get ovulation => const Color(0xFFFFC98E);

  @override
  Color get luteal => const Color(0xFFC38BDA);

  @override
  Color get chartMenstruation => const Color(0xFFD94868);

  @override
  Color get chartFollicular => const Color(0xFFF28FA7);

  @override
  Color get chartOvulation => const Color(0xFFF3AE63);

  @override
  Color get chartLuteal => const Color(0xFFAD6BC8);

  @override
  Color get glassBase => const Color(0xFFFFFFFF);

  @override
  Color get glassSecondary => const Color(0xFFFFF2F5);

  @override
  Color get glassHighlight => const Color(0xFFFFE5EC);

  @override
  Color get glassBorder => const Color(0xFFFFFFFF);

  @override
  Color get glassShadow => const Color(0xFFFFC7D4);
}

class DigitalPalette implements ColorPalette {
  @override
  Color get primary => const Color(0xFF7B61FF);

  @override
  Color get background => const Color(0xFFF8F8FE);

  @override
  Color get surface => const Color(0xFFFFFFFF);

  @override
  Color get textPrimary => const Color(0xFF2F2B45);

  @override
  Color get textSecondary => const Color(0xFF8C86A8);

  @override
  Color get textAccent => const Color(0xFFD7D2FF);

  @override
  Color get menstruation => const Color(0xFFE85D75);

  @override
  Color get follicular => const Color(0xFF9E8CFF);

  @override
  Color get ovulation => const Color(0xFF71CBEF);

  @override
  Color get luteal => const Color(0xFFC98EF2);

  @override
  Color get chartMenstruation => const Color(0xFFD94B69);

  @override
  Color get chartFollicular => const Color(0xFF7F6AF5);

  @override
  Color get chartOvulation => const Color(0xFF47B8E8);

  @override
  Color get chartLuteal => const Color(0xFFB36DE6);

  @override
  Color get glassBase => const Color(0xFFFFFFFF);

  @override
  Color get glassSecondary => const Color(0xFFF4F2FF);

  @override
  Color get glassHighlight => const Color(0xFFE8E3FF);

  @override
  Color get glassBorder => const Color(0xFFFFFFFF);

  @override
  Color get glassShadow => const Color(0xFFD6CCFF);
}

class AppTheme {
  static ColorPalette getPalette(AppThemeType type) {
    switch (type) {
      case AppThemeType.oceanic:
        return OceanicPalette();
      case AppThemeType.nature:
        return NaturePalette();
      case AppThemeType.velvet:
        return VelvetPalette();
      case AppThemeType.digital:
        return DigitalPalette();
    }
  }

  static ColorPalette colors = VelvetPalette();

  static void setPalette(AppThemeType type) {
    colors = getPalette(type);
  }

  static ThemeData get lightTheme {
    final TextTheme baseTextTheme;
    if (colors is NaturePalette) {
      baseTextTheme = GoogleFonts.spectralTextTheme();
    } else if (colors is DigitalPalette) {
      baseTextTheme = GoogleFonts.outfitTextTheme();
    } else {
      baseTextTheme = GoogleFonts.manropeTextTheme();
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
        background: colors.background,
        surface: colors.surface,
        primary: colors.primary,
        secondary: colors.textSecondary,
        tertiary: colors.menstruation,
        onSurface: colors.textPrimary,
        onPrimary: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: colors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: colors.textSecondary,
          height: 1.5,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: colors.textSecondary.withOpacity(0.82),
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.primary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colors.primary.withOpacity(0.05),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: colors.primary.withOpacity(0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: baseTextTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary.withOpacity(0.55),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: baseTextTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: baseTextTheme.bodySmall,
      ),
    );
  }
}

class AppColors {
  static Color get primary => AppTheme.colors.primary;
  static Color get background => AppTheme.colors.background;
  static Color get surface => AppTheme.colors.surface;
  static Color get textPrimary => AppTheme.colors.textPrimary;
  static Color get textSecondary => AppTheme.colors.textSecondary;
  static Color get textAccent => AppTheme.colors.textAccent;

  static Color get menstruation => AppTheme.colors.menstruation;
  static Color get follicular => AppTheme.colors.follicular;
  static Color get ovulation => AppTheme.colors.ovulation;
  static Color get luteal => AppTheme.colors.luteal;

  static Color get chartMenstruation => AppTheme.colors.chartMenstruation;
  static Color get chartFollicular => AppTheme.colors.chartFollicular;
  static Color get chartOvulation => AppTheme.colors.chartOvulation;
  static Color get chartLuteal => AppTheme.colors.chartLuteal;

  static Color get glassBase => AppTheme.colors.glassBase;
  static Color get glassSecondary => AppTheme.colors.glassSecondary;
  static Color get glassHighlight => AppTheme.colors.glassHighlight;
  static Color get glassBorder => AppTheme.colors.glassBorder;
  static Color get glassShadow => AppTheme.colors.glassShadow;

  static Color phaseTint(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return menstruation;
      case CyclePhase.follicular:
        return follicular;
      case CyclePhase.ovulation:
        return ovulation;
      case CyclePhase.luteal:
        return luteal;
      case CyclePhase.late:
        return luteal.withOpacity(0.85);
    }
  }

  static Color get gridLines => AppTheme.colors.textPrimary.withOpacity(0.05);
  static const Color divider = Color(0xFFEDF2F4);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF233C);
  static const Color secondaryBackground = Color(0xFFE0E7FF);
}

class AppStyles {
  static BoxDecoration get backgroundGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.colors.background,
          Color.lerp(AppTheme.colors.background, AppTheme.colors.primary, 0.05)!,
        ],
      ),
    );
  }

  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: AppTheme.colors.primary.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: -2,
      ),
    ];
  }
}