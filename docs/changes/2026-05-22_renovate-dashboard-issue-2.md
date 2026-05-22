# Renovate Dependency Dashboard (issue #2)

**Date:** 2026-05-22  
**Issue:** https://github.com/redjadet/flutter_bloc_app/issues/2

## Problem

Renovate’s Dependency Dashboard reported repository problems:

- Maven lookup failure for `dev.flutter.flutter-plugin-loader` in `android/settings.gradle` and vendored `third_party/.../example/android/settings.gradle`.
- Benign `Custom registries are not allowed for this datasource` warning from Bundler + GitHub-pinned `fastlane` in `Gemfile`.

## Change

- `renovate.json`: disable Gradle updates for `dev.flutter.flutter-plugin-loader`; skip Gradle/gradle-wrapper under `third_party/**/android/**`.
- `docs/DEPENDENCY_UPDATES.md`: document dashboard semantics (issue stays open) and the warnings above.

## Verification

- Valid JSON in `renovate.json` (schema unchanged).
- After merge, next Renovate run should drop the flutter-plugin-loader lookup error from **Repository Problems**.

## Note

Issue #2 remains **open** by design (`:dependencyDashboard`); this fixes actionable errors, not the dashboard lifecycle.
