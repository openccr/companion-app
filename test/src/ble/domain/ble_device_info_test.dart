// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/src/ble/domain/ble_device_info.dart';

void main() {
  group('BleDeviceInfo.fromBytes', () {
    // 12-byte layout:
    // [0]=protocol, [1]=fw_major, [2]=fw_minor, [3]=fw_patch,
    // [4–9]=serial (ASCII), [10]=model, [11]=flags
    final validBytes = [
      0x01, // protocol version
      1, 2, 3, // firmware 1.2.3
      0x41, 0x42, 0x43, 0x44, 0x45, 0x46, // serial "ABCDEF"
      0x07, // model 7
      0x01, // flags
    ];

    test('parses protocol version', () {
      final info = BleDeviceInfo.fromBytes(validBytes);
      expect(info.protocolVersion, 0x01);
    });

    test('parses firmware version', () {
      final info = BleDeviceInfo.fromBytes(validBytes);
      expect(info.firmwareMajor, 1);
      expect(info.firmwareMinor, 2);
      expect(info.firmwarePatch, 3);
      expect(info.firmwareVersionString, '1.2.3');
    });

    test('parses serial suffix', () {
      final info = BleDeviceInfo.fromBytes(validBytes);
      expect(info.serialSuffix, 'ABCDEF');
    });

    test('parses model id', () {
      final info = BleDeviceInfo.fromBytes(validBytes);
      expect(info.modelId, 0x07);
    });

    test('parses flags', () {
      final info = BleDeviceInfo.fromBytes(validBytes);
      expect(info.flags, 0x01);
    });

    test('throws FormatException for short buffer', () {
      expect(
        () => BleDeviceInfo.fromBytes([0x01, 2, 3]),
        throwsA(isA<FormatException>()),
      );
    });

    test('equality — same bytes produce equal objects', () {
      final a = BleDeviceInfo.fromBytes(validBytes);
      final b = BleDeviceInfo.fromBytes(validBytes);
      expect(a, equals(b));
    });

    test('hashCode consistent with equality', () {
      final a = BleDeviceInfo.fromBytes(validBytes);
      final b = BleDeviceInfo.fromBytes(validBytes);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains firmware string', () {
      final info = BleDeviceInfo.fromBytes(validBytes);
      expect(info.toString(), contains('1.2.3'));
    });

    test('serial strips null bytes from short serial', () {
      final bytesWithNulls = [
        0x01, 1, 0, 0,
        0x58, 0x59, 0x00, 0x00, 0x00, 0x00, // "XY\0\0\0\0"
        0x01, 0x00,
      ];
      final info = BleDeviceInfo.fromBytes(bytesWithNulls);
      expect(info.serialSuffix, 'XY');
    });
  });
}
