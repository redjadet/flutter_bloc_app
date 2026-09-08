# 2026-09-08 — Todo editor keyboard Next focus

## Why

Todo add/edit dialog owned `FocusNode`s but adaptive text fields could not set
`textInputAction`, so keyboard **Next** on the title field did not advance to
description (same class of form focus gaps as FocusNode keyboard guides).

## Change

- Pass `textInputAction` / `onSubmitted` through `PlatformAdaptive.textField`.
- Title field: `TextInputAction.next` → `descriptionFocusNode.requestFocus()`.
- Description keeps `TextInputAction.newline` for multiline entry.
- Drop redundant title `autofocus` (dialog already post-frame `requestFocus`).
- Widget tests for Material and Cupertino Next → description focus.

## Proof

```bash
cd apps/mobile && flutter test \
  test/features/todo_list/presentation/widgets/todo_list_dialogs_test.dart \
  test/shared/utils/platform_adaptive_inputs_test.dart
INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome ./bin/integration_preflight
CHECKLIST_INTEGRATION_DEVICE=<iphone_sim> INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
  ./bin/integration_tests integration_test/todo_list_flow_test.dart
ALLOW_DESKTOP_INTEGRATION_DEVICE=1 CHECKLIST_INTEGRATION_DEVICE=macos \
  INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
  ./bin/integration_tests integration_test/todo_list_flow_test.dart
```

Android emulator on this host dropped during APK install (memory / dual-adb);
APK assemble succeeded. Not treated as product regression for this focus wiring.
