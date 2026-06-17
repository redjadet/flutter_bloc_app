# Counter stale pending push rejection

## Summary

- Prevent queued counter sync replay from overwriting a newer remote snapshot.
- Add regression coverage for stale pending operations during background sync.
- Align counter queued-push conflict handling with existing stale-remote apply
  rejection.

## Validation

- `flutter test test/features/counter/data/offline_first_counter_repository_test.dart`
- `tool/check_offline_first_remote_merge.sh`

