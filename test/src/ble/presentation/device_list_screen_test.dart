// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openccr_companion/shared/theme/app_theme.dart';
import 'package:openccr_companion/src/ble/domain/ble_device.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_state.dart';
import 'package:openccr_companion/src/ble/domain/ble_repository.dart';
import 'package:openccr_companion/src/ble/domain/ble_scan_state.dart';
import 'package:openccr_companion/src/ble/presentation/ble_providers.dart';
import 'package:openccr_companion/src/ble/presentation/device_list_screen.dart';
import 'package:openccr_companion/src/ble/presentation/pairing_screen.dart';

class MockBleRepository extends Mock implements BleRepository {}

final _fakeDevice = BleDevice(
  id: 'AA:BB:CC:DD:EE:FF',
  name: 'openCCR-AABBCC',
  rssi: -65,
  hasCompanion: false,
  firmwareVersion: '1.0.0',
);

Widget _wrap(Widget child, {required BleScanState scanState}) {
  final mockRepo = MockBleRepository();
  when(() => mockRepo.stopScan()).thenAnswer((_) async {});
  when(() => mockRepo.disconnect(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      bleRepositoryProvider.overrideWithValue(mockRepo),
      bleScanProvider.overrideWith(
        (ref) => BleScanNotifier.initialState(mockRepo, scanState),
      ),
      // Override pairing provider so navigation target doesn't crash.
      blePairingProvider.overrideWith(
        (ref, deviceId) => BlePairingNotifier.initialState(
          mockRepo,
          deviceId,
          const BlePairingConnecting(),
        ),
      ),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

void main() {
  group('DeviceListScreen', () {
    testWidgets('BleScanScanning with no devices — shows scanning spinner',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DeviceListScreen(),
          scanState: const BleScanScanning(devices: []),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(DeviceListScreenKeys.scanStatus), findsOneWidget);
      expect(find.text('Scanning...'), findsOneWidget);
    });

    testWidgets(
        'BleScanScanning with device — shows device tile with name and rssi',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DeviceListScreen(),
          scanState: BleScanScanning(devices: [_fakeDevice]),
        ),
      );
      await tester.pump();

      expect(find.byKey(DeviceListScreenKeys.deviceList), findsOneWidget);
      expect(
        find.byKey(DeviceListScreenKeys.deviceTile(_fakeDevice.id)),
        findsOneWidget,
      );
      expect(find.text('openCCR-AABBCC'), findsOneWidget);
      expect(find.textContaining('RSSI'), findsOneWidget);
      expect(find.textContaining('-65'), findsOneWidget);
    });

    testWidgets('BleScanPermissionDenied — shows permission prompt',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DeviceListScreen(),
          scanState: const BleScanPermissionDenied(),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(DeviceListScreenKeys.permissionPrompt),
        findsOneWidget,
      );
      expect(find.textContaining('Bluetooth'), findsWidgets);
    });

    testWidgets('BleScanError — shows error message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DeviceListScreen(),
          scanState: const BleScanError(message: 'adapter off'),
        ),
      );
      await tester.pump();

      expect(find.text('adapter off'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping device tile navigates to PairingScreen',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DeviceListScreen(),
          scanState: BleScanScanning(devices: [_fakeDevice]),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(DeviceListScreenKeys.deviceTile(_fakeDevice.id)),
      );
      // Advance past the Material route transition animation (300 ms).
      // Cannot use pumpAndSettle because PairingScreen shows a
      // CircularProgressIndicator which animates indefinitely.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(PairingScreenKeys.screen), findsOneWidget);
    });
  });
}
