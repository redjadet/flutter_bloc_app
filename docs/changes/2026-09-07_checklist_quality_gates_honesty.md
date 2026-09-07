# Checklist / quality-gates honesty refresh (2026-09-07)

## Summary

Re-synced checklist quality-gate docs with live `CHECK_SCRIPTS`, collapsed the
deferred backlog to **open-only** items, and hardened the Engineering scorecard
gate so promoted fail gates cannot drift back into “deferred” claims.

## Why

Agents reading
[`engineering/checklist_quality_gates_baseline.md`](../engineering/checklist_quality_gates_baseline.md)
still saw `check_context_read_watch`, `check_deferred_heavy_routes`, and
`check_lifecycle_observer_dispose` listed as deferred, and a stale
`CHECK_SCRIPT_THEMES` entry count (59), while those gates are already fail-wired
(~82 scripts). That mis-route wasted time and undercut scorecard honesty.

## Changes

- [`engineering/checklist_quality_gates_deferred.md`](../engineering/checklist_quality_gates_deferred.md) — shipped table + open backlog only (`QG-D01`, `QG-D03` warn, `QG-D08`, rejects)
- [`engineering/checklist_quality_gates_baseline.md`](../engineering/checklist_quality_gates_baseline.md) — post-MVP status + corrected theme/deferred-route notes
- Local gitignored plans mirror retargeted to pointer-only (same pattern as deferred plans mirror; tracked redirect: [`plans/README.md`](../plans/README.md))
- [`validation_scripts/catalog.md`](../validation_scripts/catalog.md) — fail-gate wording
- `tool/check_engineering_quality_scorecard_gate.sh` — baseline/deferred/`CHECK_SCRIPTS` honesty guards
- [`engineering/engineering_quality_scorecard.md`](../engineering/engineering_quality_scorecard.md) — Quality gates honesty proof text
- [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) + `ai/reports/*` — refresh `git_head` so harness `--strict-head` fixtures pass on current HEAD
- [`CODE_QUALITY.md`](../CODE_QUALITY.md) — catalog section pointer (heading renamed)
- `tool/delivery_checklist.sh` — allow `ai/**` on `checklist-fast` / docs-only path (AI snapshot refresh is harness docs, not app/runtime)
- [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md) — docs/tooling matrix includes `ai/**`

## Not changed (by design)

- No new fail gates; `QG-D03` stays warn-only / not in `CHECK_SCRIPTS`
- No `CHECK_THEME` subset runner yet (still ADR-deferred; needs safety tests)
- Checklist static-check runtime: keep parallel `CHECKLIST_JOBS` (cap 8); prefer per-script auto-skip over dropping fail gates
