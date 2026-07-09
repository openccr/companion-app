// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openccr_companion/shared/constants/ble_constants.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_theme.dart';
import 'package:openccr_companion/src/ble/domain/ble_device_info.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_state.dart';
import 'package:openccr_companion/src/ble/domain/ble_repository.dart';
import 'package:openccr_companion/src/ble/presentation/ble_providers.dart';
import 'package:openccr_companion/src/ble/presentation/pairing_screen.dart';

class MockBleRepository extends Mock implements BleRepository {}

const _deviceId = 'AA:BB:CC:DD:EE:FF';
const _deviceName = 'openCCR-AABBCC';

final _fakeDeviceInfo = BleDeviceInfo.fromBytes([
  0x01,
  1,
  2,
  3,
  0x41,
  0x42,
  0x43,
  0x44,
  0x45,
  0x46,
  0x01,
  0x00,
]);

Widget _wrap(BlePairingState pairingState) {
  final mockRepo = MockBleRepository();
  when(() => mockRepo.disconnect(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      bleRepositoryProvider.overrideWithValue(mockRepo),
      blePairingProvider.overrideWith(
        (ref, deviceId) => BlePairingNotifier.initialState(
          mockRepo,
          deviceId,
          pairingState,
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const PairingScreen(deviceId: _deviceId, deviceName: _deviceName),
    ),
  );
}

void main() {
  group('PairingScreen', () {
    testWidgets('BlePairingConnecting — shows spinner', (tester) async {
      await tester.pumpWidget(_wrap(const BlePairingConnecting()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'BlePairingAwaitingKey — shows 6-char text field and disabled Submit',
        (tester) async {
      await tester.pumpWidget(
        _wrap(BlePairingAwaitingKey(deviceInfo: _fakeDeviceInfo)),
      );
      await tester.pump();

      // Text field present.
      expect(find.byKey(PairingScreenKeys.keyField), findsOneWidget);

      // Submit disabled with fewer than 6 chars.
      final submitBtn = tester.widget<ElevatedButton>(
        find.byKey(PairingScreenKeys.submitButton),
      );
      expect(submitBtn.onPressed, isNull);
    });

    testWidgets('BlePairingAwaitingKey — Submit enabled after 6 chars entered',
        (tester) async {
      await tester.pumpWidget(
        _wrap(BlePairingAwaitingKey(deviceInfo: _fakeDeviceInfo)),
      );
      await tester.pump();

      await tester.enterText(find.byKey(PairingScreenKeys.keyField), 'ABCDEF');
      await tester.pump();

      final submitBtn = tester.widget<ElevatedButton>(
        find.byKey(PairingScreenKeys.submitButton),
      );
      expect(submitBtn.onPressed, isNotNull);
    });

    testWidgets(
        'BlePairingSubmitting — shows spinner on button, field disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlePairingSubmitting()));
      await tester.pump();

      // Button should be disabled (submitting).
      final submitBtn = tester.widget<ElevatedButton>(
        find.byKey(PairingScreenKeys.submitButton),
      );
      expect(submitBtn.onPressed, isNull);

      // Text field should be disabled.
      final textField = tester.widget<TextField>(
        find.byKey(PairingScreenKeys.keyField),
      );
      expect(textField.enabled, isFalse);
    });

    testWidgets('BlePairingWrongKey — shows error text with remaining count',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const BlePairingWrongKey(remainingAttempts: 2)),
      );
      await tester.pump();

      expect(find.textContaining('2'), findsWidgets);
      expect(find.textContaining('attempt'), findsOneWidget);

      // Field still enabled.
      final textField = tester.widget<TextField>(
        find.byKey(PairingScreenKeys.keyField),
      );
      expect(textField.enabled, isTrue);
    });

    testWidgets(
        'BlePairingLockedOut — shows locked out message in warning color',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlePairingLockedOut()));
      await tester.pump();

      expect(find.byKey(PairingScreenKeys.statusText), findsOneWidget);
      expect(find.textContaining('locked'), findsOneWidget);

      // Verify text rendered with warning color.
      final textWidget = tester.widget<Text>(
        find.byKey(PairingScreenKeys.statusText),
      );
      expect(textWidget.style?.color, AppColors.warning);
    });

    testWidgets('BlePairingSuccess — shows Paired! message', (tester) async {
      await tester.pumpWidget(_wrap(const BlePairingSuccess()));
      await tester.pump();

      expect(find.byKey(PairingScreenKeys.statusText), findsOneWidget);
      expect(find.text('Paired!'), findsOneWidget);

      // Flush the 1.5 s auto-pop timer so no pending timers remain.
      await tester.pump(const Duration(milliseconds: 1600));
    });

    testWidgets(
        'key field enforces ${BleConstants.pairingKeyLength}-char limit',
        (tester) async {
      await tester.pumpWidget(
        _wrap(BlePairingAwaitingKey(deviceInfo: _fakeDeviceInfo)),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(PairingScreenKeys.keyField),
        'ABCDEFGH', // 8 chars — should be clamped to 6
      );
      await tester.pump();

      final ctrl = tester
          .widget<TextField>(find.byKey(PairingScreenKeys.keyField))
          .controller!;
      expect(
          ctrl.text.length, lessThanOrEqualTo(BleConstants.pairingKeyLength));
    });
  });
}
