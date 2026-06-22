# Todo remote-merge TOCTOU guard

**Date:** 2026-06-22

## Summary

- Re-read local todo state immediately before remote merge saves so local edits
  made after the initial snapshot remain authoritative.
- Re-read synchronized local items before deleting rows absent from remote state
  so a concurrent pending edit is not deleted.
- Extend todo repository regression coverage for both save and delete races.
- Add remote-watch TOCTOU regression test (parity with counter).
- Add remote-watch TOCTOU delete regression test and static stale-remote watch tests (full parity with counter coverage).
- Add counter `pullRemote re-checks local before save when local advances` (parity with todo).
- Document TOCTOU re-read requirement in `docs/offline_first/dont_overwrite_guide.md`.
- Extend `tool/check_offline_first_remote_merge.sh` inventory regex for `re-checks local` tests.

## Verification

```bash
flutter test test/features/counter/data/offline_first_counter_repository_test.dart --name "re-checks local"
flutter test test/features/todo_list/data/offline_first_todo_repository_test.dart --name "re-checks local"
flutter test test/features/todo_list/data/offline_first_todo_repository_test.dart --name "remote watch does not overwrite newer"
bash tool/check_offline_first_remote_merge.sh
./bin/checklist
```
