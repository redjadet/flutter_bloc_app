# app_shared_flutter

Flutter-dependent infrastructure shared across workspace packages and the
mobile app. This package owns cross-cutting Flutter adapters that do not belong
to the design system or a product feature.

`publish_to: none`; intended for this workspace, not pub.dev distribution.

## Capabilities

- structured application logging through `AppLogger`
- platform-environment detection with IO and web implementations
- secure secret storage abstraction backed by `flutter_secure_storage`
- media-pick result and error-key contracts
- shared integration-log message constants

Pure Dart primitives remain in `packages/core` or `packages/utilities`.
Reusable UI remains in `packages/design_system`.

## Usage

Add workspace dependency:

```yaml
dependencies:
  app_shared_flutter:
    path: ../app_shared_flutter
```

Import public barrel:

```dart
import 'package:app_shared_flutter/app_shared_flutter.dart';

final logger = AppLogger.instance;
logger.info('Application started');
```

Avoid deep `src/` imports. Add intended public APIs to
`lib/app_shared_flutter.dart`.

## Validation

From repository root:

```bash
dart run melos run analyze
cd packages/app_shared_flutter && flutter test
```

Package ownership and dependency rules:
[`docs/engineering/SHARED_UTILITIES.md`](../../docs/engineering/SHARED_UTILITIES.md) and
[`docs/modularity.md`](../../docs/modularity.md).
