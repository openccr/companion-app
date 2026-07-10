// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/foundation.dart';

@immutable
class BleDevice {
  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.hasCompanion,
    this.firmwareVersion,
  });

  final String id;
  final String name;
  final int rssi;
  final bool hasCompanion;
  final String? firmwareVersion;

  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? hasCompanion,
    String? firmwareVersion,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      hasCompanion: hasCompanion ?? this.hasCompanion,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BleDevice &&
        other.id == id &&
        other.name == name &&
        other.rssi == rssi &&
        other.hasCompanion == hasCompanion &&
        other.firmwareVersion == firmwareVersion;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, rssi, hasCompanion, firmwareVersion);

  @override
  String toString() => 'BleDevice(id: $id, name: $name, rssi: $rssi, '
      'hasCompanion: $hasCompanion, firmwareVersion: $firmwareVersion)';
}
