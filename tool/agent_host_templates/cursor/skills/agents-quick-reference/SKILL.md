---
name: agents-quick-reference
description: Canon pointers, lifecycle, trackers, approved shell entrypoints, and host wrapper rules. Repo canon wins.
---

# Quick reference

Thin adapter. Repo canon wins.

Open only needed:

1. `AGENTS.md`
2. `docs/agent_knowledge_base.md`
3. `docs/agents_quick_reference.md`
4. `docs/ai_code_review_protocol.md` for AI-written code

Non-trivial: `agents-delivery-workflow`; delegation discipline: `agents-meta-behavior`.

Repo: Flutter 3.41.9 / Dart 3.11.5; `Presentation -> Domain <- Data`.

Defaults: Plan -> Execute -> Verify -> Report; Context ladder: map docs -> durable memory -> code-review-graph -> targeted raw files.

Tracker: `tasks/cursor/todo.md`; lessons: `tasks/lessons.md`; reusable agent conclusion -> source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.

UI/design/Mix: `DESIGN.md` + `docs/design_system.md`; prefer `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`.

multi-agent hub -> `agent_knowledge_base.md#multi-agent-hub`; team dir `tasks/cursor/team/<run-id>/`.

Approved entrypoints:

```text
./bin/checklist-fast
./bin/router_feature_validate
./bin/checklist
./bin/integration_tests
./tool/check_agent_knowledge_base.sh
./tool/check_design_md.sh
./tool/run_mix_lint.sh
./tool/check_agent_asset_drift.sh
./tool/sync_agent_assets.sh --dry-run
```

Host wrapper rules: Cursor commands are convenience only; cross-host review explicit; self-verification local and mandatory.
