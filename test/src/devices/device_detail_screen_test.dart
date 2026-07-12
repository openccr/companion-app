// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/devices/presentation/device_detail_screen.dart';
import 'package:openccr_companion/src/live/presentation/live_data_screen.dart';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(
        home: DeviceDetailScreen(
          name: 'openCCR-TEST',
          type: 'CCR Unit',
          battery: 80,
          connected: true,
        ),
      ),
    );

Widget _wrapDisconnected() => const ProviderScope(
      child: MaterialApp(
        home: DeviceDetailScreen(
          name: 'openCCR-HUD-12',
          type: 'HUD',
          battery: 62,
          connected: false,
          lastSeen: '3 days ago',
        ),
      ),
    );

void main() {
  testWidgets('shows device name in AppBar', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(
      find.descendant(
          of: find.byType(AppBar), matching: find.text('openCCR-TEST')),
      findsOneWidget,
    );
  });

  testWidgets('shows Diver Profile quick action', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(
        find.byKey(DeviceDetailScreenKeys.diverProfileAction), findsOneWidget);
  });

  testWidgets('shows Alarm Thresholds quick action', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DeviceDetailScreenKeys.alarmThresholdsAction),
        findsOneWidget);
  });

  testWidgets('shows rename button in AppBar', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DeviceDetailScreenKeys.renameButton), findsOneWidget);
  });

  testWidgets('shows firmware update action tile', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DeviceDetailScreenKeys.firmwareUpdateAction),
        findsOneWidget);
  });

  testWidgets('tapping status header when connected pushes LiveDataScreen',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byKey(DeviceDetailScreenKeys.statusHeader));
    await tester.pumpAndSettle();
    expect(find.byKey(LiveDataScreenKeys.po2Display), findsOneWidget);
  });

  testWidgets('tapping Diver Profile pushes DiverProfileScreen',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.byKey(DeviceDetailScreenKeys.diverProfileAction));
    await tester.pumpAndSettle();
    expect(find.text('Diver Profile'), findsWidgets);
  });

  testWidgets('disconnected device hides battery icon', (tester) async {
    await tester.pumpWidget(_wrapDisconnected());
    expect(find.byIcon(Icons.battery_full), findsNothing);
  });

  testWidgets('disconnected device shows last seen text', (tester) async {
    await tester.pumpWidget(_wrapDisconnected());
    expect(find.text('Last seen: 3 days ago'), findsOneWidget);
  });
}
