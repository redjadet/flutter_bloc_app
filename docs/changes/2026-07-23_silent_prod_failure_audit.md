# Silent production-failure audit (session + sync)

## Summary

Harden auth A→B / sign-out cleanup so local session data and pending sync do
not leak across accounts, and so sync cannot race during session clear. Gate
router auth on `sessionReadyAuthStateChanges` after cleanup completes.

## Bug class

- Auth `Stream.listen` async callbacks raced: newer null/session could publish
  before an older A→B cleanup finished.
- `BackgroundSyncCoordinator.stop()` alone did not block immediate flush/FCM
  triggers during cleanup.
- Pending sync / chat local state could survive account switch when clear paths
  were incomplete or fail-open.
- Integration overflow helper only matched Material `PopupMenuEntry`, so iOS
  Cupertino action-sheet destinations timed out.

## Changes (feature touch)

- Auth: `SignOutAwareAuthRepository`, session lifecycle serialize + generation,
  Firebase local session cleanup, DI gate on session-ready stream.
- Counter / IoT / storage pending-sync clear paths and fail-closed guards.
- Networking: `quiesceForSessionCleanup` / `resumeAfterSessionCleanup`.
- Integration: overflow open accepts Cupertino action-sheet entries.
- Auth gate: `GoRouter.maybeOf` for redirects; coverage pump uses `MaterialApp.router`.

## Verification

```bash
./bin/format --changed
bash tool/check_feature_brief_linked.sh
./bin/checklist
CHECKLIST_INTEGRATION_DEVICE=<iphone-sim-udid> \
  INTEGRATION_TESTS_RUN_COVERAGE=0 INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
  ./bin/integration_tests
INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome ./bin/integration_preflight
```
