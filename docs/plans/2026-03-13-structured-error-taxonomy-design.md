# Structured Error Taxonomy — Design

- Bucket: `structured-error-taxonomy`
- Related phases: Phase 4 (primary), Phase 5 (validation alignment)

## Status

This is a **design note / working plan**. If adopted, the repository-wide
contract should be captured in an ADR under `docs/adr/` and/or reflected in the
owning core docs (for example `docs/reliability_error_handling_performance.md`
and `docs/CODE_QUALITY.md`).

## 1. Goals & Non‑Goals

### Goals

- Define a sealed, cross‑cutting error model that:
  - cleanly separates transport, storage, auth, and unknown failures
  - can be surfaced consistently from shared utilities (`http_request_failure.dart`, `network_error_mapper.dart`) up into cubits and UI
  - gives UI enough structure to distinguish retryable vs non‑retryable cases.
- Align existing shared helpers on a single canonical mapping path for HTTP/transport failures.
- Provide a migration path that lets features opt‑in incrementally without breaking existing string‑based UIs.

### Non‑Goals

- No repo‑wide migration of all cubits/UI in one step; adoption will be feature‑by‑feature.
- No change to Supabase‑specific domain error hierarchies (e.g. `GraphqlDemoException`) beyond optionally mapping them into the shared taxonomy as a secondary layer.
- No change to auth/session storage implementations; the taxonomy only describes how failures are represented, not how auth itself works.

## 2. Location & Shape of Sealed Types

### Location

- New file: `lib/shared/utils/app_error.dart`
  - Shared, Flutter‑agnostic (no `BuildContext`), reusable by data and presentation layers.

### Core types

- Root sealed hierarchy:
  - `sealed class AppError`
    - `NetworkError`
      - cases: `timeout`, `offline`, `serviceUnavailable`, `rateLimited`, `server`, `client`, `unknown`
    - `StorageError`
      - cases: `read`, `write`, `migration`, `corruption`
    - `AuthError`
      - cases: `unauthorized`, `tokenExpired`, `forbidden`
    - `UnknownError`
      - catch‑all, used when we do not have a more specific mapping.

### Properties

- `AppError`:
  - `String message` (human‑readable, non‑localized; suitable for logs and dev tools)
  - `Object? cause` (original exception where applicable)
  - `bool get isRetryable` (derived; see mapping rules)

- Child types narrow semantics but do not add UI‑specific concerns:
  - `NetworkError`:
    - `NetworkErrorKind kind` (enum with `timeout`, `offline`, `serviceUnavailable`, `rateLimited`, `server`, `client`, `unknown`)
  - `StorageError`:
    - `StorageErrorKind kind` (enum with `read`, `write`, `migration`, `corruption`)
  - `AuthError`:
    - `AuthErrorKind kind` (enum with `unauthorized`, `tokenExpired`, `forbidden`)

## 3. Relationship to Existing Helpers

### `HttpRequestFailure`

- Remains as a thin, HTTP‑specific adapter for now:
  - continues to carry `statusCode`, `message`, `retryAfterSeconds`.
  - gains a helper to project into `AppError`:
    - `AppError toAppError()` (or a static mapper function in `app_error.dart`).
- Long‑term options (to be revisited after adoption experience):
  - either keep `HttpRequestFailure` as an internal detail of HTTP helpers, or
  - deprecate it in favor of returning `NetworkError` directly from shared HTTP code.

### `NetworkErrorMapper`

- Becomes the canonical transport mapper for:
  - `DioException`
  - `HttpRequestFailure`
  - generic `Object` errors that look like HTTP/transport failures.
- Responsibilities:
  - primary: map inputs to `AppError` (structured), not just strings.
  - secondary: produce user‑facing strings from `AppError` plus optional `AppLocalizations`.
- Transitional API:
  - New: `static AppError getAppError(dynamic error)` (or similar naming).
  - Existing: `static String getErrorMessage(dynamic error, {AppLocalizations? l10n})` remains, but internally:
    - calls `getAppError(error)` first
    - then maps `AppError` → localization key → string.

## 4. Canonical Mapping Rules (Transport Focus)

### HTTP status code → `NetworkErrorKind`

- 401, 403:
  - mapped to `AuthError` (`unauthorized` / `forbidden`) when we have clear auth semantics.
  - remain `NetworkError.client` only where the call site is explicitly non‑auth (e.g. public API); this distinction will be made at mapper call sites as needed.
- 404: `NetworkError.client` (non‑retryable).
- 408: `NetworkError.timeout` (retryable).
- 429: `NetworkError.rateLimited` (retryable, with potential `retryAfterSeconds` from `HttpRequestFailure`).
- 5xx: `NetworkError.server` (retryable for 500/502/503/504; non‑retryable for other 5xx only if we later find a real need).
- Other 4xx: `NetworkError.client`.
- No status / unparsable: fall back to `NetworkError.unknown`.

### Retryability (`AppError.isRetryable`)

- `NetworkError.timeout`, `NetworkError.offline`, `NetworkError.serviceUnavailable`, `NetworkError.rateLimited`, `NetworkError.server` → `true`.
- `NetworkError.client` (including 404), `AuthError.*`, and `StorageError.*` → `false` by default.
- `UnknownError` → `false` unless explicitly created as retryable by a higher‑level mapper.

## 5. Representative Consumers for First Slice

Per the plan, the first implementation slice should touch one shared seam and one representative consumer.

- **Shared seam (mapper path):**
  - `lib/shared/utils/http_request_failure.dart`
  - `lib/shared/utils/network_error_mapper.dart`

- **Representative consumer (cubit + UI):**
  - choose one feature that already uses `NetworkErrorMapper` for user‑visible messages, for example:
    - a simple data‑loading cubit that shows generic error banners/snackbars.
  - update:
    - cubit state to carry `AppError? lastError` or similar alongside existing status flags.
    - UI to branch on `AppError` (e.g. render different variants for network vs auth vs unknown).

This first adoption will be kept intentionally small (one cubit + one UI path) to validate ergonomics before broader rollout.

## 6. Migration Strategy (High‑Level)

### Stage 1 — Introduce shared types and mappers

- Add `app_error.dart` with the sealed hierarchy and enums.
- Update `http_request_failure.dart` to be able to project to `AppError`.
- Update `network_error_mapper.dart` to:
  - implement `getAppError`.
  - re‑implement `getErrorMessage` in terms of `AppError`.
- No feature‑level code changes yet; all existing call sites keep working.

### Stage 2 — Pilot feature adoption

- Select one representative cubit + UI path:
  - switch internal error handling to use `AppError`.
  - keep existing strings as a fallback, but prefer using `NetworkErrorMapper.getErrorMessage` fed from `AppError`.
- Add focused tests:
  - mapper tests for `getAppError`.
  - cubit tests that assert correct `AppError` types are surfaced in state.
  - widget tests (or golden tests where appropriate) for new structured error UI branch.

### Stage 3 — Optional broader rollout

- Only after the pilot is stable:
  - expand adoption to other shared services and cubits that already depend on `NetworkErrorMapper`.
  - avoid forcing adoption on feature code that has highly custom error models unless there is a clear product benefit.

## 7. Out‑of‑Scope Decisions for This Slice

This design slice intentionally does not decide:

- whether Supabase‑specific domain exceptions (e.g. `GraphqlDemoException`) should directly implement `AppError` or remain separate with optional adapters.
- whether `HttpRequestFailure` should be fully deprecated; that decision can be taken after we have real usage experience with `AppError`.
- any changes to logging strategy beyond the minimal context we already carry in `AppError.cause` and `message`.
