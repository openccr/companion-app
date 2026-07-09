// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

enum BlePairingResultCode {
  pending(0x00),
  success(0x01),
  failWrongKey(0x02),
  failLockedOut(0x03),
  failBonding(0x04),
  failAlreadyPaired(0x05);

  const BlePairingResultCode(this.value);

  final int value;

  static BlePairingResultCode fromByte(int byte) {
    return BlePairingResultCode.values.firstWhere(
      (c) => c.value == byte,
      orElse: () => throw FormatException(
        'Unknown pairing result code: 0x${byte.toRadixString(16)}',
      ),
    );
  }
}
