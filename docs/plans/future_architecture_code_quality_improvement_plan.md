# Future Architecture & Code Quality Improvement Plan

## Roadmap Status

| Phase | Status | Priority | Primary output |
| ----- | ------ | -------- | -------------- |
| Phase 1 | In progress (starter guard + profile policy slice complete) | High | Protected route-group pattern proven via `/iot-demo`; explicit authenticated policy now guards `/profile`; next work requires a concrete auth/security target such as roles, biometrics, or token propagation |
| Phase 2 | In progress (trigger API + payload contract + demo wiring slice complete) | High | FCM-triggered sync contract and coordinator integration are in place; `BackgroundSyncCoordinator.triggerFromFcm()` is wired from the FCM demo and duplicate triggers coalesce safely |
| Phase 3 | Planned | Medium | Compile-time DI spike, adoption decision, migration path if accepted |
| Phase 4 | In progress (shared seam + second consumer slice complete) | High | Shared error hierarchy, mapper integration, shared error UI seam, and representative consumers are in place; next work requires naming the next specific error surface |
| Phase 5 | Mostly complete | High | Focused contract tests landed for current critical targets; keep open only for newly discovered gaps or regression-guard follow-up |
| Phase 6 | Planned | Medium | Analyzer plugin scope, proof-of-concept rules, optional state-machine spike |

## Why This Plan Exists

The repository already has strong architectural foundations, but several
accepted trade-offs now have visible product or maintenance cost. This plan
turns those known gaps into a staged execution path so the codebase continues
to read as consistently senior, testable, and explicit.

Primary source documents:

- [Trade-offs & Future Improvements](../tradeoffs_and_future.md)
- [Code Quality Review](../CODE_QUALITY.md)
- [Code Quality Improvement Plan — 2026-03-11](../changes/2026-02-23_code_quality_plan.md)
- [Code Quality Analysis — 2026-02-24](../audits/code_quality_analysis_2026-02-23.md)
- [Structured Error Taxonomy — Design](2026-03-13-structured-error-taxonomy-design.md)
- [Settings diagnostics decouple plan](settings_diagnostics_decouple_plan.md) — **complete** (settings vs `graphql_demo` / `profile` / `remote_config`)

## Goals

- Address accepted trade-offs where the cost is now visible, especially in
  auth, sync, DI, and error handling.
- Close the remaining code-quality gaps identified in the current quality and
  audit documents.
- Raise the baseline further so architecture, tests, and docs feel uniform
  across shared, core, and feature modules.

## Scope

- Auth and security: role/claims, route guards, biometric policy, token
  propagation.
- Sync and offline-first: push-triggered sync and clearer conflict behavior.
- DI and architecture: evaluate compile-time DI while preserving current
  layering and testability.
- Error handling and taxonomy: structured errors and consistent UI hooks.
- Critical coverage and regression guards: Supabase/data boundaries, bootstrap,
  and shared contracts.
- Tooling and linting: analyzer plugin exploration and optional state-machine
  helpers.

## Success Measures

- Cross-cutting contracts become more explicit, not more implicit: new route,
  sync, DI, and error behavior is documented where the code changes.
- High-risk shared or core boundaries gain direct contract tests rather than
  relying on incidental feature coverage.
- Role-protected routes and deep links execute the same policy path.
- Shared failures become typed enough that cubits and reusable UI can branch on
  structured categories rather than parsing strings.
- At least one currently review-enforced expectation is proven feasible as a
  tooling rule or analyzer check.

## Non-Goals

- No auth-provider migration or identity-system rewrite.
- No flag-day DI migration across the whole repository.
- No CRDT or strict-merge sync redesign; this plan clarifies and strengthens
  the current eventual-consistency model.
- No repo-wide state-machine or codegen rollout until a small prototype proves
  the ergonomics and maintenance cost are acceptable.

## Delivery Principles

- Keep `Domain -> Data -> Presentation` boundaries intact throughout the work.
- Prefer small vertical slices per phase instead of broad repo-wide rewrites.
- Land code, tests, and documentation together when a contract changes.
- Add regression guards only for historically fragile or high-impact behavior.
- Favor focused contract tests over indirect coverage from UI or integration
  flows.
- Treat cross-cutting decisions as repository policy changes, not local
  implementation details.

## Decision Records & Governance

- Record any accepted cross-cutting architecture change in the relevant doc set
  and add an ADR when the decision changes repository-wide policy.
