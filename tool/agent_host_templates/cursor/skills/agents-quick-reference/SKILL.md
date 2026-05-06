---
name: agents-quick-reference
description: Canon pointers, lifecycle, trackers, approved shell entrypoints, and host wrapper rules. Repo canon wins.
---

# Quick reference

Adapter only. Repo canon wins.

Open only needed repo-local canon (in order):

1. `AGENTS.md`
2. `docs/agent_knowledge_base.md`
3. `docs/agents_quick_reference.md`
4. `docs/ai_code_review_protocol.md` when reviewing AI-written code

When non-trivial:

- Delivery/completion bar: **`agents-delivery-workflow`**
- Delegation discipline: **`agents-meta-behavior`**

Repo profile:

- Flutter 3.41.9 / Dart 3.11.5
- `Presentation -> Domain <- Data`

Defaults:

- Plan -> Execute -> Verify -> Report. Plan once. Ask only hard blockers.
- Context ladder: map docs -> durable memory -> code-review-graph -> targeted raw files.

Fast pointers:

- Tracker: `tasks/cursor/todo.md`
- Lessons: `tasks/lessons.md`
- reusable agent conclusion -> source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`
- Knowledge base check: `./tool/check_agent_knowledge_base.sh`
- Host asset drift check: `./tool/check_agent_asset_drift.sh`
- Preview/apply sync: `./tool/sync_agent_assets.sh --dry-run` / `./tool/sync_agent_assets.sh --apply`
- multi-agent hub -> see `agent_knowledge_base.md#multi-agent-hub`; team run dir: `tasks/cursor/team/<run-id>/`

Approved shell entrypoints (subset; full list in `docs/agents_quick_reference.md`):

```text
./bin/checklist-fast
./bin/router_feature_validate
./bin/checklist
./bin/integration_tests
./tool/check_agent_knowledge_base.sh
./tool/check_agent_asset_drift.sh
./tool/sync_agent_assets.sh --dry-run
```

Host wrapper rules:

- Cursor slash commands are convenience wrappers only.
- Cross-host review is explicit; don’t self-delegate.
- Self-verification is mandatory and local to reporting agent.
