// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/config/presentation/config_screen.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: Scaffold(body: ConfigScreen())),
    );

void main() {
  testWidgets('shows General Settings section', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('General Settings'), findsOneWidget);
  });

  testWidgets('shows Dive Settings row', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(ConfigScreenKeys.diveSettingsRow), findsOneWidget);
  });

  testWidgets('shows Gas Settings row', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(ConfigScreenKeys.gasSettingsRow), findsOneWidget);
  });

  testWidgets('shows Alarm Thresholds row', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(ConfigScreenKeys.alarmThresholdsRow), findsOneWidget);
  });

  testWidgets('shows Per Device Type section', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.scrollUntilVisible(
      find.text('Per Device Type'),
      100,
    );
    expect(find.text('Per Device Type'), findsOneWidget);
  });

  testWidgets('shows Per-Device Settings section', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.scrollUntilVisible(
      find.text('Per-Device Settings'),
      100,
    );
    expect(find.text('Per-Device Settings'), findsOneWidget);
  });

  testWidgets('tapping Dive Settings navigates to DiveSettingsScreen',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byKey(ConfigScreenKeys.diveSettingsRow));
    await tester.pumpAndSettle();
    expect(find.text('Dive Settings'), findsWidgets);
  });

  testWidgets('tapping Gas Settings navigates to GasSettingsScreen',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byKey(ConfigScreenKeys.gasSettingsRow));
    await tester.pumpAndSettle();
    expect(find.text('Gas Settings'), findsWidgets);
  });

  testWidgets('tapping Alarm Thresholds navigates to AlarmThresholdsScreen',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byKey(ConfigScreenKeys.alarmThresholdsRow));
    await tester.pumpAndSettle();
    expect(find.text('Alarm Thresholds'), findsWidgets);
  });
}
