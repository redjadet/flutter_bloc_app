# Auth / Sync / Cubit Lifecycle Reliability Remeasure (2026-08-10)

Evidence-only re-measure for auth session, offline/sync, and Cubit lifecycle.
**No product behavior change in this PR.** Local logs under gitignored
`tmp/reliability_remeasure/`.

## Meta

| Field | Value |
| --- | --- |
| Date (UTC) | 2026-08-10 |
| HEAD | `1c27b5ac` on `main` (== `origin/main` at measure start) |
| Dirty tree at start | none |
| Scope | Auth session, offline/sync, Cubit lifecycle (auth/sync-adjacent) |
| Out of scope | AUTH-D01..D04 without unblock repro; whole-app Cubit sweep; Chat remote-watch (no entrypoint — `pullRemote` is empty hook) |

## Measurement table

| Lane | Command (CWD) | Exit | Elapsed | Decision-relevant result |
| --- | --- | ---: | ---: | --- |
| Auth | `apps/mobile`: `flutter test test/app/auth test/app/presentation/cubit/app_auth_cubit_test.dart test/shared/http test/features/auth test/shared/firebase/run_with_auth_user_test.dart` | 0 | 31s | **+137** passed |
| Sync networking | `packages/networking`: `flutter test test/sync` | 0 | 15s | **+39** passed (incl. auth pin / mid-push abort / pull pin) |
| Sync storage | `packages/storage`: `flutter test test/sync` | 0 | 15s | **+29** passed |
| Offline repos | `apps/mobile`: counter/todo/chat/profile/search offline_first repository tests | 0 | 14s | **+79** passed |
| Don't-overwrite guard | `bash tool/check_offline_first_remote_merge.sh` | 0 | 9s | Counter/Todo/IoT wired; pass |
| Cubit isClosed | `bash tool/check_cubit_isclosed.sh` | 0 | &lt;1s | Pass |
| Mutation supersession | `bash tool/check_mutation_success_after_guard.sh` | 0 | 1s | Pass |
| Lifecycle listen/mounted | `bash tool/check_lifecycle_error_handling.sh` | 0 | &lt;1s | Pass |
| Memory lint | `bash tool/run_memory_lint.sh` | 0 | 15s | Pass |
| Engineering scorecard | `bash tool/check_engineering_quality_scorecard_gate.sh` | 0 | 1s | Pass; filtered **85.16%**; core **75.32%** (record-only) |

## Seam inventory notes

### Auth

- `SignOutAwareAuthRepository` correctly exposes `sessionReadyAuthStateChanges` /
  `sessionReadyCurrentUser`. DI wraps Firebase auth before `AppAuthCubit` /
  router consumers.
- `AppAuthCubit` uses `CubitSubscriptionMixin` + `isClosed` before emit; tests
  cover sticky `sessionExpired` but **not** late stream events after `close()`,
  and **not** SignOutAware A→B session-ready delay end-to-end.
- Token manager / interceptor concurrent-401 suite green in auth lane.

### Offline / sync

- Counter/Todo remote-watch pause + auth pin contracts green (2026-07-29 /
  2026-08-01 hardening still holds under re-measure).
- Chat: `OfflineFirstChatRepository.pullRemote` is an empty future hook — **no
  remote watch**. Not eligible for watch-pause ranking.
- Profile/Search: cache-first; `processOperation` no-op. Don't-overwrite guard
  correctly limited to Counter/Todo/IoT mutation-merge features.
- **Gap:** `clearFirebaseLocalSessionData` clears todo/counter Hive, chat
  history, pending sync entity types, and profile cache — but **does not** call
  `SearchCacheRepository.clearCache()` despite search storing recent queries +
  result cache in Hive (`HiveSearchCacheRepository`).

### Cubit lifecycle

- Static guards clean for isClosed / mutation-success / listen onError.
- Auth/sync-adjacent cubits reviewed (`AppAuthCubit`, `SyncStatusCubit`,
  `ChatSyncStatusCubit`, counter/todo sync parts) show existing guards; residual
  risk is **missing deterministic regression tests**, not open static violations.

## Candidate scorecard

