# Extract `core` / `shared` into workspace packages

Move `apps/mobile/lib/core/**` and `apps/mobile/lib/shared/**` into existing workspace packages by responsibility.

Target: `apps/mobile/lib/` becomes thin app shell (`app/**` composition + `features/**` + `l10n/**` + `main*.dart`). No `core/` or `shared/` folders remain under app `lib/`.

## Status (2026-07-08)

### Done

- `shared/storage/**` → `packages/storage`
- `shared/http` interceptors + network/retry services → `packages/networking`
- `shared/ui`, `responsive`, reusable widgets → `packages/design_system`
- App-coupled widgets → `apps/mobile/lib/app/widgets/**`
- App services (`AppMemoryService`, `AppImageCacheManager`) → `apps/mobile/lib/app/services/**`
- Pure Dart helpers (`RetryPolicy`, `SubscriptionManager`, etc.) → `packages/utilities`
- Error taxonomy (`AppError`, `AppErrorCode`, `failure_to_app_error`, `HttpRequestFailure`) → `packages/utilities`
- `core/di/**` → `apps/mobile/lib/app/composition/**`
- `core/router/**` → `apps/mobile/lib/app/router/**`
- `core/bootstrap/**` → `apps/mobile/lib/app/bootstrap/**`
- Temporary shims under old `core/**` and `shared/**` paths until Phase 5 deletion

### Done (sync slice)

- `shared/sync/**` classified and moved:
  - **storage**: `SyncOperation`, `PendingSyncRepository`, `SyncableRepository`, registry, deferred exception
  - **networking**: coordinator, runner, job runner, schedule policy, status, cycle summary, FCM trigger contract
  - **app**: `sync_banner_helpers`, `sync_context_extensions`, `SyncStatusCubit` + state
- Tests moved to `packages/storage/test/sync/` and `packages/networking/test/sync/`
- Hive fingerprint manifest paths updated; generator resolves `apps/mobile/lib/` inputs

### Done (auth + config slice)

- `core/auth/jwt_claims_reader.dart`, `token_repository.dart` → `packages/auth`
- `core/auth/session_lifecycle_coordinator.dart` → `apps/mobile/lib/app/auth/`
- `core/config/**` → `apps/mobile/lib/app/config/`
- Tests: `packages/auth/test/`, `apps/mobile/test/app/auth/`, `apps/mobile/test/app/config/`
- `register_auth_services.dart` import clash fixed (`core_auth` prefix + `show AuthUser`)

### Done (flavor / theme / constants slice)

- `core/flavor.dart` → `apps/mobile/lib/app/config/flavor.dart`
- `core/constants/app_constants.dart` → `apps/mobile/lib/app/config/`
- `core/theme/app_theme.dart` → `apps/mobile/lib/app/theme/` (Mix tokens remain `design_system` re-export)
- Shims remain under `core/flavor`, `core/constants`, `core/theme`

### In progress

- Remaining `shared/utils/**` (cubit helpers, error handling, navigation, etc.)
- Remaining `shared/http/**` auth/supabase session glue
- Remaining `core/**` (platform_init, diagnostics, supabase, app_config, extensions, chat port)

### Next

- Phase 4: codegen, barrel cleanup, import scans
- Phase 5: delete `apps/mobile/lib/core` and `apps/mobile/lib/shared`
- Phase 6: docs + full validation lane

## Ownership map (draft)

### `apps/mobile/lib/shared/**`

- `shared/storage/**` → `packages/storage`
- `shared/http/**` → `packages/networking` (+ app adapters for auth glue)
- `shared/ui/**`, `shared/responsive/**`, reusable `shared/widgets/**` → `packages/design_system`
- `shared/utils/**`: pure Dart → `packages/utilities`; UI → `packages/design_system`
- `shared/extensions/**` (l10n) → `apps/mobile/lib/app/l10n_adapters/**`
- `shared/sync/**` → `packages/storage` / `packages/networking` + app adapters

### `apps/mobile/lib/core/**`

- `core/di/**` → `apps/mobile/lib/app/composition/**` ✅
- `core/router/**` → `apps/mobile/lib/app/router/**` ✅
- `core/bootstrap/**` → `apps/mobile/lib/app/bootstrap/**` ✅
- `core/auth/**` → `packages/auth` + `apps/mobile/lib/app/auth/` ✅
- `core/config/**` → `apps/mobile/lib/app/config/` ✅
- `core/flavor.dart`, `core/constants/**`, `core/theme/app_theme.dart` → `apps/mobile/lib/app/config/` + `app/theme/` ✅
- `core/theme/mix_app_theme.dart` → shim to `packages/design_system`
- Remaining `core/theme/**` → mostly shims; Mix tokens in `design_system`

## Notes

- `packages/core` and `packages/utilities` remain **pure Dart** (no Flutter deps).
- Prefer app adapters in `apps/mobile/lib/app/**` over leaking app imports into packages.
