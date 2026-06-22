# Batch F — ship proof

**Date:** 2026-06-22

## Validation (final)

| Gate | Result |
| --- | --- |
| `flutter analyze --no-pub` | **PASS** |
| `CHECKLIST_ALLOW_REUSE=0 ./bin/checklist` | **PASS** (2537 unit/widget tests; coverage summary refreshed) |
| `./bin/checklist-fast` | **PASS** (reuse fingerprint) |
| `./bin/router_feature_validate` | **PASS** |
| `tool/check_inherited_widget_in_initstate.sh` | **PASS** |
| `tool/check_unguarded_null_assertion.sh` | **PASS** |
| `CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE=always ./bin/checklist` | **PASS** (follow-up lane) |
| `./bin/integration_tests` (iPhone 17e sim, iOS 26.5) | **PASS** — smoke 18, standard 26, exhaustive 27 |
| `./bin/agent-maintain closeout` | **PASS** |

## Review follow-ups (same day)

| Item | Result |
| --- | --- |
| IAP terminal results clear `isBusy` | **done** — `_onPurchaseResult` |
| IAP unknown stream product id | **done** — `IapDemoProductIds.unknownPurchaseStream` |
| Profile `_saveProfileToCache` rethrow | **done** — `pullRemote` + cold `getProfile` tests |
| IAP terminal failure cubit test | **done** — `simulatePurchaseResult` on fake repo |

## Earlier follow-ups

- `websocket_demo_page.dart` — post-frame connect uses local `cubit` (no `!`)
- `offline_first_counter_repository_test.dart` — poll helpers replace fixed `Future.delayed`
- IAP cubit — initializing formals (`this._fakeRepository`)

## Deferred / env-only

- `libpdfium.dylib` — not reproduced in current checklist run
- B6–B10, D4, D7 — documented in inventory (repro-first)

## Scope proof

All inventory **fix** rows B1–D3 + C1–C3 have regression tests. Deferred rows in [`2026-06-22_bug-hunt-inventory.md`](2026-06-22_bug-hunt-inventory.md).
