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

- Evaluate overlap with Crashlytics; prefer one primary crash tool per flavor
- Breadcrumbs from `AppLogger` at `info` and above; scrub tokens in HTTP layer

## Verification before ship

- `./bin/checklist-fast`
- Privacy review in [security_and_secrets.md](../security_and_secrets.md)
- Update [observability.md](../observability.md) and [interview_showcase.md](../interview_showcase.md) — do not claim shipped until SDK + init exist
