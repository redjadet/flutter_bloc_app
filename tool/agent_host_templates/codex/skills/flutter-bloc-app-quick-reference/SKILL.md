---
name: flutter-bloc-app-quick-reference
description: Fast orientation, command entrypoints, and cross-host review pointer for Codex in this repo.
---

# Flutter BLoC app quick reference

Fast orientation only. Repo canon wins.

Read only what you need:

1. `AGENTS.md`
2. `docs/agent_knowledge_base.md`
3. `docs/agents_quick_reference.md`
4. `docs/ai_code_review_protocol.md` when reviewing AI-written code

Non-trivial work/delegation: **`flutter-bloc-app-delivery-workflow`**.

Repo profile:

- Flutter 3.41.9 / Dart 3.11.5
- `Presentation -> Domain <- Data`
- `GoRouter` routing
- offline-first sync under `lib/shared/sync/`

Fast reminders:

- default loop -> Plan, Execute, Verify, Report
- classify complexity / risk / scope / uncertainty before scaling depth
- non-trivial work -> `tasks/codex/todo.md`
- repeated user correction -> `tasks/lessons.md`
- reusable agent conclusion -> source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`
- agent docs/map drift -> `./tool/check_agent_knowledge_base.sh`
- agent memory-compounding drift -> `./tool/check_agent_memory_compounding.sh`
- repeated agent failure -> add missing repo capability, not bigger prompt
- UI/app changes -> prefer app-visible proof over logs-only claims
- lifecycle/memory-pressure work -> `docs/REPOSITORY_LIFECYCLE.md` + `docs/reliability_error_handling_performance.md`
- prefer `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`
- widget-test viewport sizing -> `tester.view.*` + reset; avoid deprecated `tester.binding.window`

Validation picks:

- router / auth / gates -> `./bin/router_feature_validate`
- broad / pre-ship -> `./bin/checklist`
- integration flows -> `./bin/integration_tests`
- upgrades / tooling -> `./bin/upgrade_validate_all`
- host-template changes -> `./tool/check_agent_asset_drift.sh` + `./tool/sync_agent_assets.sh --dry-run`
- agent/docs changes -> semantic-lint stale plans, duplicate rules, source/host-template contradictions
- non-trivial choices -> compare approaches, choose lowest regret, stop when extra work no longer reduces real risk
- before final report -> self-verify vs request, changed files, proof, blockers, risk

Cross-host review stays explicit-request-only:

```bash
./tool/request_codex_feedback.sh
```

don't use that helper for self-review from Codex.
