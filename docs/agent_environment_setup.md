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

**Cursor Marketplace plugins** (Figma, Firebase, BrowserStack, Context7, Superpowers, Compound Engineering, etc.): install or update from **Settings → Plugins** or [cursor.com/marketplace](https://cursor.com/marketplace). There is no repo script for marketplace plugins.

**Global agent skills** (Flutter, Dart, iOS, AI workflow) use the [skills CLI](https://skills.sh/) via repo scripts. Official Flutter/Dart skills are optional task blueprints, not repo policy — read repo canon first; repo docs and scripts win on conflicts.

Requires Node.js (`npx`). Installs under `~/.agents/skills/` and links them to **Cursor** (`-g -a cursor`).

```bash
# Default: Dart + Flutter (+ legacy local copies) + iOS + AI workflow bundles
bash tool/install_global_agent_skills.sh

# Subsets
bash tool/install_global_agent_skills.sh --dart-only
bash tool/install_global_agent_skills.sh --flutter-only
bash tool/install_global_agent_skills.sh --ios-only
bash tool/install_global_agent_skills.sh --ai-only

# Preview commands only
bash tool/install_global_agent_skills.sh --dry-run

# Refresh installed globals
bash tool/update_global_agent_skills.sh
bash tool/update_global_agent_skills.sh --check   # report-only

# Search catalog before ad-hoc installs
bash tool/find_global_agent_skills.sh flutter
bash tool/find_global_agent_skills.sh ios swift
```

After install or update, reload Cursor (**Developer: Reload Window**). List globals: `npx skills list -g`.

Ad-hoc single skill:

```bash
npx skills add <owner/repo@skill> -g -a cursor -y
```

Notes:

- Repo-managed skills from `./tool/sync_agent_assets.sh` stay thin and project-specific; they are separate from vendor globals.
- Upstream skill repos drift; use `--dry-run` or `bash tool/find_global_agent_skills.sh` before bulk installs.
- Legacy `flutter/*` skills removed from `flutter/skills` upstream may still exist locally; the install script re-links them to Cursor when `~/.agents/skills/<name>/SKILL.md` is present.
- If a vendor skill becomes high-frequency and bloats context or conflicts with repo rules, add a repo-owned shim through `tool/agent_host_templates/` instead of editing host copies by hand.

**Trim duplicates** (after bulk install; lowers skill-list token cost):

```bash
# Preview (~27 agent copies when Cursor already has the same name)
bash tool/trim_duplicate_agent_skills.sh

# Apply balanced dedupe (keeps ~/.cursor/skills, archives agents copy)
bash tool/trim_duplicate_agent_skills.sh --apply

# Flutter-first: also drop legacy flutter/* + flat swift-ios kit noise
bash tool/trim_duplicate_agent_skills.sh --mode full --apply
```

Restore from `~/.agents/skills/.archived/<timestamp>/`. Regenerate inventory: `dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json`.

## Cursor indexing (context load)

Local `.cursorignore` excludes Flutter tooling noise (`.dart_tool/`, `build/`, `coverage/`, etc.) from Cursor indexing; it is machine-local and gitignored. Prefer a **small MCP set** for daily work (see "Enable useful MCP/connectors"); widen only for infra/deploy tasks. Skill/token budgets: `./bin/checklist-fast` resolves the newest `docs/audits/skill_inventory_*.json` and runs `tool/check_skill_budgets.sh` (report-only).

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
