// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/config/presentation/alarm_thresholds_screen.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: AlarmThresholdsScreen()),
    );

void main() {
  testWidgets('shows High PO₂ section', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(
        find.byKey(AlarmThresholdsScreenKeys.highPo2Section), findsOneWidget);
  });

  testWidgets('shows Low PO₂ section', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.scrollUntilVisible(
      find.byKey(AlarmThresholdsScreenKeys.lowPo2Section),
      100,
    );
    expect(find.byKey(AlarmThresholdsScreenKeys.lowPo2Section), findsOneWidget);
  });

  testWidgets('shows Scrubber Temp section', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.scrollUntilVisible(
      find.byKey(AlarmThresholdsScreenKeys.scrubberSection),
      100,
    );
    expect(
        find.byKey(AlarmThresholdsScreenKeys.scrubberSection), findsOneWidget);
  });

  testWidgets('shows CO₂ section', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.scrollUntilVisible(
      find.byKey(AlarmThresholdsScreenKeys.co2Section),
      100,
    );
    expect(find.byKey(AlarmThresholdsScreenKeys.co2Section), findsOneWidget);
  });

  testWidgets('shows Save button', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.scrollUntilVisible(
      find.byKey(AlarmThresholdsScreenKeys.saveButton),
      100,
    );
    expect(find.byKey(AlarmThresholdsScreenKeys.saveButton), findsOneWidget);
  });
}
