# Plan: Decouple settings from graphql_demo, profile, remote_config

**Status: complete.** All items below are done; keep this file for audit trail and to align with plan todos.

## Todos

- [x] **GraphQL cache port in core** — `GraphqlCacheClearPort` in `lib/core/diagnostics/graphql_cache_clear_port.dart`; `GraphqlCacheRepository` implements it; `register_graphql_services.dart` registers the port alias.
- [x] **Profile cache port in core** — `ProfileCacheControlsPort` + `ProfileCacheMetadata` in `lib/core/diagnostics/profile_cache_controls_port.dart`; Hive repo + DI unchanged pattern.
- [x] **Cache UI out of settings feature** — `GraphqlCacheControlsSection` and `ProfileCacheControlsSection` under `lib/shared/widgets/diagnostics/` (only core ports + shared UI).
- [x] **Remote config view model in core** — `RemoteConfigDiagnosticsViewData` + `RemoteConfigDiagnosticsStatus` + freezed in `lib/core/diagnostics/remote_config_diagnostics_view_data.dart`.
- [x] **Mapper in remote_config feature** — `mapRemoteConfigStateToDiagnosticsViewData` in `lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart` (replaces former `RemoteConfigViewData.fromState` on feature-owned types).
- [x] **Remote config diagnostics UI** — `RemoteConfigDiagnosticsSection` uses core DTO + mapper; no settings feature import.
- [x] **App wiring** — `lib/app/router/routes_core.dart` composes `SettingsPage.buildQaExtras` with `getIt` ports + shared cache widgets + `RemoteConfigDiagnosticsSection`.
- [x] **Settings barrel** — Removed cache section exports from `lib/features/settings/settings.dart`.
- [x] **Validation** — `tool/check_feature_modularity_leaks.sh`; tests (cache widgets, remote config diagnostics, mapper, DI ports); `./bin/router_feature_validate`.
- [x] **Docs** — [`modularity.md`](../modularity.md) (detailed contracts); [`offline_first/offline_first_plan.md`](../offline_first/offline_first_plan.md) (profile cache controls path).

## Verification

```bash
bash tool/check_feature_modularity_leaks.sh
rg "package:flutter_bloc_app/features/(graphql_demo|profile|remote_config)/" lib/features/settings --glob "*.dart"
```

Expect: script passes; ripgrep finds no matches.

## See also

- [Modularity](../modularity.md) — dependency rules and composition notes.
- [Validation scripts](../validation_scripts.md) — `check_feature_modularity_leaks.sh`.
