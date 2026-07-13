# Web first-load splash and bootstrap overlap

## Why

Web first launch showed a long blank white page while Flutter JS/CanvasKit
downloaded and while `BootstrapCoordinator` awaited secrets, backends, DI, and
migration before the first `runApp`.

## What changed

- `apps/other_platforms/web/index.html` (symlinked as `apps/mobile/web`):
  branded HTML splash + spinner; `passkeys_bundle.js` deferred.
- Custom `web/flutter_bootstrap.js`: status updates during
  entrypoint/engine/runApp; removes splash on `flutter-first-frame`;
  `canvasKitVariant: 'auto'`.
- `BootstrapCoordinator`: early `WebLaunchSplash` on web; parallel
  secrets+version; on web, defer optional Supabase until after `MyApp` while
  Firebase remains before DI (required for configured auth registration), then
  notify `BackendAvailabilityUpdates` so chat/IoT banners rebuild.
- Demo routes listen to `BackendAvailabilityUpdates` for banner/session gates.
- `tool/build_web_github_pages.sh`: default `--wasm` (opt out `WEB_WASM=0`).
- Tests: splash, deferred backends, parallel-order assertions.

## Proof

```bash
flutter test test/app/bootstrap/web_launch_splash_test.dart \
  test/app/bootstrap/bootstrap_coordinator_additional_test.dart
flutter build web --wasm --no-wasm-dry-run -t lib/main_dev.dart --release
./bin/integration_preflight
```

## Review fixes (same day)

- Route `ListenableBuilder` moved **inside** BlocProviders so deferred backend
  ticks update banners without recreating Chat/IoT cubits.
- Deferred backend init wrapped in try/finally so availability tick still fires
  after failures.
- Firebase remains on the pre-DI path: `MyApp` resolves `AuthRepository` while
  creating its router, so deferring Firebase would permanently select the
  web-local guest implementation even when Firebase configuration exists.
- Residual: GitHub Pages may need COOP/COEP for multi-threaded skwasm; Flutter
  falls back to single-threaded/canvaskit when headers are absent.
