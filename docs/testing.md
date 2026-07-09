<!--
SPDX-License-Identifier: CC-BY-4.0
Copyright (c) 2026 openCCR contributors
-->

# Testing

## Running Tests

All test commands run inside the container. Use the Makefile:

```bash
make test              # flutter test
make check             # format-check + analyze + test (required before commit)
```

Or directly (pub get and test must share one container instance):

```bash
MSYS_NO_PATHCONV=1 podman run --rm \
  -v "$(pwd)":/workspace -w /workspace \
  ghcr.io/openccr/companion-app:flutter-3.44.5 \
  bash -c "flutter pub get && flutter test"
```

## Coverage Targets

| Type | Target share |
|------|-------------|
| Unit | ~60% |
| Widget | ~25% |
| Integration | ~10% |

## File Location

Mirror `lib/` under `test/`:

- Unit: `test/src/<feature>/domain/`, `test/src/<feature>/data/`
- Widget: `test/src/<feature>/presentation/`

`test/flutter_test_config.dart` runs before every test file — do not remove it.

## Rules

**Structure**: Arrange / Act / Assert. One logical assertion per test.
`setUp`/`tearDown` for shared fixtures.

**Naming**: `methodName_givenCondition_expectedResult` or a natural English sentence.

**Mocking**: Use `mocktail`. Mock at repository boundary (domain interfaces).
Never mock platform channels directly — wrap in abstraction first, mock the
abstraction.

**Widget tests**:

- Wrap in `MaterialApp` (or `ProviderScope` for Riverpod)
- `Key` constants defined in the widget file's `{Screen}Keys` class — use for
  element lookup, not hard-coded text strings
- Test loading, error, and populated states explicitly
- `tester.pump(duration)` / `tester.pumpAndSettle()` for async transitions

## google_fonts in Tests

`test/flutter_test_config.dart` disables runtime font fetching globally:

```dart
GoogleFonts.config.allowRuntimeFetching = false;
```

This prevents widget tests from making network calls in CI. Do not remove this
file or disable this setting.

## Life-Safety Constraints

- PO₂ alarm tests **must** verify the `SafetyWarning` widget appears — never
  `SnackBar` or `AlertDialog`.
- BLE disconnection tests **must** verify visible UI feedback is rendered.
- `AppColors.warning` (`#C0392B`) must only appear in response to a genuine
  alarm condition. Tests that exercise alarm rendering must assert this.

## Required Edge-Case Coverage

Safety-critical — all cases must have tests:

| Area | Required cases |
|------|---------------|
| Alarm rendering | Each severity level; empty/no-alarm state; multiple simultaneous alarms |
| PO₂ display | Normal range; high boundary; low boundary; null/missing data |
| BLE connection | Connected; reconnecting; disconnected; failed |

## Coverage Report

```bash
MSYS_NO_PATHCONV=1 podman run --rm \
  -v "$(pwd)":/workspace -w /workspace \
  ghcr.io/openccr/companion-app:flutter-3.44.5 \
  bash -c "flutter pub get && flutter test --coverage"
```

Coverage report lands in `coverage/lcov.info` (excluded from git).
