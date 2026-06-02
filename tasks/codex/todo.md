# Codex Task Tracker

## Goal

Keep frequently used AI-agent documents at or below 200 lines without losing
important agent knowledge.

## Write-set

- `docs/agent_knowledge_base.md`
- `docs/agent_kb/self_improvement.md`
- `docs/changes/README.md`
- `docs/changes/2026-06-02_agent_self_improvement_stack.md`
- `tasks/codex/todo.md`
- `tasks/codex/history/2026-06-02_pre_line_budget_todo.md`
- `tasks/cursor/todo.md`
- `tasks/cursor/history/2026-06-02_pre_line_budget_todo.md`
- agent doc validation guard if needed

## Risks

- Dropping durable agent rules while shortening docs.
- Breaking existing anchor checks in `tool/check_agent_knowledge_base.sh`.
- Hiding useful tracker history instead of preserving it.

## Validation command

```bash
./tool/check_agent_knowledge_base.sh
bash tool/validate_task_trackers.sh
python3 ./tool/normalize_doc_links.py --check docs/agent_knowledge_base.md docs/agent_kb/self_improvement.md docs/changes/README.md docs/changes/2026-06-02_agent_self_improvement_stack.md tasks/codex/todo.md tasks/cursor/todo.md
git diff --check -- docs/agent_knowledge_base.md docs/agent_kb/self_improvement.md docs/changes/README.md docs/changes/2026-06-02_agent_self_improvement_stack.md tasks/codex/todo.md tasks/cursor/todo.md
./bin/checklist-fast --explain
```

## Evidence/result

- In progress: inventoried core agent docs, host skill docs, active trackers,
  and line counts.
- Completed: archived old active trackers under `tasks/*/history/` and replaced
  them with short canonical trackers.
