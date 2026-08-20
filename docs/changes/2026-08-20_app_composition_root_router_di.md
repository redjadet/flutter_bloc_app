# App composition root + router DI — 2026-08-20

## Scope

Centralize app-shell and router wiring behind `AppCompositionRoot` so
presentation and route builders receive injected instances instead of calling
`getIt` directly.

## What changed

1. **`AppCompositionRoot`** (`apps/mobile/lib/app/composition/app_composition_root.dart`)
   - Creates `MyApp` with a wired `GoRouter` and resolved `AppScopeDependencies`.
   - Owns auth-redirect / refresh-listenable decisions.
2. **`AppScopeDependencies`** — explicit app-shell deps; `AppScope` no longer
   queries the locator.
3. **Typed route factories** — `CoreRouteFactory`, `AuxiliaryRouteFactory`,
   `DemoRouteFactory` (plus nested demo factories). Router/deferred pages take
   repositories and factory callbacks. New bags, factories, and widgets in this
   change use Dart 3.13 primary constructors (`class const AppScopeDependencies({
   required final BackgroundSyncCoordinator syncCoordinator, ...})`) so fields
   are not duplicated.
4. **Resolution split** (file-length):
   - `app_composition_root_route_factories.dart` — core + auxiliary
   - `app_composition_root_demo_route_factory.dart` — demo routes
5. **Router invariant:** no `getIt<...>` under `apps/mobile/lib/app/router/`.

## Preserved contracts

- Service registration still lives in `injector_registrations.dart` /
  `app/composition/features/register_*_services.dart`.
- Lazy-singleton lifetimes and dispose callbacks unchanged.
- Route paths/names and auth gates unchanged.

## Validation evidence

- `flutter test apps/mobile/test/app/router` — 61 passed
- `flutter analyze --no-pub` (apps/mobile) — clean
- `./bin/checklist` — passed
- `./bin/integration_tests` — 29 passed
- PR: [flutter_bloc_app#716](https://github.com/redjadet/flutter_bloc_app/pull/716)

## Agent map updates

- [`CODEMAP.md`](../../CODEMAP.md) — composition root entry
- [`docs/clean_architecture.md`](../clean_architecture.md) — shell composition
- [`docs/new_developer_guide.md`](../new_developer_guide.md) — mental model
- [`docs/review/flutter_best_practices_review.md`](../review/flutter_best_practices_review.md)
- [`docs/CODE_QUALITY.md`](../CODE_QUALITY.md) — Dart 3.13 primary constructors
