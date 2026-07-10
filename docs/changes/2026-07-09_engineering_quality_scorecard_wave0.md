# 2026-07-09 — Engineering quality scorecard (Wave 0)

Added a measured **Engineering X/10** scorecard for portfolio-honest “top-tier”
quality claims, distinct from the existing **Harness 10/10** score (agent tooling
wiring).

## What changed

- New owner doc: [`docs/engineering/engineering_quality_scorecard.md`](../engineering/engineering_quality_scorecard.md)
- New badge automation:
  - `tool/update_engineering_quality_badge.sh`
  - `tool/check_engineering_quality_scorecard_gate.sh`
  - `tool/check_engineering_core_coverage.sh`
- Agent closeout wiring: `./bin/agent-maintain engineering-maintain` runs when
  scorecard paths are touched (via `scope_has_engineering_edits`).

## Why

README badges and audits already provide strong signals, but agents could
conflate “harness completeness” with “app engineering completeness”.
This scorecard makes the claim measurable and prevents over-claiming.

## Proof (docs/tooling lane)

```bash
./bin/checklist-fast --no-reuse
bash tool/check_engineering_quality_scorecard_gate.sh
bash tool/update_engineering_quality_badge.sh --check
```
