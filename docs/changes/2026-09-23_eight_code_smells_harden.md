# Eight code-smell harden pass

**Date:** 2026-09-23

## Why

Reduce “expensive future change” risk (Skillstuff eight smells as signals, not
auto-rewrites): duplicated credential rules, helper option accumulation,
discarded diagnostics, competing UI/state owners, cross-feature sync tax, and
hard-to-verify failure paths.

## In

- `CubitFailure` + preferred `onFailure` / `logErrors` on `CubitExceptionHandler`;
  migrate remaining hotspots off `onErrorWithDetails` / `specificExceptionHandlers`
- `StaffDemoPushTokenResult` sealed outcomes (+ unit tests for each skip/fail path)
- `SupabaseAuthCredentialPolicy` shared email/password rules
- `RealtimeSyncTrigger` + IoT adapter registration (networking ↔ IoT decoupling)
- Chart `ChartFetchMode`, calculator helper split, social-feed replayers,
  `_TodoRemoteMergeSession`, todo search field cubit sync, FFI cause logging,
  HF token failure tests
- Audit: [`docs/audits/eight_code_smells_harden_review_2026-09-23.md`](../audits/eight_code_smells_harden_review_2026-09-23.md)

## Out / not in this change

- ~~Migrating every remaining cubit still on legacy `onError`-only paths~~ →
  completed in [`2026-09-24_cubit_failure_migration.md`](2026-09-24_cubit_failure_migration.md)
- ~~Making `onError` optional when `onFailure` is set (API follow-up)~~ →
  completed in [`2026-09-24_cubit_failure_migration.md`](2026-09-24_cubit_failure_migration.md)

## Proof

- Focused: push-token repo, session cubit, cubit async helper, credential policy,
  chat/graphql/counter/deeplink/supabase, FFI, HF token, networking sync
- Codex review (`gpt-5.6-sol`): async realtime `stop`, full todo search sync,
  IoT `logErrors: false` for validation, exhaustive push-token boundary logging
- `./bin/checklist` (pass) + `./bin/integration_tests` (pass)
- `./bin/format`; `flutter analyze` clean on apps/mobile
