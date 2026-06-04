# Validation scripts — host skills

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Agent maintain (unified entry)

Purpose: one command for host upkeep and composed workflows instead of ad-hoc shell chains.

```bash
./bin/agent-maintain help
./bin/agent-maintain list
./bin/agent-maintain preflight              # agents: non-trivial task start
./bin/agent-maintain closeout               # before task finish (alias: auto)
./bin/agent-maintain after-host-edit        # after tool/agent_host_templates/** edits
./bin/agent-maintain session
./bin/agent-maintain sync [--apply]         # dry-run warns on drift; --apply is strict
./bin/agent-maintain kb
./bin/agent-maintain docs-sync              # scope validation tooling + markdown docs
./bin/agent-maintain routine [--apply]
./bin/agent-maintain host-full --apply      # network; requires --apply
```

Implementation: `tool/agent_maintain.sh`. Wrapper: `bin/agent-maintain`. Cursor slash command: `/agent-maintain`.

| Preset | What it runs |
| --- | --- |
| `routine` | sync dry-run + drift warn; `routine --apply` sync `--apply` + **strict** drift, `update --check`, memory `--verify`, budget report (if inventory exists) |
| `preflight` | session bootstrap, drift (warn), task trackers |
| `closeout` / `auto` | `preflight`; scope `docs-sync`; templates in scope → `after-host-edit`; else agent-map → `kb` |
| `docs-sync` | `fix_validation_docs.sh` + `validate_validation_docs.sh` when `tool/agent_maintain.sh`, `bin/agent-maintain`, checklist scripts, or `docs/**` in scope; link gardening via `agent_memory_auto_maintain.sh` |
| `after-host-edit` | `sync --apply` + strict drift + `kb` |
| `host-full` | `setup --apply --install --trim-mode full` (network; requires `--apply`) |

**Drift:** `check_agent_asset_drift.sh` is warn-only in `preflight`, `sync` dry-run, and `routine` (no `--apply`); **strict** after `sync --apply`, `routine --apply`, `after-host-edit`, or `closeout` / `auto` when templates are in scope. On failure: inspect with `./tool/sync_agent_assets.sh --dry-run`, then `./bin/agent-maintain sync --apply`.

**Not changed (by design):** contract smoke uses `AGENT_MAINTAIN_PLAN_ONLY=1` (no real `sync --apply` in CI); `closeout` steps are scope-gated; `docs-sync` does not author narrative docs; `check_design_md.sh` is warn-only inside `docs-sync`. Full table: [`host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md#not-changed-by-design).

Agent policy (when to run without user asking): [`docs/agent_kb/host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md).

Low-level commands (`install`, `update`, `find`, `trim`, `inventory`, `review`, …) forward to the existing `tool/*` scripts documented below.

## Global agent skills (host machine)

Purpose: install or update **global** vendor skills for Cursor (Flutter, Dart, iOS, AI workflow) via the [skills CLI](https://skills.sh/). Does not replace `./tool/sync_agent_assets.sh` (repo-managed Cursor/Codex adapters). Requires Node.js (`npx`).

Orchestrated host setup (`tool/setup_cursor_agent_environment.sh`; Cursor `/setup-cursor-agent-environment`; skill `agents-global-skills-setup`; or `./bin/agent-maintain setup`):

```bash
bash tool/setup_cursor_agent_environment.sh
bash tool/setup_cursor_agent_environment.sh --apply
bash tool/setup_cursor_agent_environment.sh --apply --install
bash tool/setup_cursor_agent_environment.sh --apply --sync-only
bash tool/setup_cursor_agent_environment.sh --apply --install --trim-mode full
```

Install default bundles (Dart, Flutter + legacy local copies when present, iOS, AI workflow):

```bash
bash tool/install_global_agent_skills.sh
```

Subset or preview:

```bash
bash tool/install_global_agent_skills.sh --dart-only
bash tool/install_global_agent_skills.sh --flutter-only --skip-legacy
bash tool/install_global_agent_skills.sh --ios-only
bash tool/install_global_agent_skills.sh --ai-only
bash tool/install_global_agent_skills.sh --dry-run
```

Update or check for updates:

```bash
bash tool/update_global_agent_skills.sh
bash tool/update_global_agent_skills.sh --check
```

Search catalog:

```bash
bash tool/find_global_agent_skills.sh flutter
```

Trim duplicate globals (dry-run by default; archives under `~/.agents/skills/.archived/`):

```bash
bash tool/trim_duplicate_agent_skills.sh
bash tool/trim_duplicate_agent_skills.sh --apply
bash tool/trim_duplicate_agent_skills.sh --mode full --apply
bash tool/trim_duplicate_agent_skills.sh --mode flutter-repo --apply
```

Modes: `balanced` (default; archive `~/.agents/skills` when `~/.cursor/skills` has the same name), `flutter-legacy`, `flutter-repo` (Flutter-only minimal set), `ios-minimal`, or `full` (balanced + flutter-legacy + ios-minimal). Plan JSON: `docs/audits/skill_trim_plan_latest.json`.

Policy and MCP/plugin notes: [`agent_environment_setup.md`](../agent_environment_setup.md).

## Skill budget check (agent context)

Purpose: detect accidental growth in **repo-managed** agent skills and provide a signal for local `~/.cursor/skills` and `~/.agents/skills` bloat. After bulk global installs, run `bash tool/trim_duplicate_agent_skills.sh` before regenerating inventory.

Note: this check is **manual-only** and is **not** part of the `./bin/checklist` `CHECK_SCRIPTS` index (it is report-only unless you opt into enforcement).

Inventory file is generated by:

```bash
dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json
```

Report-only budget check (default exit 0):

```bash
bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json report
```

Enforce budgets (exit non-zero on breach):

```bash
SKILL_BUDGET_REPO_TOKENS=12000 bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json enforce
SKILL_BUDGET_AGENTS_TOKENS=80000 bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json enforce
```

Rank skills after inventory (proxy score for “what to shrink next”):

```bash
dart run tool/skill_rank.dart docs/audits/skill_inventory_<yyyy-mm-dd>_ctxopt.json docs/audits/skill_rank_<yyyy-mm-dd>_ctxopt.json
```

`./bin/checklist-fast` resolves the newest dated `docs/audits/skill_inventory_*.json` when `skill_inventory_latest.json` is missing.

- auto-skips `flutter analyze` on local change sets with no Dart/analyzer-relevant files; CI and Dart/config/l10n changes still run it
- auto-skips Pyright Python lane on local non-Python change sets; CI and standalone `tool/check_pyright_python.sh` runs still execute it
- auto-skips offline-first remote-merge regression lane on local non-offline-first change sets; CI and standalone `tool/check_offline_first_remote_merge.sh` runs still execute it
- auto-selects smallest honest `tool/check_regression_guards.sh` test subset for local feature-scoped changes; CI, broad shared/core changes, and standalone runs still use full suite
- skips Mix lint unless Mix-related files changed
- when coverage is disabled, runs focused regression guards and only runs Todo keyboard/layout subset when current change set touches Todo/layout-relevant files
