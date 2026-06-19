# Todo stale pending push rejection

## Summary

- Prevent queued todo sync replay from overwriting a newer remote item.
- Add `TodoMergePolicy.shouldPushPendingToRemote` so stale pending todo saves
  follow the same conflict rule as stale remote applies.
- Extend the offline-first remote-merge guard to run todo repository coverage.

## Validation

- `flutter test test/features/todo_list/data/offline_first_todo_repository_test.dart`
- `tool/check_offline_first_remote_merge.sh`