- Each spike must end with an explicit `adopt`, `defer`, or `reject` outcome.
- Do not leave permanent "pilot" code paths without a documented end-state.
- When a phase changes user-visible failure behavior or security posture,
  update the relevant docs in the same change.

## AI Agent Execution Guide

Use this plan as an implementation contract, not as permission for broad
cleanup.

- Start with the smallest vertical slice that proves the phase is viable.
- Read the touched code paths first and align with existing naming, DI, and
  repository patterns before editing.
- Prefer changing one shared seam and one representative consumer before
  expanding the pattern repo-wide.
- If a phase starts requiring cross-feature rewrites, stop and document the
  missing decision instead of improvising a repository-wide pattern.
- Once a phase's starter slice is complete, do not continue with generic
  follow-up work; name the next target feature or shared seam first.
- Do not silently introduce a second competing abstraction for auth, sync, DI,
  or error handling.
- When a phase is a spike, the minimum valid outcome is a documented decision,
  not necessarily merged production adoption.

## AI Agent Guardrails

- Preserve `Domain -> Data -> Presentation` dependencies. Do not solve shared
  problems by letting presentation import data-layer internals.
- Keep direct `GetIt` access out of presentation code.
- Keep route and bootstrap policy centralized; do not scatter auth or startup
  checks across unrelated widgets.
- Prefer shared utilities and adapters over per-feature copies when the concern
  is cross-cutting.
- Avoid wide mechanical renames or speculative abstractions unless the phase
  explicitly requires them.
- If the current code contradicts the plan, update the plan or write down the
  decision instead of forcing the code into an unclear target state.

## Likely Touchpoints By Phase

These are the first places an agent should inspect before implementing a phase.
They are anchors, not a complete file list.

| Phase | Primary paths to inspect first |
| ----- | ------------------------------ |
| Phase 1 | `lib/app/router/`, `lib/core/di/`, `lib/shared/http/`, `docs/authentication.md`, `docs/security_and_secrets.md` |
| Phase 2 | `lib/shared/sync/`, `docs/offline_first/`, `docs/fcm_demo_integration.md`, representative offline-first repositories |
| Phase 3 | `lib/core/di/`, `docs/code_generation_guide.md`, `docs/compile_time_safety.md`, one isolated feature registration path |
| Phase 4 | `lib/shared/utils/`, key cubits/services consuming request failures, `docs/reliability_error_handling_performance.md` |
| Phase 5 | target files listed in this plan, related tests under `test/`, `tool/check_regression_guards.sh`, `coverage/coverage_summary.md` |
| Phase 6 | `tool/` validation scripts, `docs/custom_lint_rules_guide.md`, `lib/shared/utils/bloc_lint_helpers.dart`, `lib/shared/utils/state_transition_validator.dart` |

## Phase Dependencies & Decision Gates

| Phase | Depends on | Gate to proceed |
| ----- | ---------- | --------------- |
| Phase 1 | None | Role source and route policy shape are agreed before broad route edits |
| Phase 2 | Phase 1 token propagation audit is preferred if sync triggers call authenticated services | Trigger contract is defined before coordinator changes land |
| Phase 3 | Phase 5 baseline coverage is preferred on the chosen pilot slice | Spike ends with an explicit yes/no adoption decision |
| Phase 4 | None | Shared error model is defined before feature-by-feature UI adoption |
| Phase 5 | None | Tests target meaningful contracts, not framework plumbing only |
| Phase 6 | Prefer Phases 1-4 patterns to be stable first | Tooling only codifies rules the repository has already chosen to keep |

## Current Recommended Next Step

Phase 4 has now completed its initial design slice, pilot consumer slice, and
one additional shared error UI slice. Phase 1's minimal protected-route slice
is also already present:

- `lib/shared/utils/app_error.dart` now defines the shared sealed error types.
- `lib/shared/utils/http_request_failure.dart` and
  `lib/shared/utils/network_error_mapper.dart` now project into `AppError`.
- `ChartCubit` / `ChartPage` act as the pilot consumer, carrying `AppError`
  state and using `isRetryable` to gate a retry action in the error UI.
- `lib/shared/utils/error_handling.dart` now accepts `AppError` while
  preserving existing string/exception-driven snackbar behavior.
- `CounterPage` is now a second representative consumer path, routing its error
  handling through `AppError` without changing the current user-visible
  message/retry behavior.
