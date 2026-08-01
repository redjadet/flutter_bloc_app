# Remote-watch session-cleanup drain

## Problem

During a Firebase account switch, a todo or counter remote-watch merge could
already be inside a local Hive save when session cleanup paused the watches.
The pause flag blocked later work, but cleanup could clear first and the stale
save could then restore the previous account's data.

## Scope

- Track todo and counter remote-watch merge futures.
- Pause first, then wait for tracked merges before clearing local state.
- Keep post-`await` pause checks as an early-abort optimization.
- Add deterministic gated-save regression tests for both repositories.

## Out of scope

- Remote-watch protocol, schema, sync queue, routes, and UI behavior.

## Contract

`clearAllLocalData()` waits for any remote-watch merge already started before
clearing its local store. No new merge starts after
`pauseRemoteWatchForSessionCleanup()`.

## Tests

- Todo: a watch merge pauses inside local `save`; cleanup releases it and the
  final Hive store remains empty.
- Counter: same gated-save race; final local snapshot remains empty.

## Proof

```bash
cd apps/mobile && flutter test \
  test/features/todo_list/data/offline_first_todo_repository_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart
./bin/checklist
```

## Rollback

Revert the focused change if session cleanup must not wait for local
remote-watch writes; restoring that behavior reopens the cross-account
persistence risk.
