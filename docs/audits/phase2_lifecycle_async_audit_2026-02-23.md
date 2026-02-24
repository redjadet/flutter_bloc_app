# Phase 2: Lifecycle & Async Security — Audit 2026-02-24

Follow-up analysis of cubits, subscriptions, and delayed work for lifecycle safety.

---

## Summary

| Check | Status | Notes |
| ------ | ------ | ------ |
| CubitExceptionHandler isAlive | ✅ | Done: all executeAsync/executeAsyncVoid call sites now pass `isAlive: () => !isClosed` |
| Stream subscriptions | ✅ | Cubits with subscriptions use CubitSubscriptionMixin, registerSubscription, closeAllSubscriptions in close() |
| CounterCubit load delay | ✅ | Fixed: uses TimerService.runOnce; disposes _initialLoadHandle in close() |
| ScapesCubit load delay | ✅ | Uses TimerService.runOnce; disposes handle in close() |
| emit after await | ✅ | Call sites checked: all have `if (isClosed) return` before emit in async paths |
| Repos/services deep audit (§4) | ✅ | OfflineFirstTodoRepository compliant; HiveCounterRepositoryWatchHelper & RemoteConfigRepository hardened with _disposed; EchoWebsocketRepository & rest_counter_repository_watch compliant |
| Centralized subscription/memory (§5) | ✅ | CubitSubscriptionMixin auto-close(); SubscriptionManager for repos |

---

## 1. CubitExceptionHandler — isAlive parameter

**Done:** All `executeAsync` and `executeAsyncVoid` call sites now pass `isAlive: () => !isClosed`. Callbacks are only invoked when the cubit is still open; manual `if (isClosed) return` guards in callbacks remain for defense in depth.

---

## 2. Stream subscriptions

**Cubits with stream subscriptions:**

- **SyncStatusCubit** — CubitSubscriptionMixin; network, sync, summary streams; closeAllSubscriptions in close(). ✅
- **DeepLinkCubit** — linkStream().listen; registerSubscription; closeAllSubscriptions; null before cancel. ✅
- **WebsocketCubit** — connectionStates, incomingMessages; registerSubscription; closeAllSubscriptions. ✅
- **GenUiDemoCubit** — surfaceEvents, errors; registerSubscription; closeAllSubscriptions. ✅
- **CounterCubitBase** — repository.watch(); registerSubscription; closeAllSubscriptions; null before cancel. ✅
- **TodoListCubit** — repository watch; registerSubscription; closeAllSubscriptions. ✅

All subscription-holding cubits follow the required pattern (guard before emit, cancel in close, use mixin).

---

## 3. Delayed work (Timer / Future.delayed)

**ScapesCubit:** Uses `TimerService.runOnce` for load delay; disposes `_loadDelayHandle` in `close()`. ✅

**CounterCubit:** Fixed. Now uses `TimerService.runOnce` for `_initialLoadDelay`; stores `_initialLoadHandle`, disposes it in `close()` and when starting a new delayed load. ✅

---

## 4. Repositories / services (streams) — deep audit

Deep audit of repositories that hold stream subscriptions: dispose/cancel, restart-after-dispose guards, and cancelOnError.

### 4.1 OfflineFirstTodoRepository ✅

- **Subscription:** `remoteRepo.watchAll().listen(..., onError, onDone, cancelOnError: true)`.
- **Dispose:** `_disposed = true`; `_remoteRestartScheduled = false`; null ref then `await sub?.cancel()`; unregister. Correct.
- **Restart:** `_scheduleRemoteRestart()` checks `_disposed || _remoteRestartScheduled`; sets `_remoteRestartScheduled = true`; `unawaited(_restartRemoteWatch())`. `_restartRemoteWatch()` does `await Future.delayed(2s)` then `_remoteRestartScheduled = false` then **checks `_disposed`** before `_startRemoteWatch()`. `_startRemoteWatch()` returns immediately if `_disposed`. No stacked restarts thanks to `_remoteRestartScheduled`. **Verdict:** Compliant.

### 4.2 HiveCounterRepositoryWatchHelper ✅ (hardened)

