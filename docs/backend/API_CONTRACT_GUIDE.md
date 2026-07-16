# Mobile / Backend API Contract Guide

Canonical contract for how this Flutter app and its backends share responsibility.
Owner docs for offline, auth, reliability, and DTOs stay authoritative — this guide
links them and fills gaps (especially future pagination).

## Responsibilities

| Layer | Owns | Must not own |
| --- | --- | --- |
| **Backend** | AuthZ, persistence truth, business rules, stable wire schemas, error codes | Client UI copy, Cubit state shapes, presentation layout |
| **Mobile data** | HTTP/GraphQL clients, DTOs, defensive parsing, retries/idempotency via shared Dio, cache merge | Domain models leaking wire types; ad-hoc `Dio()` |
| **Mobile domain** | Pure models, repository contracts, typed failures | `fromJson`/`toJson`, Dio, Flutter |
| **Mobile presentation** | Cubit UI state, mapping failures → user-visible state | Calling HTTP, parsing JSON, holding backend DTOs |
| **Shared** | Contract versioning, idempotency keys, pagination field names when introduced | Duplicating policy across hubs |

## Contract evolution and versioning

- Prefer additive JSON fields; mobile ignores unknown top-level keys.
- Breaking renames/removals require versioned path or documented migration window.
- String enums (status bands, actions) stay raw `String` on mobile until product needs sealed mapping — unknown values must not crash.
- Document breaking changes in `docs/changes/` and bump any public API version header the backend already uses.

## Defensive parsing and DTO boundary

- Wire DTOs live in `data/` only. Policy: [`architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md).
- Missing/malformed **required** fields → `FormatException` (or feature data failure), never raw `TypeError`/`CastError`.
- Nested maps may retain unknown keys for domain mappers.
- Reference: AI Decision `ai_decision_json.dart`, GraphQL `graphql_json.dart`.

## Errors, retries, idempotency

- Map transport failures in data/shared utilities (`NetworkErrorMapper`, `HttpRequestFailure`).
- Shared Dio: retry interceptor + auth refresh single-flight — do not bypass with private clients except allowlisted Render factory.
- Mutations that can replay must carry client/request ids per offline-first contracts.
- Owners: [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md), offline feature docs under [`offline_first/`](../offline_first/).

## Cache ownership

- Backend is source of truth when online; local cache is optimistic/stale-aware.
- Repositories own merge rules; Cubits must not invent “backend truth” from UI state alone.
- See offline-first adoption guide and per-feature offline contracts.

## Authentication

- Firebase/session tokens inject via shared app Dio (`createAppDio`).
- Non-shared clients (Render chat) document why they omit interceptors.
- Owner: [`authentication.md`](../authentication.md).

## Observability

- Prefer `AppErrorCode` + short context; never attach tokens/PII to crash reports.
- **Product analytics** (event taxonomy / Mixpanel-style SDKs) remain deferred —
  [`plans/future_observability.md`](../plans/future_observability.md), ADR-0005.
- Owner: [`observability.md`](../observability.md).

## Pagination contract (future — not implemented yet)

When the first paginated list ships, backends and mobile must agree on:

| Concern | Offset style | Cursor style |
| --- | --- | --- |
| Request | `limit`, `offset` (or `page`) | `limit`, `cursor` (opaque) |
| Response | `items`, `total?`, `next_offset?` | `items`, `next_cursor?`, `has_more` |
| Refresh | Reset offset to 0; replace list | Reset cursor to null; replace list |
| Load more | Increment offset by page size | Pass prior `next_cursor` |
| Duplicates | Deduplicate by stable id before append | Same |
| Empty page | Stop; do not spin | Stop when `next_cursor` null / `has_more` false |

**Required tests when first list lands:** happy page, empty page, duplicate-id append prevention, malformed page payload → controlled failure, refresh replaces not concatenates.

Until then: document intent in PRs that add list endpoints; do not invent a pagination framework.

## Related

- Boundaries / failure modes: [`architecture/MOBILE_BACKEND_BOUNDARIES.md`](../architecture/MOBILE_BACKEND_BOUNDARIES.md)
- PR questions: [`contributing/PR_REVIEW_CHECKLIST.md`](../contributing/PR_REVIEW_CHECKLIST.md)
- Transport guard: `bash tool/check_adhoc_dio_construction.sh`
