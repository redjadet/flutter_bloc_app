---
name: gh-watch-merge-pr
description: >-
  Use when the user asks to watch a GitHub PR (or CI) and merge when ready —
  phrases like "watch it and merge", "merge when green", "land when CI
  passes", or a PR URL/number with merge-after-checks intent. Prefer over
  gh-fix-ci when checks are still running or already green and the goal is
  merge, not debugging failures.
---

# Watch PR → merge when green

Repo entrypoint owns the loop. Prefer script over ad-hoc `gh` polling.

## Preferred command

```bash
bash tool/commit_push_pr_watch_merge_cleanup.sh <pr>
# or current-branch PR:
bash tool/commit_push_pr_watch_merge_cleanup.sh
```

Python:

```bash
python3 tool/commit_push_pr_deploy.py watch-merge-cleanup <pr>
```

Defaults: `gh pr checks --watch` → `gh pr merge --squash --delete-branch` →
`tool/commit_push_pr_post_merge.sh`.

Merge-method override (after `--`):

```bash
bash tool/commit_push_pr_watch_merge_cleanup.sh 487 -- --merge --delete-branch
```

Already green, skip watch:

```bash
bash tool/commit_push_pr_merge_and_cleanup.sh <pr>
```

Docs: [`docs/validation_scripts/operations_running.md`](../../../../../docs/validation_scripts/operations_running.md).
Slash command: `/watch-merge-pr`. Full delivery loop: `/commit-push-pr`.

## Manual fallback (when script unavailable)

1. `gh auth status`
2. `gh pr view <pr> --json state,mergeable,mergeStateStatus,statusCheckRollup,url`
3. `gh pr checks <pr>` — if pending: `gh pr checks <pr> --watch`
4. Failures → stop; hand off to `gh-fix-ci` (do not merge)
5. When green + `MERGEABLE`/`CLEAN`: `gh pr merge <pr> --squash --delete-branch`
   (or `--merge` only if user/repo convention requires)
6. From primary worktree (usually on `main`): `bash tool/commit_push_pr_post_merge.sh`

## Worktree cleanup (required after merge)

`gh pr merge --delete-branch` deletes **remote** branch. Local post-merge fails
when another worktree still holds the **topic** branch **or** `main`.

Before claiming session done:

```bash
git worktree list
# topic worktree still on merged head:
git worktree remove <path>
# another worktree sitting on main (blocks primary checkout):
git -C <other-worktree> switch --detach HEAD
# then from primary tree:
bash tool/commit_push_pr_post_merge.sh
```

Do not force-remove a dirty worktree. Report dirty paths; ask before discard.

## Stop conditions

- Required checks failing → diagnose (`gh-fix-ci`), do not merge
- `mergeable: CONFLICTING` / blocked reviews → report blocker
- Missing `gh` auth / permissions → ask user
- User did not authorize merge → watch/report only

## Related

- Failures only: `gh-fix-ci`
- Create+ship loop: `/commit-push-pr`, `agents-delivery-workflow`
- Branch policy: [`docs/git_and_branching_strategy.md`](../../../../../docs/git_and_branching_strategy.md)
