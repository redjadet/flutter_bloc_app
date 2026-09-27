# Background sync Object soft-fail harden

**Date:** 2026-09-27

## Why

#915 hardened per-feature offline soft-fail / enqueue paths to catch `Object`
and to avoid queueing programming `Error`s. The shared
`BackgroundSyncCoordinator` cycle still soft-failed only on `Exception`, so a
`StateError` (or other `Error`) from one `pullRemote` skipped remaining repos,
and a programming `Error` from `processOperation` aborted the pending batch.

## In

- `_pullAllRemote`: catch `Object` (soft-fail, continue next repo)
- `_processOperation`: keep `Exception` → `markFailed` backoff; add `Object`
  branch for non-Exception → log + **discard** (`markCompleted`, no retry),
  continue remaining ops
- Focused runner unit tests for both shapes

## Proof

- `dart test packages/networking/test/sync/background_sync_runner_test.dart`
- Host preflight / focused unit scripts; `./bin/integration_preflight` when
  available; GHA `run_integration=true` if iPhone sim needed for extra proof
