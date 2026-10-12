import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const Color primary = Color(0xFFB52603);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFF5A36);
  static const Color onPrimaryContainer = Color(0xFF5A0C00);

  // Secondary
  static const Color secondary = Color(0xFF0054CB);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF2D6DEB);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);
  static const Color secondaryFixed = Color(0xFFDAE2FF);

  // Tertiary
  static const Color tertiary = Color(0xFF006879);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF00A0BA);
  static const Color tertiaryFixed = Color(0xFFAAEDFF);

  // Background / Surface
  static const Color bgCanvas = Color(0xFFFDF6EC);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0EDEC);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF4A4A4A);

  // Border & Shadow
  static const Color borderDefault = Color(0xFF111111);
  static const Color shadowHard = Color(0xFF111111);

  // Status - Freshness
  static const Color statusFresh = Color(0xFF3DDC84);
  static const Color statusHalf = Color(0xFFFFC93C);
  static const Color statusSpoiled = Color(0xFFFF4D4D);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Warning surface
  static const Color warningBg = Color(0xFFFFF3DC);
}

class AppShadows {
  static BoxShadow hard({double x = 4, double y = 4, Color? color}) =>
      BoxShadow(
        color: color ?? AppColors.shadowHard,
        offset: Offset(x, y),
        blurRadius: 0,
      );

  static BoxShadow hardSmall({Color? color}) =>
      hard(x: 2, y: 2, color: color);

  static BoxShadow hardMedium({Color? color}) =>
      hard(x: 3, y: 3, color: color);

  static BoxShadow hardLarge({Color? color}) =>
      hard(x: 5, y: 5, color: color);
}

class AppBorders {
  static const double thin = 1.5;
  static const double medium = 2.5;
  static const double thick = 3.0;
}

class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 36;
  static const double margin = 16;
}

class AppTextStyles {
  static const String headlineFont = 'SpaceGrotesk';
  static const String bodyFont = 'PlusJakartaSans';

  static const TextStyle headlineXlMobile = TextStyle(
    fontFamily: headlineFont,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 40 / 32,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: headlineFont,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineMd = TextStyle(
    fontFamily: headlineFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineSm = TextStyle(
    fontFamily: headlineFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 28 / 18,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelLg = TextStyle(
    fontFamily: headlineFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: headlineFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    color: AppColors.textPrimary,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: headlineFont,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    height: 14 / 10,
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
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.tertiary,
      surface: AppColors.bgCanvas,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.onError,
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
    ),
  );
}
