// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFF0F5FA);

  // Borders
  static const Color border = Color(0xFFC8DCF0);

  // Text
  static const Color text = Color(0xFF111827);
  static const Color textMuted = Color(0xFF4B6478);

  // Brand
  static const Color navy = Color(0xFF0A3060);
  static const Color ocean = Color(0xFF0E6BAD);
  static const Color cyan = Color(0xFF24B4D8);

  // Safety-critical ONLY — CCR alarms, PO₂ alerts, BLE safety states
  static const Color warning = Color(0xFFC0392B);

  // Threshold-bar zones (alarm threshold displays, PO₂ range indicators)
  static const Color safe    = Color(0xFF27AE60); // green  — within safe range
  static const Color caution = Color(0xFFF39C12); // amber  — approaching threshold

  // Shadows (navy-tinted)
  static const Color shadowSm = Color(0x140A3060);
  static const Color shadowMd = Color(0x1F0A3060);
  static const Color shadowLg = Color(0x290A3060);

  // Tints (for badges / safety bg)
  static const Color oceanTint15   = Color(0x260E6BAD);
  static const Color cyanTint15    = Color(0x2624B4D8);
  static const Color safeTint15    = Color(0x2627AE60); // safe green at 15%
  static const Color cautionTint15 = Color(0x26F39C12); // caution amber at 15%
  static const Color warningTint10 = Color(0x1AC0392B);
  static const Color warningTint5  = Color(0x0DC0392B);

  // Grid overlay
  static const Color gridLight = Color(0x0F0E6BAD); // ocean 6%
  static const Color gridDark = Color(0x08FFFFFF); // white 3%

  // Button press state
  static const Color navyPressed = Color(0xFF062040);

  // Structural
  static const Color transparent = Color(0x00000000);
}
