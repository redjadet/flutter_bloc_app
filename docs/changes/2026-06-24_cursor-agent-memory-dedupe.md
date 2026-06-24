# Cursor agent memory dedupe (pass 3, 2026-06-24)

## Why

`agent-auto-hot-reload.mdc` was injected **twice** every session: synced copy in `~/.cursor/rules/` plus an identical workspace `.cursor/rules/` copy (both `alwaysApply: true`). `design-system.mdc` also existed in both places with divergent prose.

## What changed

- Removed workspace duplicates: `.cursor/rules/agent-auto-hot-reload.mdc`, `.cursor/rules/design-system.mdc`.
- Merged canonical `design-system.mdc` in `tool/agent_host_templates/cursor/rules/` (template + former workspace-only responsive/cross-platform/file-length bullets).
- Added `check_workspace_managed_rule_duplicates` in [`tool/agent_asset_lib.sh`](../../tool/agent_asset_lib.sh); wired into [`tool/check_agent_asset_drift.sh`](../../tool/check_agent_asset_drift.sh).
- Synced project-only [`agent-execution.mdc`](../../tool/agent_host_templates/cursor/rules/agent-execution.mdc) into workspace `.cursor/rules/`.
- Dedup matrix row: workspace rule duplicates — [`dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md).

## Agent rule

- **Synced global rules** (`agents-global`, `design-system`, `agent-auto-hot-reload`) → `~/.cursor/rules/` only via `sync_agent_assets.sh --apply`.
- **Project-only rules** (`agent-execution`, router/dependency guards) → workspace `.cursor/rules/` only.
- Re-run `./tool/check_agent_asset_drift.sh` after copying templates; drift fails on workspace/global name overlap.

## Verification

- `bash tool/check_agent_asset_drift.sh`
- `bash tool/check_agent_memory_compounding.sh`
- `bash tool/check_agent_knowledge_base.sh`
