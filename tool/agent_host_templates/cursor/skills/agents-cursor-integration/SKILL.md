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
- Global vendor skills (Flutter/Dart/iOS/AI): `bash tool/install_global_agent_skills.sh` · `docs/agent_environment_setup.md`

Host targets (written by sync): repo-managed skills include
`agents-quick-reference`, `agents-delivery-workflow`, `agents-meta-behavior`,
`agents-repo-context`, `agents-principles-baseline`, `agents-references`,
`agents-canonical-rules` (+ architecture/presentation/async/platform children),
`agents-validation-testing`, plus workflow helpers under `~/.cursor/skills/*`.

- `~/.cursor/commands/*`
- `tool/agent_host_templates/cursor/rules/agent-execution.mdc` → project `.cursor/rules/` (always-on)
- `~/.cursor/rules/agents-global.mdc` (optional depth; synced from templates)

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
