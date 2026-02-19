# Race Conditions and Bugs Analysis

This document records a deep analysis of the codebase for potential race conditions, bugs, and lifecycle issues. It complements `docs/validation_scripts.md` (automated checks) and `docs/CODE_QUALITY.md` (quality standards).

**Analysis Date:** 2025-02
**Scope:** `lib/`, `test/shared/common_bugs_prevention_test.dart`, lifecycle rules

---

## Executive Summary

The codebase demonstrates strong adherence to lifecycle guards and race-condition prevention. Most patterns follow project standards. A few lower-severity observations and one recommendation are documented below.

---

## 1. Strengths and Well-Handled Patterns

### 1.1 Cubit Async and Stream Subscriptions

- **Cubit emit after async:** Cubits consistently use `if (isClosed) return;` before `emit()` in async callbacks. Examples: `WalletConnectAuthCubit`, `ChatListCubit`, `RemoteConfigCubit`, `DeepLinkCubit`, `WebsocketCubit`, `GenUiDemoCubit`, `SyncStatusCubit`.
- **Stream subscription disposal:** Subscriptions are nullified before `cancel()` to avoid races (e.g. `SyncStatusCubit.close()`, `DeepLinkCubit._disposeSubscription`, `RemoteConfigRepository.dispose`).
- **CubitSubscriptionMixin:** Used where appropriate to centralize subscription cancellation in `close()`.

### 1.2 Search Out-of-Order Completion

`SearchCubit` correctly handles stale search results with a request-id pattern:

```dart
// lib/features/search/presentation/search_cubit.dart
bool _isRequestActive(final int requestId, final String query) =>
    !isClosed && requestId == _searchRequestId && state.query == query;
```

Callbacks check `_isRequestActive()` before emitting, preventing older responses from overwriting newer ones.

### 1.3 Context and Widget Lifecycle

- **context.mounted after async:** Callbacks use `ContextUtils.ensureMounted()` or `if (!context.mounted) return` before using `BuildContext` after `await`. Examples: `CounterPage._handleOpenSettings`, `ProfileBottomNav._handleTap`, `SignInPage.signInAnonymously`.
- **setState after async:** Validation scripts (`check_setstate_mounted.sh`) enforce `mounted` checks.
- **RetrySnackBarListener:** Uses `if (!mounted) return` before showing snackbar in stream callback.

### 1.4 Firebase Auth Stream Race (Fixed)

`AccountSection` avoids the ~200ms `authStateChanges()` startup race by:

- Using `initialData: effectiveAuth.currentUser` for synchronous initial state.
- Falling back to `snapshot.data ?? effectiveAuth.currentUser` when the stream has not yet emitted.
- Showing `CommonLoadingWidget` only when truly waiting for the first auth event (`ConnectionState.waiting` and `user == null`).

### 1.5 GoRouter and Auth Redirect

- **auth_redirect.dart:** Uses `auth.currentUser` (synchronous) for redirect logic, avoiding stream delay.
- **GoRouterRefreshStream:** Uses `authStateChanges()` only for refresh notifications; initial routing relies on sync `currentUser`.

---

## 2. Observations and Lower-Severity Items

### 2.1 OfflineFirstTodoRepository – No Explicit Dispose ✓

**Location:** `lib/features/todo_list/data/offline_first_todo_repository.dart`

**Status:** Fixed. Added `dispose()` that cancels `_remoteWatchSubscription`. Wired into DI via `registerTodoServices` dispose callback.

### 2.2 RetrySnackBarListener – Subscription Cancel in dispose()

**Location:** `lib/shared/widgets/retry_snackbar_listener.dart`

```dart
@override
void dispose() {
  unawaited(_subscription?.cancel());
  super.dispose();
}
```

`dispose()` is synchronous; `unawaited(cancel())` prevents blocking. The subscription will be cancelled asynchronously. This is acceptable for most cases, but if the stream emits right before cancel, a late callback could still run. The callback already checks `mounted`, so this is low risk.

### 2.3 HiveCounterRepositoryWatchHelper – Defensive Cancel

**Location:** `lib/features/counter/data/hive_counter_repository_watch_helper.dart` (lines 97–98)

```dart
// Cancel any existing subscription (defensive check)
await _boxSubscription?.cancel();
```

At that point, `_boxSubscription` is still `null` (we just passed the double-check). The line is effectively a no-op. Not incorrect, but redundant.

### 2.4 RemoteConfigRepository – Async Listener Callback

**Location:** `lib/features/remote_config/data/repositories/remote_config_repository.dart`

The `onConfigUpdated` listener uses an `async` callback:

```dart
(final update) async {
  // ...
  try {
    await _remoteConfig.fetchAndActivate();
  } on Exception catch (...) { ... }
  // ...
}
```

Errors are caught and logged. The listener does not emit to a Cubit directly; it only triggers Remote Config refresh. No lifecycle guards are needed here since no Cubit state is updated in this callback.

---

## 3. Potential Improvements

### 3.1 PlaylearnCubit – isClosed on Success Path

**Location:** `lib/features/playlearn/presentation/playlearn_cubit.dart`

```dart
Future<void> speakWord(final String text) async {
  try {
    await _audioService.speak(text);
  } on Object {
    if (isClosed) return;
    emit(state.copyWith(errorMessage: 'Could not play audio'));
  }
}
```

On the success path, there is no emit, so no `isClosed` check is required. On the error path, `isClosed` is checked. Current behavior is correct. Optionally, a no-op `if (isClosed) return;` could be added after the `await` on the success path for consistency, but it is not necessary.

### 3.2 applyRestorationOutcome – Used with unawaited

**Location:** `lib/features/counter/presentation/counter_cubit_base.dart`

`applyRestorationOutcome` is called via `unawaited(applyRestorationOutcome(...))` from a stream callback. The mixin checks `isClosed` before emitting. The async part (persistence) runs after the emit; if the cubit closes during that time, the emit has already occurred. This is acceptable. The `StateRestorationMixin` correctly guards the emit.

---

## 4. Patterns Verified Safe

| Area | Pattern | Status |
| ---- | ------- | ------ |
| Counter cubit | Repository watch subscription + isClosed in callback | OK |
| Deep link cubit | Link stream subscription, nullify-then-cancel in dispose | OK |
| Websocket cubit | Connection/message streams, isClosed in callbacks | OK |
| Todo list cubit | Repository watch, debounce, loadInitial with stopLoadingIfClosed | OK |
| Sync status cubit | Multiple streams, nullify-then-cancel in close | OK |
| GenUI demo cubit | Surface/error streams, isClosed in all emit paths | OK |
| Search cubit | Request ID for out-of-order completion | OK |
| Counter page | context.mounted after biometric auth + navigation | OK |
| Profile bottom nav | context.mounted before navigation actions | OK |
| App links deep link | controller.isClosed before add(uri) | OK |

---

## 5. Checklist Alignment

The project's automated checks (`./bin/checklist`) cover:

- **check_context_mounted.sh** – context usage after `await`
- **check_setstate_mounted.sh** – `setState` after `await`
- **check_cubit_isclosed.sh** – `emit()` after async in cubits

These align with the patterns analyzed above. The codebase consistently follows the lifecycle rules.

---

## 6. Related Documentation

- [Validation Scripts](validation_scripts.md) – Automated lifecycle checks
- [CODE_QUALITY.md](CODE_QUALITY.md) – Quality expectations and historical fixes
- [Architecture Details](architecture_details.md) – Architecture overview
