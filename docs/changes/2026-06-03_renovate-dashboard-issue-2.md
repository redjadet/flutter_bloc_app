# Renovate Dependency Dashboard follow-up (issue #2)

**Date:** 2026-06-03 (original); **updated:** 2026-06-08
**Issue:** <https://github.com/redjadet/flutter_bloc_app/issues/2>

## Current status (2026-06-08)

The analyzer/codegen conflict from the original note is **resolved**:

- `json_serializable: ^6.14.0` with `dependency_overrides: analyzer: 10.0.0`, `dart_style: 3.1.4`
- `custom_lint` removed from `pubspec.yaml`; vendored `mix_lint` 2.x and `file_length_lint` run via native `analysis_options.yaml` `plugins:` (`analysis_server_plugin`)
- `mix_lint` enforced via `./tool/run_mix_lint.sh`; `file_too_long` enforced at severity `error` (QG-D02 promoted)
- Renovate caps `json_serializable` at `<7.0.0` (see `renovate.json` package rule description)

Canonical pins and troubleshooting: [`docs/engineering/DEPENDENCY_UPDATES.md`](../engineering/DEPENDENCY_UPDATES.md).

## Problem (historical — 2026-06-03)

The dashboard still listed repository problems and open PR [#285](https://github.com/redjadet/flutter_bloc_app/pull/285) (`dart-minor-patch`) failed CI with `pubspec-compat|fail` because `json_serializable` 6.14.0 requires analyzer ≥10 while the repo pinned analyzer 8.4.x for `custom_lints` / `custom_lint`.

## Change (historical — 2026-06-03)

- `renovate.json`: add root `ignoreDeps` for `dev.flutter.flutter-plugin-loader` (suppress Maven lookup noise); add `allowedVersions` cap for `json_serializable` (later raised to `<7.0.0` after the analyzer-10 stack landed).
- [`DEPENDENCY_UPDATES.md`](../engineering/DEPENDENCY_UPDATES.md): document the `json_serializable` / `dart-minor-patch` interaction.

## Verification

```bash
npx --yes --package renovate -- renovate-config-validator renovate.json
bash tool/check_pubspec_codegen_compat.sh
dart analyze lib
./tool/run_mix_lint.sh
./tool/run_file_length_lint.sh
```

## Note

Issue #2 remains **open** by design (`:dependencyDashboard`). PR #285 and the analyzer-8 pin are obsolete after the 6.14 / analyzer-10 migration; use `check_pubspec_codegen_compat.sh` on future `dart-minor-patch` PRs instead.
