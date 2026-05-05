# Logging Guidelines

Project logging must help diagnose failures quickly without leaking sensitive
data or creating noisy, unstable output.

## Goals

- Make logs searchable by feature, operation, and user-visible failure.
- Capture enough execution context to identify the root cause without reruns.
- Keep recurring messages stable so tests, crash reports, and manual triage stay
  reliable.
- Avoid raw console output and secrets in every build mode.

## Logger API

Use [`AppLogger`](../lib/shared/utils/logger.dart) for app code:

```dart
AppLogger.info('sync.flush completed operation=profile reason=manual');
AppLogger.warning('sync.flush retrying operation=profile reason=offline');
AppLogger.error(
  'sync.flush failed operation=profile reason=remote_error',
  error,
  stackTrace,
);
```

Do not use `print()` or `debugPrint()` in `lib/`. The
[`tool/check_raw_print.sh`](../tool/check_raw_print.sh) guard rejects raw
console output and is part of the project validation flow.

`AppLogger` suppresses normal output in tests, supports `silence()` /
`silenceAsync()` for expected noisy blocks, and emits release logs only at
warning or error level.

## Required Context

Include compact `key=value` fields in the message text for fields that make the
event searchable.

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
- `error_code`: [`AppErrorCode`](../lib/shared/utils/error_codes.dart) or a
  stable domain error code.
- `reason`: short machine-readable cause, such as `offline`, `timeout`,
  `unauthorized`, `validation_failed`, or `storage_unavailable`.

Do not log PII, tokens, raw credentials, full request/response bodies,
authorization headers, API keys, or unredacted file contents. See
[`security_and_secrets.md`](security_and_secrets.md) for secret handling.

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
- Is the event useful at a boundary or failure point, not just noisy progress?
- Are `feature`, `operation`, and `reason` present when they help search?
- Is there a stable `error_code`, `status_code`, `request_id`, or `sync_id`
  available?
- Are secrets, PII, raw payloads, and full credentials excluded?
- Does `AppLogger.error` receive the original error and stack trace?
- Is the message wording stable enough for future triage?
