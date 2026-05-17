---
name: agents-references
description: External references and key file paths for this repo. Use when locating theme, DI, lifecycle, sync, HTTP, or Supabase code.
---

# References

**Doc index:** `docs/README.md`, `docs/agent_project_context.md` (topic table). **Layout:** `agents-repo-context`. **Rules:** `agents-canonical-rules` (+ scoped children). Prefer `rg` over loading long doc lists.

## External references

- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter AI rules](https://raw.githubusercontent.com/flutter/flutter/refs/heads/master/docs/rules/rules.md)
- [Dio 401 race note](https://medium.com/@simra.cse/your-dio-interceptor-is-swallowing-401s-heres-the-race-condition-10ae0e93e728)

## Key source paths

### Theme and design tokens

- `lib/core/theme/` — `ThemeData`, `ColorScheme`, Mix theme
- `lib/core/theme/mix_app_theme.dart` — Mix token definitions
- `lib/shared/design_system/app_styles.dart` — Mix `Style` presets
- `lib/shared/widgets/common_card.dart` — reusable card
- `lib/shared/ui/typography.dart` — `AppTypography`

### Core and shared

- `lib/core/constants/` — app-wide constants
- `lib/shared/extensions/responsive.dart` — responsive helpers
- `lib/shared/ui/` — UI utilities
- `lib/shared/widgets/` — composite widgets (layouts, skeletons)
- `lib/shared/components/` — design-system primitives

### DI

- `lib/core/di/injector*.dart` — main injector + helpers
- `lib/core/di/register_*_services.dart` — per-feature DI files

### Lifecycle and async safety helpers

- `lib/shared/utils/request_id_guard.dart` — `RequestIdGuard`
- `lib/shared/utils/in_flight_coalescer.dart` — `InFlightCoalescer`, `KeyedInFlightCoalescer`
- `lib/shared/utils/stream_controller_lifecycle.dart` — `StreamControllerSafeEmit`, `StreamControllerLifecycle`
- `lib/shared/utils/cubit_async_operations.dart`
- `lib/shared/utils/cubit_subscription_mixin.dart`
- `lib/shared/utils/subscription_manager.dart`

### Sync

- `lib/shared/sync/background_sync_coordinator.dart`
- `lib/shared/sync/background_sync_runner.dart`
- `lib/shared/sync/sync_banner_helpers.dart`

### HTTP and auth

- `lib/shared/http/app_dio.dart`
- `lib/shared/http/auth_token_manager.dart`
- `lib/shared/http/interceptors/`

### Safe parsing and errors

- `lib/shared/utils/safe_parse_utils.dart`
- `lib/shared/utils/http_request_failure.dart`
- `lib/shared/utils/network_error_mapper.dart`
- `lib/shared/utils/error_codes.dart`
- `lib/shared/utils/error_handling.dart`

### Supabase and Firebase

- `lib/core/supabase/edge_then_tables.dart`
- `lib/shared/firebase/realtime_database_guard.dart`
- `supabase/migrations/`

### Offline-first (don’t-overwrite)

- `lib/features/counter/data/offline_first_counter_repository.dart`
- `lib/features/todo_list/data/offline_first_todo_repository.dart`
- `lib/features/iot_demo/data/offline_first_iot_demo_repository.dart`

### Isolates and deferred pages

- `lib/shared/utils/isolate_json.dart`
- `lib/app/router/deferred_pages/`

### Type-safe BLoC access

- `lib/shared/extensions/type_safe_bloc_access.dart`
- `lib/shared/widgets/type_safe_bloc_selector.dart`
- `lib/shared/utils/bloc_provider_helpers.dart`
- `lib/shared/utils/state_transition_validator.dart`
- `lib/shared/utils/sealed_state_helpers.dart`

### Test helpers

- `test/test_helpers.dart`
- `test/helpers/pump_with_mix_theme.dart`
- `test/helpers/supabase_test_setup.dart`
- `test/goldens/`
