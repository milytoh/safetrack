import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,

    // ─────────────────────────────────────────
    // Base
    // ─────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'DMSans',

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.teal,
      onSecondary: AppColors.primaryForeground,
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      error: AppColors.error,
      onError: AppColors.white,
    ),

    // ─────────────────────────────────────────
    // Typography
    // ─────────────────────────────────────────
    textTheme: const TextTheme(
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,

      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.label,
      labelSmall: AppTextStyles.caption,

      titleLarge: AppTextStyles.headingLarge,
      titleMedium: AppTextStyles.headingMedium,
      titleSmall: AppTextStyles.headingSmall,
    ),

    // ─────────────────────────────────────────
    // Text fields
    // ─────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // ─────────────────────────────────────────
    // Elevated buttons
    // ─────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,

        minimumSize: const Size(double.infinity, 52),

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        elevation: 0,

        textStyle: AppTextStyles.button,
      ),
    ),
  );
}
