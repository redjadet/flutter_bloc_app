# Change note: consume public `ilkersevim_async_utils`

**Date:** 2026-07-20
**Branch:** `extract/public-ilkersevim-async-utils`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move dependency-free `InFlightCoalescer`, `KeyedInFlightCoalescer`, and
`RequestIdGuard` out of workspace `packages/utilities` into a public package
so other Dart/Flutter apps can reuse them without this monorepo.

## What changed (app repo)

- Added `ilkersevim_async_utils: ^0.1.0` on `apps/mobile` from Pub.dev
  (briefly consumed via Git tag `v0.1.0` until first upload landed).
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

- Pub.dev: <https://pub.dev/packages/ilkersevim_async_utils> (latest `0.1.1`;
  app constraint `^0.1.0`)
- Source: <https://github.com/redjadet/ilkersevim_async_utils> (Apache-2.0)
- Releases: GitHub Actions OIDC publish on tag `vX.Y.Z` with Environment
  `pub.dev` (verified on `v0.1.1`)
