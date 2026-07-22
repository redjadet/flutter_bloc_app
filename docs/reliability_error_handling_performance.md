# Reliability, Error Handling, and Performance (High-Volume / Enterprise)

This document summarizes how the project handles reliability, error handling,
and performance for high-volume, enterprise, and high-traffic mobile usage.
Details live in the linked docs and code; this file is an index and short
overview.

---

## How to use this document

- **Use this as an index**: it points to the canonical implementation files and
  the deeper docs per topic.
- **Prefer repo scripts for validation**: this document describes the intended
  patterns; `./bin/checklist` and the validator scripts enforce them.
- **Mobile/backend contracts**: [`backend/API_CONTRACT_GUIDE.md`](backend/API_CONTRACT_GUIDE.md),
  [`architecture/MOBILE_BACKEND_BOUNDARIES.md`](architecture/MOBILE_BACKEND_BOUNDARIES.md).
- **When adding new cross-cutting behavior**, update the owning utility doc
  (typically [`SHARED_UTILITIES.md`](engineering/SHARED_UTILITIES.md)) and add/extend a validator or
  regression test when the pattern is important enough to enforce.

## High-level overview

This codebase is a Flutter app (Clean Architecture, BLoC/Cubit) designed and
maintained for **high-volume, enterprise, and high-traffic** scenarios. At a
high level:

- **Reliability:** All network calls go through a resilient HTTP client with automatic retries, token refresh, and explicit timeouts. Non-HTTP work uses a shared retry policy with backoff and cancellation so cubits don’t leak. Optional circuit breaker and request-id/in-flight guards prevent duplicate or stale results under rapid navigation or refresh. Subscriptions and stream listeners are lifecycle-bound so they are cancelled on dispose.
- **Error handling:** User-facing errors are localized and surfaced through a central mapper and handler. Cubit async errors use a shared handler with an `isAlive` guard so callbacks never run after close. Structured error codes support analytics and optional crash reporting without PII.
- **Performance:** Large JSON payloads are decoded in isolates; list/scroll use slivers and builder patterns with documented guidelines. High-frequency triggers (search, sync) use debounce/throttle and request-id so the app doesn’t flood the backend or UI. Optional memory trim and startup profiling keep the app responsive under load.

Validation (checklist, lifecycle scripts, and regression guards) keeps these behaviors enforced. The sections below index where each concern is implemented and documented.

For crash reporting, structured error codes, and the **doc-only** product analytics posture, see [observability.md](observability.md) and the interview walk in [interview_showcase.md](interview_showcase.md).

---

## 1. Reliability

**Overview:** The app uses a resilient HTTP layer, standardized retries for non-HTTP work, optional circuit breaking, and in-flight/request-id guards to avoid duplicate or stale results under load.

