# Functions diagnostic Object catch + Android compile pin — 2026-08-05

## Summary

Follow-up after Flutter judgment guidance alignment (#675):

- Functions diagnostic maps non-`Exception` failures (`Object` catch) to the
  safe localized error; regression tests cover generic errors, double-tap while
  pending, and dispose-during-call
- Pin `permission_handler` to `12.0.3` so Android assemble works on compileSdk
  36 — `13.x` pulls `permission_handler_android` 14 which requires compileSdk
  37, and `platforms;android-37` is not installable on this host yet

## Residuals

- Resolved 2026-08-06: local SDK Platform 37 + compileSdk 37 restored
  `permission_handler` ^13 (see
  [`2026-08-06_restore_permission_handler_compile_sdk_37.md`](2026-08-06_restore_permission_handler_compile_sdk_37.md)).

## Validation

- Focused widget tests for Functions diagnostic: PASS (10)
- Integration PR smoke iOS simulator (`iPhone 17`): PASS (9)
- Integration PR smoke Android emulator (`emulator-5554`, after `permission_handler` pin): PASS (9)
- Chrome web integration preflight (`./bin/integration_preflight`): PASS