- `/iot-demo` is already a protected route group with `IotDemoAuthGate`,
  giving the repo one concrete guard path that covers both routed access and
  deep-link entry into that feature.
- `/profile` now has explicit authenticated route policy metadata and a shared
  route-level auth gate, so unauthenticated normal navigation and deep links
  are enforced through the same guard path.

The next meaningful step is no longer "continue Phase 1" or "continue Phase 4"
in the abstract. Future work must first choose a specific product area to
deepen. Good options include:

1. auth roles / claims:
   extend the current guard model beyond `/iot-demo` into explicit role-aware
   route policy
2. auth hardening:
   deepen Phase 1 via biometric policy or token propagation audit/adapters
3. structured error adoption:
   pick the next named high-value error surface after `ChartPage`,
   `ErrorHandling`, and `CounterPage` (for example another cubit flow or a
   reusable status/error component)
4. sync:
   start Phase 2 via the explicit FCM-to-sync trigger contract and tests

Agents should not resume either phase with broad "more guards" or "more AppError
adoption" work without naming that next target first.

## Phase 1 — Auth & Route Protection

### Phase 1 Objective

Move from authenticated-vs-anonymous checks to a route policy model that also
handles roles, deep links, biometric-sensitive screens, and consistent token
attachment outside the shared Dio path.

### Phase 1 Work Items

1. Design a minimal role/claims model that covers near-term requirements such
   as `user`, `admin`, and `betaTester`.
2. Decide whether those roles live in Supabase/Firebase claims, app-local
   profile fields, or a hybrid model.
3. Extend router configuration in `lib/app/router/` and related auth redirect
   flows so routes declare:
   - public vs authenticated vs role-restricted access
   - optional biometric requirements for sensitive screens
4. Ensure deep links go through the same checks as in-app navigation.
5. Identify sensitive flows and introduce a testable `BiometricPolicy`
   abstraction so features can opt into stricter gates without scattering
   direct biometric checks.
6. Audit non-Dio external HTTP and SDK usage, then introduce adapters or helper
   seams so auth tokens propagate consistently.

### Phase 1 Current State

- The repo already has a concrete protected route group for `/iot-demo`.
- `IotDemoAuthGate` is the current shared gate for that feature.
- This gives the plan its intended "one protected route group" baseline and
  proves the guard pattern on a real route path.
- `/profile` is now explicitly marked as an authenticated route via route
  policy metadata.
- `AppRouteAuthGate` is the shared guard path for `/profile`, covering both
  normal navigation and deep-link entry into that route.

### Phase 1 Next Slice Options

- Define the minimal roles/claims model and decide its source of truth.
- Extend route metadata or policy declarations to additional sensitive route
  groups beyond `/iot-demo` and `/profile`.
- Add biometric policy hooks for one clearly sensitive screen or action.
- Audit one non-Dio authenticated client path and introduce a shared token
  adapter if needed.

### Phase 1 Deliverables

- Route policy matrix that maps route groups to auth, role, and biometric
  requirements.
- Route policy model and route metadata conventions.
- Guard path that applies equally to deep links and in-app navigation.
- Feature-level biometric policy abstraction.
- Token propagation audit summary and remediation list.

### Phase 1 Exit Criteria

- A route can declare auth and biometric requirements without page-level
  ad-hoc logic.
- Deep-link coverage proves protected screens cannot bypass auth policy.
- External clients that need auth no longer rely on manual token attachment in
  scattered call sites.
- The chosen role-source strategy is documented so later features do not invent
  parallel authorization models.

## Phase 2 — Push-Triggered Sync & Offline-First Enhancements

### Phase 2 Objective

Reduce sync latency and make current conflict semantics explicit in both code
and documentation.

### Phase 2 Work Items

1. Define how FCM should trigger sync:
   - feature-specific topics vs generic sync events
   - payload contract keys (`sync_feature`, `sync_resource_type`, `sync_resource_id`)
   - how hints flow into `BackgroundSyncCoordinator.triggerFromFcm(hint: ...)` telemetry
2. Extend `BackgroundSyncCoordinator` and related shared sync types in
   `lib/shared/sync/` so they:
   - accept explicit triggers from FCM events
   - coalesce near-simultaneous triggers into a single sync run
3. Document the current eventual-consistency and last-write-wins model in:
   - `docs/offline_first/*.md`
   - `docs/tradeoffs_and_future.md`
