// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract final class BleConstants {
  static final Guid serviceUuid = Guid('4f434352-0001-0000-0000-000000000000');
  static final Guid deviceInfoCharUuid =
      Guid('4f434352-0001-0001-0000-000000000000');
  static final Guid pairingKeyCharUuid =
      Guid('4f434352-0001-0002-0000-000000000000');
  static final Guid pairingResultCharUuid =
      Guid('4f434352-0001-0003-0000-000000000000');

  static const int companyId = 0xFFFF;
  static const int protocolVersion = 0x01;
  static const String deviceNamePrefix = 'openCCR-';
  static const int pairingKeyLength = 6;
  static const int maxWrongAttempts = 3;
  static const Duration lockoutDuration = Duration(seconds: 30);
}
