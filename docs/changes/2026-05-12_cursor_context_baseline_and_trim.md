# Cursor context baseline and always-on trim

## Why

Execute Cursor context optimization plan: measure default surfaces, shrink always-on rules and repo-managed host skills, add local `.cursorignore`, refresh skill inventory. Detailed tables also live under [`audits/cursor_context_baseline_2026-05-12.md`](../audits/cursor_context_baseline_2026-05-12.md) **locally** (`docs/audits/` is gitignored for machine snapshots; this `docs/changes/` entry is the **committed** summary).

## What changed

- Local baseline + skill JSON: [`audits/cursor_context_baseline_2026-05-12.md`](../audits/cursor_context_baseline_2026-05-12.md), `docs/audits/skill_inventory_2026-05-12_ctxopt.json`, `docs/audits/skill_rank_2026-05-12_ctxopt.json` (regenerate with `dart run tool/skill_inventory.dart` / `dart run tool/skill_rank.dart`).
- `.cursor/rules/agent-execution.mdc` local working copy: shorter always-on text (1311 -> 873 B); pointers to [`AGENTS.md`](../../AGENTS.md), AKM, quick reference (no validation loosening). This path is gitignored with the rest of `.cursor/*`; committed behavior lives in repo-managed host templates and source docs.
- `.cursorignore` local working copy: Flutter cache paths for Cursor indexing. This file is gitignored; committed guidance lives in [`docs/agent_environment_setup.md`](../agent_environment_setup.md).
- Host templates: thinner `agents-delivery-workflow`, `agents-meta-behavior`, `upgrade-pr-triage-validate` (Cursor); `flutter-bloc-app-delivery-workflow` (Codex). Kept **memory-compounding** literals required by `tool/check_agent_memory_compounding.sh` / `tool/check_agent_knowledge_base.sh`. Preserved harness fixture string `SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all` in upgrade skill.
- [`docs/agent_environment_setup.md`](../agent_environment_setup.md): **Cursor indexing** subsection (`.cursorignore`, MCP narrow default, skill inventory resolution).
- [`docs/validation_scripts.md`](../validation_scripts.md): `skill_rank.dart` usage + note that `checklist-fast` picks newest dated `skill_inventory_*.json` when `skill_inventory_latest.json` is absent.
- [`docs/audits/README.md`](../audits/README.md): index pointers for baseline + 2026-05-12 inventory/rank (paths still local-only for JSON).

## Metrics (remeasured)

**Project rules (`.cursor/rules/*.mdc`):** total **4348 -> 3910** B; `agent-execution.mdc` **1311 -> 873** B. Key docs + rules line: **25748 -> 25310** B.

**Skill budgets** (`bash tool/check_skill_budgets.sh <inventory> report`):

| Metric                                            | Before (2026-05-08 inventory)       | After (2026-05-12 inventory)      |
| ------------------------------------------------- | ----------------------------------: | --------------------------------: |
| `repoTemplates` approxTokens                      |                                6626 |                              4887 |
| Largest single repoTemplates skill (approxTokens) | 1802 (`upgrade-pr-triage-validate`) | 720 (`agents-delivery-workflow`)  |
| `cursorSkills` approxTokens (local)               |                               48656 |                             47202 |

**Per-skill (post-change, repoTemplates):** `agents-delivery-workflow` 720; `upgrade-pr-triage-validate` 565; `flutter-bloc-app-delivery-workflow` (Codex) 509; `agents-meta-behavior` 475 approxTokens.

## Verification

- `./tool/check_agent_knowledge_base.sh`
- `bash tool/check_docs_gardening.sh`
- `./tool/sync_agent_assets.sh --apply` + `./tool/check_agent_asset_drift.sh`
- `./bin/checklist-fast --explain --no-reuse`
