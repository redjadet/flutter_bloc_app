# Constraint-bounded pub upgrade (2026-10-07)

`flutter upgrade` (stable already tip) + `flutter pub upgrade` without
`--major-versions`. Flutter/Dart pins unchanged.

## Why

Workspace lockfile had stale caret-compatible transitive bumps after tip
stable stay on Flutter `3.47.6` / Dart `3.13.5`.

## What landed

- Lockfile: `build_runner` 2.16.2, `app_links_linux` 1.0.4,
  `app_links_web` 1.0.5, `image_picker_platform_interface` 2.11.2,
  `jni_flutter` 1.0.4+1, `sqflite` 2.4.4+1, `sqflite_common` 2.5.13+1.
- Dropped unused transitive `gtk` 2.2.0; Linux generated plugin registrant
  / cmake lists now register `app_links_linux` instead of `gtk`.
- Kept: `ilkersevim_retry` `0.1.7`, analyzer/dart_style overrides,
  Renovate major holds (no `--major-versions`).

## Out of scope

- Flutter SDK pin bump (already on tip stable)
- `flutter pub upgrade --major-versions` (genui, google_sign_in 7, melos 8, etc.)
