---
name: flutter-bloc-app-delivery-workflow
description: Non-trivial delivery for Codex — planning, execution, validation, subagent rules, and completion evidence.
---

# Flutter BLoC app delivery workflow

Use at non-trivial start and before done.

Default: **Plan -> Execute -> Verify -> Report**. Plan once (<=10 lines). Ask only hard blockers. Trigger routing: `docs/agents_quick_reference.md#automatic-workflow-triggers`.

1. **Plan:** Start from repo docs. `AGENTS.md` map; `docs/agent_knowledge_base.md` source layout.
2. **Plan:** Existing-code work uses context ladder: map docs -> durable memory -> code-review-graph -> targeted raw files.
3. **Plan:** Keep active plan/proof in `tasks/codex/todo.md`.
4. **Plan:** Preserve user-supplied plan unless asked to revise.
5. **Plan:** Classify complexity/risk/scope/uncertainty.
6. **Plan:** Do not edit until 95% confident in goal/scope/approach; ask until clear.
7. **Plan:** If vague/risky, define boundaries, data flow, failure handling, and smallest verifiable slice before generation.
8. **Execute:** Reuse `lib/shared/`, `lib/core/`, adjacent patterns; keep `Presentation -> Domain <- Data`.
9. **Execute:** UI/design/Mix -> `DESIGN.md` + `docs/design_system.md`; use `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI` before new styling.
10. **Execute:** Lifecycle -> `docs/REPOSITORY_LIFECYCLE.md` + `docs/reliability_error_handling_performance.md`; prefer `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`.
11. **Execute:** Update DI/routes/l10n/codegen when touched. Widget-test viewport uses `WidgetTester.view`.
12. **Execute:** Repeated struggle => add repo capability. File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.
13. **Verify:** AI review gate: `docs/ai_code_review_protocol.md`; run smallest matching validation.
14. **Verify:** Finish gate: edge cases, failure paths, readability, operational clarity, breakage impact.
15. **Verify:** Self-verify final response vs request, changed files, proof, blockers, residual risk.
16. **Report:** Report only after Verify; proof must match scope.

Validation picks:

- router / `AppRoutes` / gates / auth UI -> `./bin/router_feature_validate`
- broad / pre-ship -> `./bin/checklist`
- integration -> `./bin/integration_tests`
- upgrades/tooling -> `./bin/upgrade_validate_all`
- design brief -> `./tool/check_design_md.sh`; Mix token/style -> `./tool/run_mix_lint.sh`
- agent docs -> targeted doc checks + `./tool/check_agent_knowledge_base.sh`; semantic-lint stale plans, duplicate rules, source/host-template contradictions

Codex rules:

- Call repo shell entrypoints directly.
- Do not invoke `./tool/request_codex_feedback.sh` unless user explicitly asks second opinion/cross-host review.
- Self-verification is mandatory and not cross-host self-review.
- Confidence from proof; state material uncertainty.
- Surgical diff: each changed line traces to request or required validation/doc update.
- UI/app changes prefer app-visible proof over logs-only claims.
- Host notes stay thin; repo canon wins.

## Subagents

Delegate only when it improves quality/speed/risk. Fewest agents, one goal each. Define scope/output/validation. Avoid multi-writer edits; default read-only. Don’t delegate current blocker. Subagent output = draft; main agent integrates + validates. Repo canon wins.
