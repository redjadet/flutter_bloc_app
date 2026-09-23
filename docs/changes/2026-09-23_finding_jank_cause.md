# Finding jank cause (DevTools under the hood)

**Date:** 2026-09-23

## Why

Agents and reviewers need a shared measure-first path: jank is a symptom;
identify UI vs Raster (or the limiting span) before changing code. Automated
frame captures prove budget misses; profile-mode DevTools still owns cause
attribution.

## In

- Canon: [`docs/performance/finding_jank_cause.md`](../performance/finding_jank_cause.md)
- Entry: `bash tool/triage_jank.sh` (`--latest` / report path; exit codes documented)
- `tool/analyze_perf_trace.py --triage` (auto-prints on gate fail; pressure =
  gate fail or `>16.7ms`; `report_only` withholds pass/fail claims)
- Agent hooks: `AGENTS.md`, [`skill_routing.md`](../ai/skill_routing.md),
  [`validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md),
  [`ai_code_review_protocol.md`](../ai_code_review_protocol.md), quick-ref /
  checklist / hubs / operator prefs
- Slim pointer from
  [`docs/performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md)

## Out / not in this change

- New automated UI-vs-Raster split from simulator Timeline (still DevTools /
  physical profile)
- Changing `perf_budgets.json` thresholds
