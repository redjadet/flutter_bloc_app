# Change note: consume public `ilkersevim_retry`

**Date:** 2026-07-22
**Branch:** `extract/public-ilkersevim-retry`
**Plan:** [`docs/plans/2026-07-20_hybrid_shared_package_distribution.md`](../plans/2026-07-20_hybrid_shared_package_distribution.md)

## Why

Move dependency-free `RetryPolicy`, `RetryDelay`, `CancelToken`, and
`CancellationException` out of workspace `packages/utilities` into a public
package so other Dart apps can reuse interruptible retry/backoff without this
monorepo.

## What changed (app repo)

- Added `ilkersevim_retry: ^0.1.0` on `apps/mobile` and `packages/networking`.
- Switched AppInfoCubit, CaseStudySessionCubit, and networking
  `RetryInterceptor` to the hosted barrel (no utilities shim; dual-import only
  where other utilities symbols remain — none of these files needed that).
- Removed `src/retry/` from `packages/utilities` (export + implementation).
- Deleted workspace `retry_policy_test.dart` (coverage lives in the public
  package).
- Documented ownership in [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md).

## Behavior

API names and semantics unchanged.

## External package

- Pub.dev: <https://pub.dev/packages/ilkersevim_retry> (`0.1.0` manual; app
  constraint `^0.1.0`)
- Source: <https://github.com/redjadet/ilkersevim_retry> (Apache-2.0)
- Releases: OIDC publish path not yet wired for this package
