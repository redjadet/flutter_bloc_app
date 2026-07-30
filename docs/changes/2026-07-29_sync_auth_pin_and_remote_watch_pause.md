# Sync auth pin + remote-watch pause on session cleanup

## Feature: Account-switch sync isolation (follow-up to session cleanup)

### Problem

After prior session-cleanup fixes, two races remained on Firebase account
switch (A→B):

1. An in-flight pending sync `processOperation` could call `runWithAuthUser`
   across awaits and write user A's payload under user B's RTDB paths if auth
   flipped mid-push.
2. Offline-first todo/counter remote watches could rebind to B and merge into
   shared Hive while session-ready identity still reflected A during cleanup
   quiesce.
3. Background `pullRemote` ran outside the auth pin. A pull beginning under A
   could therefore resolve B after an auth flip and merge B's RTDB todo data
   before cleanup paused the merge.

### Scope

- In: pin cycle-start Firebase uid around each pending push; fail closed in
  `runWithAuthUser` when live uid diverges; pause/resume todo+counter remote
  watches around `clearFirebaseLocalSessionData` / resume; pin every
  `pullRemote`, propagate its typed auth-change abort, and re-check Todo's
  pause after the remote fetch before merge.
- Out: presentation UI, non-Firebase providers, chat remote watches.

### Layers touched

- [x] data (offline-first todo/counter)
- [x] DI / app auth session cleanup
- [x] networking sync (`SyncAuthPinScope`)
- [ ] domain
- [ ] presentation
- [ ] routes / l10n

### Tests (executable contract)

- [x] Unit: pin scope + mid-push auth abort leaves pending unmarked —
  `packages/networking/test/sync/`
- [x] Unit: `runWithAuthUser` throws (and does not use `onFailureFallback`) on
  pin divergence — `apps/mobile/test/shared/firebase/run_with_auth_user_test.dart`
- [x] Unit: todo pause remote watch for session cleanup —
  `apps/mobile/test/features/todo_list/data/offline_first_todo_repository_test.dart`
- [x] Unit: pull pins the cycle uid and auth-change aborts are not failures —
  `packages/networking/test/sync/background_sync_runner_test.dart`
- [x] Unit: Todo/Counter propagate typed pull aborts; Todo skips a merge when
  cleanup starts during fetch —
  `apps/mobile/test/features/{todo_list,counter}/data/`

### Proof command

```bash
(cd packages/networking && flutter test test/sync/)
(cd apps/mobile && flutter test \
  test/shared/firebase/run_with_auth_user_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart \
  test/features/todo_list/data/offline_first_todo_repository_test.dart \
  --name 'pauseRemoteWatch|pinned uid|SyncAuthUserChanged|session cleanup')
```

### Risks

- Over-abort: sync may leave ops pending until next cycle after switch (intended).
- Pause/resume mismatch: remote watches stuck paused if resume path skipped —
  resume is paired with `resumeBackgroundSyncAfterSessionCleanup`.
