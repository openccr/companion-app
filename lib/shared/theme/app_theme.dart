// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: AppColors.bg,
        secondary: AppColors.ocean,
        onSecondary: AppColors.bg,
        tertiary: AppColors.cyan,
        surface: AppColors.bg,
        onSurface: AppColors.text,
        surfaceContainerHighest: AppColors.bgSubtle,
        outline: AppColors.border,
        error: AppColors.warning,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineLarge: AppTextStyles.h4,
        headlineMedium: AppTextStyles.h5,
        headlineSmall: AppTextStyles.h6,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.labelSm,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.border,
        titleTextStyle: AppTextStyles.h6,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
        shadowColor: AppColors.shadowSm,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.bg,
          textStyle: AppTextStyles.labelLg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy),
          textStyle: AppTextStyles.labelLg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),
        filled: true,
        fillColor: AppColors.bg,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      ),
      dividerColor: AppColors.border,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      focusColor: AppColors.cyan,
    );
  }
}
