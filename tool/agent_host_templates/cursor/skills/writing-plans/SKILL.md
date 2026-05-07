---
name: writing-plans
description: Auto-use for multi-step work; keep plan small and executable.
---

# Writing plans

Use when task non-trivial (3+ steps), risky, or many files/systems.

Triggers (examples):

- “plan”, “break this down”, “implementation plan”, “approach”
- “refactor”, “migration”, “large change”, “touches many files”

Canon first:

- `AGENTS.md`
- `docs/agent_knowledge_base.md`
- `docs/engineering/validation_routing_fast_vs_full.md`

Hard gates:

- Plan once (<=10 lines). Don’t “plan forever”.
- Ask only hard blockers (credentials/tooling/unsafe ambiguity).

Plan checklist:

- Goal + non-goals + success criteria.
- Write set (exact files).
- Verification plan (which scripts/tests).
- Rollback notes if risky.
