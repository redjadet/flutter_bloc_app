# Reliability, Error Handling, and Performance (High-Volume / Enterprise)

This document summarizes how the project handles reliability, error handling, and performance for high-volume, enterprise, and high-traffic mobile usage. Details live in the linked docs and code; this file is an index and short overview.

---

## High-level: A Flutter app built for high-volume usage

**Describe a Flutter app you’ve maintained that handled high-volume usage.**

This codebase is a Flutter app (Clean Architecture, BLoC/Cubit) designed and maintained for **high-volume, enterprise, and high-traffic** scenarios. At a high level:

- **Reliability:** All network calls go through a resilient HTTP client with automatic retries, token refresh, and explicit timeouts. Non-HTTP work uses a shared retry policy with backoff and cancellation so cubits don’t leak. Optional circuit breaker and request-id/in-flight guards prevent duplicate or stale results under rapid navigation or refresh. Subscriptions and stream listeners are lifecycle-bound so they are cancelled on dispose.
- **Error handling:** User-facing errors are localized and surfaced through a central mapper and handler. Cubit async errors use a shared handler with an `isAlive` guard so callbacks never run after close. Structured error codes support analytics and optional crash reporting without PII.
- **Performance:** Large JSON payloads are decoded in isolates; list/scroll use slivers and builder patterns with documented guidelines. High-frequency triggers (search, sync) use debounce/throttle and request-id so the app doesn’t flood the backend or UI. Optional memory trim and startup profiling keep the app responsive under load.

Validation (checklist, lifecycle scripts, and regression guards) keeps these behaviors enforced. The sections below index where each concern is implemented and documented.

---

## 1. Reliability

**Overview:** The app uses a resilient HTTP layer, standardized retries for non-HTTP work, optional circuit breaking, and in-flight/request-id guards to avoid duplicate or stale results under load.

| Concern | How it’s handled | Where to read more |
| -------- | ------------------- | -------------------- |
| **HTTP retries** | [ResilientHttpClient](../lib/shared/http/resilient_http_client.dart): automatic retries for transient errors, 401 token refresh, network check before send, telemetry. [resilient_http_client_extensions](../lib/shared/http/resilient_http_client_extensions.dart) getMapped/postMapped throw [HttpRequestFailure](../lib/shared/utils/http_request_failure.dart) for status ≥ 400 so callers get statusCode. Retry delay aligned with [RetryPolicy](../lib/shared/utils/retry_policy.dart) (exponential + jitter). | [SHARED_UTILITIES.md](SHARED_UTILITIES.md) – “Reliability and retries” |
| **Non-HTTP retries** | [RetryPolicy](../lib/shared/utils/retry_policy.dart): `executeWithRetry` with backoff, jitter, and [CancelToken](../lib/shared/utils/retry_policy.dart) so cubits cancel in-flight retries in `close()`. Used e.g. in AppInfoCubit. | [SHARED_UTILITIES.md](SHARED_UTILITIES.md) – “Reliability and retries” |
| **Timeouts** | All HTTP calls use explicit timeouts (e.g. [resilient_http_client_extensions](../lib/shared/http/resilient_http_client_extensions.dart), default 30s; configurable per call). | [SHARED_UTILITIES.md](SHARED_UTILITIES.md) – “Timeouts” |
| **Circuit breaker** | Optional [CircuitBreaker](../lib/shared/http/circuit_breaker.dart) for failing endpoints: open after N failures in a window, fail-fast until cooldown, then one probe. Enable via feature-flag for enterprise/high-traffic. | [SHARED_UTILITIES.md](SHARED_UTILITIES.md) – “Circuit breaker” |
| **In-flight / request-id guards** | Cubits that trigger load (chart, graphql, profile, todo list, search) use a request-id and ignore completions that don’t match the current request, avoiding stale state under rapid navigation or refresh. | Race-condition prevention; [SearchCubit](../lib/features/search/presentation/search_cubit.dart) (reference pattern) |
| **Subscriptions and lifecycle** | [CubitSubscriptionMixin](../lib/shared/utils/cubit_subscription_mixin.dart), [SubscriptionManager](../lib/shared/utils/subscription_manager.dart), and repo dispose/restart guards keep subscriptions bounded and cancelled on close. Provide `onError` when calling `stream.listen(...)` in widgets/adapters so errors are logged. | [phase2_lifecycle_async_audit_2026-02-23.md](audits/phase2_lifecycle_async_audit_2026-02-23.md); [REPOSITORY_LIFECYCLE.md](REPOSITORY_LIFECYCLE.md) |
| **Parsing / storage resilience** | When parsing stored or untrusted data (`fromJson`, `decode`) in data/repository layer, catch broadly (`on Object` or both `Exception` and `Error`) and return safe fallbacks (empty list, null) so bad data or `TypeError` does not crash the app. `StorageGuard.run` catches only `Exception`. | [SecureChatHistoryRepository](../lib/features/chat/data/secure_chat_history_repository.dart), [ChatLocalDataSource](../lib/features/chat/data/chat_local_data_source.dart) |

---

## 2. Error handling

**Overview:** Errors are localized, mapped through a central mapper, and **differentiated by type** (e.g. 401 auth vs 503 service unavailable) so users see accurate messages and the app avoids retry storms. Cubits use a shared handler with an `isAlive` guard; structured error codes support analytics and crash reporting.

