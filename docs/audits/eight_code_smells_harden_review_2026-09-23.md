# Eight code-smell harden review (2026-09-23)

Investigation against [Skillstuff: 8 code smells senior engineers notice](https://medium.com/skillstuff/8-code-smells-senior-engineers-notice-immediately-b52b76717552): treat smells as **signals**, not automatic refactors. Key question: how much context and risk will the next change demand?

Worktree: `codex/harden-eight-smells` → `../flutter_bloc_app-harden-eight-smells`.

## Matrix

| # | Signal | Hotspot | Action |
| --- | --- | --- | --- |
| 1 | Too much background knowledge | Social-feed queue; todo remote merge | **Fixed** → like/comment/backoff replayers; `_TodoRemoteMergeSession` |
| 2 | Boolean workflows | Chart + calculator cubits | **Fixed** → `ChartFetchMode`; split editable helpers |
| 3 | Duplicated business rules | Supabase email/password | **Fixed** → `SupabaseAuthCredentialPolicy` |
| 4 | Helper option accumulation | `CubitExceptionHandler` | **Fixed** → `CubitFailure` + `onFailure` only (legacy hooks removed); remaining cubits migrated |
| 5 | Discarded diagnostics | FFI secure core | **Fixed** → log + `SecureCoreInternalFailure(cause:)` |
| 6 | Competing state owners | Todo search field | **Fixed** → listen when cubit clears query |
| 7 | Cross-cutting change tax | Sync ↔ IoT demo | **Fixed** → `RealtimeSyncTrigger` + IoT adapter registration |
| 8 | Hard to verify failures | HF token provider; staff push tokens | **Fixed** → catch override failures + tests; `StaffDemoPushTokenResult` sealed outcomes |

## Pass 3 (this slice)

- Removed `onErrorWithDetails` / `specificExceptionHandlers` from `CubitExceptionHandler`; call sites use `onFailure` (+ `logErrors: false` where handlers own severity).
- Migrated: supabase auth, deeplink, counter (×3), graphql demo, chat send.
- Staff push tokens: `StaffDemoPushTokenResult` (`Registered` / `Skipped` / `Failed`); session logs skips only (repo already logs failures).

## Proof

- `flutter test` social-feed offline-first repository; iot_demo cubit; chart presentation tests as present
- `flutter test packages/networking/test/sync/background_sync_coordinator_test.dart` (incl. realtime trigger)
- Prior pass: FFI secure core + HF token failure tests
- Pass 3: graphql/chat/counter/deeplink/supabase cubits; staff session; `cubit_async_operations_test`; credential policy test
- Staff push tokens: `apps/mobile/test/features/staff_app_demo/data/firestore_staff_demo_push_token_repository_test.dart` (each `StaffDemoPushTokenSkipReason` + `Failed` + `Registered`)
- Pre-commit: `./bin/checklist` (pass) + `./bin/integration_tests` (pass; GraphQL domain failures keep `logErrors: false`)
- `./bin/format`
- `flutter analyze` (apps/mobile): no issues
