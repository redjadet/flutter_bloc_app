# 2026-08-20 — macOS native showcase telemetry EventChannel crash

## Why

`./bin/integration_tests` on `macos` (`ALLOW_DESKTOP_INTEGRATION_DEVICE=1`)
built successfully then failed with:

`Error waiting for a debug connection: The log reader stopped unexpectedly`

Crash: `EXC_CRASH (SIGABRT)` in `MainFlutterWindow.awakeFromNib` →
`FlutterBinaryMessengerRelay makeBackgroundTaskQueue` →
`doesNotRecognizeSelector`.

## Cause

`MainFlutterWindow` used the same optional `makeBackgroundTaskQueue` pattern as
iOS. On macOS the engine messenger does not implement that method. The relay
still responds and forwards to `parent`, which aborts.

## Fix

1. Register the telemetry `FlutterEventChannel` without a background task queue
   on macOS (main-queue path). Keep iOS task-queue path unchanged.
2. Integration flows:
   - Find Todo add via FAB tooltip (header text button is layout-gated).
   - Reset real Hive counter to `0` before persistence flow
     (desktop `hive_macos_debug` retains state across runs).
   - Complete-selected via app-bar menu when batch bar is height-gated.
   - Navigation grid scroll uses drag on macOS (fling inertia never idles).

## Proof

- `CHECKLIST_INTEGRATION_DEVICE=macos ALLOW_DESKTOP_INTEGRATION_DEVICE=1
  INTEGRATION_TESTS_RUN_COVERAGE=false INTEGRATION_TESTS_RUN_PREFLIGHT=0
  ./bin/integration_tests`
