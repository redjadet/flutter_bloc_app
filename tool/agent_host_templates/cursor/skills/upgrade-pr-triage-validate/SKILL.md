---
name: upgrade-pr-triage-validate
description: Triage open non-draft PRs on main, merge/close/make-ready, run upgrade_validate_all, then PR and merge the resulting artifacts.
allowed-tools:
  - Shell(git:*)
  - Shell(gh:*)
  - Shell(flutter:*)
  - Shell(dart:*)
  - Read
  - Glob
  - ApplyPatch
  - AskQuestion
when_to_use: >
  Use when you want to run the repo's full upgrade lane but first keep main clean by
  processing open, non-draft PRs targeting main. Triggers: "/upgrade-validate-all",
  "upgrade validate all", "run upgrade lane", "triage PRs then upgrade",
  "merge open renovate PRs then run validation".
argument-hint: "[$base_branch=main] [$fix_rounds=3]"
arguments:
  - base_branch
  - fix_rounds
context: inline
---

# Upgrade PR triage + validate

Keep `$base_branch` clean, then run `./bin/upgrade_validate_all` on a new branch.
Land generated artifacts via PR when CI green.

Canon first:

- `AGENTS.md`
- `docs/agents_quick_reference.md`
- `docs/engineering/validation_routing_fast_vs_full.md`

Inputs:

- `$base_branch` (default `main`)
- `$fix_rounds` (default `3`)

Hard gates:

- No destructive git actions (no stash/clean/reset).
- No branch-protection bypass, no force-push to `$base_branch`.
- If PR value ambiguous: leave open and report blocker.
- Stop if unmerged paths or dirty worktree (unless user explicitly says to include local changes).
- Validate inputs: `$base_branch` non-empty; `$fix_rounds` integer \(>= 0\).
- On any gate failure: stop and print blocker + next action.

## Workflow (compressed)

1) Preflight

- `test -x ./bin/upgrade_validate_all`
- `gh auth status`
- `git fetch origin "$base_branch"`
- `git status --porcelain` (must be empty unless user opted in)
- `git diff --name-only --diff-filter=U` (must be empty; unmerged paths)

2) Triage open non-draft PRs targeting `$base_branch`

- List: `gh pr list --state open --draft=false --base "$base_branch" --limit 200`
- For each PR: `gh pr view <PR> --json mergeable,reviewDecision,statusCheckRollup,url,title,headRefName,isDraft`
- For each PR: `gh pr checks <PR>` (if pending/failed, wait or fix; do not merge)
- If `mergeable` is `UNKNOWN`, wait/re-query; do not merge on unknown.
- Ready → `gh pr merge <PR> --squash --delete-branch`
- Not beneficial → `gh pr close <PR> --comment "Closing because: <brief reason>."`
- Beneficial but failing → bounded fix loop (≤ `$fix_rounds`), then merge or report blocker

3) Run upgrade lane on a working branch

```bash
git switch "$base_branch" && git pull --ff-only
git switch -c "chore/upgrade-validate-all-$(date +%Y%m%d-%H%M%S)"
flutter pub upgrade --major-versions
SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all
```

Optional (avoid mutating managed agent assets during lane):

```bash
SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all
```

4) Land generated changes (if any)

- Inspect: `git status`, `git diff`
- Stage cohesive artifacts only; never secrets.
- Commit: `chore(upgrade): refresh generated artifacts`
- `git push -u origin HEAD`
- `gh pr create` then `gh pr checks --watch` then `gh pr merge --squash --delete-branch`
