# Self-improving agent loop (map to existing owners)

## What changed

Additive teaching only (no new parallel memory stack):

- [`docs/agent_kb/self_improvement.md`](../agent_kb/self_improvement.md) —
  after-run loop table; learn-from-success; critic = evidence review (not
  self-score); reject Redis/vector agent memory products.
- [`docs/agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) —
  memory-by-purpose map + keep/skip table for this portfolio.
- Thin pointers: HITL map, operator prefs success bullet, [`tasks/lessons.md`](../../tasks/lessons.md)
  success routing, skill_routing playbook cue.

## Why

External “self-improving agent” thesis matched existing AIDLC / finish gates /
lessons / skills / prefs, but underweighted **success promotion** and lacked an
explicit purpose→store map (agents might invent Redis/Postgres/vector infra).
Same additive bar as the agentic-SDLC stakes spectrum (#995).

## Verification

Docs-only. Run:

```bash
./tool/check_agent_knowledge_base.sh
./tool/check_agent_memory_compounding.sh
```

## Rollback

Revert this note and the listed owner-doc edits.
