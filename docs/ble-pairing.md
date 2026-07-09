# BLE Scanning & Pairing

## Status

Implemented. Covers discovery → scan → pair only. Post-pairing data services are out of scope.

---

## File Map

| File | Role |
|------|------|
| `lib/shared/constants/ble_constants.dart` | All UUIDs + protocol constants — single source of truth |
| `lib/src/ble/domain/ble_device.dart` | Scan-result entity (`id`, `name`, `rssi`, `hasCompanion`, `firmwareVersion`) |
| `lib/src/ble/domain/ble_device_info.dart` | DeviceInfo characteristic value object; `fromBytes(12)` parser |
| `lib/src/ble/domain/ble_pairing_result_code.dart` | Enum ↔ protocol byte mapping |
| `lib/src/ble/domain/ble_scan_state.dart` | Sealed scan FSM states |
| `lib/src/ble/domain/ble_pairing_state.dart` | Sealed pairing FSM states |
| `lib/src/ble/domain/ble_repository.dart` | Abstract boundary — mock target for tests |
| `lib/src/ble/data/ble_repository_impl.dart` | flutter_blue_plus implementation; platform code confined here |
| `lib/src/ble/presentation/ble_providers.dart` | Riverpod providers + `BleScanNotifier` + `BlePairingNotifier` |
| `lib/src/ble/presentation/device_list_screen.dart` | Scan UI (`DeviceListScreenKeys`) |
| `lib/src/ble/presentation/pairing_screen.dart` | Pairing UI (`PairingScreenKeys`) |

---

## State Machines

```
Scan:   Idle → Scanning(devices=[]) → Scanning(devices=[…])
                    └─ PermissionDenied
                    └─ Error(message)

Pair:   Connecting → AwaitingKey(deviceInfo)
                         └─ Submitting → Success (auto-pop 1.5 s)
                         └─ Submitting → WrongKey(remainingAttempts)
                         └─ Submitting → LockedOut
                         └─ Error(message)
```

---

## Protocol Constants

Source: `lib/shared/constants/ble_constants.dart`. Never define UUIDs elsewhere.

| Constant | Value |
|----------|-------|
| Service UUID | `4f434352-0001-0000-0000-000000000000` |
| DeviceInfo char (read) | `4f434352-0001-0001-0000-000000000000` |
| PairingKey char (write) | `4f434352-0001-0002-0000-000000000000` |
| PairingResult char (notify) | `4f434352-0001-0003-0000-000000000000` |
| Company ID (adv) | `0xFFFF` |
| Key length | 6 ASCII alphanumeric, case-sensitive |
| Max wrong attempts | 3 → 30 s lockout |

Manufacturer data (5 bytes in scan response):
`[proto_ver, fw_major, fw_minor, fw_patch, flags]` — bit 0 of flags = `has_companion`.

DeviceInfo (12 bytes): `[proto, fw_major, fw_minor, fw_patch, serial×6, model, flags]`

PairingResult (3 bytes, notify): `[result_code, remaining_attempts, reserved]`
Result codes: `PENDING=0x00 SUCCESS=0x01 FAIL_WRONG_KEY=0x02 FAIL_LOCKED_OUT=0x03 FAIL_BONDING=0x04 FAIL_ALREADY_PAIRED=0x05`

Full protocol spec: `../docs/ble/` (repository sibling).

---

## Key Design Decisions

**No Freezed (deferred)** — `@immutable` classes with hand-written `==`/`hashCode`/`copyWith`. When Freezed is enabled project-wide, replace with `@freezed` equivalents. No behaviour change required.

**`submitPairingKey` returns a record** — signature is `Future<({BlePairingResultCode code, int remainingAttempts})>`. Plain `BlePairingResultCode` was insufficient; protocol byte[1] carries remaining attempts needed for UI feedback.

**Testing constructors** — `BleScanNotifier.initialState()` and `BlePairingNotifier.initialState()` (`@visibleForTesting`) skip BLE/permission init. Widget tests override providers with these to inject any UI state without platform channels.

**Permissions in notifier, not widgets** — `BleScanNotifier._init()` calls `permission_handler`. Presentation layer stays ignorant of platform permission APIs.

**`maybePop` for auto-pop** — `PairingScreen` uses `Navigator.maybePop()` (no-op when root route) rather than `pop()` to avoid crash in tests and edge cases.

**Navigation is imperative** — uses `Navigator.push`. When `go_router` is introduced, replace device-tile tap and success auto-pop with typed routes.

---

## Requirements for Downstream Features

Features building on this layer (PO₂, alarms, dive log, OTA, settings):

1. **Session handle** — `BleRepositoryImpl._connected[deviceId]` holds the `BluetoothDevice` but is not exposed via the interface. Before implementing any post-pairing data service, extend `BleRepository` with a subscribe/notify API or introduce a `BleSessionRepository` that outlives `blePairingProvider`.

2. **Characteristic UUIDs** — add to `BleConstants` only. Never define UUIDs inline.

3. **Depend on `BleRepository`** — never on `BleRepositoryImpl`. Domain and presentation must mock at the abstract boundary.

4. **`adapterEnabled` stream** — `BleRepository.adapterEnabled` emits `false` when BT is disabled mid-session. Any screen that uses BLE must subscribe and show visible feedback.

5. **`hasCompanion` flag** — `BleDevice.hasCompanion` (adv flags bit 0) indicates the controller already has a paired companion. A re-pairing UX is needed; current implementation maps `FAIL_ALREADY_PAIRED` silently to success.

6. **Reconnect flow** — no background reconnect exists. App relaunch or BT off/on requires a full reconnect through `BleRepository.connect()`. Plan for this in any feature that needs persistent connection.

---

## What Is NOT Implemented

| Gap | Notes |
|-----|-------|
| Post-pairing data services | No PO₂, alarms, dive log, OTA services |
| go_router routes | `Navigator.push` used; replace when routing is added |
| Background BLE reconnect | Requires foreground service on Android; not scoped |
| Re-pairing UX | `FAIL_ALREADY_PAIRED` → silent success; needs explicit flow |
| Linux / Windows BLE | flutter_blue_plus experimental on these platforms; no test coverage |
| OTA update service | Separate UUID namespace; design pending |
| Riverpod code-gen | Using manual `StateNotifierProvider`; migrate when `riverpod_annotation` is enabled |
