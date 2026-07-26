# Session cleanup: profile cache + sync resume ordering

## Summary

Close two cross-account leaks in Firebase session cleanup:

1. Clear `profile_cache` Hive data on sign-out / account switch (user B could
   otherwise see user A's cached profile PII).
2. Defer `BackgroundSyncCoordinator.resumeAfterSessionCleanup` until after
   session-ready identity is published so active todo/counter watchers cannot
   briefly show the next account's remote data while `sessionReadyCurrentUser`
   still reflects the previous account.

## Validation

- `firebase_local_session_cleanup_test.dart`
- `session_lifecycle_coordinator_test.dart`
