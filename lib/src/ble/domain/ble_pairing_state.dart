// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/foundation.dart';
import 'package:openccr_companion/src/ble/domain/ble_device_info.dart';

sealed class BlePairingState {
  const BlePairingState();
}

@immutable
final class BlePairingIdle extends BlePairingState {
  const BlePairingIdle();
}

@immutable
final class BlePairingConnecting extends BlePairingState {
  const BlePairingConnecting();
}

@immutable
final class BlePairingAwaitingKey extends BlePairingState {
  const BlePairingAwaitingKey({required this.deviceInfo});

  final BleDeviceInfo deviceInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlePairingAwaitingKey && other.deviceInfo == deviceInfo);

  @override
  int get hashCode => deviceInfo.hashCode;
}

@immutable
final class BlePairingSubmitting extends BlePairingState {
  const BlePairingSubmitting();
}

@immutable
final class BlePairingSuccess extends BlePairingState {
  const BlePairingSuccess();
}

@immutable
final class BlePairingWrongKey extends BlePairingState {
  const BlePairingWrongKey({required this.remainingAttempts});

  final int remainingAttempts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlePairingWrongKey &&
          other.remainingAttempts == remainingAttempts);

  @override
  int get hashCode => remainingAttempts.hashCode;
}

@immutable
final class BlePairingLockedOut extends BlePairingState {
  const BlePairingLockedOut();
}

@immutable
final class BlePairingError extends BlePairingState {
  const BlePairingError({required this.message});

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlePairingError && other.message == message);

  @override
  int get hashCode => message.hashCode;
}
