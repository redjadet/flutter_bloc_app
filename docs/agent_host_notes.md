# Agent Host Notes

Host-specific reminders. Repo canon still starts at [`../AGENTS.md`](../AGENTS.md)
and [`agent_knowledge_base.md`](agent_knowledge_base.md).

## Codex

- Use [`../tasks/codex/todo.md`](../tasks/codex/todo.md) for non-trivial active work.
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

Edit repo canon first ([`AGENTS.md`](../AGENTS.md), `docs/*`, `tool/agent_host_templates/`), then
`./bin/agent-maintain after-host-edit` when templates changed (or `./bin/agent-maintain kb` for
agent-map-only edits), and `./bin/agent-maintain closeout` before claiming host/docs work done.
Low-level equivalent: `./tool/check_agent_knowledge_base.sh`, `./tool/check_agent_memory_compounding.sh`,
inspect with `./tool/sync_agent_assets.sh --dry-run`, reconcile with `./bin/agent-maintain sync --apply`.
Sync includes project-only `agent-execution.mdc` in the active workspace; global
Cursor rules remain limited to the registered host-neutral rules.
Policy: [`docs/agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md).
Re-measure with `dart run tool/skill_inventory.dart` → `docs/audits/skill_inventory_latest.json`.
