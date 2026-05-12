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
  Main cleanup + upgrade lane. Triggers: "/upgrade-validate-all", "upgrade validate all",
  "run upgrade lane", "triage PRs then upgrade", "merge open renovate PRs then run validation".
argument-hint: "[$base_branch=main] [$fix_rounds=3]"
arguments:
  - base_branch
  - fix_rounds
context: inline
---

# Upgrade PR triage + validate

Keep `$base_branch` clean, run `./bin/upgrade_validate_all` on a fresh branch, land artifacts via PR when CI green.

**Canon:** `AGENTS.md`, `docs/agents_quick_reference.md`, `docs/engineering/validation_routing_fast_vs_full.md`

**Inputs:** `$base_branch` (default `main`), `$fix_rounds` (default `3`, integer >=0).

**Gates:** no stash/clean/reset; no force-push to `$base_branch`; worktree clean unless user opted in; no unmerged paths; if PR value ambiguous leave open; validate inputs; on failure print blocker + next action.

## Steps

1. **Preflight:** `test -x ./bin/upgrade_validate_all`; `gh auth status`; `git fetch origin "$base_branch"`; `git status --porcelain` empty; `git diff --name-only --diff-filter=U` empty.

2. **Triage PRs:** `gh pr list --state open --draft=false --base "$base_branch" --limit 200`. Per PR: `gh pr view` (mergeable, checks, draft); `gh pr checks`; if mergeable unknown wait/re-query; ready -> `gh pr merge --squash --delete-branch`; not beneficial -> `gh pr close` with reason; failing -> max `$fix_rounds` fix loops then merge or stop.

3. **Upgrade lane:** `git switch "$base_branch" && git pull --ff-only` -> `git switch -c "chore/upgrade-validate-all-$(date +%Y%m%d-%H%M%S)"` -> `flutter pub upgrade --major-versions` -> `SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all`. Optional (avoid mutating managed agent assets mid-lane):

```bash
SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all
```

1. **Land changes:** if diff exists: inspect `git status`/`git diff`; stage artifacts only; commit `chore(upgrade): refresh generated artifacts`; push; `gh pr create`; `gh pr checks --watch`; merge when green.
