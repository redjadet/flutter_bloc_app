# Constraint-bounded pub upgrade and Flutter 3.47 follow-ups

`flutter pub upgrade` (no `--major-versions`) plus the 3.47 pin leftovers:
standalone design libraries, Dart 3.13 language floor, and built-in Kotlin
status.

## Why

SDK is already Flutter 3.47 / Dart 3.13. Packages inside caret constraints
were stale. 3.47 follow-ups were still open after the toolchain pin.

## What landed

- Lockfile: go_router 17.5.0, supabase_flutter 2.17.2, video_player 2.14.0,
  permission_handler 13.0.1, retrofit 4.10.0, and related rdeps. Pins kept:
  analyzer 10.0.2, dart_style 3.1.4, email_validator ^3.0.0,
  path_provider_foundation 2.5.1.
- `dart fix --apply --code=migrate_design_widgets,avoid_final_parameters`
  plus `material_ui` / `cupertino_ui` `^1.0.0`. App wraps
  `MaterialUiCompatibilityBridge` for Mix, genui, and firebase_ui_auth
  (still on `package:flutter/material.dart`).
- Dart language floor `>=3.13.0`. Ordinary `final` params stripped; analysis
  now errors on `avoid_final_parameters` and `parameter_assignments`.
- Freezed still emits `final` on ordinary constructor parameters. Tracked
  `*.freezed.dart` outputs were stripped; re-run
  `tool/strip_freezed_dart_313_params.sh` after `build_runner` until Freezed
  is 3.13-safe. The strip keeps `final _that = this;` and `final value = ...`
  locals (regression: `tool/strip_freezed_dart_313_params_test.py`).
  Root `dart run tool/*.dart` scripts were also stripped (`--tool-scripts`);
  `analysis_options.yaml` excludes `tool/**`, so `dart fix` missed them.
- Built-in Kotlin **not** enabled. Flutter’s KGP warning listed FlutterFire
  plus `desktop_webview_auth`, `flutter_tts`, `reactive_ble_mobile`, and
  `wallet_connect_v2`. Later same-day correction: FlutterFire already guards
  the apply; only those four remain unconditional. See
  [`2026-08-17_android_builtin_kotlin_app.md`](2026-08-17_android_builtin_kotlin_app.md).

## Out of scope

- `flutter pub upgrade --major-versions` (genui, google_sign_in 7, etc.)
- Hive web `--wasm` default (still opt-in)
- `tool/bloc_codegen` SDK floor (isolated; stays `>=3.12.0`)

## Verification

- `flutter pub upgrade` (constraint-bounded); `bash tool/check_pubspec_codegen_compat.sh`
- `./bin/format --changed`
- `./tool/analyze.sh --no-pub` — 0 issues
- `python3 tool/strip_freezed_dart_313_params_test.py` (prior turn; strip still in tree)
- Material/Cupertino l10n: `test/l10n/app_localization_delegates_test.dart`;
  TR golden, AR RTL, DE formatters, dark FAB goldens;
  online therapy smoke extra-pumps leftover fake-network timer
- `./bin/checklist --no-reuse` — pass (2838 tests, 4 skip); coverage 85.23%
- `flutter build apk --debug` — `app-debug.apk` (KGP plugin warning unchanged)
- `INTEGRATION_TESTS_RUN_COVERAGE=false ./bin/integration_tests` — pass
  (Chrome preflight + iPhone sim `all_flows` 29 tests)
