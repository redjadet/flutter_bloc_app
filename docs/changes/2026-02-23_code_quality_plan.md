# Code Quality Improvement Plan — 2026-03-11

## Summary

This roadmap reflects the current repo state after the recent shared HTTP
hardening, checklist optimization, and regression-guard expansion work. The
remaining goal is not broad cleanup; it is to remove the last inconsistency
signals that keep the codebase from reading as uniformly senior.

## Status

This document is a **historical plan**. Prefer the current “core” docs and repo
scripts as the source of truth:

- `docs/CODE_QUALITY.md`
- `docs/validation_scripts.md`
- `docs/testing_overview.md`

Current baseline:

- Shared HTTP transport contracts are hardened and covered.
- Checklist behavior is now change-aware and avoids unnecessary work.
- Coverage is improving, but several architecture-critical Supabase/data
  boundaries still need direct tests.
- The remaining quality gaps are mostly stale documentation, under-tested
  repository boundaries, and baseline verification debt.

## Track 1: Infrastructure Baseline

### Current state

- `build_runner` baseline: verified with a real local run on 2026-03-11.
- Shared infrastructure rules: active and already enforced through validation
  scripts and focused regression tests.

### Coverage outcome

- Generated-code workflow is confirmed healthy and documented as a working
  baseline.
- Shared bootstrap, transport, parsing, and validation contracts stay directly
  testable.

### Next actions

1. Keep `build_runner` in the regular quality narrative only if it continues to
   run cleanly.
2. Maintain test seams only where they improve verification of shared/core
   contracts.
3. Prefer contract tests over implicit coverage from higher layers.

## Track 2: Critical Coverage and Regression Hardening

### Priority wave

Focus on files that are both low-coverage and architecturally meaningful:

- `lib/features/graphql_demo/data/supabase_graphql_demo_repository.dart`
- `lib/features/chart/data/supabase_chart_repository.dart`
- `lib/features/iot_demo/data/supabase_iot_demo_repository.dart`
- `lib/features/graphql_demo/data/graphql_demo_exception_mapper.dart`
- `lib/shared/utils/http_request_failure.dart`
- `lib/core/bootstrap/bootstrap_coordinator.dart`

### Required outcome

- No critical shared/data file remains at `0.00%` simply because it is small or
  sits behind a framework boundary.
- New tests protect real parsing, fallback, exception-mapping, or bootstrap
  contracts.
- Bootstrap behavior is verified through meaningful sequencing tests, not only
  signature smoke tests.

### Regression policy

- Register fixes in `tool/check_regression_guards.sh` when they protect
  bootstrap, lifecycle, transport, sync, or error-mapping behavior.
- Keep regression guards focused and fast; broad repository suites should stay
  outside that script unless they protect a known recurring failure mode.

## Track 3: Codebase Signal Cleanup

### Goal

Make the repo read as intentionally engineered rather than incrementally patched.

### Ongoing expectations

- Remove stale “pending” language once work is complete or intentionally
  deferred.
- Prefer pattern matching and explicit guards over workaround-style nullable
  handling when it improves clarity.
- Keep comments aligned with current behavior; delete historical bug notes once
  tests and code already encode the contract.
- Avoid “quality debt by exception”: outdated docs, redundant guards, and stale
  baseline warnings weaken reviewer trust.

## Validation Standard

For high-leverage quality work:

1. Run targeted unit/repository tests for each touched contract.
2. Run focused analyzer scope for touched files.
3. Run relevant validation scripts or regression guards.
4. Refresh `coverage/coverage_summary.md` when tests land.
5. Update documentation in the same change if the repo story changed.

## Track: Settings / diagnostics modularity — **complete**

- [x] Decouple settings from `graphql_demo`, `profile`, and `remote_config` (shared cache widgets, core ports, remote config DTO + mapper, app/router wiring). Details: [settings_diagnostics_decouple_plan.md](../plans/settings_diagnostics_decouple_plan.md).

## Completed Baseline Work

- Shared HTTP auth retry now preserves network, retry, and telemetry behavior.
- Retry handling now works for transient status responses under
  `validateStatus: (_) => true`.
- Shared sync/status lifecycle rules are enforced more consistently.
- Checklist avoids redundant work for docs-only and unrelated change sets.
- Edge-then-tables fallback helper and shared transport layers now have direct
  focused tests.
