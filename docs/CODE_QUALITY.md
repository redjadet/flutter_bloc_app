# Code Quality Review

This document consolidates code-quality analysis and improvement notes.

## Status

This file is a **human-readable quality overview**. It is not the enforcement
layer.

Measured claim gate (portfolio-honest): [`engineering/engineering_quality_scorecard.md`](engineering/engineering_quality_scorecard.md).

### Program status (2026-06-03)

**Waves 1–2 closed** on `main` (PR [#290](https://github.com/redjadet/flutter_bloc_app/pull/290), PR [#292](https://github.com/redjadet/flutter_bloc_app/pull/292), closeout [2026-06-03_quality-program-waves-1-2-closeout.md](changes/2026-06-03_quality-program-waves-1-2-closeout.md)).

Baseline audit: [code_quality_baseline_2026-06-03.md](audits/code_quality_baseline_2026-06-03.md).
Top gaps tracked there (cadence 3+):

1. **Coverage** — CI minimum **75%** filtered rollup; Engineering scorecard target **85%** filtered + app-shell (bootstrap/DI/router) **≥75%** ([coverage summary](../coverage/coverage_summary.md), [`engineering/engineering_quality_scorecard.md`](engineering/engineering_quality_scorecard.md)). Measured (2026-07-16): filtered **85.18%**, app-shell **75.75%**.
2. **App shell** — bootstrap/composition/router aggregate tracked by `tool/check_engineering_core_coverage.sh` (not legacy `lib/core/`).
3. **Next arch slice** — ~~Todo list `AppError`~~ **Done (June 2026)** — [`senior_patterns_review_2026-06.md`](audits/senior_patterns_review_2026-06.md) PR-3; `TodoListState.lastError` uses `AppError`.

Promoted checklist gates (**fail** default): **QG-D05** deferred routes, **QG-D07** lifecycle observer dispose — see [validation catalog](validation_scripts/catalog.md) and [deferred gates](plans/checklist_quality_gates_deferred.md). Proof on `main`: 0 violations; env overrides `CHECK_*_MODE=warn` for staged fixes.

**Integration proof:** standard 22/22 and exhaustive 23/23 on iPhone 17e (`665deee8`); honesty matrix in baseline audit.

Source of truth for gates and guardrails:

- `./bin/checklist`
- [`validation_scripts.md`](validation_scripts.md)
- [`testing_overview.md`](testing_overview.md)
- Checklist quality-theme gates (May 2026 MVP): [`validation_scripts/catalog.md`](validation_scripts/catalog.md#quality-theme-gates-checklist-mvp-may-2026); baseline [`plans/checklist_quality_gates_baseline.md`](plans/checklist_quality_gates_baseline.md); deferred backlog [`plans/checklist_quality_gates_deferred.md`](plans/checklist_quality_gates_deferred.md)

## Scope and Inputs

- Static review of `lib/` and supporting tooling.
- Architecture guidelines in [`clean_architecture.md`](clean_architecture.md), [`solid_principles.md`](architecture/solid_principles.md), [`dry_principles.md`](architecture/dry_principles.md), and [`separation_of_concerns.md`](architecture/separation_of_concerns.md).
- Quality gates via `./bin/checklist` (format, analyze, coverage).
- Coverage source: generated coverage summary artifact.

## Architecture Alignment

- Clean Architecture boundaries: Presentation depends on Domain, Domain depends on nothing, Data implements Domain contracts.
- Domain layer stays Flutter-agnostic (no `package:flutter` imports).
- Dependency injection is centralized in `apps/mobile/lib/app/composition/` with interface registrations and lazy singletons.
- Business logic is handled by cubits; widgets focus on layout, navigation, and theming.

## SOLID and DRY Summary

- SRP: Services and cubits are scoped to a single responsibility.
- OCP/LSP/ISP/DIP: Interface-first design and DI allow swapping implementations and fakes.
- DRY: Shared widgets/utilities and base repositories avoid duplication. See [`dry_principles.md`](architecture/dry_principles.md) for the current consolidation list.

## Resolved Quality Issues (Historical)

- Search race condition: request-id guard prevents stale results in `apps/mobile/lib/features/search/presentation/search_cubit.dart` (tests added).
- Multipart retry safety: retries for multipart requests are handled in Dio interceptors; multipart cloning is not used (Dio handles retries per interceptor policy).
- Auth token cache safety: cache is keyed by user id in `apps/mobile/lib/app/http/auth/auth_token_manager.dart` (tests added).
- Auth refresh race safety: concurrent 401 refreshes are single-flight in
  `apps/mobile/lib/app/http/auth/auth_token_manager.dart` and `apps/mobile/lib/app/http/auth/interceptors/auth_token_interceptor.dart`;
  retry flow avoids double forced-refresh (tests added).
- Completer type safety: non-nullable completion guard in `packages/utilities/lib/src/async/completer_helper.dart` (tests added).
- JSON decode error handling: try/catch and error mapping in `apps/mobile/lib/features/chat/data/huggingface_api_client.dart` (tests added).

## Notable Structural Improvements

- Bootstrap refactor: `main_bootstrap.dart` split into focused services under `apps/mobile/lib/app/bootstrap/` for clearer responsibilities and better testability.
- Runtime resilience: resilient HTTP client, centralized error mapping, sync diagnostics in Settings (dev/qa), and consistent loading/skeleton widgets.

## Quality Metrics and Gates

- File size policy: keep files under 250 LOC; extract widgets/helpers as needed.
- Coverage minimum: **75%** filtered rollup (CI gate). Team target: **85%** — see the generated coverage summary artifact.
- Static analysis and formatting: run `./bin/checklist`.
- Guardrails: see [`validation_scripts.md`](validation_scripts.md) for the full automated checks list.

## Best-Practice Expectations (Summary)

- Use type-safe cubit access and `BlocSelector`-style selectors for targeted rebuilds.
- Use builder constructors for lists and set `cacheExtent` where appropriate.
- Use `CachedNetworkImageWidget` for remote images.
- Guard `context.mounted` after `await` and avoid side effects in `build()`.
- Prefer Dart optional-to-non-null pattern matching (`if (x case final value?)`, `switch` null patterns) over force unwrapping (`!`) and repeated nullable branching.
- Avoid null assertion where possible; pattern matching gives a compile-time non-null local and lowers runtime crash risk.

For full guidance, see [`flutter_best_practices_review.md`](review/flutter_best_practices_review.md).

## Testing Standards

- Required types: unit, bloc, widget, golden, and common bug prevention tests.
- Run `./bin/checklist` before merging.
- Update goldens after Flutter upgrades (`flutter test --update-goldens`).

See [`testing_overview.md`](testing_overview.md) for the full testing playbook.

## Ongoing Maintenance

- Revisit coverage and file-size hotspots regularly.
- Keep DRY/SOLID references current when new patterns are added.
- Update this document when major architecture decisions change.

## Related Documentation

- [Race Conditions and Bugs Analysis](engineering/race_conditions_and_bugs_analysis.md) – Deep analysis of lifecycle, async, and stream patterns
- [Memory Leaks Analysis](performance/memory_leaks_analysis.md) – StreamController, subscription, and controller disposal patterns
- [Clean Architecture](clean_architecture.md)
- [SOLID Principles](architecture/solid_principles.md)
- [DRY Principles](architecture/dry_principles.md)
- [Separation of Concerns](architecture/separation_of_concerns.md)
- [Architecture Details](architecture_details.md)
- [Flutter Best Practices Review](review/flutter_best_practices_review.md)
- [Performance Bottlenecks](performance/performance_bottlenecks.md)
- [Lazy Loading Review](performance/lazy_loading_review.md)
