# 2026-07-17 — Memory quality Wave B1

Tag stable `leak_tracker` journeys only (auth-route sign-out, app-shell `go`, realtime/BLE
teardown). Global `withIgnoredAll()` unchanged.

- New: auth / app-shell / realtime thin-surface journeys under `test/shared/`
- Converted: IoT hub BLE tab leave → `leakSafeTestWidgets`
- Helper: optional `ignoredNotDisposedClasses` + `memoryLeakHarnessLayerClasses`
- `dart_test.yaml`: declare `memory_leak` tag

Boundary: no B2 ignore promotion; no B3 AST rules; no global ignore flip.
