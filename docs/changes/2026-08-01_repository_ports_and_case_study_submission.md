# Repository ports and case-study submission

## Problem

Counter and todo repository contracts mixed CRUD, offline diagnostics, and
leaf adapter responsibilities. The case-study submit flow kept a multi-port
workflow in presentation, and retrying a partially persisted submission could
append the same history record twice.

## Scope

- Split counter/todo CRUD data-source and pending-sync diagnostics ports while
  keeping application-facing repository facades and no-op test adapters.
- Bind diagnostics in composition; preserve counter/todo offline-first behavior.
- Rename the Firebase Remote Config SDK adapter as a data source.
- Move the case-study submit and local-persist workflow into pure-Dart domain
  use cases; presentation owns visible error logging and state.
- Make local history persistence replace an existing record with the same case
  ID before a retry writes the fresh draft.

## Contract

Leaf adapters depend only on narrow CRUD ports. Offline-first facades provide
the application repository contract and, when available, the separate sync
diagnostics port. A retry after `saveRecords` succeeds but `saveDraft` fails
leaves exactly one record for the submitted case ID.

## Proof

```bash
cd apps/mobile && flutter test \
  test/features/case_study_demo/domain/use_cases/persist_case_study_submission_use_case_test.dart \
  test/features/case_study_demo/presentation/cubit/case_study_session_cubit_actions_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart \
  test/features/todo_list/data/offline_first_todo_repository_test.dart \
  test/features/remote_config/data/firebase_remote_config_data_source_test.dart
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_folder_contract.sh
bash tool/check_feature_modularity_leaks.sh
./bin/checklist
```

## Out of scope

No sync protocol, persisted schema, route behavior, or Remote Config values
change.
