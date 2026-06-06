# Auth repository presentation seams (AccountSection + ChatCubit)

**Date:** 2026-06-06

## Summary

- **`AccountSection`**: Removed direct `firebase_auth` / `firebase_core` usage; listens to injected `core/auth/AuthRepository` (`authStateChanges`, `currentUser` initial data). Sign-out UI still uses FirebaseUI `SignOutButton`. Wired from `SettingsPage` via `routes_core.part.dart`.
- **`ChatCubit`**: Removed direct Firebase/Supabase SDK imports from presentation; optional DI for `AuthRepository`, `SupabaseAuthRepository`, and `RenderOrchestrationHfTokenProvider`. Auth listeners drive transport-hint refresh and clear HF token cache on Firebase sign-out.
- **Router / chat entrypoints**: `routes_demos*` and chat list widgets pass auth deps from `get_it`.
- **Tests**: `test/account_section_test.dart` fakes `AuthRepository`; `test/chat_cubit_test.dart` adds auth-driven transport-hint coverage.
- **Docs**: `docs/authentication.md`, `docs/race_conditions_and_bugs_analysis.md` (§1.4) updated for `AuthRepository` seam.

## Verification

```bash
dart analyze lib/features/settings lib/features/chat/presentation lib/app/router/routes_core.part.dart lib/app/router/routes_demos.dart lib/app/router/routes_demos.part.dart test/account_section_test.dart test/chat_cubit_test.dart
flutter test test/account_section_test.dart test/settings_page_test.dart test/chat_cubit_test.dart
./bin/checklist
CHECKLIST_INTEGRATION_DEVICE=77ECE67D-12D9-4605-889C-A715DE7F9F13 INTEGRATION_TESTS_RUN_COVERAGE=false ./bin/integration_tests integration_test/settings_flow_test.dart integration_test/chat_list_flow_test.dart
```

Integration (iPhone 17e, 2026-06-06): **2/2 passed** (`settings_flow_test`, `chat_list_flow_test`).
