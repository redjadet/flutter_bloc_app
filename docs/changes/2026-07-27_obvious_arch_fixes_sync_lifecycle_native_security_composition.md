# Obvious architecture fixes: sync ids, hydration lifecycle, one-shot sync start, and native security composition

## Summary

Batch refactor + hardening:

1. Move pending-sync entity IDs for `counter`/`todo` into domain constants and use them from Firebase session cleanup + repository implementations.
2. Prevent `CaseStudySessionCubit` from emitting after `close()` by guarding both the auth listener and `hydrate()`.
3. Move `ensureSyncStartedIfAvailable()` out of `build()` into one-shot `didChangeDependencies()` for sync widgets (queue inspector, counter banner, todo banner).
4. Move `createNativeSecurityShowcaseCubit()` into `app/composition/` so presentation layers don’t construct DI wiring.

## Validation

- `flutter test` (focused)
  - `test/features/counter/data/offline_first_counter_repository_test.dart`
  - `test/features/todo_list/data/offline_first_todo_repository_test.dart`
  - `test/app/auth/firebase_local_session_cleanup_test.dart`
  - `test/features/case_study_demo/presentation/cubit/case_study_session_cubit_actions_test.dart`
  - `test/features/counter/presentation/widgets/counter_sync_banner_test.dart`
  - `test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart`
  - `test/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit_test.dart`
  - `test/features/native_platform_showcase/presentation/pages/native_platform_showcase_page_test.dart`
- `flutter test --dart-define=SHOW_PENDING_SYNC_QUEUE_UI=true test/features/counter/presentation/widgets/counter_sync_queue_inspector_button_test.dart`
- `./bin/checklist` rerun after this note
