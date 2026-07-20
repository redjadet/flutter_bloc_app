# Low-risk reusable package extraction — Task 1

Date: 2026-07-20

## Why

Move app-owned pure-Dart diagnostics helpers into `packages/utilities` so other
Flutter apps can import them without `package:flutter_bloc_app`.

## Scope (this commit)

- Moved `isPlausibleDiagnosticsSyncTime` and `GraphqlCacheClearPort` into
  `packages/utilities`.
- Updated feature/app import sites to `package:utilities/utilities.dart`
  (graphql_demo adapter, profile cache repository, remote_config diagnostics
  widget). Behavior unchanged.
- Package tests own behavioral proof; deleted the old app unit test for the
  timestamp helper.

## Non-goals

Tasks 2–4 (`feature_flags` token port, BLoC helpers, date/JSON helpers) remain
on the same topic branch as later commits. No product behavior change.

## Proof

- `cd packages/utilities && dart test test/diagnostics`
- Focused app consumer tests for GraphQL cache controls + GraphQL/profile port
  registration
- `./bin/checklist` (Task 5 closeout for this slice)
