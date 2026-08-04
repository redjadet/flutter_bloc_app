# Memory quality Wave B2 — product dispose journeys — 2026-08-04

## Summary

Promoted dual-run product dispose classes from the remeasure audit into
**tagged** leak journeys without removing global `withIgnoredAll()` (MQ-N01).

## Changes

- Existing product tests now use tagged leak tracking:
  - `apps/mobile/test/chat_page_test.dart` mounts/unmounts the real `ChatPage`,
    covering its `TextEditingController` + `ScrollController` ownership.
  - `apps/mobile/test/features/counter/presentation/pages/counter_page_loading_state_test.dart`
    mounts/unmounts the real `CounterPage`, covering `ConfettiController`.
- `ParticleSystem` residual after confetti dispose allowed only on that test
  (package-internal); controller ownership still tracked
- [`docs/plans/2026-07-17_memory_quality_deferred.md`](../plans/2026-07-17_memory_quality_deferred.md) MQ-B2 partial

## Verification

```bash
bash tool/run_memory_lint.sh
bash tool/run_memory_leak_tests.sh
```

## Explicit non-goals (still open)

- Global track-all / dry-run checklist wire (MQ-N01/N02)
- MQ-B3 AST timer/listener rules
- Broad prod ignore-list surgery from dry-run noise
