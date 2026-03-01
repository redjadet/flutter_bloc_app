# Observability: Errors and Crash Reporting

## Structured error codes

Use [AppErrorCode](lib/shared/utils/error_codes.dart) when emitting error state or logging so analytics and crash tools can aggregate by type:

- **network** – connectivity or DNS failure
- **timeout** – request/operation timed out
- **auth** – 401 or token invalid
- **server** – 5xx or backend failure
- **serviceUnavailable** – 503; suggest retry after delay
- **client** – 4xx or bad request
- **rateLimit** – 429 or rate limited
- **unknown** – unclassified

Attach the code to freezed error state or pass to `AppLogger` / crash reporting. Map from exceptions or HTTP status using [NetworkErrorMapper](lib/shared/utils/network_error_mapper.dart): `getErrorCode(error)` for any error (including [HttpRequestFailure](lib/shared/utils/http_request_failure.dart)), `getErrorCodeForStatusCode(statusCode)` for raw status codes, or the existing `isNetworkError` / `isTimeoutError` helpers.

## Logging

- Use `AppLogger.error(message, error, stackTrace)` for structured error logging.
- For stream subscriptions (widgets, adapters), provide `onError` when calling `stream.listen(...)` so errors are logged and do not become unhandled zone errors.

## Crash reporting (optional)

If the project adopts Firebase Crashlytics or similar:

1. **Uncaught errors:** Register `FlutterError.onError` and `runZonedGuarded` so uncaught errors and zone errors are reported.
2. **Sensitive data:** Do not attach PII, tokens, or full request/response bodies to crash reports. Use `AppErrorCode` and short context strings only.
3. **Document:** Update [security_and_secrets.md](security_and_secrets.md) with the chosen tool and any auth/configuration required.

No crash reporting is configured by default; this section describes the pattern when you add it.
