import 'package:flutter/material.dart';

/// Ultra-modern dark theme with cyan-purple neon palette.
class AppTheme {
  AppTheme._();

  // Primary colors
  static const Color primaryColor = Color(0xFF0D1B2A);
  static const Color primaryDark = Color(0xFF0B1426);
  static const Color primaryLight = Color(0xFF00E5FF);
  static const Color secondaryColor = Color(0xFF7B2FFF);

  // Accent
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentPink = Color(0xFFFF4081);

  // Semantic colors
  static const Color successColor = Color(0xFF00E676);
  static const Color errorColor = Color(0xFFFF1744);
  static const Color warningColor = Color(0xFFFFAB00);
  static const Color sosColor = Color(0xFFD50000);

  // Background & surface
  static const Color backgroundColor = Color(0xFF0B1426);
  static const Color surfaceColor = Color(0xFF122240);
  static const Color cardColor = Color(0xFF152A4A);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8BA4C4);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // High contrast colors
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastSurface = Color(0xFF1A1A1A);
  static const Color highContrastText = Color(0xFFFFFFFF);
  static const Color highContrastAccent = Color(0xFF00E5FF);

  // Accessibility constants
  static const double minTouchTarget = 48.0;
  static const double largeTouchTarget = 64.0;
  static const double cardBorderRadius = 22.0;
  static const double buttonBorderRadius = 16.0;

  // Gradient helpers
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00E5FF), Color(0xFF00BFA5)],
      );

  static LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7B2FFF), Color(0xFFFF4081)],
      );

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B1426), Color(0xFF0D1B2A), Color(0xFF152A4A)],
      );

  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.03),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Modern dark theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textOnPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: primaryDark,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          side: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: primaryDark,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2F50),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryLight;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryLight.withValues(alpha: 0.3);
          return Colors.grey.withValues(alpha: 0.2);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: primaryLight.withValues(alpha: 0.15),
        thumbColor: primaryLight,
        overlayColor: primaryLight.withValues(alpha: 0.08),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        trackHeight: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryLight,
        unselectedItemColor: textSecondary,
      ),
    );
  }

  /// High contrast theme
  static ThemeData get highContrastTheme {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: highContrastBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: highContrastAccent,
        brightness: Brightness.dark,
        primary: highContrastAccent,
        surface: highContrastSurface,
      ),
      cardTheme: CardThemeData(
        color: highContrastSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: const BorderSide(color: highContrastAccent, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: highContrastText),
        bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: highContrastText),
        bodyMedium: TextStyle(fontSize: 18, color: highContrastText),
      ),
    );
  }

  static double getTextScaleFactor(bool largeText) => largeText ? 1.3 : 1.0;
}
