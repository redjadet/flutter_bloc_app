---
name: agents-cursor-integration
description: Cursor integration pointer for Flutter BLoC app. Use when editing repo rules, shared Cursor adapters, or Cursor/Codex review wiring.
---

# Cursor integration

Repo does **not** commit `.cursor/*` in this project. Cursor agent assets are
managed via repo templates and synced into the user’s Cursor profile.

Sources of truth:

- Templates: `tool/agent_host_templates/cursor/**`
- Sync script: `./tool/sync_agent_assets.sh` (mapping: `tool/agent_asset_lib.sh`)

Host targets (written by sync):

- `~/.cursor/skills/*`
- `~/.cursor/commands/*`
- `~/.cursor/rules/agents-global.mdc`

Repo canon wins. Adapters point back to `AGENTS.md`,
`docs/agent_knowledge_base.md`, `docs/agents_quick_reference.md`,
`docs/ai_code_review_protocol.md`, and repo shell helpers under `tool/`.

Rules: keep `.mdc` short; update repo templates, not host copies. Template
change => sync + drift check. Multi-agent extensions stay in
`agents-delivery-workflow` + `agents-meta-behavior`; no `agents-team-*` unless
size forces split. Doctrine: `docs/agent_knowledge_base.md#multi-agent-hub`.

Team run artifacts live under coordinator-only `tasks/cursor/team/<run-id>/`.
Track via `tasks/cursor/todo.md`; never promote run dirs into shared adapters.

Review: use `./tool/request_codex_feedback.sh` only for bounded cross-host diff
review; don’t self-delegate. `/codex-feedback` stays thin wrapper. Use
`caveman-compress` repo wrapper for agent-doc compression; no Claude auth.
