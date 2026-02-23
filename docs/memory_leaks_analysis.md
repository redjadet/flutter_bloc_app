# Memory Leaks Analysis

This document records a deep analysis of the codebase for potential memory leaks. It complements `docs/race_conditions_and_bugs_analysis.md` and `docs/CODE_QUALITY.md`.

**Analysis Date:** 2025-02
**Scope:** `lib/` — StreamController, StreamSubscription, Timer, Controllers (TextEditingController, ScrollController), lifecycle patterns

---

## Executive Summary

The codebase handles most resource lifecycle correctly. Previously identified issues have been fixed: **FixedExtentScrollController** leak in picker modal, **OfflineFirstTodoRepository** subscription disposal, and **AppLinksDeepLinkService** StreamController close. Several **good practices** are documented below.

---

## 1. Definite Leaks (Fixed)

### 1.1 FixedExtentScrollController in PlatformAdaptiveSheets (Cupertino Picker) ✓

**Location:** `lib/shared/utils/platform_adaptive_sheets.dart`

**Status:** Fixed. Replaced `StatefulBuilder` with `_CupertinoPickerSheetContent` StatefulWidget that creates the controller in `initState`, passes it to `CupertinoPicker`, and disposes it in `dispose()`.

---

## 2. Potential Leaks and Improvements

### 2.1 OfflineFirstTodoRepository – Remote Watch Subscription ✓

**Location:** `lib/features/todo_list/data/offline_first_todo_repository.dart`

**Status:** Fixed. Added `dispose()` that cancels `_remoteWatchSubscription`. Wired into DI via `registerTodoServices` dispose callback. **Restart-after-dispose:** When the remote stream emits `onError` or `onDone`, the repo schedules `_restartRemoteWatch()` after 2 seconds. If the repository was disposed in the meantime, that would have created a new subscription that was never cancelled. Fixed by adding a `_disposed` flag set in `dispose()` and checked in `_startRemoteWatch()` and `_restartRemoteWatch()` so no new subscription is created after disposal.

**Additional fix (error path):** On remote stream `onError`, the previous code nulled `_remoteWatchSubscription` and scheduled restart, but the old listener could remain active and overlap with the restarted listener. Fixed by listening with `cancelOnError: true` and deduplicating restart scheduling via `_remoteRestartScheduled`, preventing stacked delayed restarts and duplicate active subscriptions.

**Regression test:** To catch this class of bug early, run:
`flutter test test/features/todo_list/data/offline_first_todo_repository_test.dart --name "does not restart remote watch after dispose when stream ends"`. Consider adding this test file to `tool/check_regression_guards.sh` so the checklist runs it. When adding similar "stream listen + onError/onDone + delayed restart" code elsewhere, add a disposed flag and check it before creating a new subscription; add a similar regression test that disposes before the delay and asserts no second subscription.

### 2.2 AppLinksDeepLinkService – StreamController ✓

**Location:** `lib/features/deeplink/data/app_links_deep_link_service.dart` (`linkStream()`)

**Status:** Fixed. `onCancelHandler` now closes the controller after cancelling the upstream subscription. For broadcast streams, `onCancel` runs when the last listener unsubscribes.

### 2.3 RetrySnackBarListener – unawaited cancel in dispose

**Location:** `lib/shared/widgets/retry_snackbar_listener.dart`

**Issue:** `dispose()` uses `unawaited(_subscription?.cancel())`. The subscription is cancelled asynchronously; a late event could still fire before cancellation completes. The callback already checks `mounted`, so impact is minimal.

**Impact:** Very low. The `mounted` check prevents use-after-dispose. Consider `await` in dispose if the widget’s disposal path allows it, to avoid any theoretical late callbacks.

---

## 3. Well-Handled Patterns

### 3.1 StreamController Lifecycle

| Component | Controllers | Disposal |
| ----------- | ----------- | -------- |
| EchoWebsocketRepository | `_messagesController`, `_stateController` | `dispose()` closes both; DI calls dispose |
| BackgroundSyncCoordinator | `_statusController`, `_summaryController` | `dispose()` closes both; DI calls dispose |
| NetworkStatusService | `_controller` | `dispose()` closes; DI calls dispose |
| RetryNotificationService | `_controller` | `dispose()` closes; DI calls dispose |
| GenUiDemoAgentImpl | 3 StreamControllers | `dispose()` closes all; DI calls dispose |
| RestCounterRepository | `_watchController` | `dispose()` closes; manual/conditional use |
| SharedPreferencesCounterRepository | `_watchController` | Closed in closeIfNoListeners / dispose path |
| HiveCounterRepositoryWatchState | `_watchController` | Closed in dispose path |

