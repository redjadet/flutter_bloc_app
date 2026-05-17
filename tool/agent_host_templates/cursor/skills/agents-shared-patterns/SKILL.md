---
name: agents-shared-patterns
description: Request-id, in-flight coalesce, stream emit safety, offline don't-overwrite. Use for async repos/cubits and remote→local merge.
---

# Shared async / offline-first patterns

Lifecycle: `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`; memory pressure → `docs/REPOSITORY_LIFECYCLE.md` (no per-feature observers).

| Concern | Tool | Path |
| --------- | ------ | ------ |
| Cubit latest-wins | `RequestIdGuard` | `lib/shared/utils/request_id_guard.dart` |
| Repo pull coalesce | `InFlightCoalescer` / `KeyedInFlightCoalescer` | `lib/shared/utils/in_flight_coalescer.dart` |
| Shared controller emit | `StreamControllerSafeEmit` | `lib/shared/utils/stream_controller_lifecycle.dart` |
| Owned controller | `StreamControllerLifecycle` mixin | same file |
| Don't overwrite local | merge guards + pending-op skip | `docs/offline_first/dont_overwrite_guide.md`; counter/todo/iot_demo repos |
| Regression | remote-merge tests | `tool/check_offline_first_remote_merge.sh` |
