# Future observability — product analytics and error monitoring (plan only)

**Status:** Not implemented. No Mixpanel, Sentry, or Patrol SDK in `pubspec.yaml`. Governed by [ADR 0005](../adr/0005-interview-showcase-scope.md).

## Goals

- Product analytics for funnel and feature adoption (Counter, Todo, Chat)
- Error monitoring with release health (complement Firebase Crashlytics)
- Keep PII out of payloads; use `AppErrorCode` and coarse event names

## Integration seams (existing code)

| Seam | Use |
| --- | --- |
| `AppLogger` / `AppLogger.observer` | Central hook for debug + future analytics bridge |
| `AppErrorCode` + cubit error handlers | Classify failures before export |
| Sync `telemetry` / diagnostics | Queue depth, flush outcomes |
| `firebase_bootstrap_service.dart` | Crashlytics already when Firebase on |

## Event taxonomy (draft)

| Event | Properties (non-PII) |
| --- | --- |
| `counter_increment` | `delta`, `source` (local/remote) |
| `todo_created` | `priority_bucket` |
| `chat_message_sent` | `transport` enum |
| `sync_flush_completed` | `entity_type`, `success`, `duration_ms` |

## Mixpanel (if adopted)

- Flutter SDK behind a thin `AnalyticsPort` in `lib/core/` (interface only until second consumer)
- Identify users only after explicit consent; no email in super properties by default

## Sentry (if adopted)

### Positioning: coexist with Crashlytics, avoid double-triage

Crashlytics already exists behind Firebase initialization; Sentry would be adopted only if it provides clear incremental value:

- **Primary crash tool**: keep **Crashlytics** as the canonical “crash inbox” for Firebase-enabled builds unless/until Sentry proves it should replace it.
- **Primary context tool**: use **Sentry** for breadcrumbs + tracing + release health.

### Why Sentry is a good fit for this codebase

This repo leans toward patterns where “what happened between UI and IO” matters:

- Clean Architecture boundaries (UI → BLoC/Cubit → UseCase → Repository → Data source)
- Offline-first flows (queued work, retries, reconciliation)
- Enterprise-style troubleshooting needs (root cause > “crash happened”)

Sentry is typically stronger than Crashlytics at showing the full chain with breadcrumbs + tags + traces, for example:

`User Login → API call → Dio exception → Repository → UseCase → BLoC → UI`

Define one owner dashboard per incident type:

- **Crashes / fatals**: Crashlytics first; Sentry gets only what is needed for correlation (or is sampled).
- **Non-fatal errors** (domain/network/sync): Sentry first (because it can carry breadcrumbs and tags cleanly).
- **Performance regressions**: Sentry first (tracing).

### Data model mapping (non-PII)

Use existing classification and keep payloads coarse:

- Map `AppErrorCode` → Sentry `tag:error_code`
- Map feature area (Counter/Todo/Chat/Sync/Diagnostics) → `tag:feature`
- Map offline-first sync outcomes → structured breadcrumbs (no entity IDs; use entity *type*)

Avoid:

- user identifiers (email, phone) unless explicit consent + documented purpose
- request/response bodies
- auth tokens, refresh tokens, headers (Authorization, Cookie)

### Breadcrumbs

- Breadcrumb source: `AppLogger` at `info` and above (and selected `debug` only for local/dev).
- Scrubbing: ensure HTTP layer scrubs tokens and sensitive headers before any breadcrumb export.

### Tracing / performance (phased)

Start narrow to control cost and noise:

- Phase 1: app start + navigation spans (top-level only)
- Phase 2: HTTP spans (sampled)
- Phase 3: offline-first sync flush spans and durations (sampled, feature-gated)

If/when adopted, prioritize Sentry integrations that align with existing seams:

- Dio integration (HTTP spans + error context)
- HTTP tracing (sampling) to identify slow endpoints / retries
- Slow screen analysis (navigation spans + frame metrics if enabled)
- Release-based tracking (regressions by version/build)

### Symbolication / stack trace quality (must-have)

If stack traces are not symbolicated, Sentry adoption is considered “not shipped”.

- iOS: dSYM upload in CI (and validate for release build)
- Android: mapping upload for obfuscation (if enabled)
- Flutter: ensure build artifacts for symbolication are produced and upload path is documented

### Duplicate event prevention (must-have)

Goal: no “same crash, two tools” for the long term.

Options (pick one per build flavor):

- **Option A (recommended start)**: Crashlytics captures **fatals**, Sentry captures **non-fatals + performance**.
- **Option B**: Sentry captures fatals, Crashlytics disabled for crash capture (requires explicit decision + verification).

### Rollout plan (suggested)

- **Step 0**: doc-only decision record (what goes where; what counts as PII; who owns dashboards)
- **Step 1**: add Sentry SDK behind feature flag / env toggle; enable in dev only
- **Step 2**: enable in staging/internal distribution; validate:
  - symbolication works
  - duplicates controlled
  - no sensitive data in breadcrumbs/tags
- **Step 3**: production enable with conservative sampling; monitor event volume + cost
- **Step 4**: decide whether to keep dual-stack, or move to single “primary” tool for crashes

### Acceptance checks before “implemented” claim

- Crash/exception captured in intended tool(s) for each category (fatal vs non-fatal)
- No obvious duplicates for the same fatal in the default triage path
- Symbolicated stack traces on iOS + Android
- PII scrub confirmed (headers, tokens, email) in at least one captured session
- `docs/observability.md` updated to reflect the new reality (not “plan only”)

## Verification before ship

- `./bin/checklist-fast`
- Privacy review in [security_and_secrets.md](../security_and_secrets.md)
- Update [observability.md](../observability.md) and [interview_showcase.md](../interview_showcase.md) — do not claim shipped until SDK + init exist
