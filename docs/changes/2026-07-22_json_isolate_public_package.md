# Change note: consume public `ilkersevim_json_isolate`

**Date:** 2026-07-22
**Branch:** `extract/public-ilkersevim-json-isolate`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move Flutter `compute`-based JSON map/list helpers out of
`packages/app_shared_flutter` into a public package so other Flutter apps can
reuse them without this monorepo.

## What changed (app repo)

- Added `ilkersevim_json_isolate: ^0.1.0` on `apps/mobile` (and as a
  `dev_dependency` on `app_shared_flutter` for package tests).
- Switched all library call sites to the hosted barrel (four former shim
  importers plus chart/HF/GraphQL/secure-chat consumers that imported via
  `app_shared_flutter`).
- Pointed `apps/mobile/lib/app/utils/isolate_json.dart` shim at the hosted
  package during migration; shim retired in follow-up
  [`2026-07-22_retire_json_isolate_shim.md`](2026-07-22_retire_json_isolate_shim.md).
- Removed `src/json/isolate_json.dart` and its barrel export from
  `app_shared_flutter`.
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names, thresholds (`< 8 KiB` decode / small-collection encode), return
types, and `FormatException` behavior unchanged.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_json_isolate> (`0.1.0` manual
  + `0.1.1` OIDC; app constraint `^0.1.0`)
- Source: <https://github.com/redjadet/ilkersevim_json_isolate> (Apache-2.0)
- Releases: GitHub Actions OIDC on tag `vX.Y.Z*` with Environment `pub.dev`
  (reviewer `redjadet`); proven on `v0.1.1`
