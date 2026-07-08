# Contributing to openCCR Companion App

We welcome app contributions from the community. This document covers requirements specific to this repository. For general project policies, see the [openCCR website](https://openccr.github.io).

---

## Safety First

The companion app is used for pre-dive configuration and bench testing. Display correctness matters: incorrect PO₂ readings during calibration, misconfigured alarm thresholds, or a misleading BLE connection state could lead to a misconfigured system and a dangerous dive. All contributions must reflect this:

- Changes that could cause incorrect PO₂ display, silent alarm suppression during bench tests, or misleading BLE connection state must include a `[SAFETY]` tag in the PR description.
- Changes affecting any of the following require review by **at least two contributors** before merge:
  - Alarm display logic and severity rendering
  - PO₂ readout and unit display
  - BLE reconnection behaviour and connection state UI
- `flutter analyze` must produce **zero warnings or errors**. No lint suppressions without documented rationale.
- `dart format` must produce **zero diffs**. Run it before every commit.

---

## The Legal Stuff (Important)

openCCR uses a dual-licensing model. All contributors must sign the CLA.

**By submitting a Pull Request, you agree that:**

1. Your contribution is governed by the [openCCR Contributor License Agreement v1.0](CLA.md).
2. You authorize the openCCR non-profit (and its authorized commercial partners) to utilize, modify, and dual-license your contributions without restriction.

You will be prompted to sign the CLA automatically on your first Pull Request via our CLA bot. Unsigned PRs cannot be merged.

---

## Tool Requirements

- **Flutter SDK** ≥3.19
- **Dart SDK** ≥3.3
- **Xcode** ≥15 — required for iOS builds
- **Android SDK** API ≥33
- **flutter_lints** ≥3.0 — enforced linting rules

---

## How to Contribute

1. **Fork** this repository on GitHub.
2. **Sign the CLA** — prompted automatically on your first PR.
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Create a **feature branch** from `main`.
5. Make your changes following the coding guidelines below.
6. **Run dart format** — zero diffs required:
   ```
   dart format --set-exit-if-changed lib/ test/
   ```
7. **Run flutter analyze** — zero warnings or errors:
   ```
   flutter analyze
   ```
8. **Run tests**:
   ```
   flutter test
   ```
9. **Verify build succeeds**:
   ```
   flutter build apk
   flutter build ios --no-codesign
   ```
10. **Add SPDX headers** to all new files (see below).
11. Open a **Pull Request** with a clear description of what changed and why. Include a safety note if the change affects alarm display, PO₂ rendering, or BLE reconnection logic.

---

## Coding Guidelines

### Style

`dart format` is the sole style authority. Do not argue with it.

### Linting

`flutter_lints` package is enforced. No lint suppressions (`// ignore:`) without a documented rationale in the same comment.

### BLE error states

BLE error states — disconnected, timeout, pairing failure — must each have visible UI feedback. Never silently ignore a BLE error. The user must always know the connection state.

### Alarm display

All alarm severity levels must be visually distinct. Unit tests are required for alarm state rendering. An alarm that fires on the controller must never be silently suppressed on the app display.

### PO₂ display

Always show units alongside PO₂ values. Always validate the range of incoming PO₂ readings before display. Unit tests are required for PO₂ rendering logic, including edge cases (out-of-range values, unit changes, locale changes).

### BLE UUIDs and constants

No hard-coded Bluetooth UUIDs in business logic. All GATT service and characteristic UUIDs must be defined as named constants in a shared definitions file and referenced by name.

---

## License Headers

Add to all new Dart files:

```
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors
```

Add to documentation files:

```
SPDX-License-Identifier: CC-BY-4.0
Copyright (c) 2026 openCCR contributors
```

---

## Reporting Issues

Open an issue on this repository. For display defects that could affect diver safety — such as alarms not shown, incorrect PO₂ units, or misleading connection state — mark the issue **[SAFETY]** in the title.

For safety-relevant display defects, see [SAFETY.md](SAFETY.md).

---

## Dual-Licensing Model

openCCR uses a dual-licensing model:

- **Open license** (GPL-3.0-or-later / CC BY 4.0) — for community use, research, and non-commercial builds.
- **Commercial license** — available to commercial partners through the openCCR non-profit, funding continued development and ISO standardization work.

The CLA enables the non-profit to issue commercial licenses without requiring individual permission from each contributor. This is standard practice for open-source projects with a non-profit steward (examples: Eclipse Foundation, Linux kernel).
