# Dio + Retrofit Integration Plan

## Status

| Phase | Status | Notes |
| ----- | ------ | ----- |
| Phase 0: Prerequisites | Done | `retrofit` + `retrofit_generator` added; codegen works |
| Phase 1: Chart Pilot | Done | `CoingeckoApi`, `HttpChartRepository`, `DelayedChartRepository`, DI, tests |
| Phase 2: Error-Handling Strategy | Done | Keep `NetworkGuard` for manual `Dio` flows; do not force Retrofit through it; shared `Dio` uses `validateStatus: (_) => true` so repositories can keep status-based mapping |
| Phase 3: Counter / GraphQL / Hugging Face | Remaining | Optional; proceed per feature using the Phase 2 decision |

---

## Objective

Introduce Retrofit on top of the existing shared `Dio` stack to reduce
hand-written request code for stable REST-style APIs, without weakening
current repository responsibilities:

- keep clean architecture boundaries
- keep the single app `Dio` instance and its interceptors
- keep repository-owned parsing, caching, and error mapping where they already
  add product value

## Recommendation

Adopt Retrofit incrementally, starting with a low-risk pilot in chart data.

Decisions:

- Use annotation-based Retrofit first. Do not add OpenAPI generation yet.
- Keep `createAppDio()` as the only `Dio` entrypoint.
- Register generated API clients in feature DI, not in presentation.
- Keep domain interfaces unchanged.
- Keep GraphQL and Hugging Face on manual `Dio` + `NetworkGuard` by default;
  migrate only if Retrofit preserves their current behavior with less code.

## Why This Fits the Current Codebase

Current state in the repo:

- Shared `Dio` is already registered in
  `lib/core/di/register_http_services.dart`.
- Chart currently uses `HttpChartRepository`, with
  `DelayedChartRepository` adding only dev-delay behavior.
- GraphQL and chat have more custom transport concerns:
  - `CountriesGraphqlRepository` uses `NetworkGuard`, GraphQL error parsing,
    and operation-specific payloads.
  - `HuggingFaceApiClient` uses dynamic URIs, privacy-aware logging,
    content-type validation, and custom response parsing.
- Counter is a reasonable Retrofit candidate, but it is example/reference code,
  not the best first pilot.

Implication:

- Chart is the right first migration target because it is simple, already
  isolated, and does not depend on `NetworkGuard`.
- GraphQL and chat should keep their current manual `Dio` + `NetworkGuard`
  path unless Retrofit removes real duplication without weakening their
  custom error and parsing behavior.

## Non-Goals

- No domain-layer changes.
- No presentation-layer changes.
- No direct `GetIt` usage in widgets.
- No replacement of the shared `Dio` interceptors.
- No automatic OpenAPI pipeline in the first implementation.
- No forced DTO introduction where the repository currently benefits from
  custom parsing and fallback behavior.

## Migration Principles

- Put Retrofit interfaces under feature data layer paths such as
  `lib/features/<feature>/data/api/`.
- Generated `.g.dart` files stay in data/shared infrastructure only.
- Repositories keep ownership of:
  - domain mapping
  - fallback behavior
  - safe parsing for untrusted payloads
  - cache semantics
  - domain-specific exceptions
- Feature DI registers the Retrofit interface and injects it into the
  repository.
- Tests should prefer fakes or mocks of the Retrofit interface, not the
  generated implementation class.

## Target Architecture

- `register_http_services.dart`
  keeps registering the shared app `Dio`.
- Feature registration files such as `register_chart_services.dart`
  register Retrofit clients built from `getIt<Dio>()`.
- Repositories depend on Retrofit interfaces instead of raw `Dio` where the
  migration is complete.
- Wrapper repositories such as `DelayedChartRepository` remain thin and should
  not absorb HTTP details.

## Phase 0: Prerequisites

### 0.1 Add dependencies

Add:

```yaml
dependencies:
  retrofit: <compatible version>

dev_dependencies:
  retrofit_generator: <compatible version>
```

Use versions compatible with the repo's existing `dio` and `build_runner`
setup instead of pinning speculative versions in this plan.

### 0.2 Decide the pilot response shape

For the chart pilot, preserve existing repository behavior first:

- keep response parsing inside `HttpChartRepository`
- keep current cache and fallback semantics unchanged
- avoid introducing DTOs unless they clearly simplify the code without losing
  fallback safety

That means the Retrofit client should return a shape the repository can still
validate explicitly, rather than pushing all parsing into generated code on day
one.

### 0.3 Confirm codegen workflow

Use:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Only add a custom `build.yaml` if generator defaults become a real problem.
Do not add it preemptively.

## Phase 1: Chart Pilot

### Scope

Migrate the HTTP call inside `HttpChartRepository` only.

Do not change:

- `ChartRepository`
- `DelayedChartRepository` behavior
- chart caching TTL
- fallback data behavior
- chart parsing expectations in tests

### Implementation Steps

1. Add a Retrofit interface under
   `lib/features/chart/data/api/`.
2. Register that client in
   `lib/core/di/register_chart_services.dart`.
3. Update `HttpChartRepository` to depend on the Retrofit interface instead of
   raw `Dio`.
4. Keep JSON validation and `ChartPoint` mapping in the repository.
5. Keep `DelayedChartRepository` as the production-facing wrapper, updated only
   as needed to pass through the new dependency.

### Why Chart Is the Right Pilot

- It is a single endpoint.
- It already has focused regression tests.
- It does not depend on `NetworkGuard`.
- It lets us validate codegen, DI shape, and test ergonomics without touching
  more complex HTTP flows.

