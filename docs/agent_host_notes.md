# Agent Host Notes

Host-specific reminders. Repo canon still starts at [`../AGENTS.md`](../AGENTS.md)
and [`agent_knowledge_base.md`](agent_knowledge_base.md).

## Codex

- Use [`../tasks/codex/todo.md`](../tasks/codex/todo.md) for non-trivial active work.
- Do not invoke `./tool/request_codex_feedback.sh` from Codex unless the user
  explicitly asks for second opinion or cross-host review.

## Cursor

- Use [`../tasks/cursor/todo.md`](../tasks/cursor/todo.md) for non-trivial active work.
- Keep slash commands thin wrappers over repo scripts.

## Delegation

- Subagents are draft-producing helpers only: bounded scope, disjoint writes,
  main agent owns review and verification.