4. Add or extend representative conflict tests for counter, chat, and profile
   style repositories.

### Phase 2 Recommended First Slice

- Add an explicit trigger API to `BackgroundSyncCoordinator`.
- Prove trigger coalescing with tests before wiring FCM delivery.
- Document one representative conflict path end-to-end before updating all
  offline-first docs.

### Phase 2 Deliverables

- Sync trigger contract covering payload shape, coalescing rules, and
  idempotency expectations.
- FCM-to-sync trigger design.
- Coordinator support for explicit and coalesced sync triggers.
- Updated offline-first docs that describe conflict behavior plainly.
- Representative conflict-resolution tests.

### Phase 2 Exit Criteria

- FCM-triggered sync does not create duplicate or overlapping coordinator runs.
- Conflict behavior is documented in the same terms that repositories
  implement.
- At least one representative repository per conflict pattern has direct tests.
- Trigger handling is safe to receive duplicate push events without redundant
  sync churn.

## Phase 3 — DI Evolution (Compile-Time DI Exploration)

### Phase 3 Objective

Decide whether compile-time DI is worth adopting in this repository and define
an incremental migration path if the answer is yes.

### Phase 3 Work Items

1. Run a feasibility spike for `injectable` + `get_it` or another compile-time
   DI option that can coexist with current registration patterns.
2. Prototype the approach on one isolated feature slice plus a small set of
   shared services.
3. Compare trade-offs:
   - earlier wiring failure detection
   - impact on current testing patterns
   - code-generation cost and build complexity
4. If the spike succeeds, design a staged migration path that:
   - keeps `get_it` for legacy areas initially
   - makes generated DI the preferred path for new work
   - updates AI and DI guidance once the pattern is stable

### Phase 3 Recommended First Slice

- Choose one feature module with a small registration surface.
- Port only that feature plus one or two shared services into the prototype.
- Measure real build and test ergonomics before writing migration guidance.

### Phase 3 Deliverables

- Feasibility spike branch or prototype notes.
- Trade-off comparison document or section update.
- Migration strategy if adoption is recommended.
- Go/no-go recommendation with explicit reasons if compile-time DI is deferred.

### Phase 3 Exit Criteria

- The repo has a documented yes/no DI decision instead of an open-ended future
  idea.
- If adoption is recommended, the migration path preserves current test
  ergonomics and does not require a flag day rewrite.
- If adoption is rejected or deferred, the current `get_it` guidance is updated
  so the spike still produces a clearer steady-state.

## Phase 4 — Structured Error Taxonomy

### Phase 4 Objective

Replace stringly-typed error handling with a sealed hierarchy that can be
mapped consistently across transport, storage, auth, and UI layers.

### Phase 4 Work Items

1. Define a sealed error hierarchy covering:
   - `NetworkError`: timeout, offline, serverUnavailable, rateLimited
   - `StorageError`: read/write, migration, corruption
   - `AuthError`: unauthorized, tokenExpired, forbidden
   - `UnknownError`: safe fallback
2. Extend or refactor shared utilities in `lib/shared/utils/`, including
   `network_error_mapper.dart` and `http_request_failure.dart`, so they produce
   structured errors rather than ad-hoc messages.
3. Update key cubits and services to interpret typed errors directly.
4. Add shared UI rendering patterns, such as structured-error variants of
   common status views.
5. Refresh
   [Reliability, Error Handling & Performance](../reliability_error_handling_performance.md)
   with examples and usage guidance.

### Phase 4 Current State

- The design slice is documented in
  [Structured Error Taxonomy — Design](2026-03-13-structured-error-taxonomy-design.md).
- `app_error.dart` now holds the shared sealed types.
- `http_request_failure.dart` and `network_error_mapper.dart` already map into
  `AppError`.
- `ChartCubit` / `ChartPage` serve as the first representative consumer path.
- `ErrorHandling.handleCubitError` now accepts `AppError` directly while
  preserving legacy message/snackbar behavior for existing callers.
- `CounterPage` now acts as a second representative caller flowing through the
  structured error path with unchanged UX.

### Phase 4 Next Slice Options

- Migrate one additional high-value cubit or repository-facing presentation
  path to carry `AppError`.
- Update another shared error UI surface beyond `ErrorHandling`, such as a
  common status/error component.
