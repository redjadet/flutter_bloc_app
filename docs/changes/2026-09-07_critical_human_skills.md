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
- Added an uncertainty-containment standard with one shared four-question frame:
  protected rule, responsibility owner, partial-failure model, and enforcement
  paths (aligned across human-skills and reduce-surprise guides).
- Connected readability, testability, and reliability to inspectable ownership,
  falsifiable contracts, and explicit recovery behavior.
- Clarified the architecture split: domain owns reusable pure merge decisions;
  data owns I/O, ordering, retry, persistence, sync orchestration, and consistent
  policy invocation.
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
  docs/engineering/critical_human_skills.md \
  docs/architecture/reduce_surprise_patterns.md \
  docs/clean_architecture.md \
  docs/architecture/use_case_dto_policy.md \
  docs/adr/0001-architecture-and-layering.md \
  docs/adr/0002-offline-first-data.md \
  docs/review/architecture_checklist.md \
  docs/ai_code_review_protocol.md \
  docs/changes/2026-09-07_critical_human_skills.md
bash tool/check_agent_knowledge_base.sh
bash tool/check_ai_snapshot_freshness.sh
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```
