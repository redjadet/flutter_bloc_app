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

- **`SocialFeedDemoRouteScope`** — StatefulWidget owns one cubit per route visit;
  route uses `pageBuilder` + `NoTransitionPage` keyed with `state.pageKey`.
- **material_ui on social feed surface** — page, body, scenario controls import
  `material_ui` (aligns with go_router 18 page helpers).
- **Integration harness** — social feed flow waits for
  `social-feed-refresh-button` (title text duplicated on Example hub button);
  keep `_dismissModalSheet` for scenario sheet (from defer hardening).

## Proof

- `flutter analyze --no-pub` — no issues (apps/mobile)
- `cd apps/mobile && flutter test test/features/social_feed_demo/` — 74 passed
- `flutter test integration_test/social_feed_demo_flow_test.dart` (iOS sim) — passed
- `./bin/integration_tests` — web preflight + iOS simulator all_flows (30 tests)

## Follow-up

- Audit other demo routes that still use `flutter/material.dart` under
  `GoRoute.builder` + route-scoped `BlocProviderHelpers.withAsyncInit` if similar
  dispose regressions appear on future go_router majors.

Related: [2026-08-31 defer](2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md),
[2026-08-24 upgrade validate](2026-08-24_upgrade_validate_go_router_freezed_fcm.md).
