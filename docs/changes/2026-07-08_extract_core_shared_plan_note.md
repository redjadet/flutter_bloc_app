# Extract `core` / `shared` into workspace packages

Move `apps/mobile/lib/core/**` and `apps/mobile/lib/shared/**` into existing workspace packages by responsibility.

Target: `apps/mobile/lib/` becomes thin app shell (`app/**` composition + `features/**` + `l10n/**` + `main*.dart`). No `core/` or `shared/` folders under app `lib/`.

## Status (2026-07-09)

**Phase 5 complete** — merged [#458](https://github.com/redjadet/flutter_bloc_app/pull/458) (`57bc68ac` on `main`).

| Gate | Result |
| --- | --- |
| `./bin/checklist` | PASS (~2522 tests, ~80.25% coverage) |
| `./bin/integration_preflight` | PASS (log filter + Chrome web bootstrap) |
| iOS integration smoke | PASS (18/18 on iPhone simulator) |
| PR #458 CI | PASS |

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
- `shared/sync/**` classified and moved:
  - **storage**: `SyncOperation`, `PendingSyncRepository`, `SyncableRepository`, registry, deferred exception
  - **networking**: coordinator, runner, job runner, schedule policy, status, cycle summary, FCM trigger contract
  - **app**: `sync_banner_helpers`, `sync_context_extensions`, `SyncStatusCubit` + state
- Tests moved to `packages/storage/test/sync/` and `packages/networking/test/sync/`
- Hive fingerprint manifest paths updated; generator resolves `apps/mobile/lib/` inputs
- `core/auth/jwt_claims_reader.dart`, `token_repository.dart` → `packages/auth`
- `core/auth/session_lifecycle_coordinator.dart` → `apps/mobile/lib/app/auth/`
- `core/config/**` → `apps/mobile/lib/app/config/`
- Tests: `packages/auth/test/`, `apps/mobile/test/app/auth/`, `apps/mobile/test/app/config/`
- `register_auth_services.dart` import clash fixed (`core_auth` prefix + `show AuthUser`)
- `core/flavor.dart` → `apps/mobile/lib/app/config/flavor.dart`
- `core/constants/app_constants.dart` → `apps/mobile/lib/app/config/`
- `core/theme/app_theme.dart` → `apps/mobile/lib/app/theme/` (Mix tokens remain `design_system` re-export)
- Remaining `shared/utils/**`, `shared/http/**` auth glue, `core/**` (platform_init, diagnostics, supabase, app_config, extensions, chat port) → `app/**` or workspace packages
- **Phase 4:** codegen, barrel cleanup, bulk import rewrites (`tool/phase5_rewrite_imports.py`, `tool/phase5_add_missing_imports.py`, `tool/fix_self_and_duplicate_imports.py`)
- **Phase 5:** deleted `apps/mobile/lib/core/` and `apps/mobile/lib/shared/` entirely
- **Phase 5 follow-up:** `shared/media/**` → `packages/app_shared_flutter/lib/src/media/`; l10n adapter → `apps/mobile/lib/app/l10n_adapters/media_pick_error_messages.dart`
- **Phase 6:** CODEMAP/docs path sweep, guard scripts fixed for `APP_ROOT` / `WORKSPACE_ROOT`, integration preflight restored, DI dedupe (`TokenRepository` owned by auth registration)

### Optional backlog (not merge blockers)

- [x] Extract `apps/mobile/lib/shared/media/**` into `packages/app_shared_flutter` (l10n adapter stays in `app/l10n_adapters/`)
- [ ] Doc sweep for stale `lib/core/` / `lib/shared/` references in historical plan prose (melos plan § inventory)
- [x] `check_regression_guards.sh` auto-triggers: normalize `apps/mobile/` paths before matching
- [ ] Exhaustive iOS integration (`all_flows_test.dart`) — smoke + preflight proven locally/CI only
- [ ] Melos plan post-merge: PR-F wave 2, PR-C deferred utils, extra apps (see [`melos_monorepo_migration_plan.md`](../plans/melos_monorepo_migration_plan.md))

## Ownership map (final)

### `apps/mobile/lib/shared/**`

- `shared/storage/**` → `packages/storage` ✅
- `shared/http/**` → `packages/networking` (+ app adapters for auth glue) ✅
- `shared/ui/**`, `shared/responsive/**`, reusable `shared/widgets/**` → `packages/design_system` ✅
- `shared/utils/**`: pure Dart → `packages/utilities`; UI → `packages/design_system` ✅
- `shared/extensions/**` (l10n) → `apps/mobile/lib/app/l10n_adapters/**` ✅
- `shared/sync/**` → `packages/storage` / `packages/networking` + app adapters ✅
- `shared/media/**` → `packages/app_shared_flutter/lib/src/media/` ✅

### `apps/mobile/lib/core/**`

- `core/di/**` → `apps/mobile/lib/app/composition/**` ✅
- `core/router/**` → `apps/mobile/lib/app/router/**` ✅
- `core/bootstrap/**` → `apps/mobile/lib/app/bootstrap/**` ✅
- `core/auth/**` → `packages/auth` + `apps/mobile/lib/app/auth/` ✅
- `core/config/**` → `apps/mobile/lib/app/config/` ✅
- `core/flavor.dart`, `core/constants/**`, `core/theme/app_theme.dart` → `apps/mobile/lib/app/config/` + `app/theme/` ✅
- Remaining `core/**` → `app/**` or workspace packages; **tree deleted** ✅

## Notes

- `packages/core` and `packages/utilities` remain **pure Dart** (no Flutter deps).
- Prefer app adapters in `apps/mobile/lib/app/**` over leaking app imports into packages.
- Parent plan: [`melos_monorepo_migration_plan.md`](../plans/melos_monorepo_migration_plan.md) — PR-J / Phase 5 row.
