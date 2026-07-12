---
name: watch-merge-pr
description: Watch GitHub PR checks, merge when green, then local post-merge cleanup.
---

# watch-merge-pr

Thin adapter. Repo policy wins. Skill: `gh-watch-merge-pr`.

Watch CI → merge → cleanup:

```bash
bash tool/commit_push_pr_watch_merge_cleanup.sh
bash tool/commit_push_pr_watch_merge_cleanup.sh 487
bash tool/commit_push_pr_watch_merge_cleanup.sh --interval 30 --fail-fast 487
```

Python:

```bash
python3 tool/commit_push_pr_deploy.py watch-merge-cleanup
python3 tool/commit_push_pr_deploy.py watch-merge-cleanup -i 30 --fail-fast 487
```

Defaults: squash merge + delete remote branch + `commit_push_pr_post_merge.sh`.

Merge-commit style:

```bash
bash tool/commit_push_pr_watch_merge_cleanup.sh 487 -- --merge --delete-branch
```

Already green:

```bash
bash tool/commit_push_pr_merge_and_cleanup.sh 487
```

After merge: remove any leftover worktree still on the merged head branch, then
post-merge from the primary tree. See skill `gh-watch-merge-pr`.

Related: `/commit-push-pr`, `docs/validation_scripts/operations_running.md`,
`docs/git_and_branching_strategy.md`.
