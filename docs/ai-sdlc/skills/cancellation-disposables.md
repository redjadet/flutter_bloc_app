---
name: cancellation-disposables
description: Apply when Cubits manage streams, timers, retries, or in-flight futures that can complete after close.
---

# Skill: cancellation-disposables

**Owner:** [`docs/engineering/cancellation_and_cache.md`](../../engineering/cancellation_and_cache.md),
[`docs/bloc_standards.md`](../../bloc_standards.md).

## Must

1. Register subscriptions/timers so `Cubit.close()` disposes them (`CubitSubscriptionMixin` / disposable bag).
2. Guard emits after await with `isClosed` and/or `RequestIdGuard.isCurrent`.
3. Do not treat subscription cancel as hard-abort of a bare `Future` — still guard the late result.
4. Use `mounted` before using `BuildContext` after `await` in widgets.
5. Prefer existing packages (`ilkersevim_disposables`, `ilkersevim_async_utils`, `ilkersevim_retry`) over ad-hoc flags.

## Must not

- Emit after `close()`.
- Leave periodic timers running across navigation.
- Swallow lifecycle bugs with empty `catch`.

## Proof

```bash
cd apps/mobile && flutter test <cubit-or-widget-test-paths>
./tool/analyze.sh
```

Checklist: [`docs/review/bloc_checklist.md`](../../review/bloc_checklist.md).
