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

# Upgrade PR triage + validate + land results

Triage open, non-draft PRs targeting `$base_branch`, then run the repo's full
upgrade lane. If the lane generates repo artifacts, land them via PR and merge
when CI is green.

## Inputs

- `$base_branch`: Base branch to triage PRs against (default: `main`)
- `$fix_rounds`: Max fix attempts per beneficial-but-not-ready PR (default: `3`)

## Goal

- All open, non-draft PRs targeting `$base_branch` are handled:
  - beneficial+ready -> merged
  - clearly not beneficial -> closed with a short reason
  - beneficial but not ready -> made ready within bounds, then merged
  - ambiguous/blocked -> left open and reported with exact blocker
- `./bin/upgrade_validate_all` completes successfully.
- Generated repo changes, if any, are committed on a non-default branch, pushed,
  PR'd, CI-green, and merged.

## Steps

### 1. Preflight repo + auth

- Ensure repo script exists: `test -x ./bin/upgrade_validate_all`.
- Parse inputs:
  - `$base_branch` defaults to `main`; reject empty or whitespace-containing branch names.
  - `$fix_rounds` defaults to `3`; require a non-negative integer.
- Ensure git is clean enough to operate:
  - stop on unmerged paths
  - stop on dirty tracked/untracked files unless the user explicitly says to include them
  - do not stash, reset, clean, or discard changes automatically
- Ensure GitHub CLI auth: `gh auth status`.
- Ensure remote base exists: `git fetch origin "$base_branch"` then verify
  `origin/$base_branch`.

Success criteria:

- `gh auth status` succeeds.
- No merge conflicts/unmerged paths in git.
- Dirty worktree is absent or explicitly accepted by the user.
- `./bin/upgrade_validate_all` exists and is executable.
- `origin/$base_branch` resolves.

### 2. Triage open, non-draft PRs

List PRs:

```bash
gh pr list --state open --draft=false --base "$base_branch" --limit 200 \
  --json number,title,url,headRefName,baseRefName,author,labels,updatedAt
```

- If result count reaches the limit, raise the limit or page until all open,
  non-draft PRs targeting `$base_branch` have been considered.
- For each PR:
  - Inspect:
    `gh pr view <PR> --json mergeable,reviewDecision,statusCheckRollup,files,labels,commits,url,title,headRefName,baseRefName,isDraft`
  - Check: `gh pr checks <PR>` and required checks when branch protection marks
    only some checks as blocking.
  - If `mergeable` is `UNKNOWN`, wait briefly/re-query; do not merge on unknown.
  - If checks are pending, wait/re-check before deciding.
  - If the PR became draft, changed base, or was closed while triaging, skip and
    record that state.
  - Beneficial + ready: `gh pr merge <PR> --squash --delete-branch`.
  - Clearly not beneficial: close only when obsolete, superseded, unsafe, or
    outside repo scope:
    `gh pr close <PR> --comment "Closing because: <brief reason>."`
  - Beneficial but not ready:
    - prefer `gh pr checkout <PR>` followed by safe update from `origin/$base_branch`
    - avoid force-push unless PR branch is owned by this repo and user explicitly permits it
    - fix CI issues in PR branch, push, re-check checks
    - stop after `$fix_rounds` attempts and report blockers if still failing
  - Ambiguous business value or ownership: leave open and report; do not close
    or merge by guess.

Success criteria:

- No remaining beneficial, open, non-draft PRs targeting `$base_branch`.
- Any closed PRs have a short explanatory comment.
- Any merges completed without bypassing protection (`--admin` not used).
- Any skipped/blocked PRs are listed with exact reason and next action.

### 3. Update local base branch

```bash
git switch "$base_branch"
git pull --ff-only
```

Success criteria: local `$base_branch` is up to date with `origin/$base_branch`.

### 4. Create a working branch

Do upgrades off the base branch so the workspace never ends dirty on `main`.

```bash
git switch -c "chore/upgrade-validate-all-$(date +%Y%m%d-%H%M%S)"
```

Success criteria: current branch is not `$base_branch`.

### 5. Upgrade package graph post-triage

Requirement: run `flutter pub upgrade --major-versions` at least once after PR
triage. Do it now so the run happens even if later lane fails early.

```bash
flutter pub upgrade --major-versions
```

Success criteria: command exits `0`.

### 6. Run full upgrade lane

Run exactly:

```bash
SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all
```

Success criteria:

- Script exits `0`.
- Report pass/fail per step if it fails.

### 7. Land generated changes via PR

- If there are no changes, stop here.
- Commit workflow (must be explicit, safe):
  - Inspect scope first:
    - `git status`
    - `git diff`
  - Stage only cohesive generated artifacts (examples): `pubspec.lock`, coverage
    summary, docs badge/toolchain updates, managed host-template outputs.
  - Never stage: `.env*`, keys, credentials, local IDE state, simulator logs, or
    unrelated user edits.
  - Verify staged scope matches intent:
    - `git diff --staged`
  - Commit message rules:
    - concise, imperative, no trailing period
    - prefer conventional prefix: `chore(upgrade): ...` for this lane
    - no assistant mention
    - pass message via heredoc to preserve newlines
  - Commit example:
    - `git commit -m "$(cat <<'EOF'
chore(upgrade): refresh generated artifacts

Summary:

- Update lockfile + managed artifacts after upgrade lane

Tests:

- SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all
EOF
)" -- <paths...>`
- Push and open PR.
- Watch checks until complete: `gh pr checks <PR> --watch`.
- If checks fail: fix in bounded loops, max 3 pushes, then re-watch.
- When checks are green and PR mergeable: `gh pr merge <PR> --squash --delete-branch`.
- Sync local base branch again.

Success criteria:

- PR exists for generated changes, if any, and ends merged.
- Local `$base_branch` is clean and up to date afterward.

## Rules

- Never force-push to `$base_branch`.
- Never bypass branch protection (`--admin`).
- Keep fix attempts bounded (`$fix_rounds` per PR; max 3 push rounds for CI fixes).
- Don't commit secrets.
- If local changes are mixed/ambiguous, stop and require the user to pre-stage.
- Treat missing `gh` auth, branch protection blocks, unavailable integration
  devices, and dirty base branch as blockers, not reasons to skip validation.
