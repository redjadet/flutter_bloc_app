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
| Pure Dart primitives, errors, memory trim levels | `packages/utilities` |
| Public disposable bag, subscription/timer managers, `TimerDisposable` | `ilkersevim_disposables` ([pub.dev](https://pub.dev/packages/ilkersevim_disposables) `^0.1.1`; `TimerDisposable` also re-exported from `package:core`) |
| Public short relative-time labels (`3d` / `2h` / `now`) | `ilkersevim_relative_time` ([pub.dev](https://pub.dev/packages/ilkersevim_relative_time) `^0.1.1`) |
| Public `RetryPolicy` / `RetryDelay` / `CancelToken` | `ilkersevim_retry` ([pub.dev](https://pub.dev/packages/ilkersevim_retry) `^0.1.0`) |
| Public safe dynamic/JSON parse helpers | `ilkersevim_safe_parse` ([pub.dev](https://pub.dev/packages/ilkersevim_safe_parse) `^0.1.1`) |
| Public dependency-free single-flight and request-staleness guards | `ilkersevim_async_utils` ([pub.dev](https://pub.dev/packages/ilkersevim_async_utils) `^0.1.1`) |
| Public completer + StreamController lifecycle helpers | `ilkersevim_async_lifecycle` ([pub.dev](https://pub.dev/packages/ilkersevim_async_lifecycle) `^0.1.2`) |
| Public type-safe `flutter_bloc` context extensions and widgets | `ilkersevim_type_safe_bloc` ([pub.dev](https://pub.dev/packages/ilkersevim_type_safe_bloc) `^0.1.2`) |
| Public Flutter `compute` JSON map/list decode + encode | `ilkersevim_json_isolate` ([pub.dev](https://pub.dev/packages/ilkersevim_json_isolate) `^0.1.1`) |
| Hive, local storage, migrations, pending sync repositories | `packages/storage` |
| Dio/network guards, retry interceptors, circuit breaker, background sync primitives | `packages/networking` |
| Auth contracts, token repository, auth user/session value types | `packages/auth` |
| Feature flag and remote config contracts | `packages/feature_flags` |
| AI/rendering contracts reusable outside the app shell | `packages/ai` |
| Reusable Flutter UI, responsive helpers, platform-adaptive widgets, markdown rendering, image widgets, view status | `packages/design_system` |
| Flutter shared infra that is not design-system UI: logger, platform environment, secure secret storage, media pick result keys, integration log messages (JSON isolate helpers moved to `ilkersevim_json_isolate`) | `packages/app_shared_flutter` |
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
import 'package:ilkersevim_async_lifecycle/ilkersevim_async_lifecycle.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';
import 'package:ilkersevim_disposables/ilkersevim_disposables.dart';
import 'package:ilkersevim_json_isolate/ilkersevim_json_isolate.dart';
import 'package:ilkersevim_relative_time/ilkersevim_relative_time.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:utilities/utilities.dart';
import 'package:storage/storage.dart';
import 'package:networking/networking.dart';
import 'package:auth/auth.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:design_system/design_system.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
```

`ilkersevim_async_utils` owns public, dependency-free single-flight and
request-staleness guards. `ilkersevim_async_lifecycle` owns public completer
and `StreamController` lifecycle helpers. `ilkersevim_type_safe_bloc` owns
public type-safe `flutter_bloc` helpers — import it directly (no app shims;
`app_shared_flutter` does not re-export it). `ilkersevim_safe_parse` owns safe dynamic/JSON parse helpers — import it directly.
`ilkersevim_relative_time` owns short relative-time labels — import it directly.
`ilkersevim_disposables` owns `DisposableBag`, `SubscriptionManager`,
`TimerHandleManager`, and `TimerDisposable` — import the package for bag/
managers; `TimerDisposable` remains available via `package:core` re-export.
`packages/utilities` remains an internal workspace package and must not
re-export those public APIs.

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
