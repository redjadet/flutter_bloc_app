---
name: local-agents-quick-reference
description: Repo quick ref + scope-matched validation list. Usage /local-agents-quick-reference
---

# local-agents-quick-reference

Thin adapter: repo canon and scripts win (`AGENTS.md`, `docs/agents_quick_reference.md`).

Output only needed, copy/paste-ready.

```text
1) Summarize repo agent quick reference as execution guide:
   - policy index
   - Plan -> Execute -> Verify -> Report
   - ask only on hard blockers
   - review gate + self-verification
   - host tracker paths
   - UI/design path: DESIGN.md + docs/design_system.md before visual code

2) For my current change (files touched + intent), list exact validation commands, targeted first and broader only when justified.

3) If change touches business-critical, production-failure, docs-only, or shared-architecture surfaces, say so and reflect in command choice.

Output a copy/paste block: one command per line with a single-line purpose.

Prefer repo entrypoints only:
- ./bin/router_feature_validate
- ./bin/checklist-fast
- ./bin/checklist
- ./bin/integration_tests
- ./bin/upgrade_validate_all
- ./bin/agent-maintain preflight (non-trivial task start); closeout (before finish; scope host + docs); after-host-edit (same turn after tool/agent_host_templates/**)
- ./bin/agent-maintain routine --apply or host-full --apply when user asked host/globals upkeep (not app-only lanes)
- ./tool/sync_agent_assets.sh --dry-run to inspect drift; reconcile with ./bin/agent-maintain sync --apply or after-host-edit
- ./tool/check_design_md.sh when DESIGN.md changed
- ./tool/run_mix_lint.sh when Mix tokens/styles changed
- ./tool/request_codex_feedback.sh only for cross-host second opinion; do not self-delegate
```
