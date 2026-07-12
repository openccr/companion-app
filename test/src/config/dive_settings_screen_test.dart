// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/config/presentation/dive_settings_screen.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: const DiveSettingsScreen(),
        ),
      ),
    );

void main() {
  testWidgets('shows Setpoint section heading', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('Setpoint'), findsOneWidget);
  });

  testWidgets('shows setpoint mode toggle', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(
        find.byKey(DiveSettingsScreenKeys.setpointModeToggle), findsOneWidget);
  });

  testWidgets('constant setpoint picker shown in default mode', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DiveSettingsScreenKeys.constantSpPicker), findsOneWidget);
  });

  testWidgets('hi/lo pickers shown when toggle enabled', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byKey(DiveSettingsScreenKeys.setpointModeToggle));
    await tester.pumpAndSettle();
    expect(find.byKey(DiveSettingsScreenKeys.hiSpPicker), findsOneWidget);
    expect(find.byKey(DiveSettingsScreenKeys.loSpPicker), findsOneWidget);
  });

  testWidgets('surface setpoint picker always visible', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DiveSettingsScreenKeys.surfSpPicker), findsOneWidget);
  });

  testWidgets('shows Gradient Factors section heading', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Gradient Factors'), findsOneWidget);
  });

  testWidgets('shows GF display in GF X/Y format', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byKey(DiveSettingsScreenKeys.gfDisplay), findsOneWidget);
    expect(find.text('GF 35/75'), findsOneWidget);
  });

  testWidgets('shows GF Low stepper', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byKey(DiveSettingsScreenKeys.gfLowStepper), findsOneWidget);
  });

  testWidgets('shows GF High stepper', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byKey(DiveSettingsScreenKeys.gfHighStepper), findsOneWidget);
  });

  testWidgets('shows penalise high ascent rate toggle', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byKey(DiveSettingsScreenKeys.penaliseToggle), findsOneWidget);
  });

  testWidgets('shows Save button', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byKey(DiveSettingsScreenKeys.saveButton), findsOneWidget);
  });

  testWidgets('Save button pops the screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DiveSettingsScreen(),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DiveSettingsScreenKeys.saveButton));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
