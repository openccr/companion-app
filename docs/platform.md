# Platform Support

Primary: **iOS**, **Android**. Secondary: macOS, Windows, Linux (where APIs permit).

## Minimum Versions

| Platform | Minimum | Reason |
|----------|---------|--------|
| iOS | 13.0 | CBCentralManager non-deprecated APIs |
| Android | API 23 (6.0) | Runtime permissions |
| macOS | 10.14 | CoreBluetooth parity |
| Windows | 10 build 1903 | WinRT BLE APIs |
| Linux | kernel 5.10+ | BlueZ 5.55+ stable |

Set in `pubspec.yaml` and platform build files. Never assume a higher baseline silently.

## BLE Library

Use **`flutter_blue_plus`** exclusively. Do not add a second BLE package.

| Alternative | Rejected because |
|-------------|-----------------|
| `quick_blue` | Abandoned |
| `bluetooth_low_energy` | No background scan support |
| `universal_ble` | Immature; small community |

Coverage:

| Platform | Level |
|----------|-------|
| iOS | Full (CoreBluetooth) |
| Android | Full (BluetoothLeScanner / Gatt) |
| macOS | Full (CoreBluetooth) |
| Windows | Partial — central role only |
| Linux | Experimental — BlueZ via D-Bus |

`flutter_blue_plus` confined to data layer. Domain and presentation import only `lib/src/ble/domain/` types.

## BLE Platform Config

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Required to communicate with your CCR controller.</string>
```
Background scanning: add `Uses Bluetooth LE accessories` to Background Modes capability.

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

**macOS** — `macos/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Required to communicate with your CCR controller.</string>
```
`macos/Runner/*.entitlements`:
```xml
<key>com.apple.security.device.bluetooth</key>
<true/>
```

**Windows / Linux**: Gate BLE behind `Platform.isWindows` / `Platform.isLinux`. Surface a visible "BLE not supported" notice — never fail silently.

## Runtime Permissions

Use `permission_handler`. Request in BLE data layer only — never from UI:

```dart
final status = await Permission.bluetoothScan.request();
if (!status.isGranted) {
  // propagate through domain → UI; never swallow
}
```

Request only permissions needed on the current platform.

## Platform-Conditional Code

Platform branches belong in the **data layer only**. Domain and presentation must not contain `Platform.isX` checks.

For larger divergences (e.g. different BLE adapters per platform): use interface + DI, not inline conditionals.

## Desktop Notes

- **macOS**: CoreBluetooth parity with iOS — treat as first-class target.
- **Windows**: Central role only; peripheral unsupported.
- **Linux**: Experimental — do not block releases on BLE stability.

Compile-test all five platforms in CI even when BLE is runtime-gated.
