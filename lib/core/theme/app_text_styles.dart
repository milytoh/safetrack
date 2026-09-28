import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─────────────────────────────────────────────
  // Body — DM Sans
  // ─────────────────────────────────────────────

  static const TextStyle body = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.foreground,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );

  // ─────────────────────────────────────────────
  // Secondary / muted text
  // ─────────────────────────────────────────────

  static const TextStyle caption = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForeground,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedForeground,
  );

  // ─────────────────────────────────────────────
  // Display headings — Syne
  // ─────────────────────────────────────────────

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Syne',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.foreground,
    letterSpacing: -1.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Syne',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.foreground,
    letterSpacing: -1.2,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Syne',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );

  // Used for buttons and navigation titles
  static const TextStyle button = TextStyle(
    fontFamily: 'Syne',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryForeground,
  );

  static const TextStyle navTitle = TextStyle(
    fontFamily: 'Syne',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );
}
