---
name: flutter-bloc-app-quick-reference
description: Fast orientation, command entrypoints, and cross-host review pointer for Codex in this repo.
---

# Flutter BLoC app quick reference

Thin adapter. Repo canon wins.

Read only needed:

1. `AGENTS.md`
2. `docs/agent_knowledge_base.md`
3. `docs/agents_quick_reference.md`
4. `docs/ai_code_review_protocol.md` for AI-written code/review

Non-trivial delivery: **`flutter-bloc-app-delivery-workflow`**.

Repo: Flutter 3.41.9 / Dart 3.11.5; `Presentation -> Domain <- Data`; GoRouter; offline-first sync in `lib/shared/sync/`.

Fast rules:

- Plan -> Execute -> Verify -> Report.
- Non-trivial -> `tasks/codex/todo.md`.
- context ladder -> map docs, durable memory, code-review-graph, targeted raw files.
- UI/design/theme/Mix -> read `DESIGN.md` + `docs/design_system.md`; prefer `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`.
- Lifecycle -> `docs/REPOSITORY_LIFECYCLE.md` + `docs/reliability_error_handling_performance.md`; prefer `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`.
- Repeated failure -> add repo capability, not bigger prompt.
- reusable agent conclusion -> source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.
- Widget tests -> `WidgetTester.view`, not `tester.binding.window`.

Validation picks:

- router/auth/gates -> `./bin/router_feature_validate`
- broad/pre-ship -> `./bin/checklist`
- integration -> `./bin/integration_tests`
- upgrades/tooling -> `./bin/upgrade_validate_all`
- design brief -> `./tool/check_design_md.sh`
- Mix token/style -> `./tool/run_mix_lint.sh`
- agent docs -> `./tool/check_agent_knowledge_base.sh`
- host templates -> `./tool/check_agent_asset_drift.sh` + `./tool/sync_agent_assets.sh --dry-run`

Agent/docs changes: semantic-lint stale plans, duplicate rules, source/host-template contradictions. Before final: self-verify vs request, changed files, proof, blockers, risk.

Cross-host review explicit-only:

```bash
./tool/request_codex_feedback.sh
```

Codex must not use that helper for self-review.
