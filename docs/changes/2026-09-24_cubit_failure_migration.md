# CubitFailure / onFailure migration wave

**Date:** 2026-09-24

## Why

Finish the reliability follow-up left open in
[`2026-09-23_eight_code_smells_harden.md`](2026-09-23_eight_code_smells_harden.md):
migrate remaining cubits off string-only `onError` paths and make `onError`
optional when `onFailure` is set.

## In

- `CubitExceptionHandler.handleException` / `executeAsync` / `executeAsyncVoid`:
  `onError` is optional; assert that `onFailure` or `onError` is provided
  **before** running the operation / normalizing the error
- Migrated remaining `CubitExceptionHandler` call sites to `onFailure`
  (websocket, FCM, chat list/sync/helpers, staff_demo, online_therapy, todo,
  counter sync, genui, igaming, maps, settings, profile, search, remote_config,
  camera_gallery, case_study, walletconnect, iot_demo, and previously mixed
  chart / graphql / deeplink / supabase / counter sites)
- Removed no-op `onError: (_) {}` stubs where `onFailure` already owned the path
- Maps/todo failure paths use `failure.appError` (dead `onAppError` + `latestError`
  pattern removed — `onAppError` does not run when `onFailure` is set)
- Extended `cubit_async_operations_test` for onFailure-only, onError-only,
  neither-throws-before-operation, and mapped `appError` cases

## Out / not in this change

- StreamSubscription `onError` (Dart stream API) — e.g. sync status streams,
  supabase auth state listeners
- Auth route guards / RegisterPage backend (needs ADR)
- Perf W3 / jank optimization (measure-first admission still required)
- MQ-B3 memory AST rules

## Proof

- `flutter analyze` on migrated cubit paths (clean)
- `flutter test` focused: cubit async helper + websocket / FCM / chat / staff /
  therapy / chart / graphql / counter / todo / genui (as available)
- `./bin/format`
- `./bin/checklist` (run at closeout)
