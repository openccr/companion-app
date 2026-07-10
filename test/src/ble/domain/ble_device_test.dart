// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/ble/domain/ble_device.dart';

void main() {
  group('BleDevice', () {
    const device = BleDevice(
      id: 'AA:BB:CC:DD:EE:FF',
      name: 'openCCR-AABBCC',
      rssi: -65,
      hasCompanion: false,
      firmwareVersion: '1.2.3',
    );

    test('equality — same values are equal', () {
      const other = BleDevice(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'openCCR-AABBCC',
        rssi: -65,
        hasCompanion: false,
        firmwareVersion: '1.2.3',
      );
      expect(device, equals(other));
    });

    test('equality — different id not equal', () {
      const other = BleDevice(
        id: '00:11:22:33:44:55',
        name: 'openCCR-AABBCC',
        rssi: -65,
        hasCompanion: false,
        firmwareVersion: '1.2.3',
      );
      expect(device, isNot(equals(other)));
    });

    test('hashCode — equal objects have equal hashCodes', () {
      const other = BleDevice(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'openCCR-AABBCC',
        rssi: -65,
        hasCompanion: false,
        firmwareVersion: '1.2.3',
      );
      expect(device.hashCode, equals(other.hashCode));
    });

    test('copyWith — returns updated copy with changed field', () {
      final updated = device.copyWith(rssi: -80);
      expect(updated.rssi, -80);
      expect(updated.id, device.id);
      expect(updated.name, device.name);
      expect(updated.hasCompanion, device.hasCompanion);
      expect(updated.firmwareVersion, device.firmwareVersion);
    });

    test('copyWith — original unchanged', () {
      device.copyWith(rssi: -80);
      expect(device.rssi, -65);
    });

    test('copyWith — can set hasCompanion', () {
      final updated = device.copyWith(hasCompanion: true);
      expect(updated.hasCompanion, isTrue);
    });

    test('toString — contains id and name', () {
      expect(device.toString(), contains('AA:BB:CC:DD:EE:FF'));
      expect(device.toString(), contains('openCCR-AABBCC'));
    });

    test('null firmwareVersion allowed', () {
      const noFw = BleDevice(
        id: 'x',
        name: 'y',
        rssi: 0,
        hasCompanion: false,
      );
      expect(noFw.firmwareVersion, isNull);
    });
  });
}
