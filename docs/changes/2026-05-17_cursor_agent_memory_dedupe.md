# Cursor agent memory dedupe (safe trim)

## Why

Reduce duplicate agent context: always-on loop vs optional global rule vs thin skills repeating [`agents_quick_reference.md`](../agents_quick_reference.md).

## What changed

- Versioned always-on rule: [`tool/agent_host_templates/cursor/rules/agent-execution.mdc`](../tool/agent_host_templates/cursor/rules/agent-execution.mdc) (copy to gitignored `.cursor/rules/`; not synced to `~/.cursor`).
- Compressed [`agents-global.mdc`](../tool/agent_host_templates/cursor/rules/agents-global.mdc) (~3830 → ~2400 B); kept mechanical-check strings.
- Deduped Cursor/Codex quick-reference and delivery-workflow skills; aligned project `design-system.mdc` with template.
- [`docs/agent_host_notes.md`](../agent_host_notes.md): canonical path for `agent-execution.mdc`.

## Verification

- `./tool/check_agent_knowledge_base.sh`
- `./tool/check_agent_memory_compounding.sh`
- `./tool/sync_agent_assets.sh --apply` + `./tool/check_agent_asset_drift.sh`
