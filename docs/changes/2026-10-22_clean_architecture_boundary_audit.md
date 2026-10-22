# Feature: Clean Architecture boundary audit fixes

**Date:** 2026-10-22

## Problem

An import-graph audit against [`clean_architecture.md`](../clean_architecture.md),
the Flutter [app architecture guide](https://docs.flutter.dev/app-architecture/guide)
and Robert C. Martin's dependency rule found the layering largely clean: all
existing boundary guards pass, domain imports no Flutter/SDK packages, and no
feature imports another feature. It did find:

- Two regressions of
  [Maintainability Slice 3](2026-07-10_maintainability_slice3_app_config_injection.md)
  (presentation reading app bootstrap/config singletons):
  `ProductionReadinessCubit` fell back to
  `FirebaseBootstrapService.isFirebaseInitialized`, and the FCM demo token
  section read `FlavorManager.I`. No guard covered that rule, so it drifted.
- `SubmitCaseStudyUseCase`, the canonical multi-port use case cited by
  [`use_case_dto_policy.md`](../architecture/use_case_dto_policy.md), had no
  unit test of its own (only indirect Cubit coverage).
- The domain SDK deny list in `tool/check_clean_architecture_imports.sh`
  covered Hive/Dio/Supabase/GetIt/Retrofit but not Firebase, Firestore,
  `http`, `shared_preferences`, `go_router`, or `flutter_bloc`.

## Scope

- In: two injection fixes, guard hardening with fixtures, one use-case test,
  concise guide mapping in [`clean_architecture.md`](../clean_architecture.md).
- Out: renaming leaf `*Repository` classes to `*DataSource`, new ports for chat
  sync status, moving package types out of domain imports, and other larger
  refactors (listed in the PR description as proposals).

## Layers touched

- [ ] domain
- [ ] data
- [x] presentation
- [ ] DI
- [x] routes / l10n (router passes injected values; no l10n changes)

## Behavior contract (define before implementation)

- Must remain true: production readiness live/simulated mode follows whether
  Firebase initialized at route build; FCM tokens are masked in release or prod
  flavor, and copy is offered only in non-release dev/qa. Owner: router
  (`routes_demos.part.dart`) resolves values; widgets and Cubit only consume.
- Release builds keep the `kReleaseMode` guard inside the widget as defense in
  depth, whatever the router passes.
- Failure/recovery: none; same values, resolved one layer up.

## What changed

Presentation:

- `apps/mobile/lib/features/production_readiness/presentation/cubit/production_readiness_cubit.dart`:
  `firebaseInitialized` is now required; no bootstrap import.
- `apps/mobile/lib/features/fcm_demo/presentation/pages/fcm_demo_page.dart`
  and `.part.dart`: `maskTokens` / `allowTokenCopy` injected; no flavor import.
- `apps/mobile/lib/app/router/routes_demos.dart` and `.part.dart`: resolve and
  pass both values.

Tooling:

- `tool/check_clean_architecture_imports.sh`: presentation may not import
  `app/bootstrap/**` or `app/config/**` (except `backend_availability.dart`);
  domain SDK deny list extended.
- `tool/run_harness_fixtures.sh` + three fixtures under
  `tool/fixtures/clean_architecture_imports/`.

Docs:

- [`clean_architecture.md`](../clean_architecture.md): mapping to the Flutter
  guide, deliberate differences, error flow, and the no-app-singletons rule.

## Tests (executable contract)

- `apps/mobile/test/features/case_study_demo/domain/use_cases/submit_case_study_use_case_test.dart`
  (new): incomplete draft, local-only, remote with partial uploads and
  progress, remote failure cleanup, cleanup failure, persist failure after
  finalize.
- `apps/mobile/test/features/fcm_demo/presentation/pages/fcm_demo_page_test.dart`:
  injected policy plus a masked/no-copy case.
- Existing `production_readiness` Cubit and page tests already pass
  `firebaseInitialized`.

### Proof command

- `./bin/checklist`

## Docs

- [x] This note, indexed from [`docs/changes/README.md`](README.md)
- [x] Living practice in [`clean_architecture.md`](../clean_architecture.md)
- [ ] [`feature_overview.md`](../feature_overview.md): unchanged

## Risks

Low. Values are now read at route-list build, which runs after bootstrap sets
the flavor, the same as the existing `showQaExtras` / `showFlavorBadge` router
reads.

## depends_on

- None.

## blocks

- None.

## merge_order

- Single PR.

## rollback

- Revert the commit.

## proof_commands

```bash
bash tool/check_clean_architecture_imports.sh
bash tool/run_harness_fixtures.sh
bash tool/check_feature_brief_linked.sh --base origin/main
bash tool/check_docs_gardening.sh --paths docs/changes/2026-10-22_clean_architecture_boundary_audit.md docs/changes/README.md docs/clean_architecture.md
```
