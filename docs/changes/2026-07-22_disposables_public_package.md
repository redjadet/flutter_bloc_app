# Change note: consume public `ilkersevim_disposables`

**Date:** 2026-07-22
**Branch:** `extract/public-ilkersevim-disposables`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move Phase 3 Option B types (`DisposableBag`, `SubscriptionManager`,
`TimerHandleManager`) plus the `TimerDisposable` contract out of workspace
`packages/utilities` / `packages/core` into a public package so other Dart apps
can reuse lifecycle cleanup helpers without this monorepo.

## What changed (app repo)

- Added `ilkersevim_disposables: ^0.1.0` on `packages/core`, `packages/networking`,
  and `apps/mobile`.
- `packages/core` imports the mixin from the hosted package and re-exports
  `TimerDisposable` so existing `package:core` timer imports keep working.
- Switched bag/manager consumers to `package:ilkersevim_disposables`.
- Removed bag/manager implementations + exports from `packages/utilities` and
  moved package tests into the public repo.
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names and semantics unchanged.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_disposables> (`0.1.0` manual)
- Source: <https://github.com/redjadet/ilkersevim_disposables> (Apache-2.0)
- Releases: GitHub Actions OIDC on tag `vX.Y.Z*` with Environment `pub.dev`
  (reviewer `redjadet`) — **blocked** until Pub.dev Admin enables GitHub Actions
  publishing (Task 28)
