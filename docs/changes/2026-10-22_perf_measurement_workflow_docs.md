# Performance measurement workflow docs

## Summary

Tighten the portfolio’s **measurement** teaching: Impeller + in-app frame hooks
and common mistakes (rebuild ≠ jank; measure before isolate) now live on the
jank triage canon, with an index row for the official → repo map.

## Changes

- [`docs/performance/finding_jank_cause.md`](../performance/finding_jank_cause.md):
  Impeller note, `FrameTimingMonitor` / overlay / profiler pointers, common
  mistakes table, Integration_test perf path in the repo map.
- [`docs/performance/README.md`](../performance/README.md): “How to measure”
  index row.

## Non-goals

No new benchmark suites, `flutter drive` farms, or unmeasured code opts.
