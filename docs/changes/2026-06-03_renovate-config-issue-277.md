# Renovate config validation (issue #277)

**Date:** 2026-06-03
**Issue:** <https://github.com/redjadet/flutter_bloc_app/issues/277>

## Problem

Renovate opened **Action Required: Fix Renovate Configuration** and stopped opening PRs. `renovate-config-validator` reported:

`packageRules cannot combine both matchUpdateTypes and ignoreDeps`

Introduced in #276 when `ignoreDeps` was added to the `dart-minor-patch` rule (which already uses `matchUpdateTypes`).

## Change

- `renovate.json`: remove `ignoreDeps` from the `dart-minor-patch` rule; add a `pub-coordinated-pins` group rule for `genui` and `google_sign_in_mocks` on minor/patch updates (same intent as #276, valid syntax).
- `docs/engineering/DEPENDENCY_UPDATES.md`: document the separate group name.

## Verification

```bash
npx --yes --package renovate -- renovate-config-validator renovate.json
# INFO: Config validated successfully
```

After merge, Renovate should close #277 on the next run and resume PRs.
