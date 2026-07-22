# Git and Branching Strategy

This policy keeps human and AI changes reviewable, reversible, and safe to
integrate. It applies to source, tests, documentation, workflows, and generated
files in this repository.

## Operating model

- `main` is the shared integration branch. Start work from current
  `origin/main`; merge completed work back through a pull request (PR).
- One branch owns one coherent outcome. Do not mix feature work, unrelated
  cleanup, generated churn, or dependency upgrades in the same PR.
- Keep each working tree assigned to one branch. Use a separate Git worktree
  when parallel work would otherwise share files or Git state.
- Treat GitHub branch rules and required checks as the enforcement source of
  truth. This document defines the project workflow; it does not replace live
  repository settings.

## GitHub enforcement

`main` is protected for contributors. Owners and repository administrators may
push directly when an urgent or administrative change requires it. All other
contributors must use a PR with resolved review conversations and an up-to-date
successful result from:

- `build`
- `integration-preflight`
- `dependency-review`
- `scan-pr / osv-scan`

Force-pushes and branch deletion are blocked on `main`. GitHub automatically
deletes a merged PR head branch. GitHub Actions default to read-only tokens and
cannot approve PR reviews; a workflow must request only the additional
permissions it needs.

The current repository ruleset is disabled and is not an enforcement source.
Do not enable or expand it without first documenting and validating its added
rules.

## Branch names

Use lowercase, slash-separated names with a clear work type and short outcome.

| Work type | Human example | AI example |
| --- | --- | --- |
| Feature | `feat/chat-export` | `codex/feat-chat-export` |
| Fix | `fix/router-redirect-loop` | `codex/fix-router-redirect-loop` |
| Documentation | `docs/git-branching-strategy` | `codex/docs-git-branching-strategy` |
| Chore or tooling | `chore/flutter-3-44` | `codex/chore-flutter-3-44` |

`cursor/` is acceptable for Cursor-created branches. Keep its suffix equally
descriptive. Do not reuse a branch for a different task after it has a PR.

## Start work

Begin from a clean, current base. Preserve unrelated local changes; do not
discard or stash another contributor's work without permission.

```bash
git status --short --branch
git fetch origin main --prune
git switch main
git pull --ff-only origin main
git switch -c codex/docs-git-branching-strategy
```

For isolated work, create a worktree from `origin/main` rather than sharing a
working directory with another active task:

```bash
./bin/agent-worktree --name git-strategy
./bin/agent-worktree --name git-strategy --apply
```

The helper defaults to branch `codex/<name>`, adjacent path
`../flutter_bloc_app-<name>`, and existing local ref `origin/main`. It validates
the base, branch, parent, and target path before mutation; it never fetches,
deletes, reuses, or overwrites. Use `--base`, `--branch`, or `--path` only when
the task requires an explicit override. Equivalent raw Git remains:

```bash
git worktree add -b codex/git-strategy ../flutter_bloc_app-git-strategy origin/main
```

Use a path outside an existing worktree and remove only the worktree created
for the completed task. Review `git worktree list --porcelain` before cleanup.

## Work on a branch

Keep commits small and meaningful. A commit should build on its own and explain
one intention, for example `docs: add Git and branching strategy` or
`fix(router): prevent stale redirect after sign-out`.

- Stage deliberately with `git add <paths>`; inspect `git diff --cached` before
  committing.
- Never commit credentials, local configuration, build outputs, or unrelated
  formatting churn. Follow [Security and Secrets](security_and_secrets.md).
- Keep generated files with their source change when the repository tracks
  them; regenerate through the documented command instead of hand-editing.
- Update owning documentation in the same branch when behavior, setup,
  validation, or workflow changes.
- Run validation proportionate to the changed surface. The source of truth is
  [Validation Routing](engineering/validation_routing_fast_vs_full.md).

## Keep the branch current

Before review and again before merge, compare the topic branch with current
`origin/main`. Rebase a private topic branch when it improves review and avoids
an obsolete merge base:

```bash
git fetch origin main --prune
git rebase origin/main
```

