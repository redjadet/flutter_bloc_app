# Native platform showcase — PlatformView, haptic, share demos

Date: 2026-07-10

## Scope

Extend `native_platform_showcase` with three live mobile demos behind the
existing Clean Architecture ports:

- Custom PlatformView banner (`UiKitView` / `AndroidView`)
- MethodChannel `triggerHaptic`
- MethodChannel `shareText` → system share sheet / chooser

No new route, plugin, Pigeon, EventChannel, or FFI changes.

## Decisions

- Extend `NativeShowcaseHostLanguageService` instead of new ports.
- Action feedback lives on Cubit loaded state (`lastAction`,
  `lastActionResult`, `actionInFlight`); telemetry emits preserve those fields.
- PlatformView stays presentation-only (no Cubit round-trip).
- Android haptic uses `View.performHapticFeedback` (no `VIBRATE` permission).
- macOS / web / desktop: Dart unavailable + placeholder; no macOS host handlers.

## Validation

- `flutter test test/features/native_platform_showcase/` — 40 passed
- `registerNativePlatformShowcaseServices` DI test — passed
- `flutter build ios --simulator --debug` — passed (`Runner.app`)
- `bash tool/check_ios_pod_framework_embed.sh --require-built-app` — ok
- `flutter build apk --debug` — passed after fixing CMake path to repo-root
  `native/native_showcase/native_showcase.c` (7 `..` segments from
  `android/app/src/main/cpp`)
- Device smoke on booted simulator blocked by host disk space
  (`No space left on device` while copying Flutter.framework)
