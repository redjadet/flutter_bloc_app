# 2026-09-08 — Perf awaitScrollTarget shared-budget poll

## Why

`tool/capture_perf_trace.sh` failed on iPhone Simulator when the smoke suite
reached Scapes: `awaitScrollTarget` waited the full timeout for a missing
`ListView` before considering `Scrollable`/`GridView`, so grid-only screens
timed out with no scroll target.

## Change

- Poll all scroll candidates each pump step under one shared timeout.
- Prefer `GridView` in the candidate list before generic `Scrollable`.
- Add a focused widget test that proves GridView is found when ListView is absent.

## Proof

```bash
cd apps/mobile && flutter test test/integration_test_helpers/await_scroll_target_test.dart
CHECKLIST_INTEGRATION_DEVICE=<iphone_sim_udid> tool/capture_perf_trace.sh
python3 tool/analyze_perf_trace.py artifacts/perf/perf_report_data_<stamp>.json
```

Artifact (gitignored): `artifacts/perf/perf_report_data_20260908T094512Z.json`.
B6 product optimization deferred: several chart traces miss p90/p99 budgets but
most journeys are under `min_measured_frames` (100); need longer capture +
DevTools UI vs raster confirmation before code changes.