- Add focused tests proving the next consumer path improves ergonomics rather
  than adding migration noise.

### Phase 4 Expansion Gate

Before broader rollout beyond the pilot, write down:

- where the sealed error types live
- how they relate to `HttpRequestFailure` and whether that type stays, becomes
  an adapter, or is replaced
- which mapper becomes the canonical source of truth for transport failures
- how existing cubits and UI code consume the new model during migration
- which next consumer or shared error surface is the representative adoption
  target

### Phase 4 Deliverables

- Sealed error hierarchy and mapper integration.
- Updated cubit/service patterns for structured errors.
- Shared UI helpers for consistent error rendering.
- Documentation examples covering mapping and UX decisions.
- Error-to-UX mapping guidance for retryable vs non-retryable failures.

### Phase 4 Exit Criteria

- Shared transport and storage boundaries emit structured errors.
- Feature presentation logic can branch on typed failures instead of parsing
  message strings.
- Common error UIs are reusable and aligned with the taxonomy.
- The taxonomy distinguishes product-actionable cases from safe fallback cases.

## Phase 5 — Critical Coverage & Regression Guards

### Phase 5 Objective

Close the highest-value coverage gaps in shared/core and Supabase-oriented data
boundaries, then register guards for fragile behavior that has already failed
before.

### Phase 5 Current State

The main small-slice coverage targets in this phase already have focused
contract tests in place:

- `lib/core/bootstrap/bootstrap_coordinator.dart`
  via `test/core/bootstrap/bootstrap_coordinator_test.dart` and
  `test/core/bootstrap/bootstrap_coordinator_additional_test.dart`
- `lib/features/chart/data/supabase_chart_repository.dart`
  via `test/features/chart/data/supabase_chart_repository_test.dart`
- `lib/features/graphql_demo/data/supabase_graphql_demo_repository.dart`
  via `test/features/graphql_demo/data/supabase_graphql_demo_repository_test.dart`
- `lib/features/iot_demo/data/supabase_iot_demo_repository.dart`
  via `test/features/iot_demo/data/supabase_iot_demo_repository_test.dart`
- `lib/features/graphql_demo/data/graphql_demo_exception_mapper.dart`
  via `test/features/graphql_demo/data/graphql_demo_exception_mapper_test.dart`
- `lib/shared/utils/http_request_failure.dart`
  via `test/shared/utils/http_request_failure_test.dart`

Implication:

- Do not reopen Phase 5 with speculative new tests just to increase volume.
- Only return to this phase when a real gap appears in coverage, docs,
  regression protection, or when later phases expose an untested shared
  contract.

### Phase 5 Target Files

- `lib/features/graphql_demo/data/supabase_graphql_demo_repository.dart`
- `lib/features/chart/data/supabase_chart_repository.dart`
- `lib/features/iot_demo/data/supabase_iot_demo_repository.dart`
- `lib/features/graphql_demo/data/graphql_demo_exception_mapper.dart`
- `lib/shared/utils/http_request_failure.dart`
- `lib/core/bootstrap/bootstrap_coordinator.dart`

### Phase 5 Work Items

1. Add focused tests for success mapping, error mapping, fallback behavior, and
   parsing across the target Supabase repositories and mappers.
2. Add bootstrap sequencing and failure-path tests for
   `BootstrapCoordinator`.
3. Refresh `coverage/coverage_summary.md` after meaningful test additions land.
4. Register regression guards in `tool/check_regression_guards.sh` for newly
   discovered or historically recurring failures in these areas.
5. Remove or rewrite stale comments and docs in touched files when tests make
   the contract explicit.

### Phase 5 Remaining Work

- Verify whether any Phase 5 fixes should add or extend a regression guard in
  `tool/check_regression_guards.sh`.
- Keep `coverage/coverage_summary.md` aligned when later work materially
  changes the tested surface.
- Re-enter this phase only for newly discovered high-impact gaps, not as
  generic test backfill.

### Phase 5 Recommended First Slice

No new default first slice is recommended at the moment. The previously
identified small slices are already covered by focused tests, so the next
worthwhile step is the Phase 4 design slice above.

### Phase 5 Exit Criteria

- No high-impact shared/data target remains effectively unprotected because it
  is small or framework-adjacent.
- Regression guards exist only where they encode a real recurring failure mode.
- Coverage improvements correspond to real contract tests, not signature smoke
  tests.
