// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/foundation.dart';

@immutable
class BleDeviceInfo {
  const BleDeviceInfo({
    required this.protocolVersion,
    required this.firmwareMajor,
    required this.firmwareMinor,
    required this.firmwarePatch,
    required this.serialSuffix,
    required this.modelId,
    required this.flags,
  });

  /// Parses a 12-byte DeviceInfo characteristic value.
  ///
  /// Layout:
  ///   [0]    protocol version
  ///   [1]    firmware major
  ///   [2]    firmware minor
  ///   [3]    firmware patch
  ///   [4–9]  serial suffix (6 bytes, ASCII)
  ///   [10]   model ID
  ///   [11]   flags
  factory BleDeviceInfo.fromBytes(List<int> bytes) {
    if (bytes.length < 12) {
      throw FormatException(
        'DeviceInfo requires 12 bytes, got ${bytes.length}',
      );
    }
    final serialBytes = bytes.sublist(4, 10);
    final serial = String.fromCharCodes(
      serialBytes.where((b) => b != 0),
    );
    return BleDeviceInfo(
      protocolVersion: bytes[0],
      firmwareMajor: bytes[1],
      firmwareMinor: bytes[2],
      firmwarePatch: bytes[3],
      serialSuffix: serial,
      modelId: bytes[10],
      flags: bytes[11],
    );
  }

  final int protocolVersion;
  final int firmwareMajor;
  final int firmwareMinor;
  final int firmwarePatch;
  final String serialSuffix;
  final int modelId;
  final int flags;

  String get firmwareVersionString =>
      '$firmwareMajor.$firmwareMinor.$firmwarePatch';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BleDeviceInfo &&
        other.protocolVersion == protocolVersion &&
        other.firmwareMajor == firmwareMajor &&
        other.firmwareMinor == firmwareMinor &&
        other.firmwarePatch == firmwarePatch &&
        other.serialSuffix == serialSuffix &&
        other.modelId == modelId &&
        other.flags == flags;
  }

  @override
  int get hashCode => Object.hash(
        protocolVersion,
        firmwareMajor,
        firmwareMinor,
        firmwarePatch,
        serialSuffix,
        modelId,
        flags,
      );

  @override
  String toString() => 'BleDeviceInfo(protocol: $protocolVersion, '
      'firmware: $firmwareVersionString, serial: $serialSuffix, '
      'model: $modelId, flags: 0x${flags.toRadixString(16)})';
}
