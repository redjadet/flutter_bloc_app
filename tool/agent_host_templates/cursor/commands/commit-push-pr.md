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

## Start (before commit / push / PR)

Rebase the **current branch** on the latest remote default branch (**`origin/main`** by default):

```bash
bash tool/commit_push_pr_rebase_on_main.sh
```

Other remote / base name:

```bash
bash tool/commit_push_pr_rebase_on_main.sh --remote upstream --branch main
```

Python:

```bash
python3 tool/commit_push_pr_deploy.py rebase-on-main
```

Use a **clean** worktree (or stash), resolve any conflicts, then continue with `commit_push_pr_deploy.py plan` / `execute`, commit, push, PR. If this branch was **already pushed**, update it with **`git push --force-with-lease`** after a successful rebase.

## Watch CI, merge when green, then clean up

Dedicated skill/command: `gh-watch-merge-pr` / `/watch-merge-pr`.

From the PR branch (or pass a PR number), wait for checks, merge, then local cleanup:

```bash
bash tool/commit_push_pr_watch_merge_cleanup.sh
bash tool/commit_push_pr_watch_merge_cleanup.sh 205
bash tool/commit_push_pr_watch_merge_cleanup.sh --interval 30 --fail-fast
```

Python:

```bash
python3 tool/commit_push_pr_deploy.py watch-merge-cleanup
python3 tool/commit_push_pr_deploy.py watch-merge-cleanup -i 30 --fail-fast 205
```

Uses `gh pr checks --watch`, then the same merge defaults as **merge-cleanup** (`--squash --delete-branch`), then **post-merge**.

## One-shot: merge PR then clean locals

When CI is green and you want **`gh pr merge` + post-merge** in one command (defaults: **`--squash --delete-branch`**, same as triage skill):

```bash
bash tool/commit_push_pr_merge_and_cleanup.sh
```

Override merge style / PR number (anything you would pass to `gh pr merge`):

```bash
bash tool/commit_push_pr_merge_and_cleanup.sh 203 --squash
bash tool/commit_push_pr_merge_and_cleanup.sh -- --merge --delete-branch
```

Python equivalent:

```bash
python3 tool/commit_push_pr_deploy.py merge-cleanup
python3 tool/commit_push_pr_deploy.py merge-cleanup --remote upstream -- 42 --squash
```

## After the PR is merged (required if you did not use merge-cleanup)

Run once GitHub shows the PR merged (for example `gh pr merge` completed):

```bash
python3 tool/commit_push_pr_deploy.py post-merge
```

Equivalent:

```bash
bash tool/commit_push_pr_post_merge.sh
```

Runs `git fetch --prune` on `origin`, **requires a clean worktree**, checks out the **remote default branch** (usually `main`: from `refs/remotes/origin/HEAD`, else `main`), then `git pull --ff-only`, then `tool/clean_merged_local_branches.sh` with **`--apply`**. If the worktree is dirty, the script **exits** so you never prune while still checked out on the merged topic branch—commit or stash, then re-run.

Safety:

- Never mention Cursor/AI/assistant in commit or PR text.
- Never change git config, use destructive git flags, bypass branch protection, or force-push shared branches.
- Don’t silently widen commit scope or absorb validator-generated files.
