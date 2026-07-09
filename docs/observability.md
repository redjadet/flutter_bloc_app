# Observability: Errors and Crash Reporting

## Structured error codes

Use [AppErrorCode](../packages/utilities/lib/src/errors/error_codes.dart) when emitting error state or logging so analytics and crash tools can aggregate by type:

- **network** – connectivity or DNS failure
- **timeout** – request/operation timed out
- **auth** – 401 or token invalid
- **server** – 5xx or backend failure
- **serviceUnavailable** – 503; suggest retry after delay
- **client** – 4xx or bad request
- **rateLimit** – 429 or rate limited
- **unknown** – unclassified

Attach the code to freezed error state or pass to `AppLogger` / crash reporting.
Map from exceptions or HTTP status using
[NetworkErrorMapper](../apps/mobile/lib/app/utils/network_error_mapper.dart):
`getErrorCode(error)` for any error, including
[HttpRequestFailure](../packages/utilities/lib/src/errors/http_request_failure.dart),
`getErrorCodeForStatusCode(statusCode)` for raw status codes, or the existing
`isNetworkError` / `isTimeoutError` helpers.

## Logging

- Use `AppLogger.error(message, error, stackTrace)` for structured error logging.
- For stream subscriptions (widgets, adapters), provide `onError` when calling `stream.listen(...)` so errors are logged and do not become unhandled zone errors.
- Full conventions live in [logging.md](logging.md).

## Crash reporting (Firebase Crashlytics)

When Firebase initializes successfully, the app registers Flutter and zone error handlers that forward fatals to **Firebase Crashlytics**:

- Implementation: [`apps/mobile/lib/app/bootstrap/firebase_bootstrap_service.dart`](../apps/mobile/lib/app/bootstrap/firebase_bootstrap_service.dart) (`registerCrashlyticsHandlers`)
- **Sensitive data:** Do not attach PII, tokens, or full request/response bodies to crash reports. Use `AppErrorCode` and short context strings only.
- Configuration and secrets: [security_and_secrets.md](security_and_secrets.md), [firebase_setup.md](firebase_setup.md)

Crashlytics is **not** active when Firebase is disabled or fails to initialize (e.g. some test harnesses).

## Sentry + Crashlytics (plan: dual-stack, single “source of truth”)

Sentry is **not** installed or initialized today. If added, the plan is to run it **alongside Crashlytics** for a period, with an explicit division of responsibilities:

- **Crashlytics**: canonical crash reporting for Firebase-enabled builds (fatals, ANR equivalent surfaces, basic crash aggregation).
- **Sentry**: error monitoring + richer context (breadcrumbs, tracing/performance, release health, device/user segmentation) where it provides clear value.

Key constraint: avoid “two tools, two truths”. Define which tool drives on-call / triage for each incident type, and prevent double-reporting where possible.

### Recommended packaging for this repo

If Firebase ecosystem is already in use, the default plan is **Crashlytics + Sentry together** (not “either/or”).

- **Minimum setup**: Crashlytics
- **Professional setup**: Crashlytics + Sentry + strong logging discipline (`AppLogger`)

### Why add Sentry if Crashlytics exists

- **Context**: breadcrumbs + structured context on failures (e.g. `AppErrorCode`, screen/route, offline-first sync steps).
- **Performance**: tracing for cold start, navigation, HTTP spans, sync flush timings (Crashlytics is weak here).
- **Release health**: version + distribution insights (esp. if expanding beyond Firebase-only flows).

### Crashlytics vs Sentry (quick comparison)

| Feature | Crashlytics | Sentry |
| --- | --- | --- |
| Crash tracking | Very good | Very good |
| Non-fatal errors | Good | Very good |
| Stack trace detail | Good | More detailed |
| Breadcrumbs | Basic | Very strong |
| User journey analysis | Weak | Strong |
| Performance monitoring | Limited | Strong |
| Release health | Basic | Strong |
| Session replay | No | Yes |
| Flutter support | Very good | Very good |
| Setup | Very easy (5–10 min if Firebase already used) | Easy |
| Cost | Included with Firebase | Free tier + paid plans |
| Debugging experience | Simple | Advanced |

### Why this matters more in 2026

As code volume increases (including AI-assisted development), **time to find and fix** tends to cost more than time to write. Teams increasingly use Sentry not only for crash reports, but for broader **observability** (errors + context + performance).

### Known risks / causes of bad outcomes

- **Duplicate crash volume**: same fatal reported to both tools → noisy dashboards, inflated “issue count”.
- **PII leakage**: breadcrumbs / HTTP data can accidentally include tokens, emails, request bodies.
- **Symbolication mismatch**: iOS dSYM / Android mapping / Flutter symbol files not uploaded consistently → unusable stack traces.
- **Sampling / cost drift**: tracing + session replay can become expensive if enabled broadly.

Mitigations and rollout steps live in [plans/future_observability.md](plans/future_observability.md) under the Sentry section.

## Product analytics (not configured)

There is **no** Mixpanel, Sentry product SDK, or custom `AnalyticsPort` implementation in `pubspec.yaml` today. Operational diagnostics UI data lives under [`apps/mobile/lib/app/diagnostics/`](../apps/mobile/lib/app/diagnostics/) (Remote Config view models, cache controls) — not product funnel analytics.

- Interview/portfolio scope: [ADR 0005](adr/0005-interview-showcase-scope.md)
- Planned seams and event taxonomy: [plans/future_observability.md](plans/future_observability.md)
- Portfolio walk: [interview_showcase.md](interview_showcase.md) §11–12

Sync and settings surfaces expose **operational** telemetry (queue depth, flush status) via [`packages/storage/lib/src/sync/`](../packages/storage/lib/src/sync/) and Settings sync diagnostics — not product funnel analytics.

## Related docs

- [reliability_error_handling_performance.md](reliability_error_handling_performance.md)
- [interview_showcase.md](interview_showcase.md)