| ID | Finding | Repro (0–3) | Harm (0–3) | Proof gap (0–2) | Atomicity (0–2) | Total | Eligible (≥7 & repro≥2)? |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| SEARCH-01 | Session cleanup omits search Hive cache clear | 2 | 3 | 2 | 2 | **9** | **Yes → PR1** |
| AUTH-CUBIT-01 | Missing AppAuthCubit + SignOutAware A→B session-ready integration test | 2 | 3 | 2 | 2 | **9** | **Yes → PR2** |
| AUTH-CUBIT-02 | Missing AppAuthCubit late auth/invalidation event after `close()` regression | 2 | 2 | 2 | 2 | **8** | **Yes → PR3** |
| DOC-01 | `docs/testing_overview.md` cites stale `test/core/auth/session_lifecycle_coordinator_test.dart` | 3 | 1 | 1 | 2 | **7** | **Yes → absorb in PR0** |
| CHAT-WATCH | Chat remote-watch pause parity with Counter/Todo | 0 | 2 | 1 | 1 | 4 | No — no entrypoint |
| PROFILE-DOW | Wire profile into don't-overwrite guard | 1 | 1 | 1 | 1 | 4 | No — no pending-mutation merge |
| AUTH-D01 | Render FastAPI coordinator 401 hook | 0 | 2 | 1 | 1 | 4 | No — deferred unblock unmet |

## Locked fix queue (0–3)

### PR1 — SEARCH-01 (score 9)

- **Failure mode:** After Firebase sign-out / A→B account switch, next session
  can still read previous user's recent search queries and cached results from
  Hive.
- **Owner:** `apps/mobile/lib/app/auth/firebase_local_session_cleanup.dart` +
  search cache DI/port (mirror `ProfileCacheControlsPort` pattern if needed).
- **Write-set (proposed):** session cleanup + optional search clear port +
  `firebase_local_session_cleanup_test.dart` assertion + change note.
- **Proof:** failing test first — cleanup leaves search cache non-empty; after
  fix, `clearCache` invoked / recent queries empty.
- **Rollback:** revert cleanup call; search cache behavior returns to sticky
  across sessions.

### PR2 — AUTH-CUBIT-01 (score 9)

- **Failure mode:** Without an integration regression, AppAuthCubit could again
  bind a raw auth stream and emit account B while local cleanup still holds A.
- **Owner:** `apps/mobile/test/app/presentation/cubit/app_auth_cubit_test.dart`
  (and product code only if test fails against current DI contract).
- **Write-set:** test using `SignOutAwareAuthRepository` + coordinator A→B;
  code fix only if red.
- **Proof:** session-ready delay — Cubit stays on A (or loading) until cleanup
  publishes B.
- **Rollback:** delete the test / revert any accidental product change.

### PR3 — AUTH-CUBIT-02 (score 8)

- **Failure mode:** Late `authStateChanges` / invalidation event after
  `close()` could emit on a disposed Cubit if guards regress.
- **Owner:** `app_auth_cubit_test.dart`.
- **Write-set:** test closes Cubit, then pushes stream/invalidation; expect no
  throw and no state change after close.
- **Proof:** deterministic late-event test green; product change only if red.
- **Rollback:** remove test.

## Non-goals / deferred

- AUTH-D01..D04 remain deferred ([`authentication.md`](../authentication.md)).
- Chat remote-watch pause — no current entrypoint.
- Expanding don't-overwrite guard to Profile/Search — wrong fit (cache refresh,
  no mutation merge).
- Memory B2 dry-run remediation; badge rewrites; host asset drift sync from
  preflight warn.

## Doc drift (this PR)

- Fixed in PR0: [`docs/testing_overview.md`](../testing_overview.md) auth
  session lifecycle test path → `test/app/auth/session_lifecycle_coordinator_test.dart`
  (matches `tool/check_regression_guards.sh`).

## Related prior hardening

- [`docs/changes/2026-07-29_sync_auth_pin_and_remote_watch_pause.md`](../changes/2026-07-29_sync_auth_pin_and_remote_watch_pause.md)
- [`docs/changes/2026-08-01_remote_watch_session_cleanup_drain.md`](../changes/2026-08-01_remote_watch_session_cleanup_drain.md)
- [`docs/changes/2026-07-26_session_cleanup_profile_and_sync_ordering.md`](../changes/2026-07-26_session_cleanup_profile_and_sync_ordering.md)
