# Change note: consume public `ilkersevim_relative_time`

**Date:** 2026-07-22
**Branch:** `extract/public-ilkersevim-relative-time`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move the dependency-free short relative-time formatter
(`formatRelativeTimeShort`) out of workspace `packages/utilities` into a
public package so other Dart apps can reuse chat-style labels (`3d` / `2h` /
`now`) without this monorepo.

## What changed (app repo)

- Added `ilkersevim_relative_time` on `apps/mobile` (floor `^0.1.1` after OIDC).
- Switched `chat_contact_tile.dart` to the hosted barrel (utilities import
  dropped — no other utilities symbols in that file).
- Removed `relative_time_formatting` from `packages/utilities` (export +
  implementation + package test). Coverage lives in the public package.
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API name, signature, and labels unchanged.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_relative_time> (`0.1.0` manual
  + `0.1.1` OIDC; app constraint `^0.1.1`)
- Source: <https://github.com/redjadet/ilkersevim_relative_time> (Apache-2.0)
- Releases: GitHub Actions OIDC on tag `vX.Y.Z*` with Environment `pub.dev`
  (reviewer `redjadet`); proven on `v0.1.1`
