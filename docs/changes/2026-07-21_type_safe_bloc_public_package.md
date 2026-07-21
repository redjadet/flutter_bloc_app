# Change note: consume public `ilkersevim_type_safe_bloc`

**Date:** 2026-07-21
**Branch:** `extract/public-type-safe-bloc`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move type-safe `flutter_bloc` context extensions and selector/builder/listener/
consumer widgets out of workspace `packages/app_shared_flutter` into a public
package so other Flutter apps can reuse them without this monorepo.

## What changed (app repo)

- Added `ilkersevim_type_safe_bloc: ^0.1.0` on `packages/app_shared_flutter`
  and `apps/mobile` from Pub.dev.
- `app_shared_flutter` barrel re-exports the hosted package; local `src/bloc/*`
  sources and package tests removed (coverage lives in the public repo).
- App shims under `apps/mobile/lib/app/extensions/` and `app/widgets/` now
  re-export `package:ilkersevim_type_safe_bloc/...` (feature import sites
  unchanged).
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names, generics, and widget rebuild semantics unchanged. Feature behavior
should be identical.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_type_safe_bloc> (`0.1.0`;
  app constraint `^0.1.0`)
- Source: <https://github.com/redjadet/ilkersevim_type_safe_bloc> (Apache-2.0)
- Releases: GitHub Actions OIDC publish on tag `vX.Y.Z` with Environment
  `pub.dev` (proof pending `0.1.1`)
