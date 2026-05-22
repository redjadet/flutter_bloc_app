# Agent context optimization (2026-05-22)

Implemented the build-ready plan: repo doc dedupe, thin host templates + sync, balanced global trim, review fixes. Baseline: [`2026-05-22_agent-context-baseline.md`](2026-05-22_agent-context-baseline.md). Matrix: [`dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md).

## Token delta

| Origin | Baseline | Post | Δ |
| --- | ---: | ---: | ---: |
| `repoTemplates` | 10411 | 4500 | −5911 (−56.8%) |
| `cursorSkills` | 41384 | 36106 | −5278 (−12.8%) |
| `agentsSkills` | 506285 | 506285 | 0 (balanced trim: 0 archive entries) |
| `pluginCache` | 1078486 | — | measure only; unchanged |

Inventory: `docs/audits/skill_inventory_2026-05-22_post.json` → `docs/audits/skill_inventory_latest.json`.

## Success gates

| Gate | Result |
| --- | --- |
| `repoTemplates` ≤ baseline | Pass |
| `repoTemplates` ≤ 4500 | Pass (4500 by report-only inventory) |
| Max single repo skill ≤ 3000 | Pass (largest 297, `upgrade-pr-triage-validate`) |
| `cursorSkills` ≤ baseline − 5% (≤ 39315) | Pass (36106) |
| `check_agent_knowledge_base.sh` | Pass |
| `check_agent_memory_compounding.sh` | Pass |
| `check_agent_asset_drift.sh` | Pass |
| `./bin/checklist-fast` | Pass (incl. upgrade triage harness fixtures) |

## Review fixes (post-plan)

- **Delivery skill:** context ladder → [`ai/context_loading.md`](../ai/context_loading.md) (not AKM-only).
- **Canon moves:** upgrade lane → [`docs/validation_scripts/upgrade_pr_triage_validate.md`](../validation_scripts/upgrade_pr_triage_validate.md); regression anchors → [`testing_overview.md`](../testing_overview.md) § Regression test anchors.
- **Host skills:** router-only canonical-rules + validation-testing; vendor workflows → `~/.cursor/skills/*` pointers; preserved mechanical anchors + `SKIP_PUB_UPGRADE` fixture strings in upgrade skill.
- **WidgetTester.view:** documented as resolved in matrix (root/Codex playbook; `agents-global.mdc` guardrail — not a conflict).

## Slices

1. **Repo docs** — Harness → pointers; AKM Progressive Disclosure → [`docs/ai/context_loading.md`](../ai/context_loading.md).
2. **Host templates** — Thin `tool/agent_host_templates/**`; `./tool/sync_agent_assets.sh --apply`.
3. **Global trim** — Balanced: **0 entries** (`docs/audits/skill_trim_plan_2026-05-22_balanced_*.json`). **`--mode full` deferred** (operator approval).
4. **Closeout** — This file + [`agent_host_notes.md`](../agent_host_notes.md) edit loop.

## Deferred / out of scope

- `agentsSkills` global budget (506285 > 80000) — measure only; no CI enforce
- `pluginCache` deletion; shared `.cursorignore` in repo
- `compress_agent_doc.sh` on AKM
- `--mode full` global trim
- Automated semantic dedup script

Reload Cursor after sync if skills look stale.
