# Bug hunt inventory (Batch A baseline)

<!-- markdownlint-disable MD060 -->

**Date:** 2026-06-22
**Status:** Batches A–F complete (see change notes below). Plan closure: 2026-06-22 — full checklist + iOS simulator integration (27 flows) green; deferred rows documented with repro-first rationale.

## Baseline gate summary

| Check | Result | Notes |
| --- | --- | --- |
| `./bin/checklist` | **PASS** | Forced full run 2537 tests; reuse fingerprint OK |
| iOS integration (`./bin/integration_tests`) | **PASS** | iPhone 17e sim — exhaustive 27 flows |
| `tool/check_inherited_widget_in_initstate.sh` | **PASS** | Extended for `context.cubit<` + postFrameCallback allowance |
| `tool/check_offline_first_remote_merge.sh` | **PASS** | Counter watch tests use poll-until-stable (no fixed delay) |
| `tool/check_mutation_success_after_guard.sh` | **PASS** | |
| `tool/check_regression_guards.sh` | **PASS** | |

### Follow-up fixes (post Batch F)

| Item | Disposition |
| --- | --- |
| `websocket_demo_page.dart` `_cubit!.connect()` | **done** — local `cubit` after post-frame read |
| `offline_first_counter_repository_test.dart` remote watch timing | **done** — `_waitForLocalCount` / `_waitForWatchMergeSettled` |
| IAP `prefer_initializing_formals` | **done** (prior) — `this._fakeRepository` initializing formals |
| IAP unknown stream product + terminal `isBusy` | **done** — review follow-up |
| Profile cache save rethrow | **done** — review follow-up |
| `libpdfium.dylib` regression guard | **not repro** on current env; re-check when `pdfrx` widget tests land |

---

## Infrastructure finding

| ID | Finding | Disposition | Status |
| --- | --- | --- | --- |
| INF-01 | Guard missed `context.cubit<Type>()` | **fix** | **done** |
| INF-02 | `libpdfium.dylib` regression guard | **pre-existing** | not repro (env) |
| INF-03 | Checklist parallel flaky counter test | **fix** | **done** |

---

## Mechanical hits — disposition table

| ID | Feature | Disposition | Batch | Status |
| --- | --- | --- | --- | --- |
| B1–B5 | streams | **fix** | B | **done** |
| B6 | deeplink | **deferred** | B | done |
| B7 | realtime_market | **deferred** | E | done |
| B8 | counter onError | **deferred** | E | done |
| B9 | todo onError | **deferred** | E | done |
| B10 | todo cancelOnError | **document** | E | done |
| C1 | CallCubit guard | **fix** | C | **done** |
| C2/C2b/C3 | initState | **fix** | C | **done** |
| D1 | chat reset persist-first | **fix** | D | **done** |
| D2 | profile pullRemote throws + cache save rethrow | **fix** | D | **done** |
| D3 | graphql await refresh | **fix** | D | **done** |
| D4 | chat unawaited persist | **deferred** | E | done |
| D5 | staff pullRemote no-op | **document + test** | E | **done** |
| D6 | chat pullRemote stub | **document** | — | done |
| D7 | DI ensureConfigured | **deferred** | E | done |

---

## 34-feature audit worksheet

| Feature | Audit status | Notes |
| --- | --- | --- |
| ai_decision_demo | deferred | Equatable legacy — out of scope |
| auth | pass | |
| calculator | pass | partial tests |
| camera_gallery | pass | postFrameCallback pattern |
| case_study_demo | pass | |
| chart | pass | |
| chat | fix | D1 done; D4 deferred |
| counter | pass | B8 deferred; watch timing stabilized |
| deeplink | fix | B6 deferred |
| event_bus_demo | pass | |
| example | pass | |
| fcm_demo | pass | partial tests |
| genui_demo | deferred | log-only stream onError |
| google_maps | pass | |
| graphql_demo | fix | D3 done |
| igaming_demo | pass | partial tests |
| in_app_purchase_demo | fix | B3 + review (unknown product, terminal busy) |
| iot | deferred | BLE log-only onError |
| iot_demo | fix | B5 done |
| library_demo | pass | |
| native_platform_showcase | pass | |
| online_therapy_demo | fix | C1–C3 done |
| playlearn | pass | partial tests |
| profile | fix | D2 done |
| realtime_market | deferred | B7 |
| remote_config | pass | |
| scapes | deferred | demo favorites — out of scope |
| search | pass | RequestIdGuard present |
| settings | pass | |
| staff_app_demo | fix/doc | D5 done |
| supabase_auth | fix | B1 done |
| todo_list | deferred | B9/B10 |
| walletconnect_auth | pass | |
| websocket | fix | B4, C3 done |

---

## Change notes

1. [`2026-06-22_batch-b-stream-error-hardening.md`](2026-06-22_batch-b-stream-error-hardening.md)
2. [`2026-06-22_batch-c-therapy-initstate-call-guard.md`](2026-06-22_batch-c-therapy-initstate-call-guard.md)
3. [`2026-06-22_batch-d-data-chat-profile-graphql.md`](2026-06-22_batch-d-data-chat-profile-graphql.md)
4. [`2026-06-22_batch-e-feature-audit-closeout.md`](2026-06-22_batch-e-feature-audit-closeout.md)
5. [`2026-06-22_batch-f-ship-proof.md`](2026-06-22_batch-f-ship-proof.md)
