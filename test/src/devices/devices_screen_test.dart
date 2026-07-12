// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openccr_companion/src/ble/domain/ble_device.dart';
import 'package:openccr_companion/src/ble/domain/ble_repository.dart';
import 'package:openccr_companion/src/ble/domain/ble_scan_state.dart';
import 'package:openccr_companion/src/ble/presentation/ble_providers.dart';
import 'package:openccr_companion/src/devices/presentation/devices_screen.dart';

class MockBleRepository extends Mock implements BleRepository {}

final _fakeNearby = BleDevice(
  id: 'AA:BB:CC:DD:EE:FF',
  name: 'openCCR-B891',
  rssi: -72,
  hasCompanion: false,
  firmwareVersion: null,
);

Widget _wrap({BleScanState scanState = const BleScanScanning(devices: [])}) {
  final mockRepo = MockBleRepository();
  when(() => mockRepo.stopScan()).thenAnswer((_) async {});
  return ProviderScope(
    overrides: [
      bleRepositoryProvider.overrideWithValue(mockRepo),
      bleScanProvider.overrideWith(
        (ref) => BleScanNotifier.initialState(mockRepo, scanState),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: DevicesScreen())),
  );
}

void main() {
  testWidgets('shows Your Devices section header', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DevicesScreenKeys.yourDevicesHeader), findsOneWidget);
  });

  testWidgets('shows Nearby section header', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DevicesScreenKeys.nearbyHeader), findsOneWidget);
  });

  testWidgets('shows stub paired device names', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('openCCR-F3A2'), findsOneWidget);
    expect(find.text('openCCR-HUD-12'), findsOneWidget);
  });

  testWidgets('disconnected paired device shows last seen text',
      (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('Last seen: 3 days ago'), findsOneWidget);
  });

  testWidgets('connected paired device shows battery icon', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byIcon(Icons.battery_full), findsOneWidget);
  });

  testWidgets('nearby shows scanning spinner when no devices found',
      (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.byKey(DevicesScreenKeys.nearbySpinner), findsOneWidget);
  });

  testWidgets('nearby shows BLE device when scan returns result',
      (tester) async {
    await tester.pumpWidget(
      _wrap(scanState: BleScanScanning(devices: [_fakeNearby])),
    );
    expect(find.text('openCCR-B891'), findsOneWidget);
  });

  testWidgets('nearby shows permission message on BleScanPermissionDenied',
      (tester) async {
    await tester.pumpWidget(
      _wrap(scanState: const BleScanPermissionDenied()),
    );
    expect(
        find.byKey(DevicesScreenKeys.nearbyPermissionMessage), findsOneWidget);
  });
}
