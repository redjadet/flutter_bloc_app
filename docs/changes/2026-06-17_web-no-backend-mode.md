# Web: no-backend mode (guest-first + graceful fallbacks)

**Date:** 2026-06-17

## Summary

- **Web policy (`BackendAvailability`)**: Centralized runtime flags for backend readiness (Firebase/Supabase) and web-only “no-backend mode” behavior.
- **Auth (web)**: When Firebase Auth is unavailable, web uses a local guest auth repository (release included) instead of hard failing.
- **Demo routes (Chat / IoT)**: Web bypasses Supabase session gates; pages stay reachable and show a backend-disabled banner when backends are not configured.
- **Chat**: Composite chat now supports a local demo reply fallback when no remote transport is usable on web no-backend mode.
- **UX**: Added `BackendDisabledBanner` + localized strings across supported locales.
- **Build tooling**: Hardened FlutterFire Crashlytics symbol upload script for Debug/simulator and local `flutterfire` failures so iOS integration builds do not fail. iOS also conditionally copies local `GoogleService-Info.plist` into `Runner.app` when present, preventing simulator `FirebaseApp.configure()` launch crashes without making fresh checkouts depend on gitignored Firebase files.

## Files (high signal)

| Area | Paths |
| --- | --- |
| Policy | `apps/mobile/lib/core/config/backend_availability.dart`, `apps/mobile/lib/core/bootstrap/bootstrap_coordinator.dart` |
| DI | `apps/mobile/lib/core/di/groups/register_core_services.dart`, `register_auth_services.dart`, `register_chat_services.dart` |
| Routes | `apps/mobile/lib/app/router/routes_demos.part.dart` |
| Features | `apps/mobile/lib/features/chat/data/composite_chat_repository.dart`, chat/IoT pages |
| Shared UI | `apps/mobile/lib/shared/widgets/backend_disabled_banner.dart`, `apps/mobile/lib/l10n/app_*.arb` |
| Tooling | `tool/patch_ios_flutterfire_crashlytics_upload.sh`, iOS/macOS `project.pbxproj` |

## Verification

```bash
flutter test test/core/config/backend_availability_test.dart
flutter test test/shared/widgets/backend_disabled_banner_test.dart
flutter test test/features/chat/data/composite_chat_repository_test.dart
flutter test test/core/bootstrap/bootstrap_coordinator_additional_test.dart
./bin/integration_preflight
./bin/checklist
flutter run -d 77ECE67D-12D9-4605-889C-A715DE7F9F13 --debug --no-pub
```
