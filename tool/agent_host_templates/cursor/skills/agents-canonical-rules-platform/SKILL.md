---
name: agents-canonical-rules-platform
description: Canonical rules — DI, Hive, Dio, Retrofit, offline-first, HTTP errors, parsing, null/doc hygiene, logging, serialization, deferred routes. Part of agents-canonical-rules split.
---

# Platform, data & quality

Slice of **`agents-canonical-rules`**. **Paths:** `agents-references`. **Offline merge:** `docs/offline_first/dont_overwrite_guide.md`, `agents-shared-patterns`.

## DI, persistence, HTTP

- `registerLazySingletonIfAbsent`; no `GetIt` in feature presentation (router/app shell may wire providers).
- No direct `Hive.openBox` — `HiveService` / `HiveRepositoryBase`.
- One app `Dio` (`lib/shared/http/app_dio.dart`); feature data uses DI clients, not ad-hoc Dio.
- Retrofit under `data/api/`; `validateStatus: (_) => true`; `build_runner` after API changes; repos map to domain + exceptions.
- In-flight coalescing: single `Future` per resource or keyed `Map` with `identical` clear guards.
- Offline-first watch/pull: never overwrite newer unsynced local with older remote (`_shouldApplyRemote` pattern); guard `tool/check_offline_first_remote_merge.sh`.
- HTTP: `>= 400` → `HttpRequestFailure`; single-flight 401 refresh; `Retry-After` → `retryAfterSeconds`; `NetworkErrorMapper`.
- Token managers: respect user override; hydrate once; `completeError` waiters; reset in `finally`.
- Parsing: `on Object` at boundaries; `safe_parse_utils` / `parseMapOfMaps`; required bad types → `FormatException` for `StorageGuard`.

## Hygiene & tooling

- Prefer patterns over `!`; `// check-ignore: reason` when truly needed; line length ≤ 80.
- `///` on public APIs; `// TODO(username): message`.
- `AppLogger` only; error as 2nd arg to `AppLogger.error`; log before fallback returns.
- `json_serializable` + `fieldRename: snake`; sync codegen.
- Deferred routes: `lib/app/router/deferred_pages/` + `DeferredPage`.
