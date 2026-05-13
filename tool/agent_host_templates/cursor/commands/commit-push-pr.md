---
name: commit-push-pr
description: Safely commit, push, and PR; watch CI; merge when green; otherwise diagnose, fix, and push again (bounded).
---

# commit-push-pr

Thin adapter. Repo policy wins.

Closed-loop: run end-to-end. Stop only on blockers: merge conflicts, missing
git author, secrets in staged set, missing `gh` auth, ambiguous mixed worktree.

Preferred entrypoint:

- Use repo helper when present: `tool/commit_push_pr_deploy.py`
- Otherwise follow `AGENTS.md` and `docs/agents_quick_reference.md`.

## After the PR is merged (required)

Run once GitHub shows the PR merged (for example `gh pr merge` completed):

```bash
python3 tool/commit_push_pr_deploy.py post-merge
```

Equivalent:

```bash
bash tool/commit_push_pr_post_merge.sh
```

This `git fetch --prune` on `origin`, checks out the remote default branch when the worktree is **clean**, `git pull --ff-only`, then runs `tool/clean_merged_local_branches.sh` with **`--apply`** (`--gone` and `--merged-base` for that default branch). If the worktree is dirty, checkout is skipped and only pruning runs.

Safety:

- Never mention Cursor/AI/assistant in commit or PR text.
- Never change git config, use destructive git flags, bypass branch protection, or force-push shared branches.
- Don’t silently widen commit scope or absorb validator-generated files.
