# Restore permission_handler 13 + compileSdk 37 — 2026-08-06

## Summary

Local Android SDK Platform 37 is installed. Restore the post-#662
`permission_handler: ^13.0.0` graph (android 14) and raise app/plugin
`compileSdk` to **37** so `assembleDebug` resolves `CINNAMON_BUN` /
`ACCESS_LOCAL_NETWORK`.

Reverses the temporary `12.0.3` pin from
[`2026-08-05_functions_object_catch_android_pin.md`](2026-08-05_functions_object_catch_android_pin.md).

## Host note

`sdkmanager` may install the platform as `platforms/android-37.0`. If Gradle
looks for `platforms/android-37`, symlink:

`ln -sfn android-37.0 "$ANDROID_HOME/platforms/android-37"`

## Validation

- Android emulator PR smoke (`emulator-5554`): PASS (9) with
  `permission_handler` 13 / `permission_handler_android` 14 / compileSdk 37
