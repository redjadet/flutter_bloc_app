# Cursor Task Tracker

## Goal

Keep active Cursor tracker short; preserve older tracker content in history.

## Write-set

- `tasks/cursor/todo.md`
- `tasks/cursor/history/2026-06-02_pre_line_budget_todo.md`

## Risks

- Losing past tracker context.

## Validation command

```bash
bash tool/validate_task_trackers.sh
git diff --check -- tasks/cursor/todo.md
```

## Evidence/result

- Completed: previous active tracker moved to
  `tasks/cursor/history/2026-06-02_pre_line_budget_todo.md`.
