# Renovate Dependency Dashboard follow-up (issue #2)

**Date:** 2026-06-03
**Issue:** <https://github.com/redjadet/flutter_bloc_app/issues/2>

## Problem

The dashboard still listed repository problems and open PR [#285](https://github.com/redjadet/flutter_bloc_app/pull/285) (`dart-minor-patch`) failed CI with `pubspec-compat|fail` because `json_serializable` 6.14.0 requires analyzer ≥10 while the repo pins analyzer 8.4.x for `custom_lints`.

## Change

- `renovate.json`: add root `ignoreDeps` for `dev.flutter.flutter-plugin-loader` (suppress Maven lookup noise); add `allowedVersions: "<6.12.0"` for `json_serializable`.
- `docs/DEPENDENCY_UPDATES.md`: document the `json_serializable` / `dart-minor-patch` interaction.

## Verification

```bash
npx --yes --package renovate -- renovate-config-validator renovate.json
bash tool/check_pubspec_codegen_compat.sh
```

## Note

Issue #2 remains **open** by design (`:dependencyDashboard`). After merge, close PR #285 or let Renovate rebase it; the next dashboard refresh should clear the flutter-plugin-loader lookup warning.
