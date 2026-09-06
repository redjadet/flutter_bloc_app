# Agent Host Notes

Host-specific deltas only. Canonical load order starts at
[`../AGENTS.md`](../AGENTS.md) and [`ai/context_loading.md`](ai/context_loading.md).

## Codex

- Use [`../tasks/codex/todo.md`](../tasks/codex/todo.md) for non-trivial active work.
- Project [`AGENTS.md`](../AGENTS.md) is worktree-scoped and is **not** synced into
  the Codex home AGENTS file under `~/.codex/`. That home file is unmanaged user
  config: keep it a short host-neutral pointer to the nearest repository map, or
  omit project rules entirely. Do not overwrite, delete, or re-sync it unless the
  human explicitly authorizes that host change. Prefer the repository (or active
  worktree) map when instructions conflict.
- Dart/Flutter MCP: `codex mcp add dart -- dart mcp-server --force-roots-fallback`
  (repo host config may also set `cwd` and `FLUTTER_SDK`). Smoke:
  `node script/mcp_smoke_dart.js`, then verify with `mcp__dart.roots` +
  `mcp__dart.analyze_files`. Runtime errors (debug app): `bash tool/check_runtime_errors.sh`
  or `node script/mcp_runtime_errors.js --self-test`.
  Note: `dart mcp-server` speaks **newline-delimited JSON-RPC** (NDJSON), not `Content-Length` framing.
- Don't invoke `./tool/request_codex_feedback.sh` from Codex unless user
  explicitly asks for second opinion or cross-host review.
- If user explicitly asks for second opinion after material edits to agent-facing docs or
  [`tool/agent_host_templates/cursor/rules/agent-execution.mdc`](../tool/agent_host_templates/cursor/rules/agent-execution.mdc)
  (sync manages its gitignored `.cursor/rules/` copy with `alwaysApply: true`),
  Cursor may run `./tool/request_codex_feedback.sh` before merge.

## Cursor

- Use [`../tasks/cursor/todo.md`](../tasks/cursor/todo.md) for non-trivial active work.
- Keep slash commands thin wrappers over repo scripts.

## Delegation

- Subagents are draft-producing helpers only: bounded scope, disjoint writes,
  main agent owns review and verification.

## Agent doc edit loop

Edit repo canon first; follow
[`host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md).
Re-measure host skills through
[`operations_host_skills.md`](validation_scripts/operations_host_skills.md).
