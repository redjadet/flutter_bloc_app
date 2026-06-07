# Agent doc dedup (2026-06-08)

## Why

Reduce redundant prose across frequently loaded agent files while keeping
`check_agent_knowledge_base.sh` and `check_harness_scorecard_gate.sh` needles.

## Changes

- Fixed [`tool/agent_host_templates/cursor/commands/agent-maintain.md`](../../tool/agent_host_templates/cursor/commands/agent-maintain.md) doc link
  (`../../../../docs/...`).
- [`AGENTS.md`](../../AGENTS.md): Start no longer duplicates Pre-Flight (Loop owns it); Map
  `Harness` → `Doctrine`; Must Keep host line points to owner doc; Loop Pre-Flight
  sentence merged (review fix).
- [`harness_auto_maintenance.md`](../ai/harness_auto_maintenance.md): harness-only
  loop; preflight/closeout → host maintenance doc.
- Thinned echoes: delivery-workflow skill, quick ref host row, agent-maintain
  command.
- [`ai_failure_risks.md`](../ai/ai_failure_risks.md): footnote on `../../tool` vs
  repo-root paths.
- [`audits/dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md): 2026-06-08 pass; Stale → Echo for
  gate-required quick-ref rows.

## Proof

```bash
bash tool/check_agent_knowledge_base.sh
bash tool/check_harness_scorecard_gate.sh
bash tool/check_ai_failure_risk_register.sh
bash tool/run_harness_fixtures.sh
./bin/agent-maintain after-host-edit
```