- Touched docs and inline comments no longer describe already-removed failure
  modes as current behavior.

## Phase 6 — Tooling & Linting Improvements

### Phase 6 Objective

Move some of the repository's documented engineering expectations into tooling
so consistency does not depend solely on review discipline.

### Phase 6 Work Items

1. Scope a custom analyzer plugin that can encode lifecycle and BLoC rules,
   starting with a short design document plus one or two simple proof-of-
   concept rules.
2. Candidate first rules:
   - lifecycle guards such as `isClosed` and `context.mounted`
   - BLoC access and state-handling expectations
3. Optionally identify one or two complex flows where explicit state-machine
   helpers or local code generation would improve transition clarity and test
   coverage.

### Phase 6 Recommended First Slice

- Start with a rule that mirrors an already-existing validation expectation.
- Keep proof-of-concept rules narrow and low-noise.
- Only explore state-machine helpers on flows that already show transition
  complexity in code or tests.

### Phase 6 Deliverables

- Analyzer plugin scope/design note.
- One or two proof-of-concept lint rules.
- Optional state-machine helper prototype for a genuinely complex flow.
- Maintenance-cost note covering ownership, false-positive risk, and rollout
  plan.

### Phase 6 Exit Criteria

- The plugin scope is concrete enough to estimate maintenance cost.
- Proof-of-concept rules catch at least one class of mistakes the current
  review process handles manually.
- Any state-machine helper is proven on a real complex flow, not a toy example.

## Recommended Execution Order

1. Pick the next product area explicitly before touching more code.
2. If auth/security is the chosen target, continue Phase 1 by deepening roles,
   biometrics, or token propagation beyond the existing `/iot-demo` guard.
3. If error handling UX is the chosen target, continue Phase 4 by choosing one
   additional named consumer or shared UI seam after `ChartPage`,
   `ErrorHandling`, and `CounterPage`.
4. If sync is the chosen target, start Phase 2 with the explicit trigger
   contract and coalescing tests.
5. Continue broader Phase 2 rollout once sync-trigger contracts are ready,
   ideally after any relevant auth/token decisions are clear.
6. Run the Phase 3 DI spike only after the immediate auth, sync, and error
   seams are clearer.
7. Keep Phase 6 after the stronger repository patterns are stable enough to
   encode in tooling.

## Validation Standard

For each phase, prefer the narrowest validation that proves the contract:

1. Run targeted unit, repository, or bloc tests for touched boundaries.
2. Run focused `flutter analyze` scope for changed files.
3. Run relevant regression guards and validation scripts.
4. Update docs in the same change when behavior or architectural policy shifts.
5. Refresh coverage reporting when a phase adds meaningful new tests.

## Suggested Validation Commands

Choose the smallest command set that validates the touched phase:

```bash
# Repo baseline
./bin/checklist

# Focused tests
flutter test <target_test_file>

# Focused analysis
flutter analyze <touched_path>

# Regression guards
tool/check_regression_guards.sh

# Coverage refresh after meaningful new tests
dart run tool/update_coverage_summary.dart
```

## Escalation Triggers For Agents

Pause implementation and document the blocker when any of the following is
true:

- the phase requires choosing between two repository-wide patterns that are not
  already documented
- the smallest viable slice still forces unrelated feature rewrites
- a proposed change weakens existing validation rules or architectural
  boundaries to make the phase easier to land
- the target behavior conflicts with current docs and the conflict cannot be
  resolved from local code and documentation alone

## Phase Completion Checklist

Close a phase only when all of the following are true:

1. The implementation is merged or intentionally deferred with a documented
   decision.
2. The phase-specific exit criteria are satisfied by code, tests, or updated
   documentation.
3. Related repo-level docs are updated so the current behavior and the intended
   future state do not contradict each other.
4. Any new regression guard or analyzer rule added by the phase is fast enough
   to keep in the normal validation path.

## Implementation Handoff Format

When an agent finishes a slice from this plan, the handoff should state:

- what decision was made
- which files were changed
- which tests or validation commands were run
- what was intentionally deferred
- whether the plan or related docs were updated to reflect the new state

## Tracking Buckets

Use these buckets in the repo's existing task tracking flow:

- `auth-route-guards`
- `push-triggered-sync`
- `compile-time-di-spike`
- `structured-error-taxonomy`
- `critical-coverage-wave`
- `analyzer-plugin-scope`
- `state-machine-exploration`
