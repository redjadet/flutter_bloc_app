# Layering optimization (Presentation → Domain ← Data)

**Date:** 2026-06-07  
**Plan:** Cursor workspace plan *Layering optimization* (build-ready, 2026-06-07)

## Summary

Strengthened Clean Architecture boundaries across demo and production features without changing state-management stack (Cubit/BLoC, `get_it`, GoRouter).

## Slices delivered

1. **Domain shims removed** — `ai_decision_demo`, `in_app_purchase_demo`, `chat` (diagnostics port), `online_therapy_demo` (network mode controller), `staff_app_demo` (timeclock local store contract).
2. **Sync state in cubits** — Counter, todo, and chat banners no longer import `PendingSyncRepository` in presentation.
3. **Composition roots** — Online therapy and staff shift dialog receive dependencies from routes; `AiDecisionCubit` and IAP demo controls wired in `routes_demos.part.dart`.
4. **Conventions** — Chat/search/igaming cubits under `presentation/cubit/`; IoT cubit emits error codes (l10n in page); `ChatAuthSessionPort` for transport-hint refresh.
5. **Guardrail** — `tool/check_feature_modularity_leaks.sh` blocks `export` of `features/*/data/` from `features/*/domain/`.

## Verification

```bash
./tool/check_solid_presentation_data_imports.sh
./tool/check_feature_modularity_leaks.sh
./tool/check_flutter_domain_imports.sh
./bin/router_feature_validate
flutter test test/features/ai_decision_demo/ test/features/in_app_purchase_demo/ \
  test/features/counter/ test/features/todo_list/ test/features/chat/ \
  test/chat_cubit_test.dart test/features/online_therapy_demo/ \
  test/features/iot_demo/ test/features/staff_app_demo/
```

## Follow-up (same initiative)

- CounterPage: `CounterSyncBanner` composed in `CounterPageBody` (remote-config slot unchanged).
- Counter pending-sync counts filter by `counter` entity (matches todo/chat pattern); test in `offline_first_counter_repository_test.dart`.
- `CounterSyncQueueInspectorButton` accepts optional `CounterRepository`; Settings QA extras wire `getIt<CounterRepository>()` so inspector works without `CounterCubit`.
- `CounterSyncBanner` no-ops when `SyncStatusCubit` is absent (widget tests without full DI).
- `tool/check_feature_modularity_leaks.sh`: `find`+`grep` fallback when `rg` is unavailable (domain purity + data re-export checks).

## Out of scope (unchanged)

- event_bus / case_study demo `getIt` sandboxes
- Remaining l10n-in-cubit features (walletconnect, supabase_auth, playlearn, igaming) — follow-up PRs
