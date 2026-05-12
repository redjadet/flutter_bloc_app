# Feature-scoped `get_it` feasibility (2026-05-12)

## Goal

Dispose demo-heavy registrations (`case_study_demo`, `iot_demo`, `walletconnect_auth`) when the user leaves a route, reducing long-lived listeners and test pollution.

## API sketch

- `GetIt.pushNewScope()` / `popScope()` around `GoRouter` route observers or shell routes.
- `AppScope` helper in `lib/app/` owns scope push/pop tied to specific `GlobalKey<NavigatorState>` subtrees **or** explicit `registerScopeForRoute` in router builders.

## Risks

- **Lazy singletons:** instances created inside scope may still be referenced by global coordinators (e.g. `BackgroundSyncCoordinator` ↔ `IotDemoRealtimeSubscription`). Must keep global “platform” services in root scope only.
- **Async teardown:** `dispose` callbacks must run before pop; document ordering vs `unawaited` realtime stops.
- **Tests:** `GetIt.reset()` vs nested scopes — integration tests that assume a flat singleton graph will need helpers.

## Recommendation

**Defer adoption.** Global `get_it` stays default. Revisit after:

1. isolating IoT realtime + sync wiring behind a narrow port with explicit start/stop, and
2. proving scope pop does not race `BackgroundSyncCoordinator` startup.

Spike branch should add **one** demo route scope with golden path manual QA before widening.
