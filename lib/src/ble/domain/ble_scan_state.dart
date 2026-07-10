// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/foundation.dart';
import 'package:openccr_companion/src/ble/domain/ble_device.dart';

sealed class BleScanState {
  const BleScanState();
}

@immutable
final class BleScanIdle extends BleScanState {
  const BleScanIdle();
}

@immutable
final class BleScanScanning extends BleScanState {
  const BleScanScanning({required this.devices});

  final List<BleDevice> devices;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BleScanScanning) return false;
    if (devices.length != other.devices.length) return false;
    for (var i = 0; i < devices.length; i++) {
      if (devices[i] != other.devices[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(devices);
}

@immutable
final class BleScanPermissionDenied extends BleScanState {
  const BleScanPermissionDenied();
}

@immutable
final class BleScanError extends BleScanState {
  const BleScanError({required this.message});

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BleScanError && other.message == message);

  @override
  int get hashCode => message.hashCode;
}
