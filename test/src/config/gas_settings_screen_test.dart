// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/config/presentation/gas_settings_screen.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: GasSettingsScreen()),
    );

void main() {
  testWidgets('shows Gas Mix section', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('Gas Mix'), findsOneWidget);
  });

  testWidgets('shows O₂ stepper', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(GasSettingsScreenKeys.o2Stepper), findsOneWidget);
  });

  testWidgets('shows He stepper', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(GasSettingsScreenKeys.heStepper), findsOneWidget);
  });

  testWidgets('shows Conservatism section', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('Conservatism'), findsOneWidget);
  });

  testWidgets('shows Save button', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(GasSettingsScreenKeys.saveButton), findsOneWidget);
  });

  testWidgets('Save button pops the screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GasSettingsScreen(),
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
    await tester.tap(find.byKey(GasSettingsScreenKeys.saveButton));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
