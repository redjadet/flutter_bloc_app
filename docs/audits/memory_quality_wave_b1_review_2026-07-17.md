# Memory quality Wave B1 review — 2026-07-17

## Scope

Tag stable leak journeys only; keep default ignore for untagged tests.

## Journeys tagged

1. **Auth** — `ValueNotifier` sign-in/out under `Directionality` (avoids GoRouter
   auth-gate harness noise).
2. **App-shell** — `GoRouter.go` with `NoTransitionPage` (Material transitions
   dominate leak reports otherwise).
3. **Realtime** — thin `BlocBuilder` + `BlocProvider.create`; full
   `RealtimeMarketPage` + fl_chart hangs leak finalization. Fake repo uses
   `broadcast(sync: true)` so emit is visible before the next pump.
4. **BLE** — existing IoT hub “leaving BLE tab…” converted to `leakSafeTestWidgets`.

## Harness ignores

Realtime journey ignores `memoryLeakHarnessLayerClasses` + `TextPainter` only.
Product owners (cubit, stream controller, GoRouter) stay tracked.

## Proof

```text
flutter test … --tags memory_leak --concurrency=1  →  +8 All tests passed
```

## Non-goals

Wave B2/B3; dry-run checklist gate; global `withIgnoredAll()` removal.
