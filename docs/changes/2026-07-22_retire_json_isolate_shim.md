# Change note: retire json_isolate app shim

**Date:** 2026-07-22
**Branch:** `extract/retire-json-isolate-shim`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)
**Related:** [`2026-07-22_json_isolate_public_package.md`](2026-07-22_json_isolate_public_package.md)

## Why

Phase 4 kept `apps/mobile/lib/app/utils/isolate_json.dart` as a short-lived
export shim. All library consumers already import the hosted package; the shim
is unused and blocks a clean ownership story.

## What changed

- Deleted `apps/mobile/lib/app/utils/isolate_json.dart`.
- Pointed docs and `tool/check_raw_json_decode.sh` at
  `package:ilkersevim_json_isolate` / Pub.dev.

## Behavior

API unchanged. Import path only (already migrated).
