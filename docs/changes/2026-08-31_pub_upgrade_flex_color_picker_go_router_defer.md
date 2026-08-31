# 2026-08-31 — pub upgrade (flex_color_picker 4; defer go_router 18)

## Why

Major dependency bump: `flex_color_picker` ^4 and attempted `go_router` ^18.

## Result

- **Kept:** `flex_color_picker` ^4.0.0 (+ transitive `flex_seed_scheme` 5.x)
- **Deferred:** `go_router` stays on `^17.5.0` — 18.0.0 still trips integration with
  `InheritedElement.debugDeactivated` (`_dependents.isEmpty`) and route-scoped
  `SocialFeedCubit` `ProviderNotFoundException` during navigator transitions
  (same class as [2026-08-24 upgrade validate](2026-08-24_upgrade_validate_go_router_freezed_fcm.md)).

## Harness hardening (still useful on 17.x)

- `_dismissModalSheet` — barrier tap / modal `pageBack` instead of route `_pageBack`
  when closing social-feed scenario sheet
- Wait for hit-testable scenario button before opening sheet

## Proof

- `flutter analyze --no-pub` — no issues
- `cd apps/mobile && flutter test` — 2909 passed
- `./bin/integration_tests` — green (web preflight + iOS simulator all_flows, 30 tests)

## Follow-up (go_router 18 migration)

Before raising the caret to `^18.0.0`:

1. Audit shell routes and `pageBuilder` / `NoTransitionPage` dispose order.
2. Ensure route-scoped `BlocProvider`s outlive navigator transitions (social feed
   is the canary — `SocialFeedCubit` `ProviderNotFoundException`).
3. Keep integration harness on `_dismissModalSheet` (not route `_pageBack` under sheets).
4. Re-run `./bin/integration_tests` (web preflight + iOS simulator all_flows).
5. Update pins in `apps/mobile/pubspec.yaml`, `renovate.json`, and
   [`DEPENDENCY_UPDATES.md`](../engineering/DEPENDENCY_UPDATES.md).

Related: [2026-08-24 upgrade validate](2026-08-24_upgrade_validate_go_router_freezed_fcm.md),
[`docs/tech_stack.md`](../tech_stack.md), [`agent_project_context.md`](../agent_project_context.md).
