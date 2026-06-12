# Mutation success ack + counter remote-watch TOCTOU

**Date:** 2026-06-12

## Summary

- **Therapy demo cubits**: After a successful `createAppointment` / `sendMessage`, return success (or clear draft) even when `RequestIdGuard` was superseded by a newer read — avoids false failure UI and duplicate user retries.
- **Offline-first counter**: Re-read local Hive snapshot immediately before applying a remote merge in `watch` / `pullRemote` so a concurrent local write during the first load cannot be overwritten (TOCTOU).

## Verification

```bash
flutter test test/features/online_therapy_demo/edge_cases_test.dart --name "reports success when superseded"
flutter test test/features/counter/data/offline_first_counter_repository_test.dart --name "re-checks local"
```
