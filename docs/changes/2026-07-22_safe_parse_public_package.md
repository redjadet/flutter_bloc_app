# Change note: consume public `ilkersevim_safe_parse`

**Date:** 2026-07-22
**Branch:** `extract/public-ilkersevim-safe-parse`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move dependency-free safe dynamic/JSON parse helpers (`stringFromDynamic`,
`intFromDynamic`, `mapFromDynamic`, and siblings) out of workspace
`packages/utilities` (and the storage fork) into a public package so other Dart
apps can reuse them without this monorepo.

## What changed (app repo)

- Added `ilkersevim_safe_parse: ^0.1.0` on `apps/mobile` and `packages/storage`.
- Switched parse-helper consumers to the hosted barrel (dual-import where a
  file still needs other `utilities` APIs), including `parseMapOfMaps` for
  Realtime Database todo parsing.
- Removed `safe_parse_utils` from `packages/utilities` and deleted the storage
  fork under `packages/storage/lib/src/utils/`.
- `MigrationHelpers` now imports hosted `intFromDynamic`; AppLogger warnings for
  invalid timestamps stay on `app_shared_flutter`.
- Deleted the mobile copy of safe-parse unit tests (coverage lives in the public
  package). `migration_helpers_test` still covers normalizeCount/Timestamp.
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names unchanged. `mapFromDynamic` now returns `null` when a map entry has a
non-string key (was previously coerced); that semantic fix ships in public
`0.1.0` and was applied in-repo before this consume cutover.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_safe_parse> (`0.1.0`)
- Source: <https://github.com/redjadet/ilkersevim_safe_parse> (Apache-2.0)
