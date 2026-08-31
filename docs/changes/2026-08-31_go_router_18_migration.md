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
  ownership; social feed route uses `pageBuilder` + `NoTransitionPage` keyed with
  `state.pageKey`.
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

## Follow-up

- ~~Audit other demo routes that still use `flutter/material.dart` under
  `GoRoute.builder` + route-scoped `BlocProviderHelpers.withAsyncInit`~~
  **2026-08-31 closeout:** inventory in [Route audit](#route-audit) below;
  shared helper `BlocProviderHelpers.routeScopedWithAsyncInit` + remaining social
  feed widgets migrated to `material_ui`.
- When adding route-scoped cubits under go_router 18+, use
  `routeScopedWithAsyncInit` with `pageBuilder` + `NoTransitionPage(key:
  state.pageKey)` instead of `withAsyncInit` in `GoRoute.builder`.

## Route audit

Integration matrix (30 flows) passed on go_router 18 before this note; only social
feed required code changes. Remaining demo/core routes still use
`GoRoute.builder` + `withAsyncInit` — acceptable until a route shows the same
dispose/provider failure in device integration.

| Area | File | Pattern | Notes |
| --- | --- | --- | --- |
| Demos | `routes_demos.part.dart` | builder + nested `withAsyncInit` | chat, genui, lobby/game, FCM, production readiness, IoT, IAP, AI decision |
| Demos | `routes_demos.part.dart` | **pageBuilder + `routeScopedWithAsyncInit`** | social feed (fixed) |
| Demos | `routes_demos.part.dart` | builder + `MultiBlocProvider` / `withAsyncInit` | native platform showcase |
| Staff app | `routes_staff_app_demo.dart` | shell + nested `withAsyncInit` | session/sites/timeclock/messages/content/forms/proof/admin |
| Case study | `routes_case_study_demo.dart` | shell + nested `withAsyncInit` | session/history/detail |
| Online therapy | `routes_online_therapy_demo.dart` | builder routes | therapy demo subtree |
| Core | `routes_core.dart` / `routes_core.part.dart` | builder + `withAsyncInit` | profile, graphql, counter |
| Other | `route_groups.dart`, `routes_certificate_pinning_demo.dart` | builder + `withAsyncInit` | todos, wallet, supabase auth, cert pinning |
| Deferred | `deferred_pages/google_maps_page.dart`, `pages/iot_demo_hub_page.dart` | `withAsyncInit` | loaded inside parent routes |

**Mitigation playbook:** (1) migrate route page/widgets to `material_ui` when under
`MaterialPage`; (2) switch to `pageBuilder` with `state.pageKey`; (3) replace
`withAsyncInit` with `routeScopedWithAsyncInit` for single route-owned cubits.

Related: [2026-08-31 defer](2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md),
[2026-08-24 upgrade validate](2026-08-24_upgrade_validate_go_router_freezed_fcm.md).
