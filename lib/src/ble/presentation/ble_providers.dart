// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:openccr_companion/src/ble/data/ble_repository_impl.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_result_code.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_state.dart';
import 'package:openccr_companion/src/ble/domain/ble_repository.dart';
import 'package:openccr_companion/src/ble/domain/ble_scan_state.dart';

final bleRepositoryProvider = Provider<BleRepository>(
  (ref) => BleRepositoryImpl(),
);

// ---------------------------------------------------------------------------
// Scan
// ---------------------------------------------------------------------------

class BleScanNotifier extends StateNotifier<BleScanState> {
  BleScanNotifier(this._repo) : super(const BleScanIdle()) {
    _init();
  }

  /// For testing only — injects an initial state without performing BLE init.
  @visibleForTesting
  BleScanNotifier.initialState(this._repo, BleScanState initial)
      : super(initial);

  final BleRepository _repo;
  StreamSubscription<dynamic>? _sub;

  Future<void> _init() async {
    final granted = await _requestPermissions();
    if (!granted) {
      state = const BleScanPermissionDenied();
      return;
    }
    await _startScan();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every(
      (s) => s == PermissionStatus.granted || s == PermissionStatus.limited,
    );
  }

  Future<void> _startScan() async {
    state = const BleScanScanning(devices: []);
    try {
      _sub = _repo.startScan().listen(
        (devices) {
          state = BleScanScanning(devices: devices);
        },
        onError: (Object e) {
          state = BleScanError(message: e.toString());
        },
      );
    } catch (e) {
      state = BleScanError(message: e.toString());
    }
  }

  Future<void> retry() async {
    await _sub?.cancel();
    _sub = null;
    await _init();
  }

  Future<void> requestPermissions() async {
    final granted = await _requestPermissions();
    if (granted) {
      await _startScan();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _repo.stopScan();
    super.dispose();
  }
}

final bleScanProvider = StateNotifierProvider<BleScanNotifier, BleScanState>(
  (ref) => BleScanNotifier(ref.watch(bleRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Pairing
// ---------------------------------------------------------------------------

class BlePairingNotifier extends StateNotifier<BlePairingState> {
  BlePairingNotifier(this._repo, this._deviceId)
      : super(const BlePairingConnecting()) {
    _connect();
  }

  /// For testing only — injects an initial state without performing BLE connect.
  @visibleForTesting
  BlePairingNotifier.initialState(
    this._repo,
    this._deviceId,
    BlePairingState initial,
  ) : super(initial);

  final BleRepository _repo;
  final String _deviceId;

  Future<void> _connect() async {
    state = const BlePairingConnecting();
    try {
      final info = await _repo.connect(_deviceId);
      if (mounted) {
        state = BlePairingAwaitingKey(deviceInfo: info);
      }
    } catch (e) {
      if (mounted) {
        state = BlePairingError(message: e.toString());
      }
    }
  }

  Future<void> submitKey(String key) async {
    state = const BlePairingSubmitting();
    try {
      final result = await _repo.submitPairingKey(_deviceId, key);
      if (!mounted) return;
      switch (result.code) {
        case BlePairingResultCode.success:
          state = const BlePairingSuccess();
        case BlePairingResultCode.failWrongKey:
          state = BlePairingWrongKey(
            remainingAttempts: result.remainingAttempts,
          );
        case BlePairingResultCode.failLockedOut:
          state = const BlePairingLockedOut();
        case BlePairingResultCode.failAlreadyPaired:
          state = const BlePairingSuccess();
        default:
          state = BlePairingError(message: 'Pairing failed: ${result.code}');
      }
    } catch (e) {
      if (mounted) {
        state = BlePairingError(message: e.toString());
      }
    }
  }

  Future<void> retry() => _connect();

  @override
  void dispose() {
    _repo.disconnect(_deviceId);
    super.dispose();
  }
}

final blePairingProvider = StateNotifierProvider.autoDispose
    .family<BlePairingNotifier, BlePairingState, String>(
  (ref, deviceId) => BlePairingNotifier(
    ref.watch(bleRepositoryProvider),
    deviceId,
  ),
);
