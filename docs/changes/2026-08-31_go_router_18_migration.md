# 2026-08-31 — go_router 18 migration

## Why

Raise `go_router` to `^18.0.0` (material_ui / cupertino_ui split) after
[2026-08-31 defer](2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md)
documented integration failures on 18.0.0.

## Root cause

Social feed demo tripped `ProviderNotFoundException` for route-scoped
`SocialFeedCubit` and `InheritedElement.debugDeactivated` (`_dependents.isEmpty`)
under go_router 18 when:

1. Route pages mixed `package:flutter/material.dart` with `material_ui`
   `MaterialPage` / app shell.
2. `GoRoute.builder` + ephemeral `BlocProvider(create: …)` could dispose the
   cubit during navigator page rebuilds mid-transition.

## Fix

- **`BlocProviderHelpers.routeScopedWithAsyncInit`** — stateful route-scoped cubit
  ownership; routes use `pageBuilder` + `NoTransitionPage` keyed with
  `state.pageKey`.
- **`RouteScopedPage`** — `route` / `routeWithCubit` factories plus
  `Widget.routeScoped` for nested cubits; pages keyed with `state.pageKey`.
- **material_ui on social feed feature** — page, body, scenario controls, and
  feed widgets import `material_ui` (aligns with go_router 18 page helpers).
- **Integration harness** — social feed flow waits for
  `social-feed-refresh-button` (title text duplicated on Example hub button);
  keep `_dismissModalSheet` for scenario sheet (from defer hardening).

## Proof

- `flutter analyze --no-pub` — no issues (apps/mobile)
- `cd apps/mobile && flutter test test/features/social_feed_demo/` — 74 passed
- `flutter test integration_test/social_feed_demo_flow_test.dart` (iOS sim) — passed
- `./bin/integration_tests` — web preflight + iOS simulator all_flows (30 tests)
- Follow-up closeout ([#751](https://github.com/redjadet/flutter_bloc_app/pull/751)):
  `routeScopedWithAsyncInit`, full social feed `material_ui`, route audit doc
- Proactive demo migration
  ([#756](https://github.com/redjadet/flutter_bloc_app/pull/756)): all
  demo/auxiliary routes in audit table migrated to `RouteScopedPage` +
  `routeScopedWithAsyncInit` / `Widget.routeScoped`; Dart 3.13 `class const`
  primary constructors on route factories, route-owned widgets, and
  `AppRoutePolicy` (no duplicated ctor params / fields).
  Proof: `./bin/checklist` (2920 tests, coverage 85.35%); `./bin/integration_tests`
  web preflight + iOS simulator all_flows (30). macOS desktop all_flows attempted
  but hung on guest sign-in (not blocking; desktop opt-in via
  `ALLOW_DESKTOP_INTEGRATION_DEVICE`).

## Follow-up

- ~~Audit other demo routes that still use `flutter/material.dart` under
  `GoRoute.builder` + route-scoped `BlocProviderHelpers.withAsyncInit`~~
  **2026-08-31 closeout:** inventory in [Route audit](#route-audit) below;
  shared helper `BlocProviderHelpers.routeScopedWithAsyncInit` + remaining social
  feed widgets migrated to `material_ui`.
- ~~Proactively migrate remaining demo routes from `builder` + `withAsyncInit`~~
  **2026-08-31:** demo + auxiliary routes migrated (see audit table).
- When adding route-scoped cubits under go_router 18+, use
  `RouteScopedPage.withAsyncInit` (or `routeScopedWithAsyncInit` with
  `pageBuilder` + `NoTransitionPage(key: state.pageKey)`) instead of
  `withAsyncInit` in `GoRoute.builder`.
- **Core routes** (`routes_core.dart` / `routes_core.part.dart`) still use
  `builder` + `withAsyncInit` — migrate when touched or if integration fails.

## Route audit

| Area | File | Pattern | Notes |
| --- | --- | --- | --- |
| Demos | `routes_demos.part.dart` | **pageBuilder + `RouteScopedPage`** | chat, genui, playlearn, lobby/game, FCM, production readiness, IoT, IAP, AI decision, event bus, social feed, native showcase |
| Staff app | `routes_staff_app_demo.dart` | shell + **`routeScopedWithAsyncInit`** | session/sites shell; tab routes via `RouteScopedPage` |
| Case study | `routes_case_study_demo.dart` | shell + **`RouteScopedPage`** | session shell; history/detail + static pages keyed |
| Online therapy | `routes_online_therapy_demo.dart` | builder routes | scope in shell only; no route-owned cubits |
| Core | `routes_core.dart` / `routes_core.part.dart` | builder + `withAsyncInit` | profile, graphql, counter — **not migrated** |
| Other | `route_groups.dart`, `routes_certificate_pinning_demo.dart` | **`RouteScopedPage`** | todos, wallet, supabase auth, cert pinning, deferred aux routes |
| Deferred | `deferred_pages/google_maps_page.dart`, `pages/iot_demo_hub_page.dart` | **`routeScopedWithAsyncInit`** | maps cubit + IoT BLE tab |

**Mitigation playbook:** (1) migrate route page/widgets to `material_ui` when under
`MaterialPage`; (2) use `RouteScopedPage.route` / `routeWithCubit` (or
`pageBuilder` + `state.pageKey`); (3) nest route-owned cubits with
`Widget.routeScoped` / `routeScopedWithAsyncInit` (optional `init`).

Related: [2026-08-31 defer](2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md),
[2026-08-24 upgrade validate](2026-08-24_upgrade_validate_go_router_freezed_fcm.md).
