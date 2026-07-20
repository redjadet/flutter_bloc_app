# Low-risk reusable package extraction — Tasks 2–4

Date: 2026-07-20

## Why

Finish the build-ready extraction plan: move remaining app-independent
contracts/helpers into existing workspace packages without product behavior
change.

## Scope

- **Task 2:** `RenderOrchestrationRemoteTokenPort` → `packages/feature_flags`
  (import-only chat/remote_config/composition touch).
- **Task 3:** Type-safe BLoC access/selector widgets →
  `packages/app_shared_flutter` with app re-export shims; add direct
  `flutter_bloc` + `provider` deps.
- **Task 4:** `date_time_formatting` + full `isolate_json` (incl.
  `encodeJsonIsolate`) → `packages/app_shared_flutter` with app shims.

## Non-goals

Shim retirement (rewrite ≥10 importers), Freezed diagnostics view model,
platform_adaptive_sheets, new packages.

## Harden (post-shim)

After shims re-exported package roots, files that already imported
`package:app_shared_flutter` / `package:feature_flags` tripped
`unnecessary_import` on the shim/domain barrel. Dropped those redundant
imports only (kept existing package-root imports). Alphabetized shim `show`
lists. Package `isolate_json_test` casts `jsonDecode` results to satisfy
`avoid_dynamic_calls`.

## Proof

- Package tests: `feature_flags`, `app_shared_flutter` (`bloc`/`date_time`/`json`)
- Focused app: isolate JSON, BLoC helpers, GraphQL bytes decode, HF token
  provider, `app_scope_test`
- Task 5 guards: no `package:flutter_bloc_app` in `packages/*/lib`; DAG;
  modularity; folder contract
- `./bin/checklist` — pass
- `./bin/integration_tests` — `integration_test/all_flows_test.dart` **+28**
  exit 0 on iOS simulator (preflight web smoke also green)

Commits for Tasks 2–4 deferred until operator asks.
