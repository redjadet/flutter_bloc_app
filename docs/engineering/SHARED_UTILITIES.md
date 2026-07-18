# Shared Utilities And Package Ownership

## Overview

The old `apps/mobile/lib/shared/` tree has been drained. Shared code now lives
in focused packages when it is reusable across apps/packages, or under
`apps/mobile/lib/app/` when it is app-shell glue.

Do not recreate `apps/mobile/lib/shared/` or `apps/mobile/lib/core/` for new
cross-cutting code. Pick an existing owner first.

## Current Owners

| Need | Owner |
| --- | --- |
| Pure Dart primitives, errors, retry, request guards, lifecycle helpers, parsing, memory trim levels | `packages/utilities` |
| Hive, local storage, migrations, pending sync repositories | `packages/storage` |
| Dio/network guards, retry interceptors, circuit breaker, background sync primitives | `packages/networking` |
| Auth contracts, token repository, auth user/session value types | `packages/auth` |
| Feature flag and remote config contracts | `packages/feature_flags` |
| AI/rendering contracts reusable outside the app shell | `packages/ai` |
| Reusable Flutter UI, responsive helpers, platform-adaptive widgets, markdown rendering, image widgets, view status | `packages/design_system` |
| Flutter shared infra that is not design-system UI: logger, platform environment, secure secret storage, media pick result keys, integration log messages | `packages/app_shared_flutter` |
| App startup, DI, routing, app config, app theme, Firebase/Supabase bootstrap, app-owned diagnostics, app-owned widgets, feature adapters | `apps/mobile/lib/app` |
| Feature-specific UI, data adapters, repositories, cubits, and domain logic | `apps/mobile/lib/features/<feature>` |

## App Shell

`apps/mobile/lib/app/` is the composition boundary. It can depend on packages
and features to wire the running application, but packages must not depend back
on `package:flutter_bloc_app/app/` or `package:flutter_bloc_app/features/`.

Common app-shell areas:

- `app/bootstrap/` - platform, Firebase, Supabase, and startup coordination
- `app/composition/` - `get_it` registrations and feature adapter factories
- `app/config/` - runtime config, flavor, constants, backend availability, secret config
- `app/router/` - route tables, auth gates, route policies
- `app/http/` - app-specific Dio assembly and auth/header glue
- `app/sync/` - app-visible sync banner/context helpers
- `app/theme/` - app `ThemeData` assembly using design-system tokens
- `app/widgets/` - app-level composite widgets that are not package-level UI
- `app/diagnostics/` - app-owned diagnostics views, reports, and ports

## Package Entry Points

Prefer package barrels instead of deep imports unless package docs require a
specific private path:

```dart
import 'package:utilities/utilities.dart';
import 'package:storage/storage.dart';
import 'package:networking/networking.dart';
import 'package:auth/auth.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:design_system/design_system.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
```

Use app imports only from the app or app tests:

```dart
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
```

## Placement Rules

Add code to an existing package when it is reusable, has no dependency on the
mobile app shell, and can be validated through package analysis/tests.

Keep code in `apps/mobile/lib/app/` when it coordinates startup, routes, DI,
app configuration, app-owned diagnostics, or concrete platform/service adapters.

Keep code inside a feature when it is only used by that feature or represents a
feature-specific data/domain/presentation concern.

Move reusable Flutter widgets to `packages/design_system` only when they are
generic UI building blocks. Keep app-flow widgets such as banners tied to app
state in `apps/mobile/lib/app/widgets/` or `apps/mobile/lib/app/sync/`.

## Validation

Run the narrowest honest proof for the changed owner:

- Package-only edits: `dart run melos run analyze`, plus focused package tests.
- App-shell, DI, routing, sync, auth, or cross-package changes: `./bin/checklist`.
- Router/auth changes: `./bin/router_feature_validate` plus full checklist when wide.
- Architecture boundary checks:
  - `bash tool/check_package_dependency_dag.sh`
  - `bash tool/check_clean_architecture_imports.sh`
  - `bash tool/check_feature_modularity_leaks.sh`

Expected result: no `package:flutter_bloc_app/app/` or
`package:flutter_bloc_app/features/` imports from `packages/**`, and no new
`apps/mobile/lib/core/` or `apps/mobile/lib/shared/` trees.
