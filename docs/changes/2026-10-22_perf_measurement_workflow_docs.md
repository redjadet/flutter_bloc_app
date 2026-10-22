# Performance measurement workflow docs

## Summary

Tighten the portfolio’s **measurement** teaching: Impeller + in-app frame hooks
and common mistakes (rebuild ≠ jank; measure before isolate) now live on the
jank triage canon, with discoverable entry points from AGENTS / quick reference /
review checklist / `triage_jank.sh`.

## Changes

- [`docs/performance/finding_jank_cause.md`](../performance/finding_jank_cause.md):
  Impeller note, `FrameTimingMonitor` / overlay / profiler pointers, common
  mistakes table, measure-first path, Integration_test perf path in the repo map.
- [`docs/performance/README.md`](../performance/README.md): single “Measure first”
  index row (merged duplicate jank/measure rows).
- Entry points: [`AGENTS.md`](../../AGENTS.md), [`agents_quick_reference.md`](../agents_quick_reference.md),
  [`docs/README.md`](../README.md), [`review/performance_checklist.md`](../review/performance_checklist.md),
  `tool/triage_jank.sh` header + printed map (Impeller / overlay).

## Non-goals

No new benchmark suites, `flutter drive` farms, or unmeasured code opts.
