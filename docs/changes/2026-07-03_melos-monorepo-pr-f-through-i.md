# Melos monorepo migration — PR-F through PR-I closeout

Date: 2026-07-03  
Branch: `codex/melos-monorepo-build` · PR [#437](https://github.com/redjadet/flutter_bloc_app/pull/437)

## Summary

Infrastructure package wave: primitive networking/storage extractions, AI contracts,
Firebase backend layout, and optional auth/feature_flags contracts. App compatibility
barrels preserve import paths.

## PR-F wave 1 — `packages/networking`, `packages/storage`

### Moved (PR-F)

- `circuit_breaker.dart`, `retrofit_response_utils.dart` → `packages/networking`
- `hive_recoverable_errors.dart` → `packages/storage` (+ package unit test)

### Deferred (PR-F, stay in app)

- `app_dio.dart`, interceptors, auth token managers (app/auth coupling)
- `hive_service`, `hive_repository_base`, migrations, secure storage stack

## PR-G — `packages/ai`

Provider-neutral contracts only: providers, prompts, structured outputs, tools,
agents, RAG, MCP. No app feature migration.

## PR-H — Firebase backend layout

| Before (root) | After |
| --- | --- |
| `functions/` | `backend/firebase/functions/` |
| `firestore.rules` | `backend/firebase/firestore_rules/firestore.rules` |
| `storage.rules` | `backend/firebase/storage_rules/storage.rules` |
| `firestore.indexes.json` | `backend/firebase/indexes/firestore.indexes.json` |

Updated: `firebase.json.example`, `tool/commit_push_pr_deploy.py`, secret-literal
guard paths, [`firebase_setup.md`](../firebase_setup.md), [`deployment.md`](../deployment.md).

## PR-I — `packages/auth`, `packages/feature_flags`

### Moved (PR-I)

- Auth domain ports: `auth_user`, `auth_provider_kind`, `auth_repository`,
  `remote_backend_auth_port`, `session_invalidation_reason`
- Feature flags: `remote_config_service`, `remote_config_keys`

### Deferred (PR-I)

- `token_repository`, `session_lifecycle_coordinator` (Firebase/Supabase SDK deps)
- Sync presentation split (app-owned per plan)

## Tooling

- Root workspace members: `ai`, `auth`, `feature_flags`, `networking`, `storage`
- `tool/check_package_dependency_dag.sh` — DAG edges for new packages
- Mobile `pubspec.yaml`: explicit `app_links`, `ffi` for `depend_on_referenced_packages`

## Proof

- `dart test` in `packages/ai`, `packages/storage`
- `python3 -m unittest tool.commit_push_pr_deploy_test`
- `./bin/checklist` (~2618 tests, ~80.6% coverage)

## Next

- PR-F wave 2 when Hive/HTTP seams stabilize (or accept wave-1 deferral)
- PR-C deferred: `safe_parse_utils`, `date_time_formatting`
- Extra apps deferred until product split
