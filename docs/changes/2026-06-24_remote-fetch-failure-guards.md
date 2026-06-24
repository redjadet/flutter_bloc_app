# Remote fetch failure guards (todo + counter)

**Date:** 2026-06-24

## Summary

- **Bug fix:** `RealtimeDatabaseTodoRepository.fetchAll` and `RealtimeDatabaseCounterRepository.load` no longer return empty/default data via `onFailureFallback` on Firebase errors. Failed reads now propagate to offline-first `pullRemote`, which logs and skips merge instead of treating failure as an empty remote.
- **Static guard:** `tool/check_remote_fetch_failure_fallback.sh` fails CI when remote read ops use `onFailureFallback` (wired in `tool/delivery_checklist.sh`).
- **Regression tests:** `pullRemote does not delete local items when remote fetch fails` (todo), `pullRemote does not overwrite local when remote load fails` (counter); inventory extended in `tool/check_offline_first_remote_merge.sh`.
- **Docs:** [`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md) § Remote fetch failures; validation catalog + testing matrix updated.

## Verification

```bash
bash tool/check_remote_fetch_failure_fallback.sh
bash tool/check_offline_first_remote_merge.sh
flutter test test/features/todo_list/data/realtime_database_todo_repository_test.dart test/realtime_database_counter_repository_test.dart --name "rethrows"
flutter test test/features/todo_list/data/offline_first_todo_repository_test.dart test/features/counter/data/offline_first_counter_repository_test.dart --name "pullRemote does not"
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
```
