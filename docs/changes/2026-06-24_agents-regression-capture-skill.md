# agents-regression-capture skill

**Date:** 2026-06-24

## Why

Operationalize Missing Capability Loop for post-fix hardening — turn unique bugs
into regression tests, static guards, checklist wiring, and lessons so the same
failure class is caught early.

## What shipped

- Skill: [`tool/agent_host_templates/shared/skills/agents-regression-capture/SKILL.md`](../../tool/agent_host_templates/shared/skills/agents-regression-capture/SKILL.md)
- Routing: [`ai/skill_routing.md`](../ai/skill_routing.md), `agents-skill-routing`, `agents-validation-testing`
- Finish gate: `agents-delivery-workflow` step 2 (before report)
- Cross-refs: `systematic-debugging`, `verification-before-completion`
- Harness needles: `tool/check_harness_scorecard_gate.sh`, `tool/check_agent_knowledge_base.sh`
- Sync: `tool/agent_asset_lib.sh` (Cursor + Codex)

## Verification

```bash
bash tool/check_agent_knowledge_base.sh
bash tool/check_harness_scorecard_gate.sh
./bin/agent-maintain after-host-edit
```
