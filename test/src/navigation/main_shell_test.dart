// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/navigation/presentation/main_shell.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: MainShell()),
    );

void main() {
  testWidgets('renders NavigationBar with 4 destinations', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Devices'), findsWidgets);
    expect(find.text('Config'), findsWidgets);
    expect(find.text('Live'), findsWidgets);
    expect(find.text('Logs'), findsWidgets);
  });

  testWidgets('default tab shows Devices in AppBar', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Devices')),
      findsOneWidget,
    );
  });

  testWidgets('tapping Config tab updates AppBar title', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Config')),
      findsOneWidget,
    );
  });

  testWidgets('tapping Live tab updates AppBar title', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byIcon(Icons.monitor_heart_outlined));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Live')),
      findsOneWidget,
    );
  });

  testWidgets('tapping Logs tab updates AppBar title', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Logs')),
      findsOneWidget,
    );
  });
}
