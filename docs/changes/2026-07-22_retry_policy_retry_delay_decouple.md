# RetryPolicy: replace TimerService with RetryDelay

**Date:** 2026-07-22  
**Scope:** Internal utilities refactor — **not** Phase 8 / public package work.

## Summary

`RetryPolicy.executeWithRetry` no longer takes `TimerService?` from
`package:core`. It takes optional `RetryDelay` (`Future<void> Function(Duration)`).
Default delay is `Future.delayed`. Cancel-token polling still calls the delay
once per ≤50 ms chunk.

`packages/utilities/lib/src/retry/*` has **no** `package:core` import.
`packages/utilities` still depends on `core` for other surfaces
(`failure_to_app_error`).

## App adapter

`CaseStudySessionCubit` keeps `_timerService` and adapts it locally to
`RetryDelay` for local-persist retries.

## Tests

`retry_policy_test.dart` uses recording / immediate / gateable `RetryDelay`
fakes instead of `FakeTimerService`.

## Follow-up

After merge: re-run **retry** public-package admission only. Repo helpers stay
deferred until the retry decision completes. No Pub name / repo / publish yet.