| Concern | How it’s handled | Where to read more |
| -------- | ------------------- | -------------------- |
| **HTTP retries** | Shared [Dio](../apps/mobile/lib/app/http/app_dio.dart) with interceptors: [RetryInterceptor](../packages/networking/lib/src/interceptors/retry_interceptor.dart), [AuthTokenInterceptor](../apps/mobile/lib/app/http/auth/interceptors/auth_token_interceptor.dart), [NetworkCheckInterceptor](../packages/networking/lib/src/interceptors/network_check_interceptor.dart), [TelemetryInterceptor](../packages/networking/lib/src/interceptors/telemetry_interceptor.dart). For concurrent 401s, refresh is serialized in [AuthTokenManager](../apps/mobile/lib/app/http/auth/auth_token_manager.dart) (single-flight). [NetworkGuard.executeDio](../packages/networking/lib/src/guards/network_guard.dart) and [NetworkErrorMapper](../apps/mobile/lib/app/utils/network_error_mapper.dart) map status ≥ 400 to [HttpRequestFailure](../packages/utilities/lib/src/errors/http_request_failure.dart). Retry delay aligned with [RetryPolicy](../packages/utilities/lib/src/retry/retry_policy.dart) (exponential + jitter). Retry/replay defaults to idempotent `GET`/`HEAD`; non-idempotent methods must opt in at the call site. | [SHARED_UTILITIES.md](engineering/SHARED_UTILITIES.md) – “Reliability and retries” |
| **Non-HTTP retries** | [RetryPolicy](../packages/utilities/lib/src/retry/retry_policy.dart): `executeWithRetry` with backoff, jitter, and [CancelToken](../packages/utilities/lib/src/retry/retry_policy.dart) so cubits cancel in-flight retries in `close()`. Used e.g. in AppInfoCubit. | [SHARED_UTILITIES.md](engineering/SHARED_UTILITIES.md) – “Reliability and retries” |
| **Timeouts** | All HTTP calls use explicit timeouts (Dio created with 30s in [createAppDio](../apps/mobile/lib/app/http/app_dio.dart); [NetworkGuard.executeDio](../packages/networking/lib/src/guards/network_guard.dart) supports per-call timeout). | [SHARED_UTILITIES.md](engineering/SHARED_UTILITIES.md) – “Timeouts” |
| **Circuit breaker** | Optional [CircuitBreaker](../packages/networking/lib/src/circuit_breaker.dart) for failing endpoints: open after N failures in a window, fail-fast until cooldown, then one probe. Enable via feature-flag for enterprise/high-traffic. | [SHARED_UTILITIES.md](engineering/SHARED_UTILITIES.md) – “Circuit breaker” |
| **In-flight / request-id guards** | **Request-id:** [RequestIdGuard](../packages/utilities/lib/src/request_id_guard.dart) — use `next()` before starting a load and `isCurrent(id)` before emitting so stale completions are ignored. After a **successful mutation**, if the guard is inactive (superseded by a newer read), still return success (`true` for `Future<bool>`, bare `return` for `Future<void>`)—never `return false`, which surfaces false failure UI. Enforced by `tool/check_mutation_success_after_guard.sh`. **In-flight coalescing:** [InFlightCoalescer](../packages/utilities/lib/src/in_flight_coalescer.dart) (single) and [KeyedInFlightCoalescer](../packages/utilities/lib/src/in_flight_coalescer.dart) (per-key) so concurrent callers share one run. Used in cubits (chart, graphql, profile, todo list, search, camera) and repos (search, profile, remote config). `BackgroundSyncCoordinator.flush()` coalesces immediate triggers and avoids overlapping sync cycles. | Race-condition prevention; [reliability_error_handling_performance.md](reliability_error_handling_performance.md) §1 |
| **Subscriptions, timers, and lifecycle** | [DisposableBag](../packages/utilities/lib/src/disposable_bag.dart) is the shared lifecycle primitive for cancellable/closable resources. [CubitSubscriptionMixin](../apps/mobile/lib/app/utils/bloc/cubit_subscription_mixin.dart) centralizes subscription cancellation **and TimerService handle disposal** (`registerSubscription`, `registerTimer`) on `close()`. [SubscriptionManager](../packages/utilities/lib/src/subscriptions/subscription_manager.dart) and [TimerHandleManager](../packages/utilities/lib/src/timers/timer_handle_manager.dart) are thin, bounded facades for repositories/services (including delayed restart timers) that delegate cleanup behavior to the same primitive. Provide `onError` when calling `stream.listen(...)` in widgets/adapters so errors are logged. | [phase2_lifecycle_async_audit_2026-02-23.md](audits/phase2_lifecycle_async_audit_2026-02-23.md); [REPOSITORY_LIFECYCLE.md](engineering/REPOSITORY_LIFECYCLE.md) |
| **Parsing / storage resilience** | When parsing stored or untrusted data (`fromJson`, `decode`) in data/repository layer, catch broadly (`on Object` or both `Exception` and `Error`) and return safe fallbacks (empty list, null) so bad data or `TypeError` does not crash the app. `StorageGuard.run` catches only `Exception`. | [SecureChatHistoryRepository](../apps/mobile/lib/features/chat/data/secure_chat_history_repository.dart), [ChatLocalDataSource](../apps/mobile/lib/features/chat/data/chat_local_data_source.dart) |

