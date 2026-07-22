# Change note: retire type_safe_bloc app shims

**Date:** 2026-07-22
**Branch:** `extract/retire-type-safe-bloc-shims`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)
**Related:** [`2026-07-21_type_safe_bloc_public_package.md`](2026-07-21_type_safe_bloc_public_package.md)

## Why

Phase 2 kept app shims so migration stayed small. Follow-up retires those shims
so feature/test code imports the hosted package directly.

## What changed

- Rewrote ~115 shim import sites (plus remaining `app_shared_flutter` TypeSafe
  consumers) to
  `package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart`.
- Deleted `apps/mobile/lib/app/extensions/type_safe_bloc_access.dart` and
  `apps/mobile/lib/app/widgets/type_safe_bloc_selector.dart`.
- Removed `ilkersevim_type_safe_bloc` re-export and unused
  `flutter_bloc` / `provider` / hosted deps from `packages/app_shared_flutter`.
- Updated ADR 0004 + compile-time safety / SoC / `SHARED_UTILITIES` ownership
  docs to the hosted import path.

## Behavior

API unchanged. Import path only.
