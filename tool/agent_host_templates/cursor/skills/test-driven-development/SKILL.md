---
name: test-driven-development
description: Auto-use for testable behavior changes; keep TDD pragmatic.
---

# Test-driven development

Use when implementing behavior change that can be tested.

Triggers (examples):

- “add tests”, “write a test”, “regression test”, “cover this”
- “implement feature”, “bugfix”, “prevent regression”

Canon first:

- `AGENTS.md`
- `docs/testing_overview.md`
- `docs/agent_knowledge_base.md`

Hard gates:

- Prefer failing test first when feasible.
- If test-first is too costly (UI polish, infra), document why and add a later guard.

Workflow:

- Write minimal failing test (unit/widget/integration as appropriate).
- Implement smallest change to pass.
- Refactor if needed, keep tests green.
