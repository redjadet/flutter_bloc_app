# Logging Guidelines

Project logging must help diagnose failures quickly without leaking sensitive
data or creating noisy, unstable output.

## Goals

- Make logs searchable by feature, operation, and user-visible failure.
- Capture enough execution context to identify the root cause without reruns.
- Keep recurring messages stable so tests, crash reports, and manual triage stay
  reliable.
- Avoid raw console output and secrets in every build mode.
- Prefer privacy-minimized security/diagnostic events in production — not
  silence.

## Logger API

Use [`AppLogger`](../../packages/app_shared_flutter/lib/src/utils/logger.dart) for app code.
All public entry points sanitize message and error text through
[`LogRedaction`](../../packages/app_shared_flutter/lib/src/utils/log_redaction.dart)
before console, `AppLogger.observer`, and Crashlytics sinks.

Legacy string APIs remain supported:

```dart
AppLogger.info('sync.flush completed operation=profile reason=manual');
AppLogger.warning('sync.flush retrying operation=profile reason=offline');
AppLogger.error(
  'sync.flush failed operation=profile reason=remote_error',
  error,
  stackTrace,
);
```

Prefer structured events for new logs:

```dart
AppLogger.event(
  AppLogLevel.info,
  'login_failed',
  fields: {
    'statusCode': response.statusCode,
    'requestId': requestId,
  },
);
```

Do not pass `response.body`, headers, tokens, or full URIs with query values.
Pass caught errors via `error:` / `AppLogger.error` so redaction runs before any
sink.

Do not use `print()` or `debugPrint()` in `lib/`. The
[`tool/check_raw_print.sh`](../../tool/check_raw_print.sh) guard rejects raw
console output.
[`tool/check_sensitive_logging.sh`](../../tool/check_sensitive_logging.sh)
rejects high-confidence secret/URI/body patterns in log calls (including iOS
`absoluteString`).

`AppLogger` suppresses normal output in tests, supports `silence()` /
`silenceAsync()` for expected noisy blocks, and emits release logs only at
warning or error level.

## Redaction contract

- Secret field keys (case-insensitive camel/snake/kebab, matched on the
  normalized **suffix**): `password`, `passwd`, `token`, `authorization`,
  `cookie`, `apiKey`, `sessionId`, `secret`, `bearer`, `privateKey` →
  `[REDACTED]`. Suffix matching covers `client_secret`, `x-api-key`,
  `set-cookie`, `csrfToken`; counters such as `maxTokens` stay visible.
- URIs keep scheme/host/port/path; query and fragment **values** are redacted.
- Invalid URI strings become `[INVALID_URI]` (never echoed).
- CR/LF/control characters collapse; messages truncate at 1024 chars with
  `…[truncated]`.
- Free-text scrub covers Bearer credentials, JWT-like blobs, email
  addresses, and denylist assignments in `key=value`, `key: value`, and
  JSON-style `"key":"value"` form, including compound names such as
  `refresh_token` or `client_secret` (heuristic; exception text from HTTP
  clients often embeds response JSON).
- Crashlytics receives sanitized exception **text** plus the original stack;
  raw `FlutterErrorDetails` / exception objects are never recorded.

## What reaches production sinks

Redaction protects `AppLogger` sinks only. Other paths ship whatever they are
given:

| API | Release behaviour | Rule |
| --- | --- | --- |
| `print` / `debugPrint` | Both write in release (Android logcat tag `flutter`, iOS/macOS unified log). `debugPrint` only throttles; it is not compiled out. | Banned in `lib/` (`avoid_print`, `tool/check_raw_print.sh`). |
| `dart:developer` `log()` | Goes to the VM service logging stream (DevTools/IDE). Release builds have no VM service, but debug/profile sessions show unredacted `error:` objects. | Prefer `AppLogger`; never pass secrets as `error:`. |
| `if (kDebugMode)` / `assert` | `kDebugMode` / `kReleaseMode` are `const`; guarded code is tree-shaken from release. | Use `AppLogger.debugInDebugMode` for local-only detail. |
| Android R8 `-assumenosideeffects android.util.Log` | Strips Java/Kotlin `Log.*` calls only. Dart output goes through the Flutter engine and is unaffected. | Do not rely on R8 for Dart logs. |
| Swift `os_log` / `Logger` | Dynamic string values are redacted as private by default in the unified log; `privacy: .public` publishes them. `print` / `NSLog` are not redacted. | Keep `.public` for non-sensitive values only; `check_sensitive_logging.sh` scans iOS Swift. |

## Third-party SDKs and backends

- **dio `LogInterceptor`:** defaults log request/response **headers**
  (`Authorization`, `Cookie`) and URLs; bodies are off. Its default `logPrint`
  only prints inside `assert`, but passing `print`, `debugPrint`, or an
  `AppLogger` lambda ships that output in release. This repo uses no
  `LogInterceptor`; if one is added, set `requestHeader: false`,
  `responseHeader: false`, keep bodies off, and gate it with `kDebugMode`.
  `package:http` has no built-in logging; wrappers must log method, path,
  status, and duration only.
- **Crashlytics:** `recordError` reason, custom keys, `log()` breadcrumbs, and
  `setUserIdentifier` are uploaded with every report. Keep the allowlist in
  [`observability.md`](../observability.md); do not set a user identifier from
  email or phone.