| Concern | How it’s handled | Where to read more |
| -------- | ------------------- | -------------------- |
| **User-facing messages** | [NetworkErrorMapper](../lib/shared/utils/network_error_mapper.dart) and [ErrorHandling](../lib/shared/utils/error_handling.dart) use [AppLocalizations](../lib/l10n/app_localizations.dart) (e.g. `context.l10n`) for error text and retry button; fallback when l10n not available (e.g. repository layer). | [SHARED_UTILITIES.md](SHARED_UTILITIES.md) – Utils; `lib/l10n/app_*.arb` |
| **Error differentiation** | HTTP failures use [HttpRequestFailure](../lib/shared/utils/http_request_failure.dart) (statusCode + optional retryAfter). [resilient_http_client_extensions](../lib/shared/http/resilient_http_client_extensions.dart) getMapped/postMapped throw it for status ≥ 400. Mapper returns distinct messages for 401 (auth), 503 (service unavailable), 429 (rate limit), etc. | [SHARED_UTILITIES.md](SHARED_UTILITIES.md); [observability.md](observability.md) |
| **Cubit async errors** | [CubitExceptionHandler](../lib/shared/utils/cubit_async_operations.dart) and [CubitErrorHandler](../lib/shared/utils/cubit_error_handler.dart) with `isAlive: () => !isClosed` so callbacks don’t run after close. For [HttpRequestFailure](../lib/shared/utils/http_request_failure.dart), the handler uses NetworkErrorMapper so emitted messages are status-aware. | State, Lifecycle, and Async Safety; [phase2_lifecycle_async_audit_2026-02-23.md](audits/phase2_lifecycle_async_audit_2026-02-23.md) |
| **Structured error codes** | [AppErrorCode](../lib/shared/utils/error_codes.dart) (network, timeout, auth, server, **serviceUnavailable**, client, rateLimit, unknown). Map from exceptions or status via [NetworkErrorMapper.getErrorCode](../lib/shared/utils/network_error_mapper.dart) / `getErrorCodeForStatusCode`. | [observability.md](observability.md) |
| **Crash reporting (optional)** | Pattern for uncaught errors (`FlutterError.onError`, `runZonedGuarded`) and no PII in reports; document in [security_and_secrets.md](security_and_secrets.md) when a tool is adopted. | [observability.md](observability.md) |

---

## 3. Performance

**Overview:** The app uses isolate-based JSON for large payloads, list/scroll best practices, debounce/throttle and request-id for high-frequency triggers, optional memory trim, and startup safeguards.

| Concern | How it’s handled | Where to read more |
| -------- | ------------------- | -------------------- |
| **Large JSON** | [isolate_json](../lib/shared/utils/isolate_json.dart): `decodeJsonMap` / `decodeJsonList` / `encodeJsonIsolate` for payloads &gt;8KB (configurable). No raw `jsonDecode`/`jsonEncode` for large data (enforced by [tool/check_raw_json_decode.sh](../tool/check_raw_json_decode.sh)). | [compute_isolate_review.md](compute_isolate_review.md) |
| **List and scroll** | Guidelines: `RepaintBoundary` for heavy list items; `CustomScrollView` + slivers over shrinkWrap for long lists; builder patterns for dynamic length. | [performance_bottlenecks.md](performance_bottlenecks.md) – “List and scroll performance”; [shrinkwrap_slivers_audit.md](audits/shrinkwrap_slivers_audit.md) |
| **High-frequency events** | Debounce/throttle (e.g. [TimerService](../lib/core/time/timer_service.dart), request-id) for search, sync flush, and similar triggers so the app doesn’t flood the backend or UI. | [performance_bottlenecks.md](performance_bottlenecks.md) – “High-frequency events” |
| **Memory and caches** | Documented approach: trim in-memory caches (search, profile, image) on memory pressure via a single entry point; optional for enterprise/high-traffic. | [REPOSITORY_LIFECYCLE.md](REPOSITORY_LIFECYCLE.md) – “Memory pressure and cache trim” |
| **Startup** | Deferred loading, lazy DI, route-level cubits, gated background sync. Optional CI gate: startup trace and fail if TTFF exceeds a threshold. | [STARTUP_TIME_PROFILING.md](STARTUP_TIME_PROFILING.md); [lazy_loading_review.md](lazy_loading_review.md) |

---

## 4. Validation and quality

- **Checklist:** [./bin/checklist](../bin/checklist) – format, analyze, tests, and project guards.
- **Lifecycle scripts:** e.g. `tool/check_cubit_isclosed.sh`, `tool/check_context_mounted.sh` (see [validation_scripts.md](validation_scripts.md)).
- **Canonical rules:** Architecture, lifecycle, type-safe BLoC access, no hardcoded strings (see project rules).

---

## 5. Quick reference – key files

| Area | Files |
| ------ | -------- |
| HTTP / retries | [resilient_http_client.dart](../lib/shared/http/resilient_http_client.dart), [resilient_http_client_helpers.dart](../lib/shared/http/resilient_http_client_helpers.dart), [retry_policy.dart](../lib/shared/utils/retry_policy.dart) |
| Circuit breaker | [circuit_breaker.dart](../lib/shared/http/circuit_breaker.dart) |
| Errors / UI | [http_request_failure.dart](../lib/shared/utils/http_request_failure.dart), [network_error_mapper.dart](../lib/shared/utils/network_error_mapper.dart), [error_handling.dart](../lib/shared/utils/error_handling.dart), [error_codes.dart](../lib/shared/utils/error_codes.dart) |
| Async / lifecycle | [cubit_async_operations.dart](../lib/shared/utils/cubit_async_operations.dart), [cubit_subscription_mixin.dart](../lib/shared/utils/cubit_subscription_mixin.dart), [subscription_manager.dart](../lib/shared/utils/subscription_manager.dart) |
| Performance | [isolate_json.dart](../lib/shared/utils/isolate_json.dart), [TimerService](../lib/core/time/timer_service.dart) |

All paths above are relative to the project root.
