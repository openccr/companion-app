<!--
SPDX-License-Identifier: CC-BY-4.0
Copyright (c) 2026 openCCR contributors
-->

# Adding Features

Pattern for adding a new feature to the openCCR companion app. Example: a `depth` gauge feature.

## Feature Structure

Every feature lives under `lib/src/<feature>/` with three layers:

```
lib/src/depth/
├── presentation/   # Widgets, providers, state
├── domain/         # Entities, repository interfaces (no Flutter imports)
└── data/           # Repository implementations, data sources
```

---

## Step-by-Step: Adding `depth`

### 1. Create directory scaffold

```bash
mkdir -p lib/src/depth/{presentation,domain,data}
touch lib/src/depth/{presentation,domain,data}/.gitkeep
```

### 2. Domain layer — entity

`lib/src/depth/domain/depth_reading.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:freezed_annotation/freezed_annotation.dart';

part 'depth_reading.freezed.dart';

@freezed
class DepthReading with _$DepthReading {
  const factory DepthReading({
    required double metres,
    required DateTime timestamp,
  }) = _DepthReading;
}
```

Run code gen after adding Freezed models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Domain layer — repository interface

`lib/src/depth/domain/depth_repository.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:openccr_companion/src/depth/domain/depth_reading.dart';

abstract interface class DepthRepository {
  Stream<DepthReading> watch();
}
```

### 4. Data layer — repository implementation

`lib/src/depth/data/depth_repository_impl.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:openccr_companion/src/depth/domain/depth_reading.dart';
import 'package:openccr_companion/src/depth/domain/depth_repository.dart';

class DepthRepositoryImpl implements DepthRepository {
  @override
  Stream<DepthReading> watch() {
    // TODO: connect to BLE data source
    return const Stream.empty();
  }
}
```

### 5. Presentation layer — Riverpod provider

`lib/src/depth/presentation/depth_provider.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openccr_companion/src/depth/data/depth_repository_impl.dart';
import 'package:openccr_companion/src/depth/domain/depth_reading.dart';
import 'package:openccr_companion/src/depth/domain/depth_repository.dart';

final depthRepositoryProvider = Provider<DepthRepository>(
  (ref) => DepthRepositoryImpl(),
);

final depthReadingProvider = StreamProvider<DepthReading>(
  (ref) => ref.watch(depthRepositoryProvider).watch(),
);
```

### 6. Presentation layer — screen widget

`lib/src/depth/presentation/depth_screen.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';

abstract final class DepthScreenKeys {
  static const ValueKey<String> screen = ValueKey<String>('depth_screen');
  static const ValueKey<String> readingText = ValueKey<String>('depth_reading');
}

class DepthScreen extends StatelessWidget {
  const DepthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: DepthScreenKeys.screen,
      appBar: AppBar(title: const Text('Depth')),
      body: Center(
        child: Text(
          '-- m',
          key: DepthScreenKeys.readingText,
          // JetBrains Mono for sensor values — per visual-standards.md
          style: AppTextStyles.mono.copyWith(
            fontSize: 48,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }
}
```

### 7. Tests

`test/src/depth/presentation/depth_screen_test.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openccr_companion/shared/theme/app_theme.dart';
import 'package:openccr_companion/src/depth/presentation/depth_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: child,
    );

void main() {
  group('DepthScreen', () {
    testWidgets('renders with correct key', (tester) async {
      await tester.pumpWidget(_wrap(const DepthScreen()));
      expect(find.byKey(DepthScreenKeys.screen), findsOneWidget);
    });

    testWidgets('shows placeholder reading', (tester) async {
      await tester.pumpWidget(_wrap(const DepthScreen()));
      expect(find.byKey(DepthScreenKeys.readingText), findsOneWidget);
    });
  });
}
```

**Mock at the repository boundary**, never below.

### 8. Register route

In `lib/main.dart` (or your go_router config once added), register the new route.

---

## Quality Gate Checklist

Before committing any feature:

- [ ] `dart format --set-exit-if-changed lib/ test/` — zero diffs
- [ ] `flutter analyze` — zero warnings, zero infos
- [ ] `flutter test` — all green
- [ ] SPDX header + copyright on every new Dart file
- [ ] No hardcoded colours, sizes, or spacing — use token classes
- [ ] PO₂ values show units and are range-validated before rendering
- [ ] BLE errors → visible UI feedback (never silent)
- [ ] Life-safety alerts use `SafetyWarning` widget (never `SnackBar`)
- [ ] No hardcoded BLE UUIDs — use `lib/shared/constants/`

---

## Rules Recap

| Rule | Where defined |
|------|--------------|
| Token classes only (no hardcoded values) | CLAUDE.md |
| `AppColors.warning` safety-critical only | docs/visual-standards.md |
| BLE confined to data layer | docs/architecture.md |
| `Platform.isX` checks in data layer only | docs/platform.md |
| Mock at repository boundary in tests | docs/testing.md |
