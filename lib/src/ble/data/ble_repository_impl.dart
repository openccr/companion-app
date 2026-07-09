// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:openccr_companion/shared/constants/ble_constants.dart';
import 'package:openccr_companion/src/ble/domain/ble_device.dart';
import 'package:openccr_companion/src/ble/domain/ble_device_info.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_result_code.dart';
import 'package:openccr_companion/src/ble/domain/ble_repository.dart';

class BleRepositoryImpl implements BleRepository {
  final Map<String, BluetoothDevice> _connected = {};
  final Map<String, StreamController<List<int>>> _pairingResultControllers = {};

  @override
  Stream<List<BleDevice>> startScan() async* {
    await FlutterBluePlus.startScan(
      withServices: [BleConstants.serviceUuid],
      timeout: const Duration(seconds: 30),
    );

    final Map<String, BleDevice> seen = {};

    await for (final results in FlutterBluePlus.scanResults) {
      for (final r in results) {
        final device = _mapScanResult(r);
        if (device != null) {
          seen[device.id] = device;
        }
      }
      yield seen.values.toList();
    }
  }

  @override
  Future<void> stopScan() => FlutterBluePlus.stopScan();

  @override
  Future<BleDeviceInfo> connect(String deviceId) async {
    final fbpDevice = BluetoothDevice.fromId(deviceId);
    await fbpDevice.connect(license: License.nonprofit, autoConnect: false);
    _connected[deviceId] = fbpDevice;

    final services = await fbpDevice.discoverServices();
    final service = services.firstWhere(
      (s) => s.uuid == BleConstants.serviceUuid,
      orElse: () => throw StateError(
        'openCCR service not found on device $deviceId',
      ),
    );

    // Subscribe to PairingResult notifications.
    final pairingResultChar = service.characteristics.firstWhere(
      (c) => c.uuid == BleConstants.pairingResultCharUuid,
      orElse: () => throw StateError('PairingResult characteristic missing'),
    );
    await pairingResultChar.setNotifyValue(true);
    final ctrl = StreamController<List<int>>.broadcast();
    _pairingResultControllers[deviceId] = ctrl;
    pairingResultChar.onValueReceived.listen(ctrl.add);

    // Read DeviceInfo characteristic.
    final deviceInfoChar = service.characteristics.firstWhere(
      (c) => c.uuid == BleConstants.deviceInfoCharUuid,
      orElse: () => throw StateError('DeviceInfo characteristic missing'),
    );
    final bytes = await deviceInfoChar.read();
    return BleDeviceInfo.fromBytes(bytes);
  }

  @override
  Future<({BlePairingResultCode code, int remainingAttempts})> submitPairingKey(
    String deviceId,
    String key,
  ) async {
    final fbpDevice = _connected[deviceId];
    if (fbpDevice == null) {
      throw StateError('Device $deviceId not connected');
    }

    final services = fbpDevice.servicesList;
    final service = services.firstWhere(
      (s) => s.uuid == BleConstants.serviceUuid,
    );

    final pairingKeyChar = service.characteristics.firstWhere(
      (c) => c.uuid == BleConstants.pairingKeyCharUuid,
      orElse: () => throw StateError('PairingKey characteristic missing'),
    );

    final keyBytes = key.codeUnits;
    await pairingKeyChar.write(keyBytes, withoutResponse: false);

    final ctrl = _pairingResultControllers[deviceId];
    if (ctrl == null) {
      throw StateError('No PairingResult subscription for $deviceId');
    }

    // Wait for a non-PENDING result.
    // Byte layout: [0] result code, [1] remaining attempts, [2] reserved.
    await for (final bytes in ctrl.stream) {
      if (bytes.isEmpty) continue;
      final code = BlePairingResultCode.fromByte(bytes[0]);
      if (code != BlePairingResultCode.pending) {
        final remaining = bytes.length > 1 ? bytes[1] : 0;
        return (code: code, remainingAttempts: remaining);
      }
    }

    throw StateError('PairingResult stream closed without result');
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await _pairingResultControllers.remove(deviceId)?.close();
    await _connected.remove(deviceId)?.disconnect();
  }

  @override
  Future<List<BleDevice>> bondedDevices() async {
    try {
      final devices = await FlutterBluePlus.bondedDevices;
      return devices
          .where(
            (d) => d.platformName.startsWith(BleConstants.deviceNamePrefix),
          )
          .map(
            (d) => BleDevice(
              id: d.remoteId.str,
              name: d.platformName,
              rssi: 0,
              hasCompanion: true,
            ),
          )
          .toList();
    } catch (_) {
      // bondedDevices is Android-only; other platforms return empty.
      return [];
    }
  }

  @override
  Stream<bool> get adapterEnabled => FlutterBluePlus.adapterState.map(
        (s) => s == BluetoothAdapterState.on,
      );

  BleDevice? _mapScanResult(ScanResult result) {
    final name = result.device.platformName;
    if (!name.startsWith(BleConstants.deviceNamePrefix) &&
        !result.advertisementData.serviceUuids
            .contains(BleConstants.serviceUuid)) {
      return null;
    }

    final mfr = result.advertisementData.manufacturerData;
    final mfrBytes = mfr[BleConstants.companyId];

    bool hasCompanion = false;
    String? firmwareVersion;

    if (mfrBytes != null && mfrBytes.length >= 5) {
      final major = mfrBytes[1];
      final minor = mfrBytes[2];
      final patch = mfrBytes[3];
      firmwareVersion = '$major.$minor.$patch';
      hasCompanion = (mfrBytes[4] & 0x01) != 0;
    }

    return BleDevice(
      id: result.device.remoteId.str,
      name: name.isEmpty ? result.device.remoteId.str : name,
      rssi: result.rssi,
      hasCompanion: hasCompanion,
      firmwareVersion: firmwareVersion,
    );
  }
}