- **Subscription:** `box.watch().listen(...)` in `_startBoxWatch()`, called from `handleOnListen()` (unawaited). No delayed restart; onError nulls and cancels manually (`cancelOnError: false`).
- **Race:** If `dispose()` runs while `_startBoxWatch()` is pending (e.g. after `await getBox()`), a new subscription could be created after dispose and never cancelled.
- **Fix applied:** Added `_disposed`; set in `dispose()` before null/cancel; check at start of `_startBoxWatch()` and **after** `await getBox()` before creating subscription; dispose nulls ref before cancel. **Verdict:** Now compliant.

### 4.3 RemoteConfigRepository ✅ (hardened)

- **Subscription:** `_remoteConfig.onConfigUpdated.listen(...)` in `_subscribeToRealtimeUpdates()`, called from `initialize()`. No restart logic; single subscription via `??=`.
- **Risk:** If `initialize()` is called again after `dispose()` (e.g. re-init), `_isInitialized` is false and `_subscribeToRealtimeUpdates()` would run again, creating a new subscription while the repo is considered disposed.
- **Fix applied:** Added `_disposed`; set in `dispose()` before null/cancel; `_subscribeToRealtimeUpdates()` returns immediately if `_disposed`. **Verdict:** Now compliant.

### 4.4 EchoWebsocketRepository ✅

- **Subscription:** `channel.stream.listen(..., cancelOnError: true)`. No delayed restart; `_handleError` / `_handleDone` call `_cleanupChannel()` (null ref then cancel). `dispose()` cancels connection completer and calls `disconnect()` then closes controllers. **Verdict:** Compliant.

### 4.5 rest_counter_repository_watch.dart

- **Subscription:** Created per `watch()` call via `Stream.multi`; `onCancel` binds to `subscription.cancel`. Lifecycle is per-stream; no long-lived repository-held subscription that outlives the watch. No _disposed needed. **Verdict:** Compliant.

---

## 5. Centralized subscription and memory management

To automate and centralize subscription/memory handling without adding risk:

- **CubitSubscriptionMixin** (`lib/shared/utils/cubit_subscription_mixin.dart`): `close` is overridden to call `closeAllSubscriptions` then `Cubit.close`. Cubits that use the mixin no longer call `closeAllSubscriptions` explicitly; they override `close` only for extra cleanup (null refs, dispose timer handles) then call `super.close()`. Subscriptions registered via `registerSubscription` are always cancelled on close.

- **SubscriptionManager** (`lib/shared/utils/subscription_manager.dart`): Composable holder for `StreamSubscription`s used by repositories and services. `register` adds a subscription; `dispose` sets disposed and cancels all; `isDisposed` is checked before creating/registering new subscriptions (e.g. in delayed restart logic). If `register` is called when already disposed, the subscription is cancelled immediately to avoid leaks. Used by OfflineFirstTodoRepository, HiveCounterRepositoryWatchHelper, and RemoteConfigRepository so a single abstraction owns “disposed” state and cancellation.

---

## Action items

1. ~~**CounterCubit load delay:** Refactor to use `TimerService.runOnce` for `_initialLoadDelay` and dispose the handle in `close()` (and when starting a new load) so the delay is cancellable.~~ **Done:** CounterCubit now uses `_timerService.runOnce`, stores `_initialLoadHandle`, disposes it in `close()` and when starting a new delayed load; also passes `isAlive: () => !isClosed` in loadInitial and _persistState.
2. ~~**Optional:** Add `isAlive: () => !isClosed` to remaining `CubitExceptionHandler.executeAsync` / `executeAsyncVoid` call sites.~~ **Done:** Added to all call sites (DeepLink, AppInfo, Search, Chat message/persist, Profile, GraphqlDemo, TodoList methods/crud, RemoteConfig, GenUiDemo, Chart, ChatList, CounterCubitBase, MapSample, Websocket, WalletConnectAuth, CounterCubit).
3. ~~**Deep audit (Section 4):** Repositories/services with stream subscriptions — dispose/cancel, restart-after-dispose guards, cancelOnError.~~ **Done:** OfflineFirstTodoRepository already compliant; HiveCounterRepositoryWatchHelper and RemoteConfigRepository hardened with `_disposed`; EchoWebsocketRepository and rest_counter_repository_watch compliant. See §4 above.
