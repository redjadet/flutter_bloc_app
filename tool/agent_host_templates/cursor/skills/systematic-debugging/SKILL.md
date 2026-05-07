---
name: systematic-debugging
description: Auto-use on errors/failures; preserve root-cause discipline.
---

# Systematic debugging

Use when bug/error/failing test/unexpected behavior.

Triggers (examples):

- “error”, “exception”, “stack trace”, “fails”, “flaky”, “regression”
- “why is this broken”, “debug”, “investigate”, “root cause”

Canon first:

- `AGENTS.md`
- `docs/agent_knowledge_base.md`
- `docs/reliability_error_handling_performance.md`

Hard gates:

- No fix without root cause. Evidence before change.
- Reproduce or isolate with smallest surface.

Workflow:

- Capture symptom + expected vs actual + repro steps.
- Narrow scope (file/feature) using map->docs->targeted search.
- Form 1–2 hypotheses; test with logs/assertions/minimal probe.
- Apply smallest reversible fix; verify with matching script/test.
