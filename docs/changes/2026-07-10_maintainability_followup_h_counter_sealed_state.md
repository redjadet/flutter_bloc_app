# Maintainability follow-up H — sealed CounterState

**Date:** 2026-07-10  
**Seam:** Rank 7 / counter dual ViewStatus + CounterError

## Change

Introduce `CounterViewData` + sealed `CounterState` (`initial|loading|ready|failure`).
Drop `ViewStatus` from counter presentation. Cubit helpers `asLoading`/`asReady`/`asFailure`/`copyData`.

## Proof

```bash
flutter test test/counter_cubit_test.dart test/counter_state_test.dart \
  test/countdown_bar_test.dart test/features/counter/
```