### Pilot Acceptance Criteria

- Shared app `Dio` is still the only underlying HTTP client.
- The chart repository no longer builds requests manually with raw `Dio`.
- Existing cache behavior remains unchanged.
- Existing invalid-payload and failed-request fallback behavior remains
  unchanged.
- No domain or UI contract changes are required.

## Phase 2: Establish the Error-Handling Strategy

Decision:

- Keep `NetworkGuard` as the shared repository-level wrapper for manual
  `Dio` requests.
- Do not add a Retrofit-specific adapter just to force generated clients
  through `NetworkGuard`.
- Allow Retrofit-backed repositories to handle response parsing and
  domain-specific fallback/error behavior directly in the repository.
- Keep shared `Dio` configured with `validateStatus: (_) => true` so
  repositories and `NetworkGuard` can inspect non-2xx responses instead of
  receiving premature `DioException.badResponse` failures.

Resulting rule:

- Use Retrofit for stable REST endpoints where it replaces boilerplate.
- Use manual `Dio` + `NetworkGuard` for custom, dynamic, or guard-heavy flows.
- Do not migrate a repository to Retrofit unless it preserves the existing
  status mapping, logging, parsing, and fallback behavior with less code.

Why this matters:

- `CountriesGraphqlRepository` currently relies on `NetworkGuard` to centralize
  timeout handling, status checks, and logging.
- `HuggingFaceApiClient` has custom error/privacy behavior that should not be
  weakened just to fit Retrofit.

Phase 2 acceptance criteria:

- non-2xx responses remain available to repository code and `NetworkGuard`
- no repository loses status-based exception mapping because of Dio defaults
- Retrofit stays optional, not mandatory, for each feature migration

## Phase 3: Candidate Migrations After the Pilot

### 3.1 Counter

Migrate `RestCounterRepository` next if we want a second low-risk Retrofit
example.

Reason:

- Simple REST shape
- good teaching/reference value
- lower risk than GraphQL or chat

### 3.2 GraphQL

Default path: keep manual `Dio` + `NetworkGuard`.

Only migrate if Retrofit clearly reduces boilerplate after preserving the same
error behavior.

Constraints:

- keep operation-specific methods, not one generic `postGraphql`
- preserve explicit GraphQL `errors` parsing
- preserve domain exception mapping
- prefer typed request/response DTOs if introduced

### 3.3 Hugging Face

Treat as optional and last.

Constraints:

- two endpoint shapes
- dynamic model-specific URI construction
- strict content-type validation
- privacy-aware failure logging
- custom response parsing that already lives in dedicated classes

Recommendation:

- Keep `HuggingFaceApiClient` as-is unless Retrofit removes meaningful
  duplication without making the flow harder to reason about.
- A justified decision to not migrate this path is acceptable.

## OpenAPI Generation

Do not include OpenAPI generation in the initial implementation plan.

Revisit later only if:

- the project gains maintained OpenAPI specs for real REST services
- the generated clients would replace meaningful manual code
- the output still fits the current clean architecture and testing patterns

Until then, OpenAPI adds planning overhead without helping the first migration.

## DI Plan

Register Retrofit clients close to the feature that owns them.

Preferred pattern:

- shared `Dio` remains in `register_http_services.dart`
- feature Retrofit clients are registered in the corresponding
  `register_<feature>_services.dart`
- repositories receive typed clients through constructors

Avoid:

- constructing Retrofit clients inside repositories
- centralizing all feature API clients in one unrelated DI file
- exposing Retrofit types outside the data layer

## Testing and Validation

For the chart pilot, add or update regression guards around the behavior being
preserved.

Minimum validation:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/chart_repository_test.dart
flutter test test/delayed_chart_repository_test.dart
npx markdownlint-cli --ignore-path /dev/null docs/plans/dio_retrofit_integration_plan.md
```

If the implementation expands beyond the chart feature or changes shared HTTP
utilities, run:

```bash
./tool/analyze.sh
```

Testing expectations:

- update existing chart repository tests rather than duplicating them
- keep regression coverage for cache reuse
- keep regression coverage for fallback-on-error
- keep regression coverage for invalid payload handling
- add DI coverage only if the registration shape changes materially

## Risks and Mitigations

| Risk | Impact | Mitigation |
| ---- | ------ | ---------- |
| Retrofit adds little value on highly custom clients | Complexity without payoff | Start with chart only; make later migrations opt-in |
| Guard-heavy repos diverge in error behavior | Regressions in logging or exception mapping | Keep manual `Dio` + `NetworkGuard` as the default for those flows |
| Generated clients leak outside data layer | Architecture drift | Register and consume Retrofit types only in data/DI |
| Pilot adds DTO churn too early | More code, weaker fallback paths | Keep parsing in the repository for phase 1 |

## Rollout Order

1. Add Retrofit dependencies and confirm codegen works.
2. Implement the chart Retrofit client and wire it through chart DI.
3. Preserve and verify current chart behavior with focused tests.
4. Keep `NetworkGuard` for manual `Dio` flows and avoid forcing Retrofit into
   custom clients.
5. Migrate counter next if a second low-risk example is useful.
6. Re-evaluate GraphQL and Hugging Face individually instead of forcing a
   blanket migration.

## Summary

This should be treated as a targeted Retrofit adoption, not a repo-wide
conversion.

The implementation-ready path is:

- use chart as the pilot
- keep the shared `Dio` instance
- keep repository-owned parsing and fallback behavior
- keep `NetworkGuard` for manual `Dio` flows and use Retrofit selectively
- validate with focused regression tests before expanding scope
