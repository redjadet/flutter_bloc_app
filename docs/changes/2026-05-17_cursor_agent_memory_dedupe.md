# Cursor agent memory dedupe (safe trim)

## Why

Reduce duplicate agent context: always-on loop vs optional global rule vs thin skills repeating [`agents_quick_reference.md`](../agents_quick_reference.md).

## What changed

- Versioned always-on rule: [`tool/agent_host_templates/cursor/rules/agent-execution.mdc`](../tool/agent_host_templates/cursor/rules/agent-execution.mdc) (copy to gitignored `.cursor/rules/`; not synced to `~/.cursor`).
- Compressed [`agents-global.mdc`](../tool/agent_host_templates/cursor/rules/agents-global.mdc) (~3830 → ~2400 B); kept mechanical-check strings.
- Deduped Cursor/Codex quick-reference and delivery-workflow skills; aligned project `design-system.mdc` with template.
- [`docs/agent_host_notes.md`](../agent_host_notes.md): canonical path for `agent-execution.mdc`.

## Follow-up (suggested next actions — done)

- Regenerated `docs/audits/skill_inventory_2026-05-17_post.json`, `skill_rank_2026-05-17.json`, `skill_inventory_latest.json`.
- Global `agents-*` dedupe (versioned + synced): `agents-repo-context`, `agents-principles-baseline`, `agents-references` → `tool/agent_host_templates/cursor/skills/` + `tool/agent_asset_lib.sh`.
- Metrics: [`docs/audits/cursor_context_baseline_2026-05-17.md`](../audits/cursor_context_baseline_2026-05-17.md) — `cursorSkills` **47202 → 42819** (final inventory); trio **~3025 → ~1384**; canonical-rules + validation six-pack **~4608 → ~2308**.
- Optional pass: thinned `agents-canonical-rules` (+ 4 children) and `agents-validation-testing`; lifecycle script lists → `docs/validation_scripts.md`; kept regression test anchors + Mix/golden paths.
- Second optional pass: versioned + synced `agents-common-pitfalls`, `agents-figma`, `figma-this-repo`, `agents-modularity`, `agents-shared-patterns`, `agents-supabase` (table/pointer style; `tool/agent_asset_lib.sh`).

## Verification

- `./tool/check_agent_knowledge_base.sh`
- `./tool/check_agent_memory_compounding.sh`
- `./tool/sync_agent_assets.sh --apply` + `./tool/check_agent_asset_drift.sh`
- `./bin/checklist-fast`
- `bash tool/check_skill_budgets.sh docs/audits/skill_inventory_2026-05-17_post.json`