- **Sentry (not shipped, ADR 0008):** if adopted, keep `sendDefaultPii: false`
  (the default) and scrub with `beforeSend` / `beforeBreadcrumb` using
  `LogRedaction`; HTTP integrations record URLs and, with PII enabled, headers.
- **Analytics:** event parameters go to Google; never pass free text, emails,
  or ids that identify a person.
- **Python demo backends:** log exception **type**, not `str(e)`, for auth and
  upstream client errors. Library messages can echo the input
  (google-auth includes token segments in malformed-token errors).

## Required Context

Include compact `key=value` fields (via `AppLogger.event` fields or message
text) that make the event searchable.

Use these fields when they apply:

- `feature`: app feature or demo area, such as `todo`, `chat`, `iot_demo`,
  `staff_demo`, or `profile`.
- `operation`: user or system action, such as `load`, `save`, `sync.flush`,
  `subscription.start`, or `bootstrap`.
- `entity_id`: durable local/domain id when it is safe to log.
- `route`: route name/path for navigation and auth-gate decisions.
- `request_id`: in-flight/request guard id when diagnosing stale async results.
- `sync_id` or `operation_id`: background sync or queued work id.
- `status_code`: HTTP status when the error came from a remote call.
- `error_code`: [`AppErrorCode`](../../packages/utilities/lib/src/errors/error_codes.dart) or a
  stable domain error code.
- `reason`: short machine-readable cause, such as `offline`, `timeout`,
  `unauthorized`, `validation_failed`, or `storage_unavailable`.

Do not log PII, tokens, raw credentials, full request/response bodies,
authorization headers, API keys, or unredacted file contents. See
[`security_and_secrets.md`](../security_and_secrets.md) for secret handling.

## Message Design

- Start with `feature.operation outcome`, for example
  `profile.load failed ...` or `chat.stream retrying ...`.
- Prefer deterministic wording for recurring lifecycle events.
- Include the outcome: `started`, `completed`, `failed`, `retrying`,
  `skipped`, or `cancelled`.
- Include `reason=...` for failures, retries, skips, and cancellations.
- Keep messages short; put verbose diagnostics in tests, debug tools, or
  purpose-built traces instead of app logs.
- Pass the caught error and stack trace to `AppLogger.error` instead of
  interpolating large exception text into the message.

## Scope Guidance

- **Cubits/BLoCs:** log meaningful load/save/sync failures at boundaries.
  Avoid logging every state transition.
- **Repositories/data sources:** log remote/storage failures after mapping them
  to stable domain context. Keep payload data out of logs.
- **Streams/subscriptions:** pass `onError` to `stream.listen(...)` and use
  `AppLogger.streamErrorHandler('context')` when simple logging is enough.
- **Router/auth gates:** log unexpected redirect/auth failures with `route` and
  short `reason`; avoid logging auth tokens or provider payloads.
- **Bootstrap/storage:** log initialization, migration, and storage-unavailable
  failures with `operation`, `reason`, and safe path category when useful.
- **Debug-only diagnostics:** use `AppLogger.debugInDebugMode` when the message
  is only useful during local debugging and should not allocate work in release.

## Checklist For New Logs

- Does the log use `AppLogger`, not `print()` or `debugPrint()`?
- Prefer `AppLogger.event` with safe fields for new structured events?
- Is the event useful at a boundary or failure point, not just noisy progress?
- Are `feature`, `operation`, and `reason` present when they help search?
- Is there a stable `error_code`, `status_code`, `request_id`, or `sync_id`
  available?
- Are secrets, PII, raw payloads, and full credentials excluded?
- Does `AppLogger.error` / `event(..., error:)` receive the original error and
  stack (so redaction runs) rather than interpolating secrets into the message?
- Is the message wording stable enough for future triage?

## Sources

- Flutter: [Add logging to your app](https://docs.flutter.dev/testing/code-debugging)
  (`debugPrint` prints in release unless guarded),
  [kReleaseMode](https://api.flutter.dev/flutter/foundation/kReleaseMode-constant.html),
  [kDebugMode](https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html),
  [dart:developer log](https://api.dart.dev/dart-developer/log.html)
- Dart lint: [avoid_print](https://dart.dev/tools/linter-rules/avoid_print)
- OWASP: [MASVS-STORAGE](https://mas.owasp.org/MASVS/05-MASVS-STORAGE/),
  [MASWE-0001 Insertion of Sensitive Data into Logs](https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0001/),
  [Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- Android: [Shrink, obfuscate, and optimize your app](https://developer.android.com/build/shrink-code)
- Apple: [Generating log messages from your code](https://developer.apple.com/documentation/os/generating-log-messages-from-your-code),
  [OSLogPrivacy](https://developer.apple.com/documentation/os/oslogprivacy)
- Crashlytics: [Customize crash reports (Flutter)](https://firebase.google.com/docs/crashlytics/customize-crash-reports?platform=flutter)
- Sentry: [Options: sendDefaultPii](https://docs.sentry.io/platforms/dart/guides/flutter/configuration/options/),
  [Scrubbing sensitive data](https://docs.sentry.io/platforms/dart/guides/flutter/data-management/sensitive-data/)
- dio: [LogInterceptor](https://pub.dev/documentation/dio/latest/dio/LogInterceptor-class.html)
