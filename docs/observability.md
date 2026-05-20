# Observability: Errors and Crash Reporting

## Structured error codes

Use [AppErrorCode](../lib/shared/utils/error_codes.dart) when emitting error state or logging so analytics and crash tools can aggregate by type:

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
[NetworkErrorMapper](../lib/shared/utils/network_error_mapper.dart):
`getErrorCode(error)` for any error, including
[HttpRequestFailure](../lib/shared/utils/http_request_failure.dart),
`getErrorCodeForStatusCode(statusCode)` for raw status codes, or the existing
`isNetworkError` / `isTimeoutError` helpers.

## Logging

- Use `AppLogger.error(message, error, stackTrace)` for structured error logging.
- For stream subscriptions (widgets, adapters), provide `onError` when calling `stream.listen(...)` so errors are logged and do not become unhandled zone errors.
- Full conventions live in [logging.md](logging.md).

## Crash reporting (Firebase Crashlytics)

When Firebase initializes successfully, the app registers Flutter and zone error handlers that forward fatals to **Firebase Crashlytics**:

- Implementation: [`lib/core/bootstrap/firebase_bootstrap_service.dart`](../lib/core/bootstrap/firebase_bootstrap_service.dart) (`registerCrashlyticsHandlers`)
- **Sensitive data:** Do not attach PII, tokens, or full request/response bodies to crash reports. Use `AppErrorCode` and short context strings only.
- Configuration and secrets: [security_and_secrets.md](security_and_secrets.md), [firebase_setup.md](firebase_setup.md)

Crashlytics is **not** active when Firebase is disabled or fails to initialize (e.g. some test harnesses).

## Product analytics (not configured)

There is **no** Mixpanel, Sentry product SDK, or custom `AnalyticsPort` implementation in `pubspec.yaml` today. Operational diagnostics UI data lives under [`lib/core/diagnostics/`](../lib/core/diagnostics/) (Remote Config view models, cache controls) — not product funnel analytics.

- Interview/portfolio scope: [ADR 0005](adr/0005-interview-showcase-scope.md)
- Planned seams and event taxonomy: [plans/future_observability.md](plans/future_observability.md)
- Portfolio walk: [interview_showcase.md](interview_showcase.md) §11–12

Sync and settings surfaces expose **operational** telemetry (queue depth, flush status) via [`lib/shared/sync/`](../lib/shared/sync/) and Settings sync diagnostics — not product funnel analytics.

## Related docs

- [reliability_error_handling_performance.md](reliability_error_handling_performance.md)
- [interview_showcase.md](interview_showcase.md)
