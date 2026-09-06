# Host Parity and Mechanical Enforcement

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_environment_setup.md`](../agent_environment_setup.md), [`agents_quick_reference.md`](../agents_quick_reference.md)

## Host Parity

- Codex and Cursor are first-class validated hosts. Other AI agents follow the
  same repository map and owner docs; host-specific conveniences cannot weaken
  shared safety or validation policy.
- Root [`AGENTS.md`](../../AGENTS.md) is the only project AGENTS source. Agents
  read the versioned copy from the repository or active worktree.
- Do not copy the project map into a global agent home or between worktrees.
  Home-level instructions are user-wide; each worktree owns the version checked
  out with its branch. The Codex home AGENTS file under `~/.codex/` is unmanaged
  user config (recommended: short host-neutral pointer only) — see
  [`agent_host_notes.md`](../agent_host_notes.md) § Codex; change it only with
  explicit human authorization.
- Host-neutral skills live under `tool/agent_host_templates/shared/` and sync
  to both Codex and Cursor. Host-specific skills stay under their host folder.
- Project-only Cursor rules sync to workspace `.cursor/rules/`; they do not
  leak into `~/.cursor/rules`.
- Shared-source skills now include `agents-quick-reference`,
  `agents-delivery-workflow`, `agents-repo-context`, `agents-references`,
  `agents-validation-testing`, `agents-principles-baseline`,
  `agents-canonical-rules*`, `agents-common-pitfalls`, `agents-modularity`,
  `agents-shared-patterns`, `agents-figma`, `figma-this-repo`,
  `agents-supabase`, small workflow routers, `gh-watch-merge-pr`, and
  `flutter-cross-platform-modern`.
- Cursor-only templates (not in shared): `agents-meta-behavior`,
  `agents-global-skills-setup`, `agents-cursor-integration`. Codex uses the
  same owner docs; see [`docs/ai/skill_routing.md`](../ai/skill_routing.md)
  § Host availability.
- Global/vendor skills (`type-safe-bloc-access`, `gh-fix-ci`, process skills)
  live under host skill homes — install via `./bin/agent-maintain find/install`
  when missing; never treat absence as a blocker if the owner doc or `gh`
  CLI covers the job.
- Behavior change order: owning source doc -> quick reference if command choice changed -> review protocol if acceptance changed -> Codex/Cursor templates if cold-start affected.
- After host-template changes: `./bin/agent-maintain after-host-edit` (or inspect `./tool/sync_agent_assets.sh --dry-run`, then `./bin/agent-maintain sync --apply` + strict drift). Reload Cursor after `--apply`.
- Before claiming host/docs/tooling work done: `./bin/agent-maintain closeout` (scope-based; see [`host_maintenance_automation.md`](host_maintenance_automation.md)).
- No Cursor-only/Codex-only workaround unless host capability differs; document delta in template, not source rule.
- Some overlap between [`AGENTS.md`](../../AGENTS.md), quick-reference reminders,
  and final contract is intentional. Do not merge them into one mega-doc just
  to remove repetition.
- User/global host hooks that force broad skill loading are outside this repo's
  source of truth. Change them only on explicit ask; otherwise keep repo docs
  aligned with open-only-needed context.

## Compatibility References

Verified 2026-09-03:

- [OpenAI Codex instruction loading](https://openai.com/index/unrolling-the-codex-agent-loop/)
  — home instructions are global; repository instructions load by directory scope.
- [OpenAI harness engineering](https://openai.com/index/harness-engineering/)
  — keep AGENTS as a short map and repository docs as system of record.
- [Cursor rules](https://docs.cursor.com/context/rules) — keep rules concise,
  focused, composable, and scoped.
- [Cursor CLI](https://docs.cursor.com/en/cli/using) — reads root AGENTS alongside
  project rules.

## Mechanical Enforcement

- `./tool/check_agent_knowledge_base.sh`: keeps [`AGENTS.md`](../../AGENTS.md) short; checks required links, host-template pointers, closed-loop invariants.
- `./tool/check_agent_memory_compounding.sh`: source-aligned memory-compounding; autonomous action explicit-approval-gated.
- `./tool/validate_validation_docs.sh`: validation docs vs on-disk `check_*.sh` inventory and catalog counts.
- `./tool/normalize_doc_links.py`: clickable local links.
- `./tool/check_agent_asset_drift.sh`: managed Cursor/Codex assets vs templates, including required project-only Cursor rules; fails on workspace `.cursor/skills/` or `.cursor/rules/` duplicates of globally synced host assets.
- `./bin/checklist`: full gate. `./bin/checklist-fast`: local-only clean/narrow docs/tooling.
- `.original.md` compression backups temporary; delete after verifying active docs.
