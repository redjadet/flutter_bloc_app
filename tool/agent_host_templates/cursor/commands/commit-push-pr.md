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

Safety:

- Never mention Cursor/AI/assistant in commit or PR text.
- Never change git config, use destructive git flags, bypass branch protection, or force-push shared branches.
- Don’t silently widen commit scope or absorb validator-generated files.
