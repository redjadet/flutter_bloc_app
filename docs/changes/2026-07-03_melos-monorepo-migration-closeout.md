# Melos monorepo migration — scoped closeout

Date: 2026-07-03  
Branch: `codex/melos-monorepo-build` · PR [#437](https://github.com/redjadet/flutter_bloc_app/pull/437)

## Summary

Scoped Melos monorepo migration (PR-A through PR-I) is **complete** on the build
branch. All Build Todo checkboxes in
[`melos_monorepo_migration_plan.md`](../plans/melos_monorepo_migration_plan.md)
are done or explicitly deferred. Operator next step: merge PR #437 to `main`.

## Delivered phases

| Phase | Scope |
| --- | --- |
| PR-A/B | Melos workspace shell, `apps/mobile/` relocation, script/CI path updates |
| PR-C/D | `packages/utilities`, `packages/core`, DAG guard |
| PR-E | `packages/design_system` (deferred l10n/routing widgets documented) |
| PR-F wave 1 | `packages/networking`, `packages/storage` primitives |
| PR-G | `packages/ai` contracts |
| PR-H | `backend/firebase/` layout |
| PR-I | `packages/auth`, `packages/feature_flags` domain contracts |
| CI | `tool/workspace_pub_get.sh` — workspace + Flutter codegen (`1da531ab`) |

## Accepted deferrals (not blocking merge)

- **PR-C:** `safe_parse_utils` (`AppLogger`), `date_time_formatting` (Material l10n)
- **PR-E:** `CommonSearchField`, app bar/page layout, error/empty/loading widgets
- **PR-F wave 2:** `app_dio`, interceptors, Hive service/migrations
- **PR-I:** `token_repository`, `session_lifecycle_coordinator`, sync presentation split
- **Product:** extra apps (`apps/web`, `apps/admin`) until real split

## Proof

- `./bin/checklist` from repo root (~2618 tests, ~80.6% coverage)
- `bash tool/check_package_dependency_dag.sh`
- `python3 -m unittest tool.commit_push_pr_deploy_test`

## Post-merge backlog

Optional follow-ups after #437 lands — separate PRs, not part of scoped plan:

1. PR-F wave 2 when Hive/HTTP/auth seams stabilize
2. PR-C deferred utils if logger/l10n decouple
3. Remove app compatibility barrels once import churn is acceptable
