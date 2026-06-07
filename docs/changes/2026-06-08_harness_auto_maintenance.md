# Harness auto-maintenance for max score

## Why

Host-only or harness-doc edits could finish without running the scorecard gate
when `docs-sync` did not apply. Agents needed an explicit, scope-driven loop to
preserve 10/10 harness wiring.

## What

- Added [`docs/ai/harness_auto_maintenance.md`](../ai/harness_auto_maintenance.md)
  (agent loop, scope table, optimization triggers).
- `tool/agent_maintain.sh`: `scope_has_harness_edits`, `harness-maintain` command,
  closeout/preflight harness scope logging and gate execution.
- `RISK-HARNESS-SCORE-DROP` in [`ai_failure_risks.md`](../ai/ai_failure_risks.md).
- Wired AGENTS.md, scorecard, host maintenance doc, delivery/meta skills, gates,
  checklist CLI contract fixture.

## Proof

```bash
bash tool/check_ai_failure_risk_register.sh
bash tool/check_harness_scorecard_gate.sh
bash tool/run_harness_fixtures.sh
./bin/checklist-fast --no-reuse
./bin/agent-maintain after-host-edit   # when host templates touched
```
