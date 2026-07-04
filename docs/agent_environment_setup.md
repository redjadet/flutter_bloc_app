# Agent Environment Setup

Goal: reproducible Codex/Cursor runs. Prefer repo scripts and repo-managed host assets over ad-hoc global tweaks.

## One-Time

### 1. Sync repo-managed agent assets

Cursor/Codex skills, commands, rules, and maps live under `tool/agent_host_templates/`.

```bash
./tool/sync_agent_assets.sh --apply   # also runs agent_memory_auto_maintain.sh --verify
./tool/check_agent_asset_drift.sh
```

Local agent-doc edits: `./tool/check_agent_knowledge_base.sh` runs safe link normalize via `agent_memory_auto_maintain.sh --if-changed` (skipped in CI). Opt-out: `AGENT_MEMORY_AUTO_MAINTAIN=0`.

### 2. Enable useful MCP/connectors

Enable only tools you will use; disabled stale servers create noise.

Suggested for this Flutter repo (Cursor MCP settings):

- `user-dart` (Flutter/Dart tooling: analyze, DTD, **`get_runtime_errors`**, hot reload — [`agent_kb/devtools_runtime_errors.md`](agent_kb/devtools_runtime_errors.md); **`read_package_uris`**, **`rip_grep_packages`**, `pub_dev_search` — [`agent_kb/package_docs_mcp.md`](agent_kb/package_docs_mcp.md))
- `plugin-context7-plugin-context7` (current library docs for drift-prone APIs — [`agent_kb/package_docs_mcp.md`](agent_kb/package_docs_mcp.md))
- `cursor-ide-browser` (runtime proof, screenshots)
- optional: `user-playwright` (repeatable browser flows)
- optional: `user-github` (PRs/comments/checks)

If a server needs auth, complete it once. Keep tokens out of prompts and repo files.

### 3. Install plugins/skills by capability

Prefer tools that observe or verify real state over prompt packs.

High-signal categories: GitHub/CI, browser automation, docs retrieval, observability, deploy, design, security, and project-specific delivery skills.

**Cursor Marketplace plugins** (Figma, Firebase, BrowserStack, Context7, Superpowers, Compound Engineering, etc.): install or update from **Settings → Plugins** or [cursor.com/marketplace](https://cursor.com/marketplace). There is no repo script for marketplace plugins.

**Flutter-first plugin slim-down (optional, biggest real context win):** Marketplace plugins load vendor skills into every session (~1M+ tokens in a typical install; see `docs/audits/vendor_plugin_inventory_latest.json`). That load is **not** counted in `skill_inventory_latest.json`. Audit:

```bash
bash tool/audit_vendor_plugin_skills.sh
```

Disable plugins you do not use this month under **Cursor → Settings → Plugins** (reversible). High-impact cuts for this repo (`recommendedForFlutter: false` in the audit): `compound-engineering`, `posthog`, `sentry`, `vercel`, `shopify-plugin`, `azure`, `harness`, `figma`, `huggingface-skills`, `render`, `superpowers`, `subtext`, `mongodb`, `atlassian`, `convex`. Keep what you need (e.g. Context7, Firebase, Supabase, BrowserStack, design tools).

**Habits (inventory, plugins, reload):** [`validation_scripts/operations_host_skills.md`](validation_scripts/operations_host_skills.md) § Suggested habits; snapshot commands in [`audits/README.md`](audits/README.md) § Habits.

**Global agent skills** (Flutter, Dart, iOS, AI workflow) use the [skills CLI](https://skills.sh/) via repo scripts. Official Flutter/Dart skills are optional task blueprints, not repo policy — read repo canon first; repo docs and scripts win on conflicts.

Requires Node.js (`npx`). Installs under `~/.agents/skills/` and links them to **Cursor** (`-g -a cursor`).

**Unified entry** (recommended; wraps setup, sync, globals, and composed workflows):

```bash
./bin/agent-maintain help
./bin/agent-maintain preflight                 # agents: run at non-trivial task start
./bin/agent-maintain closeout                  # agents: before claiming task done (alias: auto)
./bin/agent-maintain after-host-edit           # agents: after tool/agent_host_templates/** edits
./bin/agent-maintain docs-sync                 # agents: mechanical validation-doc + link sync (also in closeout when in scope)
./bin/agent-maintain routine --apply          # light upkeep: sync --apply + strict drift (no network install)
./bin/agent-maintain host-full --apply        # full install + trim (network)
```

**Automated host setup** (same orchestrator via `setup` or direct script; Cursor `/setup-cursor-agent-environment`):

```bash
./bin/agent-maintain setup                    # preview
./bin/agent-maintain setup --apply            # sync + drift check
./bin/agent-maintain setup --apply --install
./bin/agent-maintain setup --apply --install --trim-mode full

bash tool/setup_cursor_agent_environment.sh              # equivalent
bash tool/setup_cursor_agent_environment.sh --apply
bash tool/setup_cursor_agent_environment.sh --apply --install
bash tool/setup_cursor_agent_environment.sh --apply --install --trim-mode full
```

Flags: `--sync-only`, `--install`, `--trim`, `--trim-mode` (`balanced`|`full`), `--skip-trim`, `--skip-inventory`. VS Code tasks: **Agent maintain (routine preview/apply)**, **Cursor agent environment setup (preview)**.

**Agent automation policy:** [`docs/agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md) — when agents must run `preflight` / `closeout` / `after-host-edit` without the user asking.

Manual steps (same result, more control):

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

**Which skill to use:** [`docs/ai/skill_routing.md`](ai/skill_routing.md) (canonical task → skill table; repo canon wins over vendor skills). Synced shim: `agents-skill-routing`.

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

## Melos Pub workspace

The repo is a Melos-managed Pub workspace ([#437](https://github.com/redjadet/flutter_bloc_app/pull/437) pending merge to `main`):

- **Workspace root** — repo root (`pubspec.yaml` hosts `melos:` scripts; no standalone `melos.yaml`).
- **Flutter app** — `apps/mobile/` (`package:flutter_bloc_app`).
- **Shared packages** — `packages/*` (see [`agents_quick_reference.md`](agents_quick_reference.md) Melos table), `custom_lints/*`.
- **Firebase backend** — `backend/firebase/`.
- **Pub get** — from repo root: `bash tool/workspace_pub_get.sh` (workspace `dart pub get` + app `flutter pub get` for `generate: true` / l10n).
- **Run the app** — `cd apps/mobile && flutter run -t apps/mobile/lib/main_dev.dart`; root `flutter run -t apps/mobile/lib/main_dev.dart` works when `.envrc` puts `tool/direnv/bin` first in `PATH`.
- **Analyze / test the app** — `./tool/analyze.sh` / `bash tool/test_coverage.sh` from repo root (`workspace_paths.sh` resolves `apps/mobile`); narrow tests may use `cd apps/mobile && flutter test …`.
- **Authoritative gate** — `./bin/checklist` from **repo root** (unchanged).

Plan and phase status: [`docs/plans/melos_monorepo_migration_plan.md`](plans/melos_monorepo_migration_plan.md).

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
