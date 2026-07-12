# Validation scripts — running and sync

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Keeping This Doc in Sync

`tool/validate_validation_docs.sh` checks that every on-disk `tool/check_*.sh`
script (except `check_helpers.sh`) is mentioned in [`validation_scripts.md`](../validation_scripts.md)
or a shard under [`validation_scripts/`](.), and that [`catalog.md`](catalog.md)
and [`overview.md`](overview.md) inventory counts match disk + `CHECK_SCRIPTS`.
The auto-generated checklist index lives in [`checklist_index.md`](checklist_index.md).
Run `bash tool/fix_validation_docs.sh` to refresh the index block after
`CHECK_SCRIPTS` changes, then `bash tool/validate_validation_docs.sh` to verify.

## Running Validation Scripts

### Full Sweep

All validation scripts are run by delivery checklist when you want full
repo sweep:

```bash
./bin/checklist
```

This runs all validation scripts in sequence and fails if any critical violations are found.

### Fast Local Sanity Path

Use `./bin/checklist-fast` for local-only sanity pass when tree is clean
or when local change set is limited to docs/tooling surfaces (including
agent-readable docs such as `llms.txt`):

```bash
./bin/checklist-fast
```

Contract:

- local only; CI must keep using `./bin/checklist`
- supports clean-tree sanity checks
- supports narrow local docs/tooling change sets only
- refuses broader app/runtime diffs instead of silently weakening full gate
- runs syntax/doc-link/doc-sync/agent-drift checks when relevant
- skips dependency, analyze, app validator-suite, Mix lint, focused regression, and coverage work

checklist is also change-aware:

- skips `flutter pub get` when dependency metadata is unchanged
- formats only changed Dart files
- exits early for docs-only change sets instead of running code validation
- exits early for local tooling-only change sets (`tool/*.sh`, `bin/*`, host-template files, and validation-guidance docs) after syntax/doc-sync/drift checks instead of running app-wide Flutter validation
- caches checklist self-validation until checklist script/dependency scripts or validation docs change

## Git pre-commit hook (optional, local)

Install once per clone:

```bash
./bin/install-git-hooks
```

Sets `git config core.hooksPath githooks`. The tracked `githooks/pre-commit` runs
`tool/check_mutation_success_after_guard.sh --staged`:

- scans staged `lib/**/*.dart` when any are staged
- scans all of `lib/` when `request_id_guard.dart`, the guard script, or fixtures change
- skips when the index has no relevant paths

Full static sweep still runs in `./bin/checklist` / CI. Pre-commit is a narrow early
lane for the RequestIdGuard supersession bug class only.

Uninstall: `git config --unset core.hooksPath` (or point at your own hooks dir).

## Git · local branch cleanup

- **`commit_push_pr_rebase_on_main.sh`**: **Start of `/commit-push-pr`**: `git fetch` + **`git rebase <remote>/<branch>`** (default **`origin/main`**). Optional **`--remote`**, **`--branch`**. See `bash tool/commit_push_pr_rebase_on_main.sh --help`.
- **`commit_push_pr_watch_merge_cleanup.sh`**: **`gh pr checks --watch`** until CI finishes, then **`commit_push_pr_merge_and_cleanup.sh`** (merge + post-merge). Optional **`--interval`**, **`--fail-fast`**, optional leading **PR number**, same merge defaults as merge+cleanup. Agent skill: `gh-watch-merge-pr`; Cursor command: `/watch-merge-pr`. See `bash tool/commit_push_pr_watch_merge_cleanup.sh --help`.
- **`commit_push_pr_merge_and_cleanup.sh`**: **`gh pr merge`** then **`commit_push_pr_post_merge.sh`**. With no extra args, merge uses **`--squash --delete-branch`**. Pass **`--`** then any `gh pr merge` flags/PR number. Optional **`--remote`** for the cleanup step. See `bash tool/commit_push_pr_merge_and_cleanup.sh --help`.
- **`commit_push_pr_post_merge.sh`**: After a PR is merged on GitHub, run locally (or `python3 tool/commit_push_pr_deploy.py post-merge`). Fetches/prunes `origin`, **requires a clean worktree**, checks out the **remote default branch** (from `refs/remotes/origin/HEAD`, else `main`), **`git pull --ff-only`**, then runs **`clean_merged_local_branches.sh`** with **`--apply`**. Aborts with exit **1** if the worktree is dirty (cleanup must not run while still on a topic branch you intend to delete).
- **`clean_merged_local_branches.sh`**: Deletes **local** branches that are safe to drop: `--gone` (upstream deleted after `git fetch --prune`) and/or `--merged-base origin/main` (true merges into that ref only; squash merges need the remote topic branch removed first, then `--gone`). Defaults to **dry-run**; pass **`--apply`** to execute. Removes linked **worktrees** (not the main checkout) before deleting a branch. See `bash tool/clean_merged_local_branches.sh --help`.