Resolve only conflicts whose intent is clear. Stop and request maintainer input
when a conflict changes product behavior, ownership, security, generated files,
or another task's work. After a rebase, rerun validation affected by the
resolution.

Never force-push a shared branch. A human may use `git push --force-with-lease`
for their own rebased branch only after checking its remote state. An AI must
obtain same-turn user approval before any force-push or other remote rewrite.

## Pull request contract

Open one PR against `main` after the branch has a focused, reviewable diff.
Use a draft PR for early feedback; mark it ready only when the acceptance
criteria and validation evidence are complete.

PR description includes:

- Goal and boundaries.
- User-visible or operational impact.
- Files or systems intentionally excluded.
- Validation commands and exact results; state `Tests: N/A — reason` only when
  behavior cannot change.
- Migration, rollback, security, or follow-up notes when applicable.

Review the final diff before requesting review. Do not approve, merge, or
bypass failing checks merely because a local command passed. CI and GitHub PR
state decide merge readiness; [CI Automation](engineering/ci_automation.md) describes the
expected gates and local equivalents.

## Merge and cleanup

Squash merge is the default for a focused topic branch. It keeps `main` history
linear at the change level and matches the repository's current default merge
method. Use merge commits or rebase merges only when a maintainer deliberately
needs their history properties.

After a merged PR:

```bash
git switch main
git pull --ff-only origin main
git fetch origin --prune
```

Delete the remote branch when the PR merge flow did not already do so. For a
full prune (squash-merged / closed PR heads via `gh`, remotes, and ancestor
worktrees), preview then apply:

```bash
./bin/prune-git-stale
./bin/prune-git-stale --closed-prs --keep mapbox-demo-improvements-2026-03-23 --apply
```

Locals-only (true-merge / `[gone]` upstream) remains available:

```bash
bash tool/clean_merged_local_branches.sh --help
```

`--apply`, branch deletion, and worktree removal change local or remote state.
AI agents require same-turn user confirmation before those operations. Humans
should confirm the PR is merged, working tree is clean, and target worktree is
the completed task before applying cleanup.

## AI agent rules

AI agents follow the same Git history rules as human contributors plus these
operational boundaries:

1. Read [`AGENTS.md`](../AGENTS.md), run task preflight, create the Codex or Cursor tracker for
   non-trivial work, and state the intended write-set before edits.
2. Inspect `git status`, branch, and relevant upstream state before editing. Do
   not overwrite existing uncommitted changes.
3. Keep edits surgical. Do not change Flutter or Dart SDK sources to solve an
   application issue.
4. Run the repository-selected validation lane and report executed proof,
   failures, blockers, and residual risk.
5. Treat every Git state mutation as approval-gated, including stage/unstage,
   index/ref changes, commit, amend, stash, branch/tag/worktree changes, rebase,
   cherry-pick, push, PR creation, review submission, merge, deployment, and
   force-push. Take them only with direct current-turn user authorization;
   confirm affected items when required by [`AGENTS.md`](../AGENTS.md).
6. Stop for a user-owned decision, missing credentials, ambiguous conflict, or
   a required check that cannot be made green safely. Do not hide the condition
   with retries, skipped checks, or broad unrelated edits.

Repository-specific AI workflow and command routing remain in
[AGENTS.md](../AGENTS.md), [Agent Quick Reference](agents_quick_reference.md),
and [AI Code Review Protocol](ai_code_review_protocol.md).

## Fast reference

| Situation | Required action |
| --- | --- |
| New task | Update `main`, create one descriptive branch, inspect clean state. |
| Parallel task | Create separate worktree from `origin/main`. |
| Main advanced | Fetch, rebase private topic branch, resolve only clear conflicts, revalidate. |
| Ready for review | Inspect final diff, open focused PR, include validation evidence. |
| Checks pending or failing | Wait or fix root cause; do not merge. |
| PR merged | Fast-forward `main`, prune, then preview targeted cleanup. |
| AI needs remote or destructive Git action | Obtain current-turn user authorization first. |
