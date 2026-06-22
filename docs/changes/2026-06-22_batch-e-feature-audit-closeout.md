# Batch E — 34-feature audit closeout

**Date:** 2026-06-22

## Summary

Timeboxed worksheet pass across 34 modules. **Fix** items tracked in inventory (B–D) implemented in prior batches. Remaining mechanical hits **B7–B10** closed as **deferred** — no repro proving stale UI in timebox.

| ID | Disposition | Rationale |
| --- | --- | --- |
| B7 realtime_market `onError` | deferred | Log-only; stream reconnect path exists; no stale UI repro |
| B8 counter sync `onError` | deferred | Badge paths recover on next load; no repro |
| B9 todo sync badge `onError` | deferred | Same as counter |
| B10 todo `cancelOnError: true` | documented | Intentional — `_scheduleRemoteRestart` on error/done |
| D4 chat unawaited persist | deferred | Kill-mid-persist needs integration harness |
| D5 staff `pullRemote` no-op | done | Documented + regression test |
| D7 DI `ensureConfigured` | deferred | No failing repro in baseline |

Worksheet: all 34 features have non-pending audit status in inventory.

## Verification

```bash
flutter test test/features/staff_app_demo/data/offline_first_staff_demo_event_proof_repository_test.dart --name pullRemote
```
