---
name: agents-delivery-workflow
description: Non-trivial delivery start→finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

Canon: `AGENTS.md`, `docs/agent_knowledge_base.md`, `docs/agents_quick_reference.md`.
Default: **Plan -> Execute -> Verify -> Report**. Plan once (<=10 lines). Ask only hard blockers.

- **Plan**: non-trivial -> write plan + verification in `tasks/cursor/todo.md`.
- **Plan**: delegation/parallelism -> `agents-meta-behavior`.
- **Plan**: Do not change files until at least 95% confident in goal, scope, approach.
- **Execute**: reuse seams; keep `Presentation -> Domain <- Data`.
- **Execute**: lifecycle/memory -> `docs/REPOSITORY_LIFECYCLE.md` + `docs/reliability_error_handling_performance.md`.
- **Execute**: prefer helpers: `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`.
- **Execute**: update DI/routes/l10n/codegen when touched.
- **Verify**: AI review gate: `docs/ai_code_review_protocol.md`.
- **Verify**: run smallest matching repo validation command.
- **Verify**: Self-verify final response vs request, changed files, proof, blockers, residual risk.
- **Execute**: File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.

Docs-only note:

- Repo docs validation-bearing. Prefer targeted doc/link checks; use `./bin/checklist` when guidance changed materially.
- Agent knowledge-base/map changes should also run
  `./tool/check_agent_knowledge_base.sh`.
- Agent/docs changes should semantic-lint stale plans, duplicate rules, and
  source/host-template contradictions.

## Multi-agent

Coordinator-as-hub. Gate before broad work/fan-out.

- **Team** when >=2: blast radius, cross-layer read, high-risk logic, separate implement/review bars, or user asked plan+implement+verify.
- **Single** otherwise; tie-break single. Tracker line: `Benefit: team - <reason>` or `Benefit: single - <reason>`.
- `single`: normal Plan -> Execute -> Verify -> Report; no `tasks/cursor/team/<run-id>/`.
- `team`: create `tasks/cursor/team/<run-id>/` (`goal.md`, `findings.md`, `plan.md`, `diff-summary.md`/`diff.md`, `review.md`). Coordinator owns artifacts + validation.
- Spawn specialists with **inline** context, never path-only. Max two Implementer fix loops unless user extends.

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

## Commit rules (when user asks to commit)

- Inspect before staging:
  - `git status`
  - `git diff`
- Stage only intended scope. If scope unclear or mixed, stop and require
  pre-staging by user.
- Sanity check staged diff:
  - `git diff --staged`
- Message rules:
  - imperative, <= 72 chars, no trailing period
  - include “why” when not obvious
  - include tests run (or “not run” with reason)
  - no assistant mention
  - prefer heredoc for newlines
- Commit example:

  - ```bash
    git commit -m "$(cat <<'EOF'
    <type>(<scope>): <short summary>

    Summary:
    - <what changed>

    Rationale:
    - <why>

    Tests:
    - <command or "not run (reason)">
    EOF
    )" -- <paths...>
    ```

Full testing and validation bar: `docs/testing_overview.md`,
`docs/validation_scripts.md`.
