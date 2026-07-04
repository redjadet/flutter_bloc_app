# Agent automated delivery loop

**Date:** 2026-05-21  
**Canon for:** `/commit-push-pr`, checklist + integration proof before land, post-merge `main` sync.  
**Example:** [PR #240](https://github.com/redjadet/flutter_bloc_app/pull/240) (ARCH-001/002).

## Automated sequence (agents)

| Step | Command / tool | Notes |
| --- | --- | --- |
| 1 | `bash tool/commit_push_pr_rebase_on_main.sh` | Clean worktree first; rebase topic branch on `origin/main` |
| 2 | Commit + push | Feature scope only; **omit** local [`coverage/coverage_summary.md`](../../coverage/coverage_summary.md) and README badge churn from `./bin/checklist` unless intentionally shipping coverage |
| 3 | `gh pr create` or `python3 tool/commit_push_pr_deploy.py` | No AI/Cursor wording in commits or PR body |
| 4 | `bash tool/commit_push_pr_watch_merge_cleanup.sh <pr>` | `gh pr checks --watch` → squash merge + delete branch → post-merge |
| 5 | Post-merge local sync | If `git pull --ff-only` on `main` fails after squash merge, use `git fetch --prune origin && git reset --hard origin/main` (worktree must be clean) |

Script reference: [`docs/validation_scripts.md`](../validation_scripts.md) § Git.

## Proof gates (full ship example)

```bash
./bin/checklist                    # exit 0
./bin/integration_tests            # all_flows_test.dart, 23 passed (iOS sim)
flutter test test/features/case_study_demo test/features/camera_gallery
bash tool/modular_metrics.sh --cross-feature-only
bash tool/check_feature_brief_linked.sh --base origin/main
```

## Feature-brief guard (Phase 5)

When `apps/mobile/lib/features/**/*.dart` changes, run:

```bash
bash tool/check_feature_brief_linked.sh
```

Add or update `docs/changes/*.md`, or `SKIP_FEATURE_BRIEF=1` for trivial-only fixes. Strict CI: `FEATURE_BRIEF_CHECK_STRICT=1`.
