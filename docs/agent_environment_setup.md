# Agent Environment Setup

Goal: reproducible Codex/Cursor runs. Prefer repo scripts and repo-managed host assets over ad-hoc global tweaks.

## One-Time

### 1. Sync repo-managed agent assets

Cursor/Codex skills, commands, rules, and maps live under `tool/agent_host_templates/`.

```bash
./tool/sync_agent_assets.sh --apply
./tool/check_agent_asset_drift.sh
```

### 2. Enable useful MCP/connectors

Enable only tools you will use; disabled stale servers create noise.

Suggested for this Flutter repo (Cursor MCP settings):

- `user-dart` (Flutter/Dart tooling + run/analyze/test)
- `plugin-context7-plugin-context7` (docs retrieval for drift-prone APIs)
- `cursor-ide-browser` (runtime proof, screenshots)
- optional: `user-playwright` (repeatable browser flows)
- optional: `user-github` (PRs/comments/checks)

If a server needs auth, complete it once. Keep tokens out of prompts and repo files.

### 3. Install plugins/skills by capability

Prefer tools that observe or verify real state over prompt packs.

High-signal categories: GitHub/CI, browser automation, docs retrieval, observability, deploy, design, security, and project-specific delivery skills.

## Per Session

Print the canon + validation pointers:

```bash
bash tool/agent_session_bootstrap.sh
```

## Verification Pipelines

Use the narrowest honest lane:

- Docs/tooling: `./bin/checklist-fast`
- Router/auth/gates: `./bin/router_feature_validate`
- Integration journeys: `./bin/integration_tests`
- Broad/high-risk: `./bin/checklist`
- Agent assets: `./tool/check_agent_knowledge_base.sh` + `./tool/check_agent_asset_drift.sh`

## Memory System

Where durable facts belong:

- Tier 1, current context: current diff, errors, acceptance proof.
- Tier 2, session memory: [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) / [`tasks/codex/todo.md`](../tasks/codex/todo.md).
- Tier 3, project memory: `docs/changes/`, `docs/plans/`, ADRs, tests, tool scripts.
- Tier 4, index: code-review-graph + targeted search, then raw reads before edits.

Rule: no chat-only durable conclusions. Promote validated repeats into the owning doc/test/script.
