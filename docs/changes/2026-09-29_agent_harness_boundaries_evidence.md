# Agent harness: Boundaries + Evidence under stronger models

Sharpened existing harness doctrine after fact-checking operator guidance:
stronger models may need less *prompt scaffolding*, but Boundaries and Evidence
become more important—not less.

## What changed

- [`agent_knowledge_base.md`](../agent_knowledge_base.md) — harness-vs-model belief
  + Prompt Hygiene: measure before removing scaffolding; never drop gates/evidence
- [`ai/harness_auto_maintenance.md`](../ai/harness_auto_maintenance.md) —
  scaffolding vs durable Boundaries/Evidence table; optimization triggers
- [`ai/harness_scorecard.md`](../ai/harness_scorecard.md) — Surfaces rows for
  Boundaries and Evidence / reconstructability
- [`agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md)
  + [`agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md) —
  ~10 minute run reconstructability bar (points at existing artifacts)
- [`ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md) — proof column
  pointer

No new essay file; no scorecard area score changes.

## Verification

```bash
bash tool/check_agent_knowledge_base.sh
bash tool/check_agent_safety_contracts.sh
bash tool/check_harness_scorecard_gate.sh
bash tool/refresh_ai_reports.sh   # unblocks docs-only fixtures (--strict-head)
./bin/checklist-fast --no-reuse
./bin/agent-maintain harness-maintain
```

Also refreshed stale `ai/` discovery snapshot frontmatter (`git_head` → current
`HEAD`) so harness fixtures pass `--strict-head` on docs-only CI.