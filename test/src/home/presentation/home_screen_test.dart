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
import 'package:openccr_companion/src/home/presentation/home_screen.dart';

class MockBleRepository extends Mock implements BleRepository {}

final _fakeDevice = BleDevice(
  id: 'AA:BB:CC:DD:EE:FF',
  name: 'openCCR-AABBCC',
  rssi: -70,
  hasCompanion: true,
);

Widget _wrap({
  List<BleDevice> knownDevices = const [],
  BleScanState scanState = const BleScanIdle(),
}) {
  final mockRepo = MockBleRepository();
  when(() => mockRepo.stopScan()).thenAnswer((_) async {});
  when(() => mockRepo.disconnect(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      bleRepositoryProvider.overrideWithValue(mockRepo),
      knownDevicesProvider.overrideWith((_) async => knownDevices),
      bleScanProvider.overrideWith(
        (ref) => BleScanNotifier.initialState(mockRepo, scanState),
      ),
      blePairingProvider.overrideWith(
        (ref, deviceId) => BlePairingNotifier.initialState(
          mockRepo,
          deviceId,
          const BlePairingConnecting(),
        ),
      ),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
  );
}

void main() {
  group('HomeScreen — hero', () {
    testWidgets('shows welcome heading text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Welcome to OpenCCR companion app'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Diver interface for CCR controllers'), findsOneWidget);
    });

    testWidgets('renders brand wordmark with correct key', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byKey(HomeScreenKeys.brandWordmark), findsOneWidget);
    });

    testWidgets('hero section has correct key', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byKey(HomeScreenKeys.heroSection), findsOneWidget);
    });
  });

  group('HomeScreen — known devices', () {
    testWidgets('no paired devices — shows placeholder text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.textContaining('No paired devices yet'), findsOneWidget);
    });

    testWidgets('with paired device — shows device name + Connect button',
        (tester) async {
      await tester.pumpWidget(_wrap(knownDevices: [_fakeDevice]));
      await tester.pumpAndSettle();

      expect(
        find.byKey(HomeScreenKeys.knownDeviceTile(_fakeDevice.id)),
        findsOneWidget,
      );
      expect(find.text('openCCR-AABBCC'), findsOneWidget);
      expect(
        find.byKey(HomeScreenKeys.connectButton(_fakeDevice.id)),
        findsOneWidget,
      );
    });
  });

  group('HomeScreen — scanning', () {
    testWidgets('scanning with no results — shows searching text',
        (tester) async {
      await tester.pumpWidget(
        _wrap(scanState: const BleScanScanning(devices: [])),
      );
      await tester.pump();
      expect(find.textContaining('Searching'), findsOneWidget);
    });

    testWidgets('scanning with unpaired device — shows Pair button',
        (tester) async {
      final scanDevice = BleDevice(
        id: '11:22:33:44:55:66',
        name: 'openCCR-112233',
        rssi: -60,
        hasCompanion: false,
      );
      await tester.pumpWidget(
        _wrap(scanState: BleScanScanning(devices: [scanDevice])),
      );
      await tester.pump();

      expect(
        find.byKey(HomeScreenKeys.scanDeviceTile(scanDevice.id)),
        findsOneWidget,
      );
      expect(
        find.byKey(HomeScreenKeys.pairButton(scanDevice.id)),
        findsOneWidget,
      );
    });

    testWidgets('known device excluded from scan results', (tester) async {
      // Same ID in both known and scan — should NOT appear in scan section.
      final scanDevice = BleDevice(
        id: _fakeDevice.id,
        name: _fakeDevice.name,
        rssi: -60,
        hasCompanion: true,
      );
      await tester.pumpWidget(
        _wrap(
          knownDevices: [_fakeDevice],
          scanState: BleScanScanning(devices: [scanDevice]),
        ),
      );
      // Two pumps: first frame + FutureProvider resolve.
      // Cannot use pumpAndSettle — BleScanScanning shows a continuous CPI.
      await tester.pump();
      await tester.pump();

      expect(
          find.byKey(HomeScreenKeys.pairButton(_fakeDevice.id)), findsNothing);
    });

    testWidgets(
        'device paired with different app — shows foreign bond tile, no Pair button',
        (tester) async {
      final foreignDevice = BleDevice(
        id: '77:88:99:AA:BB:CC',
        name: 'MyCustomName',
        rssi: -65,
        hasCompanion: true, // bonded elsewhere — not in knownDevices
      );
      await tester.pumpWidget(
        _wrap(scanState: BleScanScanning(devices: [foreignDevice])),
      );
      await tester.pump();

      expect(
        find.byKey(HomeScreenKeys.foreignBondTile(foreignDevice.id)),
        findsOneWidget,
      );
      expect(find.text('Paired with a different app'), findsOneWidget);
      expect(
        find.byKey(HomeScreenKeys.pairButton(foreignDevice.id)),
        findsNothing,
      );
    });

    testWidgets('permission denied — shows permission banner', (tester) async {
      await tester.pumpWidget(
        _wrap(scanState: const BleScanPermissionDenied()),
      );
      await tester.pump();
      expect(find.text('Grant'), findsOneWidget);
    });

    testWidgets('scan error — shows error message and Retry', (tester) async {
      await tester.pumpWidget(
        _wrap(scanState: const BleScanError(message: 'adapter off')),
      );
      await tester.pump();
      expect(find.text('adapter off'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
