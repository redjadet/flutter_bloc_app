# Change note: bump `ilkersevim_retry` to `^0.1.1`

**Date:** 2026-07-22
**Branch:** `chore/bump-ilkersevim-retry-0.1.1`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md) Phase 8 OIDC

## Why

OIDC publish path proven for Phase 8 (`v0.1.1`). Raise the app caret floor
to the OIDC patch.

## What changed

- `apps/mobile` + `packages/networking`: `ilkersevim_retry: ^0.1.1`
- Workspace lock refreshed to hosted `0.1.1`
- `SHARED_UTILITIES.md` table caret updated

## External proof

- OIDC Actions: <https://github.com/redjadet/ilkersevim_retry/actions/runs/29945293398>
- Pub.dev: <https://pub.dev/packages/ilkersevim_retry/versions/0.1.1>
