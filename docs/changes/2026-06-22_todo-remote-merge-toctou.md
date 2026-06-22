# Todo remote-merge TOCTOU guard

**Date:** 2026-06-22

## Summary

- Re-read local todo state immediately before remote merge saves so local edits
  made after the initial snapshot remain authoritative.
- Re-read synchronized local items before deleting rows absent from remote state
  so a concurrent pending edit is not deleted.
- Extend todo repository regression coverage for both save and delete races.

## Verification

```bash
flutter test test/features/todo_list/data/offline_first_todo_repository_test.dart
bash tool/check_offline_first_remote_merge.sh
./bin/checklist
```