---

## 2. Error handling

**Overview:** Errors are localized, mapped through a central mapper, and **differentiated by type** (e.g. 401 auth vs 503 service unavailable) so users see accurate messages and the app avoids retry storms. Cubits use a shared handler with an `isAlive` guard; structured error codes support analytics and crash reporting.

| Concern | How it’s handled | Where to read more |
| -------- | ------------------- | -------------------- |
| **User-facing messages** | [NetworkErrorMapper](../apps/mobile/lib/app/utils/network_error_mapper.dart) and [ErrorHandling](../apps/mobile/lib/app/utils/error_handling.dart) use [AppLocalizations](../apps/mobile/lib/l10n/app_localizations.dart) (e.g. `context.l10n`) for error text and retry button; fallback when l10n not available (e.g. repository layer). | [SHARED_UTILITIES.md](engineering/SHARED_UTILITIES.md) – Utils; `apps/mobile/lib/l10n/app_*.arb` |
| **Error differentiation** | HTTP failures use [HttpRequestFailure](../packages/utilities/lib/src/errors/http_request_failure.dart) (statusCode + optional retryAfter). [NetworkGuard.executeDio](../packages/networking/lib/src/guards/network_guard.dart) and [NetworkErrorMapper](../apps/mobile/lib/app/utils/network_error_mapper.dart) map [DioException](https://pub.dev/documentation/dio/latest/dio/DioException-class.html) to failures and user messages (401 auth, 503 service unavailable, 429 rate limit, etc.). | [SHARED_UTILITIES.md](engineering/SHARED_UTILITIES.md); [observability.md](observability.md) |
| **Cubit async errors** | [CubitExceptionHandler](../apps/mobile/lib/app/utils/cubit_async_operations.dart) with `isAlive: () => !isClosed` so callbacks don’t run after close. For [HttpRequestFailure](../packages/utilities/lib/src/errors/http_request_failure.dart), the handler uses NetworkErrorMapper so emitted messages are status-aware. | State, Lifecycle, and Async Safety; [phase2_lifecycle_async_audit_2026-02-23.md](audits/phase2_lifecycle_async_audit_2026-02-23.md) |
| **Structured error codes** | [AppErrorCode](../packages/utilities/lib/src/errors/error_codes.dart) (network, timeout, auth, server, **serviceUnavailable**, client, rateLimit, unknown). Map from exceptions or status via [NetworkErrorMapper.getErrorCode](../apps/mobile/lib/app/utils/network_error_mapper.dart) / `getErrorCodeForStatusCode`. | [observability.md](observability.md) |
| **Logging** | Use [AppLogger](../packages/app_shared_flutter/lib/src/utils/logger.dart) instead of raw `print()` / `debugPrint()`. Keep messages stable and searchable with compact context fields, and keep secrets/PII out of logs. | [logging.md](engineering/logging.md); [observability.md](observability.md) |
| **Crash reporting** | Firebase Crashlytics when Firebase initializes (`registerCrashlyticsHandlers`); no PII in reports. Inactive when Firebase is off (tests/mock harness). | [observability.md](observability.md); [firebase_bootstrap_service.dart](../apps/mobile/lib/app/bootstrap/firebase_bootstrap_service.dart) |

---

## 3. Performance

**Overview:** The app uses isolate-based JSON for large payloads, list/scroll best practices, debounce/throttle and request-id for high-frequency triggers, optional memory trim, and startup safeguards.

| Concern | How it’s handled | Where to read more |
| -------- | ------------------- | -------------------- |
| **Large JSON** | [isolate_json](../package:ilkersevim_json_isolate (shim: apps/mobile/lib/app/utils/isolate_json.dart)): `decodeJsonMap` / `decodeJsonList` / `encodeJsonIsolate` for payloads &gt;8KB (configurable). Prefer **`decodeJsonMapFromBytes`** / **`decodeJsonListFromBytes`** when the HTTP layer exposes UTF-8 **`List<int>`** (e.g. Dio `ResponseType.bytes`) so parsing does not allocate a full body **`String`** first. No raw `jsonDecode`/`jsonEncode` for large data (enforced by [tool/check_raw_json_decode.sh](../tool/check_raw_json_decode.sh)). | [compute_isolate_review.md](performance/compute_isolate_review.md); [changes/2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md](changes/2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md) |
| **List and scroll** | Guidelines: `RepaintBoundary` for heavy list items; `CustomScrollView` + slivers over shrinkWrap for long lists; builder patterns for dynamic length. | [performance_bottlenecks.md](performance/performance_bottlenecks.md) – “List and scroll performance”; [shrinkwrap_slivers_audit.md](audits/shrinkwrap_slivers_audit.md) |
| **High-frequency events** | Debounce/throttle (e.g. [TimerService](../packages/core/lib/src/time/timer_service.dart), request-id) for search, sync flush, and similar triggers so the app doesn’t flood the backend or UI. | [performance_bottlenecks.md](performance/performance_bottlenecks.md) – “High-frequency events” |
| **Memory and caches** | Documented approach: trim in-memory caches (search, profile, image) on memory pressure via a single entry point; optional for enterprise/high-traffic. | [REPOSITORY_LIFECYCLE.md](engineering/REPOSITORY_LIFECYCLE.md) – “Memory pressure and cache trim” |
| **Startup** | Deferred loading, lazy DI, route-level cubits, gated background sync. Optional CI gate: startup trace and fail if TTFF exceeds a threshold. | [STARTUP_TIME_PROFILING.md](performance/startup_time_profiling.md); [lazy_loading_review.md](performance/lazy_loading_review.md) |

---

## 4. Validation and quality

- **Checklist:** [./bin/checklist](../bin/checklist) – format, analyze, tests, and project guards.
- **Lifecycle scripts:** e.g. `tool/check_cubit_isclosed.sh`, `tool/check_context_mounted.sh`, `tool/check_lifecycle_error_handling.sh` (see [validation_scripts.md](validation_scripts.md)).
- **Canonical rules:** Architecture, lifecycle, type-safe BLoC access, no hardcoded strings (see project rules).

---

## 5. Quick reference – key files

| Area | Files |
| ------ | -------- |
| HTTP / retries | [app_dio.dart](../apps/mobile/lib/app/http/app_dio.dart), [interceptors/](../packages/networking/lib/src/interceptors/) (auth, retry, network check, telemetry), [network_guard.dart](../packages/networking/lib/src/guards/network_guard.dart), [retry_policy.dart](../packages/utilities/lib/src/retry/retry_policy.dart) |
| Circuit breaker | [circuit_breaker.dart](../packages/networking/lib/src/circuit_breaker.dart) |
| Errors / UI | [http_request_failure.dart](../packages/utilities/lib/src/errors/http_request_failure.dart), [network_error_mapper.dart](../apps/mobile/lib/app/utils/network_error_mapper.dart), [error_handling.dart](../apps/mobile/lib/app/utils/error_handling.dart), [error_codes.dart](../packages/utilities/lib/src/errors/error_codes.dart) |
| Async / lifecycle | [cubit_async_operations.dart](../apps/mobile/lib/app/utils/cubit_async_operations.dart), [cubit_subscription_mixin.dart](../apps/mobile/lib/app/utils/bloc/cubit_subscription_mixin.dart), [subscription_manager.dart](../packages/utilities/lib/src/subscriptions/subscription_manager.dart) |
| Performance | [isolate_json.dart](../package:ilkersevim_json_isolate (shim: apps/mobile/lib/app/utils/isolate_json.dart)), [TimerService](../packages/core/lib/src/time/timer_service.dart) |

All paths above are relative to the project root.
