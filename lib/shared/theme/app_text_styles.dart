// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';

abstract final class AppTextStyles {
  // Headings — Space Grotesk, navy, weight 700, height 1.2
  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      );

  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      );

  static TextStyle get h4 => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      );

  static TextStyle get h5 => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.2,
      );

  static TextStyle get h6 => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.2,
      );

  // Body — Inter
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  // Labels — Inter medium
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  // Monospace — JetBrains Mono (sensor values, BLE UUIDs, firmware output)
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get monoSm => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  // Badge — Space Grotesk, uppercase
  static TextStyle get badge => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.bg,
        letterSpacing: 0.5,
      );
}
