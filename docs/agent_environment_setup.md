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

Official Flutter/Dart Agent Skills are optional task blueprints, not repo
policy. Use them for generic workflows (widget tests, routing, layout,
localization, JSON, package conflicts, static analysis) after reading repo
canon. Repo docs and scripts win on conflicts.

Install/update only when the host supports `.agents/skills`, Node/npm is
available, and the user wants vendor skills in the workspace:

```bash
npx skills add flutter/skills --skill '*' --agent universal
npx skills add dart-lang/skills --skill '*' --agent universal
npx skills update
```

Notes:

- Compatible agents discover `.agents/skills`; current repo-managed skills stay
  thin and project-specific.
- On this machine, global installs with `npx skills add flutter/skills` /
  `dart-lang/skills` plus `-g` materialize under `~/.agents/skills/`.
- Upstream skill repos drift; check their README/docs before bulk install.
- If a vendor skill becomes high-frequency and bloats context or conflicts with
  repo rules, add a repo-owned shadow shim through `tool/agent_host_templates/`
  instead of editing host copies by hand.

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
