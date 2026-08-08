# Web counter save: disable dart2wasm with Hive 2.x

## Summary

Production GitHub Pages builds used `flutter build web --wasm`. Hive 2.x links
its stub backend under dart2wasm (`dart.library.html` absent), so `openBox`
throws `UnimplementedError`. Counter load falls back to empty; Increment save
surfaces “Failed to save counter”.

## Changes

- Default `WEB_WASM=0` in `tool/build_web_github_pages.sh`; require
  `WEB_WASM_FORCE=1` to opt into WASM.
- Web Hive init always calls `Hive.init` (`hive_web_v1` release /
  `hive_web_debug_v4` debug); stop relying on no-op `Hive.initFlutter()`.
- Document in `docs/deployment.md` and `docs/engineering/workarounds.md`.

## Verification

- Console on wasm Pages build: `Failed to open Hive box: counter` +
  `UnimplementedError` (pre-fix).
- `bash -n tool/build_web_github_pages.sh`
- Script regression: `tool/test_build_web_github_pages_wasm_guard.sh`
- Follow-up deploy: dart2js web build; Increment persists without save snackbar.
