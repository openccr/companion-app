// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';

void main() {
  test('safe is green', () => expect(AppColors.safe, const Color(0xFF27AE60)));
  test('caution is amber',
      () => expect(AppColors.caution, const Color(0xFFF39C12)));
  test('safeTint15 alpha byte is 0x26', () {
    final a = (AppColors.safeTint15.a * 255.0).round() & 0xff;
    expect(a, 0x26);
  });
  test('cautionTint15 alpha byte is 0x26', () {
    final a = (AppColors.cautionTint15.a * 255.0).round() & 0xff;
    expect(a, 0x26);
  });
}
