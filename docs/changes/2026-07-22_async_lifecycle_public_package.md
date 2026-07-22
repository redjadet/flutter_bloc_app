# Change note: consume public `ilkersevim_async_lifecycle`

**Date:** 2026-07-22
**Branch:** `extract/public-ilkersevim-async-lifecycle`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move dependency-free `CompleterHelper`, `StreamControllerSafeEmit`, and
`StreamControllerLifecycle` out of workspace `packages/utilities` into a public
package so other Dart apps can reuse them without this monorepo.

## What changed (app repo)

- Added `ilkersevim_async_lifecycle: ^0.1.0` on `apps/mobile`,
  `packages/networking`, and `packages/storage`.
- Switched three library consumers to the hosted barrel.
- Removed the two implementations + barrel exports from `packages/utilities`.
- App shared tests now import the hosted package (coverage also lives in the
  public repo).
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names and semantics unchanged. Option B types (`DisposableBag`,
`TimerHandleManager`, etc.) stay private in `utilities` / `core`.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_async_lifecycle> (`0.1.0`;
  app constraint `^0.1.0`)
- Source: <https://github.com/redjadet/ilkersevim_async_lifecycle> (Apache-2.0)
- Releases: GitHub Actions OIDC publish on tag `vX.Y.Z` with Environment
  `pub.dev` (proof pending Task 12)
