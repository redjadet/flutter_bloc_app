# 2026-09-21 — Cubit async ownership guards (weather, AI decision, GenUI)

## Summary

Prevent stale async completions from overwriting newer presentation state in
three Cubits. Cancellation alone is insufficient; each path uses request
ownership / in-flight busy checks. No DI, Dio cancel, offline sync, l10n, or
codegen changes.

## Changes

| Area | Fix |
| --- | --- |
| Weather | `RequestIdGuard` on `search` (keeps `_lastQuery` for retry only); reverse-completion + ABA + typed/unexpected stale-error tests |
| AI decision | Guards on `loadQueue` / selection-changing `loadCase` / `runDecisionSupport` / `saveAction`; same-case refresh does not kill sibling mutations; race tests |
| GenUI | `_sendInFlight` ownership + preserve `isSending` across `_onError`; stream-error race + Completer tests |

## Validation

```bash
./bin/format --changed
cd apps/mobile && flutter test \
  test/features/weather_demo/presentation/weather_cubit_test.dart \
  test/features/ai_decision_demo/presentation/cubit/ai_decision_cubit_test.dart \
  test/features/genui_demo/presentation/cubit/genui_demo_cubit_test.dart
bash tool/check_cubit_isclosed.sh
bash tool/check_mutation_success_after_guard.sh
./bin/checklist
./bin/integration_tests
```

## Out of scope

NotesCubit `error.toString()`, AppInfo cancel residual, new static ownership
scanner, harness scaffolding cleanup.
