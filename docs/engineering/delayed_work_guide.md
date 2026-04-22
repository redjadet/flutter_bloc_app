# Delayed work and TimerService

This guide describes how to schedule delayed work in production code so it stays testable and cancelable.

## Preferred: TimerService

Use `TimerService` (from `lib/core/time/timer_service.dart`) for any delayed work where:

- delay should be **cancelable** (e.g. on dispose, sign-out, or navigation).
- Tests need **deterministic time** (e.g. `FakeTimerService` with `elapse()` or `tick()`).

### API

- **`runOnce(Duration delay, void Function() onComplete)`** – one-shot delay. Returns `TimerDisposable`; call `dispose()` to cancel.
- **`periodic(Duration interval, void Function() onTick)`** – repeating timer. Returns `TimerDisposable`; call `dispose()` to cancel.

### Wiring via DI

`TimerService` is registered in `lib/core/di/injector_registrations.dart` as lazy singleton. Inject it into repositories, coordinators, or services that need delayed work:

```dart
class MyRepository {
  MyRepository({required TimerService timerService}) : _timerService = timerService;
  final TimerService _timerService;
  TimerDisposable? _restartHandle;

  void scheduleRestart() {
    _restartHandle?.dispose();
    _restartHandle = _timerService.runOnce(const Duration(seconds: 2), () {
      _restartHandle = null;
      _doRestart();
    });
  }

  Future<void> dispose() async {
    _restartHandle?.dispose();
    _restartHandle = null;
  }
}
```

### Centralize timer disposal

- **Cubits**: If cubit already uses `CubitSubscriptionMixin`, register timer handles with `registerTimer(...)` and unregister when replaced (`unregisterTimer(...)`). This prevents late-async timer leaks and keeps timer cleanup consistent with subscription cleanup.
- **Repositories/services**: Prefer `TimerHandleManager` (`lib/shared/utils/timer_handle_manager.dart`) to keep timer handles bounded and to ensure delayed restarts don’t outlive `dispose()`.

### Tests

Use `FakeTimerService()` from `test/test_helpers.dart` so tests can advance time without real waits:

```dart
final fakeTimer = FakeTimerService();
final repo = MyRepository(timerService: fakeTimer);
repo.scheduleRestart();
fakeTimer.elapse(const Duration(seconds: 2));
await pumpEventQueue();
// assert restart happened
```

### Retry backoff

For retry/backoff delays, pass `TimerService` into `RetryPolicy.executeWithRetry(..., timerService: myTimerService)` when you need test time control; when omitted, backoff uses `Future.delayed` (allow-listed).

## When Future.delayed is allowed

validation script `tool/check_raw_future_delayed.sh` flags `Future.delayed` in `lib/` except in allow-listed paths. Allowed without change:

- **Mock/demo code**: `mock_*.dart`, `*_demo_*.dart`, `delayed_chart_repository.dart`, `isolate_samples.dart`.
- **Justified production paths** (allow-listed in script): `retry_policy.dart` (interruptible via `CancelToken` polling), `navigation.dart` (short safeGo delay with `context.mounted` check), `todo_list_page_handlers.dart` (UI timing), `walletconnect_service.dart` (demo placeholder).

For **new** production code, prefer `TimerService`. If you must use `Future.delayed`, add `// check-ignore: reason` on line (or line above) and ensure script’s allow-list or validation docs are updated if exception is permanent.

## Validation script

- **`tool/check_raw_future_delayed.sh`** – run as part of `tool/delivery_checklist.sh`. Fails if `Future.delayed` appears in `lib/` outside allow-listed files or check-ignore.
- **`tool/check_raw_timer.sh`** – fails if raw `Timer(` is used in production code (use `TimerService` instead).

Running full checklist: `./tool/delivery_checklist.sh` (or `./bin/checklist` if available).
