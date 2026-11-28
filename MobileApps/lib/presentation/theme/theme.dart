import 'package:flutter/material.dart';

/// Palet & token desain MeatFresh AI bertema Fresh Meat Culinary:
/// - `#A61D28` Fresh Ruby Meat Red (brand utama, tombol aktif, aksen inti)
/// - `#5C242C` Deep Burgundy Plum (header melengkung & permukaan pendukung)
/// - `#F5B81E` Warm Golden Amber (CTA utama & sorotan kontras tinggi)
/// - `#D96B43` Warm Terracotta (aksen AI/model & elemen sekunder hangat)
/// - `#1E8E5A` Rosemary Herb Green (khusus status semantik SEGAR agar tetap jelas)
class AppColors {
  // ─── Core Brand Palette (Fresh Meat Theme) ─────────────────
  static const Color primary = Color(0xFFA61D28); // Fresh Ruby Meat Red
  static const Color primaryDark = Color(0xFF7D121C); // Deep Marbled Burgundy
  static const Color primarySoft = Color(0xFFFCEBED); // Soft Rose Blush
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFA61D28);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // ─── Meat Fresh Red Gradient (Hero Beranda) ────────────────
  static const Color meatRedLight = Color(0xFFC82D38);
  static const Color meatRed = Color(0xFFA61D28);
  static const Color meatRedDark = Color(0xFF7D121C);
  static const Color meatRedDeep = Color(0xFF5D0C14);

  // ─── Warm Golden Accent (Primary CTAs) ─────────────────────
  static const Color accent = Color(0xFFF5B81E); // Warm Golden Amber
  static const Color accentSoft = Color(0xFFFFF5DB);
  static const Color onAccent = Color(0xFF261315); // > 10:1 contrast on #F5B81E
  static const Color amberInk = Color(0xFF6A4300); // > 7:1 contrast on accentSoft

  // ─── Secondary Warm Terracotta (AI / Highlights) ───────────
  static const Color secondary = Color(0xFFD96B43); // Warm Terracotta
  static const Color secondaryDark = Color(0xFF9A3D1C); // Accessible ink
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD96B43);
  static const Color onSecondaryContainer = Color(0xFF4A1C0D);
  static const Color secondaryFixed = Color(0xFFFDEEE8);

  // ─── Tertiary Deep Burgundy-Plum (Headers & Support) ───────
  static const Color tertiary = Color(0xFF5C242C); // Warm Deep Burgundy
  static const Color tertiaryDark = Color(0xFF461920);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF5C242C);
  static const Color tertiaryFixed = Color(0xFFF5E9EB);

  // ─── Warm Neutrals & Butcher-Paper Surfaces ────────────────
  static const Color bgCanvas = Color(0xFFFBF7F6);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF5EEEC);
  static const Color surfaceContainerHighest = Color(0xFFE3D6D2);

  // ─── Text Hierarchy (WCAG AA/AAA Compliant) ────────────────
  static const Color textPrimary = Color(0xFF241416);
  static const Color textSecondary = Color(0xFF6E5558);
  static const Color textTertiary = Color(0xFF9A8184);

  // ─── Subtle Warm Hairline Borders & Shadow Base ────────────
  static const Color borderSubtle = Color(0xFFEFE3E1);
  static const Color borderDefault = Color(0xFFE2D1CE);
  static const Color shadowBase = Color(0xFF3A0D12);

  // ─── Freshness Status Colors (Food-Safety Semantic) ────────
  static const Color statusFresh = Color(0xFF1E8E5A); // Rosemary Herb Green
  static const Color statusFreshSoft = Color(0xFFE6F5ED);
  static const Color statusFreshInk = Color(0xFF11603C);
  static const Color statusHalf = Color(0xFFF5B81E); // Golden Amber
  static const Color statusHalfSoft = Color(0xFFFFF5DB);
  static const Color statusSpoiled = Color(0xFFD9363E); // Alert Crimson
  static const Color statusSpoiledSoft = Color(0xFFFDECEC);
  static const Color statusSpoiledInk = Color(0xFF8F161D);

  // ─── Error & Warning Surfaces ──────────────────────────────
  static const Color error = Color(0xFFC92A32);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDECEC);
  static const Color warningBg = Color(0xFFFFF7E2);
}

class AppShadows {
  static BoxShadow softCard({Color? color}) => BoxShadow(
        color: (color ?? AppColors.shadowBase).withValues(alpha: 0.08),
        offset: const Offset(0, 8),
        blurRadius: 24,
        spreadRadius: -2,
      );

  static BoxShadow softSm({Color? color}) => BoxShadow(
        color: (color ?? AppColors.shadowBase).withValues(alpha: 0.06),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: -1,
      );

  static BoxShadow glow(Color color, {double alpha = 0.28}) => BoxShadow(
        color: color.withValues(alpha: alpha),
        offset: const Offset(0, 8),
        blurRadius: 20,
        spreadRadius: -3,
      );

  static BoxShadow navBar() => BoxShadow(
        color: AppColors.shadowBase.withValues(alpha: 0.09),
        offset: const Offset(0, -4),
        blurRadius: 22,
      );
}

class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double full = 9999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double margin = 20;
}

class AppTextStyles {
  static const String headlineFont = 'PlusJakartaSans';
  static const String bodyFont = 'PlusJakartaSans';

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: headlineFont,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 31 / 24,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineMd = TextStyle(
    fontFamily: headlineFont,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 28 / 21,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineSm = TextStyle(
    fontFamily: headlineFont,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 24 / 17,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 22 / 15,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    height: 20 / 13.5,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelLg = TextStyle(
    fontFamily: headlineFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: headlineFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    height: 17 / 12.5,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: headlineFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 15 / 11,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgCanvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryFixed,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryFixed,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
    ),
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.headlineLgMobile,
      headlineMedium: AppTextStyles.headlineMd,
      headlineSmall: AppTextStyles.headlineSm,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.labelLg,
      labelMedium: AppTextStyles.labelMd,
      labelSmall: AppTextStyles.labelSm,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodySm.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bgSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titleTextStyle: AppTextStyles.headlineSm,
      contentTextStyle: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  );
}
