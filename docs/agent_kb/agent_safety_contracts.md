# Agent Safety Contracts

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

Canonical summary for agent scope, safety, and closeout proof. Deep policy
owners remain authoritative — this doc links to them; it does not replace them.

Use on non-trivial work after [`ai_failure_risks.md`](../ai/ai_failure_risks.md)
Pre-Flight. Risk IDs map in the risk register.

## Contract index

| ID | Topic | Risk IDs | Deep owner |
| --- | --- | --- | --- |
| `SAFETY-01` | Scope and target certainty | `RISK-SCOPE-CREEP`, `RISK-MISSING-TARGET` | [`adaptive_execution.md`](adaptive_execution.md) |
| `SAFETY-02` | Destructive and external actions | `RISK-DESTRUCTIVE-SIDE-EFFECT` | [`host_maintenance_automation.md`](host_maintenance_automation.md) |
| `SAFETY-03` | Git preservation | `RISK-UNAPPROVED-GIT` | [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) § AI agent rules |
| `SAFETY-04` | Secrets and production access | `RISK-SECRET-LEAK`, `RISK-SECURITY-GAP` | [`security_and_secrets.md`](../security_and_secrets.md) |
| `SAFETY-05` | Execution and verification | `RISK-VALIDATION-SHORTCUT` | [`agent_operating_manual.md`](../ai/agent_operating_manual.md) |
| `SAFETY-06` | Flutter repository boundaries | `RISK-ARCH-LAYER`, `RISK-FLUTTER-SDK-MUTATION` | [`AGENTS.md`](../../AGENTS.md); [`clean_architecture.md`](../clean_architecture.md) |
| `SAFETY-REPORT` | Mandatory closeout report | `RISK-VALIDATION-SHORTCUT` | [`legibility_and_finish_gate.md`](legibility_and_finish_gate.md) |

## SAFETY-01 — Scope and target certainty

- Modify only files required for the stated request.
- Never expand the task, substitute similar targets, or clean up unrelated files.
- Declare the write-set before edits on T1/T2 work.
- If the requested file, environment, branch, resource, or identifier cannot be
  found, stop and ask. Do not guess or choose an alternative.

## SAFETY-02 — Destructive and external actions

Do not perform these without explicit same-turn approval after the approval
template below:

- Delete files, directories, databases, worktrees, branches, commits, caches,
  emulators, simulators, cloud resources, or credentials.
- Overwrite existing files unless that exact file is in the approved write-set.
- Run destructive or equivalent commands (examples, not an exhaustive shell
  parser): `rm`, `git reset --hard`, `git clean`, `git checkout --`,
  `git restore`, force-push, destructive database queries, worktree removal,
  deploys, remote writes, or host-local sync (`after-host-edit` / `sync --apply`).

### Same-turn approval template

Before any `SAFETY-02` action, list and wait for approval:

1. **Targets** — exact paths, refs, resources, or host surfaces
2. **Command or action** — exact command or operation
3. **Effect** — what changes or may be lost
4. **Rollback/recovery** — how to recover if the action fails

Routine repo-local edits inside the approved write-set remain governed by user
scope; they do not require this template.

## SAFETY-03 — Git preservation

- Inspect `git status` and the relevant diff before editing.
- Treat all existing uncommitted changes as user-owned; preserve them.
- Never discard, revert, amend, stash, commit, push, create PRs, merge, switch
  branches, or manipulate worktrees unless the user explicitly requests that
  operation in the current turn.
- Never modify files outside this repository.

## SAFETY-04 — Secrets and production protection

- Never search for, read, print, copy, expose, or use credentials, tokens, SSH
  keys, `.env` contents, keychains, caches, browser data, or hidden
  authentication files.
- Never access production systems, cloud consoles, remote databases, deployment
  targets, or external services unless the user explicitly authorizes the exact
  target and action.
- Use least-privilege local development configuration only.

## SAFETY-05 — Execution discipline

- Prefer read-only inspection first.
- Make the smallest reversible change.
- Do not claim tests, builds, runtime checks, or fixes succeeded unless you
  actually ran them and report the exact result.
- If blocked, report the blocker and safe options. Do not bypass permissions,
  safeguards, or failures.

## SAFETY-06 — Flutter app rules

- Preserve Clean Architecture: `Presentation -> Domain <- Data`; domain stays
  pure Dart.
- Do not modify Flutter/Dart SDK or framework sources.
- After Dart changes, format changed Dart files and run the narrowest relevant
  repository validation.
- Follow [`AGENTS.md`](../../AGENTS.md) and canonical docs before implementation.

## SAFETY-REPORT — Mandatory closeout report

Coding-task closeout must include:

1. **Files Changed** — each changed file plus one-line modification summary
2. **Verification** — exact command(s) run and pass/fail/skipped/N/A result
3. **Known limitations** — residual risk, skipped lanes, or manual blockers; or
   `None`
4. **Follow-up Actions** — required next steps or `None`
5. **Destructive/external actions** — state
   `No destructive or external actions were performed` unless a same-turn
   approved action is named with its approval

Never fabricate verification results.
