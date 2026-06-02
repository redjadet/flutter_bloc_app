# Agent doc line budget

## What changed

High-frequency AI-agent docs now stay under 200 lines:

- [`agent_knowledge_base.md`](../agent_knowledge_base.md) routes self-improvement details to
  [`docs/agent_kb/self_improvement.md`](../agent_kb/self_improvement.md).
- Active trackers [`tasks/codex/todo.md`](../../tasks/codex/todo.md) and [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md) were reset
  to short current trackers.
- Previous tracker content moved to `tasks/codex/history/` and
  `tasks/cursor/history/`.
- [`tool/check_agent_knowledge_base.sh`](../../tool/check_agent_knowledge_base.sh)
  enforces the 200-line budget for frequent agent docs and active trackers.

## Why

Frequently loaded agent files should stay small enough for predictable context
loading. Historical content remains available outside hot-path files.

## Verification

Use:

```bash
./tool/check_agent_knowledge_base.sh
bash tool/validate_task_trackers.sh
./bin/checklist-fast --explain
```

## Rollback

Restore the archived tracker files to `tasks/*/todo.md`, inline
self-improvement rules back into [`agent_knowledge_base.md`](../agent_knowledge_base.md), and remove the
line-budget guard if the repo intentionally allows larger hot-path docs.
