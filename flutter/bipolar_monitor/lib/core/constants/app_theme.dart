import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentWarm,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onPrimary: AppColors.background,
          error: AppColors.accentWarm,
        ),
        // Respect system text scale — do not clamp below 1.0
        textTheme: _buildTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.accent : Colors.transparent),
          side: const BorderSide(color: AppColors.textSecondary),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.accent : AppColors.textSecondary),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.elevated : AppColors.surfaceAlt),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );

  // High-contrast variant — stronger text/background separation
  static ThemeData get highContrast => dark.copyWith(
        colorScheme: dark.colorScheme.copyWith(
          primary: const Color(0xFF9FFFDF),        // brighter mint
          secondary: const Color(0xFFFFD0A0),      // brighter warm
          onSurface: Colors.white,
          surface: const Color(0xFF111318),
        ),
        textTheme: _buildTextTheme(highContrast: true),
      );

  static TextTheme _buildTextTheme({bool highContrast = false}) {
    final primary = highContrast ? Colors.white : AppColors.textPrimary;
    final secondary = highContrast ? const Color(0xFFBBBFD4) : AppColors.textSecondary;
    return TextTheme(
      displayLarge: AppTypography.heading.copyWith(color: primary),
      bodyLarge: AppTypography.body.copyWith(color: secondary),
      bodyMedium: AppTypography.bodySm.copyWith(color: secondary),
      labelSmall: AppTypography.label.copyWith(color: secondary),
    );
  }
}
