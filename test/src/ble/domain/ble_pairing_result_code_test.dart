// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_result_code.dart';

void main() {
  group('BlePairingResultCode.fromByte', () {
    test('0x00 → pending', () {
      expect(BlePairingResultCode.fromByte(0x00), BlePairingResultCode.pending);
    });

    test('0x01 → success', () {
      expect(BlePairingResultCode.fromByte(0x01), BlePairingResultCode.success);
    });

    test('0x02 → failWrongKey', () {
      expect(
        BlePairingResultCode.fromByte(0x02),
        BlePairingResultCode.failWrongKey,
      );
    });

    test('0x03 → failLockedOut', () {
      expect(
        BlePairingResultCode.fromByte(0x03),
        BlePairingResultCode.failLockedOut,
      );
    });

    test('0x04 → failBonding', () {
      expect(
        BlePairingResultCode.fromByte(0x04),
        BlePairingResultCode.failBonding,
      );
    });

    test('0x05 → failAlreadyPaired', () {
      expect(
        BlePairingResultCode.fromByte(0x05),
        BlePairingResultCode.failAlreadyPaired,
      );
    });

    test('unknown byte → throws FormatException', () {
      expect(
        () => BlePairingResultCode.fromByte(0xFF),
        throwsA(isA<FormatException>()),
      );
    });

    test('enum values map protocol byte values', () {
      for (final code in BlePairingResultCode.values) {
        expect(BlePairingResultCode.fromByte(code.value), code);
      }
    });
  });
}
