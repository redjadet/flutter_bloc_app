# AI failure risk minimization (2026-06-08)

## Why

Agents still hit async lifecycle, offline merge, integration seams, and
security gaps even with architecture gates. Risk register needed earlier
routing, richer IDs, and a stronger static gate.

## What changed

- [`ai/ai_failure_risks.md`](../ai/ai_failure_risks.md): Pre-Flight, Priority tiers, four new risks
  (`RISK-ASYNC-LIFECYCLE`, `RISK-OFFLINE-OVERWRITE`, `RISK-INTEGRATION-SEAM`,
  `RISK-SECURITY-GAP`), expanded Minimum proof by task.
- `tool/check_ai_failure_risk_register.sh`: requires preflight sections, new
  risk IDs, detection scripts, and security/reference tokens.
- Entry wiring: [`AGENTS.md`](../../AGENTS.md), [`ai/context_loading.md`](../ai/context_loading.md),
  [`ai/skill_routing.md`](../ai/skill_routing.md), [`agents_quick_reference.md`](../agents_quick_reference.md),
  `.cursor/rules/agent-execution.mdc`.
- Host skills: expanded `agents-common-pitfalls` (pitfall → risk map);
  `agents-feature-delivery` and `agents-validation-testing` read register first.
- `tool/check_harness_scorecard_gate.sh`: enforces preflight wiring and
  `agents-common-pitfalls` skill file.

## Proof

```bash
bash tool/check_ai_failure_risk_register.sh
bash tool/check_harness_scorecard_gate.sh
bash tool/run_harness_fixtures.sh
./bin/agent-maintain after-host-edit
```
