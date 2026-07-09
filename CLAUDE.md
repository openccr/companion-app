# openCCR Companion App — AI Instructions

## Design Authority

Source of truth: [`docs/visual-standards.md`](docs/visual-standards.md).

- Token classes only (`AppColors`, `AppTextStyles`, `AppSpacing`) — no hardcoded values in widget files
- `AppColors.warning` (`#C0392B`): life-safety use only (alarms, PO₂ alerts, BLE safety states)
- Life-safety notices: `SafetyWarning` widget — never `SnackBar` or `AlertDialog`
- Grid overlay: `CustomPaint` — not image assets

## Tech Stack

| | Version |
|---|---------|
| Flutter | ≥ 3.19 |
| Dart | ≥ 3.3 |
| Fonts | google_fonts — Space Grotesk, Inter, JetBrains Mono |
| Lints | flutter_lints ≥ 3.0 (enforced) |

## Code Quality

Before every commit (all commands run inside container via `make`):

```bash
make check   # format-check + analyze + test
```

Must pass — zero diffs, zero warnings, zero failures.

Never run `flutter` or `dart` on the host. Use `make` targets only.
iOS / macOS / Windows native builds are the only exception (Apple/MS restriction — no container).

- No `// ignore:` without rationale in the same comment
- No hardcoded BLE UUIDs — use shared constants file
- New Dart files: SPDX header (`GPL-3.0-or-later`) + copyright line
- BLE errors → visible UI feedback, never silent. Controller alarms must appear in app.
- PO₂ values must show units. Validate range before rendering.

## File Conventions

| What | Where |
|------|-------|
| Colour tokens | `lib/shared/theme/app_colors.dart` |
| Text styles | `lib/shared/theme/app_text_styles.dart` |
| Spacing | `lib/shared/theme/app_spacing.dart` |
| Theme assembly | `lib/shared/theme/app_theme.dart` |
| BLE constants | `lib/shared/constants/` (TBD) |

## Reference Docs

| Topic | Doc |
|-------|-----|
| Platform targets, BLE setup, permissions | [`docs/platform.md`](docs/platform.md) |
| Architecture, packages, naming, code gen | [`docs/architecture.md`](docs/architecture.md) |
| Testing rules and required coverage | [`docs/testing.md`](docs/testing.md) |
| UI design tokens and component patterns | [`docs/visual-standards.md`](docs/visual-standards.md) |
