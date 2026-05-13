#!/usr/bin/env bash
# End-of-flow for commit-push-pr: after a PR is merged on GitHub, run locally to
# fetch/prune, switch to the remote default branch (usually main), pull, then
# delete merged / [gone] local branches (see clean_merged_local_branches.sh).
# Requires a clean worktree so checkout happens before cleanup (otherwise the
# merged topic branch may still be checked out and cannot be removed).
#
# Usage:
#   bash tool/commit_push_pr_post_merge.sh
#   bash tool/commit_push_pr_post_merge.sh --remote upstream
#
# Also: python3 tool/commit_push_pr_deploy.py post-merge
# Or merge + cleanup in one step: bash tool/commit_push_pr_merge_and_cleanup.sh
# Or watch CI + merge + cleanup: bash tool/commit_push_pr_watch_merge_cleanup.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REMOTE="origin"
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --remote)
      [[ "${2:-}" ]] || { echo "❌ --remote needs a name" >&2; exit 2; }
      REMOTE="$2"
      shift
      ;;
    -h | --help)
      cat <<'EOF'
After a PR is merged: fetch/prune, checkout remote default branch (e.g. main),
git pull --ff-only, then run clean_merged_local_branches.sh --apply.

Requires a clean worktree (commit or stash first).

Usage: bash tool/commit_push_pr_post_merge.sh [--remote NAME]

Or: python3 tool/commit_push_pr_deploy.py post-merge
EOF
      exit 0
      ;;
    *)
      echo "❌ unknown arg: $1" >&2
      exit 2
      ;;
  esac
  shift
done

echo "📡 git fetch --prune $REMOTE"
git fetch --prune "$REMOTE"

default_branch="$(
  git symbolic-ref -q "refs/remotes/${REMOTE}/HEAD" 2>/dev/null |
    sed "s@^refs/remotes/${REMOTE}/@@"
)"
if [[ -z "$default_branch" ]]; then
  default_branch="main"
fi
base_ref="${REMOTE}/${default_branch}"

if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  echo "❌ Dirty worktree: checkout $default_branch is required before local branch cleanup." >&2
  echo "   Commit or stash your changes, then re-run this script." >&2
  exit 1
fi

current="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current" != "$default_branch" ]]; then
  echo "🔀 checkout $default_branch (default branch before cleanup)"
  git checkout "$default_branch"
else
  echo "✓ already on $default_branch"
fi
echo "⬇️  git pull --ff-only $REMOTE $default_branch"
git pull --ff-only "$REMOTE" "$default_branch"

echo ""
exec bash "$PROJECT_ROOT/tool/clean_merged_local_branches.sh" \
  --gone \
  --merged-base "$base_ref" \
  --apply \
  --remote "$REMOTE"
