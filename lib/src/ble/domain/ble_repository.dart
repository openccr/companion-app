// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:openccr_companion/src/ble/domain/ble_device.dart';
import 'package:openccr_companion/src/ble/domain/ble_device_info.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_result_code.dart';

abstract class BleRepository {
  /// Starts BLE scan filtered to openCCR service UUID.
  /// Emits updated device lists as new results arrive.
  Stream<List<BleDevice>> startScan();

  Future<void> stopScan();

  /// Connects to device, discovers services, reads DeviceInfo characteristic,
  /// and subscribes to PairingResult notifications.
  Future<BleDeviceInfo> connect(String deviceId);

  /// Writes 6-byte ASCII key to PairingKey characteristic then waits for
  /// PairingResult notification.
  /// Returns (result code, remaining attempts from byte[1]).
  Future<({BlePairingResultCode code, int remainingAttempts})> submitPairingKey(
    String deviceId,
    String key,
  );

  Future<void> disconnect(String deviceId);

  /// Emits true when BLE adapter is enabled, false when disabled.
  Stream<bool> get adapterEnabled;

  /// Returns OS-bonded openCCR devices (Android only; empty list on other platforms).
  Future<List<BleDevice>> bondedDevices();
}
