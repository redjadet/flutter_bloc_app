---
name: agents-delivery-workflow
description: Non-trivial delivery start→finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

Use repo docs/scripts as workflow source:

1. `AGENTS.md`
1. `docs/agent_knowledge_base.md`
1. `docs/agents_quick_reference.md`
1. `docs/validation_scripts.md`

Default path: **Plan -> Execute -> Verify -> Report**.

Closed-loop default:

- Plan once (<=10 lines), then execute end-to-end.
- Ask only on hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confidence, or user-owned product decision.
- Keep context tight: targeted search + narrow reads.

1. **Plan:** Start from repo-local docs.
2. **Plan:** For non-trivial tasks, write plan and verification steps in
   `tasks/cursor/todo.md`.
3. **Plan:** Keep delegates and cross-host helpers attached to that same tracker.
4. **Plan:** Use **`agents-meta-behavior`** for delegation, parallel analysis, or
   higher-risk verification.
5. **Plan:** Do not change files until at least 95% confident in goal, scope,
   and approach. Ask follow-up questions until reaching that confidence.
6. **Execute:** Reuse patterns in `lib/shared/`, `lib/core/`, and adjacent features.
7. **Execute:** Route lifecycle and memory-pressure work through
   `docs/REPOSITORY_LIFECYCLE.md` and
   `docs/reliability_error_handling_performance.md`.
8. **Execute:** Prefer shared lifecycle helpers (`DisposableBag`,
   `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`) over
   custom resource tracking.
9. **Execute:** Keep `Presentation -> Domain <- Data`.
10. **Execute:** Update DI, routes, l10n, and codegen when touched.
11. **Execute:** Widget-test viewport sizing uses `WidgetTester.view`, not
    deprecated `tester.binding.window`.
12. **Execute:** Repeated struggle => add missing repo capability: doc, fixture,
    test, script, UI proof, log helper, validation check.
13. **Execute:** File verified reusable conclusions into owning source doc,
    `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`; don't leave them
    chat-only.
14. **Verify:** Apply AI review gate when accepting AI-generated code.
15. **Verify:** Run smallest matching repo validation command.
16. **Verify:** Self-verify final response vs request, changed files, proof,
    blockers, residual risk.
17. **Report:** don't mark work complete without proof that matches scope.

Docs-only note:

- Repo docs are validation-bearing. Prefer targeted doc/link checks first; use
  `./bin/checklist` when guidance materially changes or full sweep needed.
- Agent knowledge-base/map changes should also run
  `./tool/check_agent_knowledge_base.sh`.
- Agent/docs changes should semantic-lint stale plans, duplicate rules, and
  source/host-template contradictions.

## Multi-agent

Coordinator-as-hub. Gate before broad work/fan-out.

- **Team** when >=2: blast radius, cross-layer read, high-risk logic,
  separate implement/review bars, or user asked plan + implement + verify.
- **Single** otherwise; tie-break single. Non-trivial tracker line:
  `Benefit: team - <reason>` or `Benefit: single - <reason>`.
- `single`: normal Plan -> Execute -> Verify -> Report; no `tasks/cursor/team/<run-id>/`.
- `team`: create `tasks/cursor/team/<run-id>/` with `goal.md`, `findings.md`,
  `plan.md`, `diff-summary.md`/`diff.md`, `review.md`. Coordinator owns artifacts + validation.
- Spawn specialists with **inline** context, never path-only. Max two
  Implementer fix loops unless user extends.

`Task` roles + redaction: see `agents-meta-behavior`. Doctrine + repo-sensitive
matrix: `docs/agent_knowledge_base.md#multi-agent-hub`.

## Completion gate (before “done” / commit)

Repo canon for sign-off:

1. `AGENTS.md`
1. `docs/testing_overview.md`
1. `docs/ai_code_review_protocol.md` for AI-generated changes

Required checks:

- Apply AI review gate before accepting AI-written code.
- Non-trivial tasks: `tasks/cursor/todo.md` includes plan + verification notes.
- Docs/agent-guidance changes: validate touched docs, links, host-template drift path.
- If subagents were used, review their output and validate integrated result
  yourself.
- For UI/app changes, prefer app-visible proof over logs-only claims.
- Surgical diff: each changed line traces to request or required validation/doc update.
- Self-verify final report vs actual diff, validation output, blockers, risk.
  don't use cross-host helpers as self-review.
- Report only after Verify step has checked own output and available proof.
- Resolve failures in selected validation scope.
- Add or update focused tests when behavior changes warrant it.
- Update docs when architecture, workflow, behavior, or validation guidance
  changes materially.

Full testing and validation bar: `docs/testing_overview.md`,
`docs/validation_scripts.md`.
