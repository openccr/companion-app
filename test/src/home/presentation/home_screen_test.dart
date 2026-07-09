// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/shared/theme/app_theme.dart';
import 'package:openccr_companion/src/home/presentation/home_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: child,
    );

void main() {
  group('HomeScreen', () {
    testWidgets('shows welcome heading text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(
        find.text('Welcome to OpenCCR companion app'),
        findsOneWidget,
      );
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(
        find.text('Diver interface for CCR controllers'),
        findsOneWidget,
      );
    });

    testWidgets('renders brand wordmark with correct key', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.byKey(HomeScreenKeys.brandWordmark), findsOneWidget);
    });

    testWidgets('hero section has correct key', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.byKey(HomeScreenKeys.heroSection), findsOneWidget);
    });
  });
}
