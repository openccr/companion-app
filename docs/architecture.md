# Architecture

## Folder Structure

Feature-first. Each feature has three layers.

```
lib/
├── shared/
│   ├── widgets/       # Reusable widgets
│   ├── theme/         # AppColors, AppTextStyles, AppSpacing, AppTheme
│   └── constants/     # BLE UUIDs, shared constants
├── src/
│   ├── ble/
│   │   ├── presentation/  # Pages, widgets, state
│   │   ├── domain/        # Entities, repo interfaces
│   │   └── data/          # Implementations, DTOs, sources
│   ├── po2/
│   ├── alarms/
│   ├── divelog/
│   ├── settings/
│   └── ota/
└── main.dart
```

## Layers

| Layer | Contains | Rule |
|-------|----------|------|
| Presentation | Widgets, state (providers/blocs) | No direct service calls |
| Domain | Entities, repo interfaces, use cases | No Flutter imports |
| Data | Repo implementations, DTOs, sources | Only layer touching external APIs/BLE |

UI → domain interfaces → data. Never shortcut.

## Packages

| Concern | Package |
|---------|---------|
| State | Riverpod (preferred); Bloc for strict event-driven flows only |
| Navigation | go_router + go_router_builder (type-safe routes) |
| HTTP | Dio |
| Immutable models | Freezed |
| JSON | json_serializable |
| BLE | flutter_blue_plus — see [docs/platform.md](platform.md) |
| Permissions | permission_handler |

Generated files (`*.g.dart`, `*.freezed.dart`) excluded in `.gitignore`.

## Widget Decomposition

Extract when: used in 2+ places, `build()` exceeds one screen, or needs `const` for performance.
Screen-specific widgets: colocate with screen file.
Shared widgets: `lib/shared/widgets/`.

## Naming

| Thing | Convention |
|-------|-----------|
| Files / folders | `lowercase_with_underscores` |
| Classes | `UpperCamelCase` |
| Variables / methods | `lowerCamelCase` |
| Private members | `_leadingUnderscore` |

Ref: [Dart Effective Style](https://dart.dev/effective-dart/style)

## Code Generation

After modifying Freezed or json_serializable models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Never edit `*.g.dart` or `*.freezed.dart` manually.
