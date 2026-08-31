# 2026-08-31 — pub upgrade (flex_color_picker 4; defer go_router 18)

> **Superseded:** go_router 18 landed same day — see
> [2026-08-31 go_router 18 migration](2026-08-31_go_router_18_migration.md).

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

**Completed** in [#750](https://github.com/redjadet/flutter_bloc_app/pull/750) and
[#751](https://github.com/redjadet/flutter_bloc_app/pull/751). See
[2026-08-31 go_router 18 migration](2026-08-31_go_router_18_migration.md) for
route audit and mitigation playbook.

Related: [2026-08-24 upgrade validate](2026-08-24_upgrade_validate_go_router_freezed_fcm.md),
[`docs/tech_stack.md`](../tech_stack.md), [`agent_project_context.md`](../agent_project_context.md).
