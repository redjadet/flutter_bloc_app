# Critical human engineering skills guide

## Why

Repository documentation covered architecture, review, testing, security,
debugging, product context, production operations, and agent governance in
separate owner documents. It lacked one discoverable English guide connecting
these practices as human skills with observable evidence.

## Change

- Added [`engineering/critical_human_skills.md`](../engineering/critical_human_skills.md) covering twelve critical
  skills requested by the project owner.
- Defined behaviors, questions, evidence, failure boundaries, and repository
  owner links for each skill.
- Made human ownership explicit for product decisions, risk acceptance,
  production outcomes, and supervision of AI-generated work.
- Linked the guide from the main documentation index, engineering
  index, change-history index, and agent operating manual (human-skills
  theme). Intentionally not linked from [`AGENTS.md`](../../AGENTS.md) — that
  map stays agent-facing; this guide targets humans.

## Ownership

The new guide is a synthesis and navigation owner for human engineering skills.
Deep technical rules remain in existing architecture, review, security,
testing, observability, governance, and agent-policy documents. Future edits
should update those deep owners first, then adjust this guide when navigation or
the shared evidence standard changes.

## Validation

```bash
bash tool/check_docs_gardening.sh --paths \
  docs/engineering/critical_human_skills.md docs/engineering/README.md \
  docs/README.md docs/ai/agent_operating_manual.md \
  docs/changes/README.md docs/changes/2026-09-07_critical_human_skills.md
bash tool/check_agent_knowledge_base.sh
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```
