# Agent Host Notes

Host-specific reminders. Repo canon still starts at [`../AGENTS.md`](../AGENTS.md)
and [`agent_knowledge_base.md`](agent_knowledge_base.md).

## Codex

- Use [`../tasks/codex/todo.md`](../tasks/codex/todo.md) for non-trivial active work.
- Dart/Flutter MCP: `codex mcp add dart -- dart mcp-server --force-roots-fallback`
  (repo host config may also set `cwd` and `FLUTTER_SDK`). Smoke:
  `node script/mcp_smoke_dart.js`, then verify with `mcp__dart.roots` +
  `mcp__dart.analyze_files`.
  Note: `dart mcp-server` speaks **newline-delimited JSON-RPC** (NDJSON), not `Content-Length` framing.
- Don't invoke `./tool/request_codex_feedback.sh` from Codex unless user
  explicitly asks for second opinion or cross-host review.
- If user explicitly asks for second opinion after material edits to agent-facing docs or
  [`tool/agent_host_templates/cursor/rules/agent-execution.mdc`](../tool/agent_host_templates/cursor/rules/agent-execution.mdc)
  (copy to gitignored `.cursor/rules/` with `alwaysApply: true`),
  Cursor may run `./tool/request_codex_feedback.sh` before merge.

## Cursor

- Use [`../tasks/cursor/todo.md`](../tasks/cursor/todo.md) for non-trivial active work.
- Keep slash commands thin wrappers over repo scripts.

## Delegation

- Subagents are draft-producing helpers only: bounded scope, disjoint writes,
  main agent owns review and verification.

## Agent doc edit loop

Edit repo canon first ([`AGENTS.md`](../AGENTS.md), `docs/*`, `tool/agent_host_templates/`), run
`./tool/check_agent_knowledge_base.sh` and `./tool/check_agent_memory_compounding.sh`,
then `./tool/sync_agent_assets.sh --dry-run`, `./tool/sync_agent_assets.sh --apply`,
dry-run clean, and `./tool/check_agent_asset_drift.sh`.
Re-measure with `dart run tool/skill_inventory.dart` → `docs/audits/skill_inventory_latest.json`.
