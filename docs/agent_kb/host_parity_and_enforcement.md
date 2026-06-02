# Host Parity and Mechanical Enforcement

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_environment_setup.md`](../agent_environment_setup.md), [`agents_quick_reference.md`](../agents_quick_reference.md)

## Host Parity

- Root [`AGENTS.md`](../../AGENTS.md) = repo-local map.
- Root [`AGENTS.md`](../../AGENTS.md) is the only project AGENTS source.
  `./tool/sync_agent_assets.sh --apply` copies it to the Codex home AGENTS
  file and Codex worktrees; Cursor reads the root map in-repo.
- Host-neutral skills live under `tool/agent_host_templates/shared/` and sync
  to both Codex and Cursor. Host-specific skills stay under their host folder.
- Shared-source skills now include `agents-quick-reference`,
  `agents-delivery-workflow`, `agents-repo-context`, `agents-references`,
  `agents-validation-testing`, `agents-principles-baseline`,
  `agents-canonical-rules*`, `agents-common-pitfalls`, `agents-modularity`,
  `agents-shared-patterns`, `agents-figma`, `figma-this-repo`,
  `agents-supabase`, small workflow routers, and
  `flutter-cross-platform-modern`.
- Behavior change order: owning source doc -> quick reference if command choice changed -> review protocol if acceptance changed -> Codex/Cursor templates if cold-start affected.
- After host-template changes: `./tool/sync_agent_assets.sh --dry-run` -> `./tool/sync_agent_assets.sh --apply` -> dry-run clean -> `./tool/check_agent_asset_drift.sh`.
- No Cursor-only/Codex-only workaround unless host capability differs; document delta in template, not source rule.
- Some overlap between [`AGENTS.md`](../../AGENTS.md), quick-reference reminders,
  and final contract is intentional. Do not merge them into one mega-doc just
  to remove repetition.
- User/global host hooks that force broad skill loading are outside this repo's
  source of truth. Change them only on explicit ask; otherwise keep repo docs
  aligned with open-only-needed context.

## Mechanical Enforcement

- `./tool/check_agent_knowledge_base.sh`: keeps [`AGENTS.md`](../../AGENTS.md) short; checks required links, host-template pointers, closed-loop invariants.
- `./tool/check_agent_memory_compounding.sh`: source-aligned memory-compounding; autonomous action explicit-approval-gated.
- `./tool/validate_validation_docs.sh`: validation docs vs checklist scripts.
- `./tool/normalize_doc_links.py`: clickable local links.
- `./tool/check_agent_asset_drift.sh`: managed Cursor/Codex assets vs templates.
- `./bin/checklist`: full gate. `./bin/checklist-fast`: local-only clean/narrow docs/tooling.
- `.original.md` compression backups temporary; delete after verifying active docs.
