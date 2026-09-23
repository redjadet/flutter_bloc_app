# Finding the real cause of jank

Canonical triage for UI stutter. **Jank is a symptom;** find which work delayed
the frame before changing code.

Upstream:

- [Flutter Performance view](https://docs.flutter.dev/tools/devtools/performance)
- [CPU Profiler](https://docs.flutter.dev/tools/devtools/cpu-profiler)
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Memory view](https://docs.flutter.dev/tools/devtools/memory)
- [Network view](https://docs.flutter.dev/tools/devtools/network)
- [Isolates](https://docs.flutter.dev/perf/isolates)

Pipeline and list/scroll guidelines:
[`performance_bottlenecks.md`](performance_bottlenecks.md). Automated frame
capture: [`flutter_performance_improvements_b1fcaecb.md`](flutter_performance_improvements_b1fcaecb.md).

## Takeaway

Capture the slow interaction, identify the late frame and expensive operation,
make **one** targeted change, then measure the same interaction again.

Do **not** treat debug-mode smoothness, intuition, or a single low `build()`
time as proof. Do **not** optimize PipelineProduce / PipelineItem noise unless
it coincides with frame-budget misses.

## Frame budget

| Refresh | Budget per frame |
| --- | --- |
| 60 Hz | ≈ **16.7 ms** |
| 120 Hz | ≈ **8.3 ms** |

A Flutter frame is an end-to-end pipeline, not a screenshot:

```text
input/state → schedule frame → build → layout → paint → compose → raster → display
```

UI work (build / layout / paint) and raster work are **separate** budgets.
Missing either produces jank.

## Possible causes (symptom → candidates)

| Suspect | Typical signal |
| --- | --- |
| Widget building | High UI time; BUILD spans; wide rebuilds / eager lists |
| Layout | High UI time; LAYOUT / intrinsic layout in lists |
| Painting | High UI time; PAINT; excessive repaints |
| Rasterization | High Raster time; clips, opacity, shadows, `saveLayer`, offscreen layers |
| Dart CPU (main isolate) | CPU Profiler hot methods; sync JSON / crypto / loops in `build` or handlers |
| Garbage collection | GC spikes alongside allocation churn (confirm with Memory, not guess) |
| Images | Decode / cache pressure during scroll; network + decode on first paint |
| Platform calls | Slow MethodChannel / plugin work on the UI isolate |
| Isolates needed | Measurement shows main-isolate CPU blocking frames — move heavy work off UI |

Related symptoms that are **not** the same investigation:

- Growing memory → [`dart_memory_under_the_hood.md`](dart_memory_under_the_hood.md)
- Slow first appearance of a screen → Network timing + startup docs
- Heavy JSON → [`compute_isolate_review.md`](compute_isolate_review.md)

## Triage procedure

### 1. Reproduce in profile mode

Debug frame times do not represent release performance.

```bash
# Interactive (physical device preferred for final proof)
cd apps/mobile && flutter run --profile

# Automated symptom capture (simulator OK for regression)
CHECKLIST_INTEGRATION_DEVICE=<iphone_sim_udid> bash tool/capture_perf_trace.sh
python3 tool/analyze_perf_trace.py artifacts/perf/perf_report_data_<stamp>.json --triage
```

Agent entry: `bash tool/triage_jank.sh` (prints this map; analyzes a report when
given a path or `--latest`).

**Budgets:** interactive frame target is ≈16.7 ms @ 60 Hz / ≈8.3 ms @ 120 Hz.
Automated gate thresholds live in `tool/perf_budgets.json` (p90 ≤ 8.3 ms, p99 ≤
16.7 ms). A gate **fail** with zero `>16.7ms` frames still means pressure —
identify the limiting work before patching. UI vs Raster attribution still
requires profile-mode DevTools.

In DevTools **Performance**, select a slow (red) frame and compare **UI** vs
**Raster** durations.

### 2. Follow the slow side

**High UI time**

1. Inspect the frame timeline for BUILD / LAYOUT / PAINT.
2. Enable build, layout, or paint tracking for the suspected stage.
3. Use **CPU Profiler** for costly Dart methods on the UI isolate.
4. Repo static guards (when the surface matches):
   - `bash tool/check_perf_unnecessary_rebuilds.sh`
   - `bash tool/check_perf_nonbuilder_lists.sh`
   - `bash tool/check_perf_shrinkwrap_lists.sh`
   - `bash tool/check_side_effects_build.sh`

**High raster time**

Inspect effects: clipping, opacity stacks, shadows, `saveLayer`, offscreen
layers, image-heavy cells without isolation.

Repo static guard when scroll jank is plausible:

- `bash tool/check_perf_missing_repaint_boundary.sh`

### 3. Check related symptoms separately

| Symptom | Tool / doc |
| --- | --- |
| Growing heap / retainers | DevTools **Memory**; [`dart_memory_under_the_hood.md`](dart_memory_under_the_hood.md) |
| Slow screen appearance | DevTools **Network**; startup profiling |
| Main-isolate CPU blocks frames | Move work to an isolate **after** measurement proves it; [`compute_isolate_review.md`](compute_isolate_review.md) |

## Agent rules

1. State **observed** UI vs Raster (or analyzer `>16.7ms` / gate fail) before proposing a fix.
2. Name the **limiting stage or method**, not only “the list is slow.”
3. Prefer the narrowest static script when the failure mode is already covered.
4. One change → same interaction remeasure (profile or `capture_perf_trace` +
   `analyze_perf_trace`).
5. Simulator Timeline is useful; iOS Simulator often cannot run `--profile` —
   physical-device profile for final accept when the user requires it
   ([operator prefs](../agent_kb/operator_preferences_durable.md)).

## Repo map

| Concern | Owner |
| --- | --- |
| This triage | `finding_jank_cause.md` |
| Pipeline + list/scroll guidelines | [`performance_bottlenecks.md`](performance_bottlenecks.md) |
| Automated traces + budgets | `tool/capture_perf_trace.sh`, `tool/analyze_perf_trace.py`, `tool/perf_budgets.json` |
| Review questions | [`../review/performance_checklist.md`](../review/performance_checklist.md) |
| Reliability performance rules | [`../reliability_error_handling_performance.md`](../reliability_error_handling_performance.md) |
