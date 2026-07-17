# Melos monorepo migration — scoped closeout

Date: 2026-07-03  
Branch: `codex/melos-monorepo-build` · PR [#437](https://github.com/redjadet/flutter_bloc_app/pull/437)

## Summary

Scoped Melos monorepo migration (PR-A through PR-I) is **complete** on the build
branch. All Build Todo checkboxes in
[`2026-07-03_melos-monorepo-migration-closeout.md`](../changes/2026-07-03_melos-monorepo-migration-closeout.md)
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
| CI | `tool/analyze.sh` in workflows — monorepo cwd + plugin lints (`a1ded483`) |
| Docs/tooling | Agent analyze guidance + gitignored task-tracker link stability (`599d7e34`) |
| Harness | `check_clean_architecture_imports` workspace path resolve (post-closeout) |
| iOS tooling | `check_ios_pod_framework_embed`, `ios_entitlements`, Firebase upload/patch scripts use `APP_ROOT` |
| Integration | iOS smoke + Chrome preflight green after Firebase delegate reset, placeholder plist guard, Remote Config fake when no app (`2026-07-03`) |

## Integration hardening (2026-07-03)

Smoke suite mixed `realFirebaseAuth` (guest sign-in) with mock-auth flows in one
file. After guest sign-in, `firebase_core` cached `MethodChannelFirebase` via
`Firebase.delegatePackingProperty`, so later mock-platform installs were ignored.

Fixes:

- Reset `Firebase.delegatePackingProperty` in integration tearDown; force mock
  platform install when mock auth is selected.
- Skip `FirebaseApp.configure()` on iOS when `GoogleService-Info.plist` is
  missing or uses placeholder `YOUR_IOS_API_KEY`.
- Return `FakeRemoteConfigRemoteDataSource` when `Firebase.apps.isEmpty` or
  integration harness omits Firebase remote repos.
- Runner: skip/copy guard for placeholder Firebase plist; resolve selective map
  against `APP_ROOT`; epoch-based integration timeout.

## Accepted deferrals (not blocking merge)

- **PR-C:** `safe_parse_utils` (`AppLogger`), `date_time_formatting` (Material l10n)
- **PR-E:** `CommonSearchField`, app bar/page layout, error/empty/loading widgets
- **PR-F wave 2:** `app_dio`, interceptors, Hive service/migrations
- **PR-I:** `token_repository`, `session_lifecycle_coordinator`, sync presentation split
- **Product:** extra apps (`apps/web`, `apps/admin`) until real split

## Proof

- `./bin/checklist` from repo root (2618 tests, 80.61% coverage, 2026-07-03)
- `./bin/integration_preflight` (Chrome web bootstrap, 2026-07-03)
- `INTEGRATION_TESTS_TIER=smoke ./bin/integration_tests` on iPhone simulator
  (18/18, 2026-07-03)
- `bash tool/check_package_dependency_dag.sh`
- `python3 -m unittest tool.commit_push_pr_deploy_test`

## Post-merge backlog

Optional follow-ups after #437 lands — separate PRs, not part of scoped plan:

1. PR-F wave 2 when Hive/HTTP/auth seams stabilize
2. PR-C deferred utils if logger/l10n decouple
3. Remove app compatibility barrels once import churn is acceptable
