# Android Built-in Kotlin: app migrate, plugin flag still off

Enable Built-in Kotlin as far as the plugin graph allows. Flutter 3.47 / AGP 9
still ships `android.builtInKotlin=false` because leftover plugins apply KGP.

## Why

AGP 9 fails when a plugin applies `kotlin-android` while Built-in Kotlin is
on. Earlier notes listed every FlutterFire Android plugin as a hard blocker.
Several already skip KGP when the flag is true.

## What landed

- **App** aligns with AGP 9 Kotlin DSL: drop `id "kotlin-android"` from
  `apps/mobile/android/app/build.gradle`; use `kotlin { compilerOptions }`
  (`JvmTarget.JVM_11`, not 17). Flutter still applies KGP to `:app` while the
  flag is false. The “app project applies KGP” warning is gone.
- **`android.builtInKotlin` stays `false`.** Turning it `true` still fails at
  `desktop_webview_auth` (`Failed to apply plugin 'kotlin-android'`). No newer
  pub versions drop the apply. Patching plugin Gradle in pub-cache / intercepting
  Groovy `apply plugin:` from the host `Project` are not repo-owned fixes.
- Unconditional remaining applies (need upstream): `desktop_webview_auth`
  0.0.16, `flutter_tts` 4.2.5, `reactive_ble_mobile` 5.5.0,
  `wallet_connect_v2` 1.0.9 (`kotlin-kapt` unused).
- Already guarded (would be fine with the flag true): FlutterFire packages that
  wrap `apply plugin: 'kotlin-android'` in `if (agpMajor < 9 || !builtInKotlin)`,
  plus `device_info_plus` / `package_info_plus` (`if (agpMajor < 9)`). Flutter’s
  KGP warning still lists the FlutterFire names because it regex-scans source
  text, not the guarded branch.

## Flip condition

Set `android.builtInKotlin=true` only after the four unconditional plugins
drop `apply plugin: 'kotlin-android'` (or add the FlutterFire AGP 9 guard).
Then confirm `flutter build apk --debug`.

## Verification

- `android.builtInKotlin=true` (probe): Gradle fails on `desktop_webview_auth`.
- `flutter build apk --debug` with the app migrate and flag false:
  `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`
