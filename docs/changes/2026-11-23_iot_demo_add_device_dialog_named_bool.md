# IoT add-device dialog — named `hasValue` (analyzer compat)

## Why

PR #1093 removed `avoid_positional_boolean_parameters` from the part file
`ignore_for_file` so weekly upgraded-deps analyze would stop reporting
`unnecessary_ignore`. Pinned-toolchain CI still enforces `avoid_positional_boolean_parameters`
on `buildMaterialDialog` / `buildCupertinoDialog`.

## What landed

- `iot_demo_add_device_dialog_ui.part.dart`: `hasValue` is a required named parameter on both dialog builders.
- `iot_demo_add_device_dialog.dart`: call sites pass `hasValue: hasValue`.

No behavior change.

## Verification

```bash
cd apps/mobile && flutter analyze lib/features/iot_demo/presentation/widgets/iot_demo_add_device_dialog.dart
flutter test test/features/iot_demo/presentation/widgets/iot_demo_add_device_dialog_test.dart
bash tool/check_feature_brief_linked.sh --base origin/main
```