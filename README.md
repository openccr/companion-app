# openCCR Companion App

Flutter iOS/Android companion app for openCCR dive computers. Used before and after dives for configuration, calibration, bench testing, log review, and firmware updates — not during a dive.

## Contents

Flutter app implementing the openCCR companion interface:

- **Pre-dive configuration** — set PO₂ setpoints, alarm thresholds, depth-based setpoint changeover, and cell calibration constants over BLE
- **Cell calibration wizard** — guided calibration with live per-cell millivolt readout and calibration commit
- **Bench test display** — live 3-cell PO₂ readout, alarm state visualization, and CCRAN inter-board health status for pre-dive system checks
- **Setpoint view/management** — view and manage CCR setpoint configuration
- **Dive log download and review** — retrieve and browse time-stamped dive logs from the controller; export as CSV, UDDF, or native binary
- **Firmware OTA update** — over-the-air firmware update for connected controller boards

## Repository Structure

```
companion-app/
├── lib/
│   └── src/{ble,po2,alarms,divelog,settings,ota}/
├── test/
├── integration_test/
├── ios/
├── android/
├── docs/
├── licenses/
└── pubspec.yaml
```

## Tools Required

- **Flutter SDK** ≥3.19
- **Dart SDK** ≥3.3
- **Xcode** ≥15 — required for iOS builds
- **Android SDK** API ≥33
- **flutter_lints** ≥3.0 — enforced linting rules

## Related Repositories

| Repository | Description |
|---|---|
| [openccr/firmware](https://github.com/openccr/firmware) | Zephyr RTOS firmware for all openCCR boards |
| [openccr/hardware](https://github.com/openccr/hardware) | KiCad schematics and PCB designs |
| [openccr/mechanics](https://github.com/openccr/mechanics) | Mechanical CAD designs |
| [openccr/docs](https://github.com/openccr/docs) | Documentation and CCRAN protocol spec |

## License

App source code: **GPL-3.0-or-later**
Documentation: **CC BY 4.0**

See [LICENSE.md](LICENSE.md) for the full licensing framework.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All contributors must sign the [Contributor License Agreement](CLA.md) before their first pull request is merged.

---

© 2026 openCCR contributors
