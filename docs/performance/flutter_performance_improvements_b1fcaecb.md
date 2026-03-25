<!--
This file was moved from repo root to keep docs organized.
-->

# Flutter performance improvements — baseline + triage

## Environment

- **Date**: 2026-03-25
- **Flutter**: 3.41.5 (stable)
- **Dart**: 3.11.3
- **DevTools**: 2.54.2
- **Target**: iOS (iPhone simulator)
- **Chosen simulator (UDID)**: `82B916E8-9CEC-48F1-8219-22C73B6F7037` (iPhone 17e)

## Flows used (automation-friendly)

Baseline uses the existing integration aggregate suite:

- `integration_test/all_flows_test.dart` via `./bin/integration_tests`

This covers representative flows for:

- app launch and navigation
- todo list interactions (add/list/filter)
- chat flows
- multiple feature screens that exercise lists, images, and UI composition

## Baseline evidence

### Integration run (iPhone simulator)

- **Command**: `./bin/integration_tests`
- **Result**: ✅ `All tests passed!` (aggregate suite)
- **Notes**: Xcode build completed; suite ran to completion on the simulator UDID above.

### Repo performance guard scripts (static)

All of the following are currently green:

- ✅ `tool/check_perf_shrinkwrap_lists.sh`
- ✅ `tool/check_perf_nonbuilder_lists.sh`
- ✅ `tool/check_raw_network_images.sh`
- ✅ `tool/check_perf_missing_repaint_boundary.sh`
- ✅ `tool/check_perf_unnecessary_rebuilds.sh` (warning-only; no warnings)
- ✅ `tool/check_side_effects_build.sh` (warning-only; existing allowlisted ignores only)
- ✅ `tool/check_missing_const.sh` (warning-only; no warnings)

## Hotspot ranking (top 1–3)

This baseline includes real **`traceAction()` frame timing artifacts** captured on the pinned iPhone simulator.

### Captured frame timing artifacts (traceAction)

- **Test**: `integration_test/perf/perf_smoke_flows_test.dart`
- **Command**:
  - `CHECKLIST_INTEGRATION_DEVICE=82B916E8-9CEC-48F1-8219-22C73B6F7037 tool/capture_perf_trace.sh`
- **Artifact**: `artifacts/perf/perf_report_data_20260325T105350Z.json`

Quick “Frame” duration stats (async trace \(b/e\) pairs; best used comparatively):

- `todo_list_add_trace`: p50 1.333ms, p90 2.033ms, max 4.666ms
- `chat_list_scroll_trace`: p50 2.497ms, p90 3.790ms, max 10.101ms
- `charts_scroll_refresh_trace`: p50 1.934ms, p90 4.275ms, max 5.654ms

### Current hotspot ranking

At this point we have artifacts, but not a clear “bad” hotspot yet. Next step is to:

- compute worst-frame / jank thresholds from the artifacts
- correlate the slowest spans to widget/build hotspots via targeted follow-up traces

## Outcome / decision

- We now have a repeatable automated way to capture iOS simulator frame timing artifacts.
- Targeted code changes should only start after we identify top 1–3 hotspots from these artifacts.

## Current state (2026-03-25)

### What changed since the initial baseline section

- **Trace analyzer upgraded**: `tool/analyze_perf_trace.py` now prints a per-trace **Frame budget** summary:
  - **Frame p90/p99/max**
  - **counts of frames over 8.3ms and 16.7ms**
  This is the primary signal to avoid optimizing based on pipeline scheduling noise.
- **Perf traces expanded**:
  - Added `scapes_grid_scroll_trace` (image-heavy grid scroll) to `integration_test/perf/perf_smoke_flows_test.dart`.
  - Split `integration_test/perf/perf_charts_traces.dart` to clear the repo’s 400-line file limit by extracting the minimal toggle harness and builders to `integration_test/perf/perf_charts_toggle_harness.dart`.
- **Chart experiment cleanup**:
  - `ChartLineGraph` no longer hides titles when zoom is enabled (the “hide titles” branch was an experiment and was reverted).
  - `ChartLineGraph` keeps full point fidelity; sampled-point rendering was not kept because it changes chart semantics and makes zoom misleading.

### Latest artifacts captured

- `artifacts/perf/perf_report_data_20260325T141806Z.json`
  - Used to validate that scroll traces can show **low Frame durations** even when pipeline spans look “spiky”.
- `artifacts/perf/perf_report_data_20260325T142757Z.json`
  - Includes **`scapes_grid_scroll_trace`**.

### Key finding (important)

In the latest captures, the scroll traces we care about show **no frame-budget misses** in the `traceAction()` “Frame” metric:

- **`scapes_grid_scroll_trace`**: `>8.3ms=0`, `>16.7ms=0` (p99/max ~3.5ms)
- **`chat_list_scroll_trace`**: `>8.3ms=0`, `>16.7ms=0` (example capture shows p99 ~2.9ms)
- **`charts_zoom_*_scroll_trace`**: `>8.3ms=0`, `>16.7ms=0`

This means that the large p90/p99 values in `PipelineProduce` / `PipelineItem` observed in some traces are **not automatically actionable** unless they coincide with frame-budget misses.

## Next best move (when resuming)

### Make the traces “hard enough” to reveal real jank

Adjust the heaviest real-UI traces (start with `scapes_grid_scroll_trace`) to increase pressure:

- **Warm up + scroll longer**: include a short warmup scroll to kick off image decoding/caching, then do a longer sustained scroll.
- **Reduce between-fling idle**: shorten per-iteration `pump()` delays so frames are denser.
- **Add interaction during scroll** (optional): toggle favorites or open/close a lightweight overlay while scrolling to force rebuilds during raster load.

### Use the Frame budget section as the gate

For any trace we change (or any optimization we attempt), only proceed if we see:

- **`>8.3ms` increasing meaningfully**, and especially
- **any `>16.7ms` frames** (true frame-budget misses on 60Hz),

then identify the tightest code-level hypothesis and re-capture before/after on the pinned simulator UDID.
