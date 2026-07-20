# Change note: consume public `ilkersevim_async_utils`

**Date:** 2026-07-20  
**Branch:** `extract/public-ilkersevim-async-utils`  
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move dependency-free `InFlightCoalescer`, `KeyedInFlightCoalescer`, and
`RequestIdGuard` out of workspace `packages/utilities` into a public package
so other Dart/Flutter apps can reuse them without this monorepo.

## What changed (app repo)

- Added `ilkersevim_async_utils` dependency on `apps/mobile` via Git tag
  `v0.1.0` (`https://github.com/redjadet/ilkersevim_async_utils.git`) until
  Pub.dev `0.1.0` is uploaded manually.
- Switched feature import sites to
  `package:ilkersevim_async_utils/ilkersevim_async_utils.dart` (dual-import
  where `AppError` / `RetryPolicy` still come from `utilities`, including
  `todo_list_cubit` parts).
- Removed the three types from `packages/utilities` barrel, sources, and tests.
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names, nullability, and completion-reset semantics unchanged. Feature
behavior should be identical.

## External package

Public repo: https://github.com/redjadet/ilkersevim_async_utils (Apache-2.0).
Pub.dev first upload deferred (interactive `dart pub login` required).
