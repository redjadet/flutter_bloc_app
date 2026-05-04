---
name: flutter-bloc-app-delivery-workflow
description: Non-trivial delivery for Codex — planning, execution, validation, subagent rules, and completion evidence.
---

# Flutter BLoC app delivery workflow

Use at non-trivial task start and before marking complete.

Default path: **Plan -> Execute -> Verify -> Report**.

Closed-loop: plan once (<=10 lines). Ask only hard blockers. Keep context tight.

1. **Plan:** Start from repo docs, not host assumptions.
2. **Plan:** Use `AGENTS.md` as map and `docs/agent_knowledge_base.md` as source-of-truth layout.
3. **Plan:** Keep active plan and verification in `tasks/codex/todo.md`.
4. **Plan:** Preserve user-supplied execution plans unless user asks for revisions.
5. **Plan:** Classify complexity, risk, scope, uncertainty before validation/delegation depth.
6. **Plan:** Do not change files until at least 95% confident in goal, scope, and approach. Ask until clear.
7. **Execute:** Reuse `lib/shared/`, `lib/core/`, adjacent patterns before new abstractions.
8. **Execute:** Route lifecycle/memory-pressure work through `docs/REPOSITORY_LIFECYCLE.md` and `docs/reliability_error_handling_performance.md`.
9. **Execute:** Prefer shared lifecycle helpers (`DisposableBag`,
   `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`) over
   custom resource tracking.
10. **Execute:** Keep `Presentation -> Domain <- Data`.
11. **Execute:** Update DI, routes, l10n, and codegen when touched.
12. **Execute:** Widget-test viewport sizing uses `WidgetTester.view`, not
    deprecated `tester.binding.window`.
13. **Execute:** Repeated struggle => add repo capability (doc/fixture/test/script/UI proof/log helper/validation check).
14. **Execute:** File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`; don't leave chat-only.
15. **Verify:** AI review gate: `docs/ai_code_review_protocol.md`.
16. **Verify:** Run smallest matching repo validation.
17. **Verify:** Self-verify vs request + changed files + proof + blockers + residual risk.
18. **Report:** don't mark complete without proof matching scope.

Required phrase (guard): Self-verify final response vs request, changed files, proof, blockers, residual risk.

Validation picks:

- router / `AppRoutes` / gates / auth UI -> `./bin/router_feature_validate`
- broad / pre-ship -> `./bin/checklist`
- integration flows -> `./bin/integration_tests`
- upgrades / tooling -> `./bin/upgrade_validate_all`
- docs / agent guidance -> targeted doc checks first; escalate to `./bin/checklist` when validation guidance changed materially
- agent knowledge-base/map changes -> `./tool/check_agent_knowledge_base.sh`
- agent/docs changes -> semantic-lint stale plans, duplicate rules, and
  source/host-template contradictions

Codex host rules:

- Call repo shell entrypoints directly instead of host-local wrappers.
- don't invoke `./tool/request_codex_feedback.sh` from Codex unless user
  explicitly asks for second opinion or cross-host review.
- Self-verification is mandatory and is not cross-host self-review.
- Confidence should come from proof; state uncertainty when material risk remains.
- Surgical diff: each changed line traces to request or required validation/doc update.
- Report only after Verify step has checked own output and available proof.
- For UI/app changes, prefer app-visible proof over logs-only claims.
- Keep host-local notes thin; repo canon wins.

## Subagents

Use this section before delegating or spawning parallel work.

- Delegate only when it materially improves quality/speed/risk.
- Fewest subagents that help. One goal per subagent.
- Define scope + expected output + validation target up front.
- Avoid multi-writer file edits. Default read-only.
- don't delegate current blocker if main agent needs answer to move critical path.
- don't let subagents expand scope or own shared architecture decisions.
- Lifecycle/memory-management stays main-agent by default.
- Subagent output = draft. Main agent integrates + validates.

Repo canon wins over host-local delegation habits.