### 3.2 StreamSubscription Lifecycle

| Component | Subscriptions | Disposal |
| ----------- | -------------- | -------- |
| SyncStatusCubit | 3 streams | `close()` nullifies then cancels; CubitSubscriptionMixin |
| DeepLinkCubit | link stream | `close()` via CubitSubscriptionMixin |
| WebsocketCubit | status, messages | `close()` via CubitSubscriptionMixin |
| GenUiDemoCubit | surface, errors | `close()` via CubitSubscriptionMixin |
| CounterCubit / CounterCubitBase | repository watch | CubitSubscriptionMixin + close |
| TodoListCubit | repository watch | CubitSubscriptionMixin + close |
| RemoteConfigRepository | onConfigUpdated | `dispose()` cancels; DI calls dispose |
| EchoWebsocketRepository | channel stream | `dispose()` cancels |
| WalletConnectService | session stream | `dispose()` cancels; DI calls dispose |
| CounterSyncBanner | counter repository | `dispose()` cancels |
| RetrySnackBarListener | notifications | `dispose()` cancels |
| GoRouterRefreshStream | auth stream | `dispose()` cancels |

### 3.3 Timer Lifecycle

| Component | Timers | Disposal |
| ----------- | ------ | -------- |
| CounterCubitBase | `_countdownTicker` | `_stopCountdownTicker()`; sync with state |
| SearchCubit | `_debounceHandle` | `close()` cancels |
| TodoListCubit | search debounce | `_cancelSearchDebounce()`; close cancels |
| BackgroundSyncCoordinator | `_periodicTimer` | `stop()` disposes |
| NetworkStatusService | `_debounceTimer` | `dispose()` disposes |

### 3.4 TextEditingController / ScrollController (Widget-Owned)

| Widget | Controllers | Disposal |
| ------ | ----------- | -------- |
| ChatPage | `_controller`, `_scrollController` | `dispose()` |
| MarkdownEditorWidget | `_controller`, `_scrollController` | `dispose()` |
| GenUiDemoContent | `_textController` | `dispose()` |
| WebsocketDemoPage | `_messageController` | `dispose()` |
| SearchTextField | `_controller` | `dispose()` |
| TodoSearchField | `_controller` | `dispose()` |
| RegisterPasswordField | `_controller` | `dispose()` |
| CalculatorRateSelectorDialog | `_controller` | `dispose()` |
| TodoListDialogs | `_titleController`, `_descriptionController` | `dispose()` |

Controllers passed in via constructor (e.g. ChatMessageList, ChatInputBar, MarkdownEditorField) are owned by the parent; no disposal in the child.

---

## 4. DI Dispose Registration Summary

Services with explicit `dispose` in GetIt:

- `EchoWebsocketRepository`
- `NetworkStatusService`
- `BackgroundSyncCoordinator`
- `GenUiDemoAgentImpl`
- `RetryNotificationService` (via registerHttpServices)
- `RemoteConfigRepository`
- `WalletConnectService`
- `ResilientHttpClient`

Singletons without `dispose` (typically live for app lifetime):

- `CounterRepository`
- `TodoRepository`
- `HiveService`
- `LocaleRepository`, `ThemeRepository`, `AppInfoRepository`
- `DeepLinkService` (AppLinksDeepLinkService – no dispose, creates transient controllers)

---

## 5. Validation and Checks

The project uses `check_stream_controller_close.sh` (or equivalent) for StreamController usage. The `FixedExtentScrollController` leak is at the widget level and may require a custom check or code review to catch.

**Recommendation:** Add a lint or review guideline: controllers (ScrollController, TextEditingController, etc.) created in widgets must be stored in State and disposed in `dispose()`.

---

## 6. Related Documentation

- [Race Conditions and Bugs Analysis](race_conditions_and_bugs_analysis.md)
- [CODE_QUALITY](CODE_QUALITY.md)
- [Validation Scripts](validation_scripts.md)
