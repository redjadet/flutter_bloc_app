# Upgrade PR triage + validate

Procedure for skill `upgrade-pr-triage-validate` and `/upgrade-validate-all`. Router:
[`../agents_quick_reference.md`](../agents_quick_reference.md) (SDK / tooling row).

## Inputs

- `$base_branch` — default `main`
- `$fix_rounds` — default `3`, integer `>= 0`

## Gates

- No stash/clean/reset; no force-push to `$base_branch`
- Worktree clean unless user opted in; no unmerged paths
- If PR value ambiguous, leave open
- On failure: print blocker + next action

## Steps

1. **Preflight:** `test -x ./bin/upgrade_validate_all`; `gh auth status`; `git fetch origin "$base_branch"`; `git status --porcelain` empty; `git diff --name-only --diff-filter=U` empty.

2. **Triage PRs:** `gh pr list --state open --draft=false --base "$base_branch" --limit 200`. Per PR: `gh pr view` (mergeable, checks, draft); prefer `bash tool/commit_push_pr_watch_merge_cleanup.sh <pr>` over ad-hoc check polling; if mergeable unknown wait/re-query. **Do not merge** dependency-bot PRs when only CodeQL (or other non-build checks) is green — require dependency-updates / build workflow that runs `flutter pub get`. **`renovate/artifacts` failing alone is non-blocking** (bot `dart pub` vs repo `flutter pub`); merge when required `build` / dependency-updates checks are green. ready → `gh pr merge --squash --delete-branch`; not beneficial → `gh pr close` with reason; failing → max `$fix_rounds` fix loops then merge or stop.

3. **Upgrade lane:** `git switch "$base_branch" && git pull --ff-only` → `git switch -c "chore/upgrade-validate-all-$(date +%Y%m%d-%H%M%S)"` → `flutter pub upgrade --major-versions` → `SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all`. Optional (avoid mutating managed agent assets mid-lane):

```bash
SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all
```

1. **Land changes:** if diff exists: inspect `git status`/`git diff`; stage artifacts only; commit `chore(upgrade): refresh generated artifacts`; push; `gh pr create`; `gh pr checks --watch`; merge when green.
