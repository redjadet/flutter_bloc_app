#!/usr/bin/env bash
# End-of-flow for commit-push-pr: after a PR is merged on GitHub, run locally to
# fetch/prune, optionally switch to the remote default branch when the worktree
# is clean, then delete merged / [gone] local branches (see clean_merged_local_branches.sh).
#
# Usage:
#   bash tool/commit_push_pr_post_merge.sh
#   bash tool/commit_push_pr_post_merge.sh --remote upstream
#
# Also: python3 tool/commit_push_pr_deploy.py post-merge
# Or merge + cleanup in one step: bash tool/commit_push_pr_merge_and_cleanup.sh

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
After a PR is merged: fetch/prune, checkout default branch if worktree is clean,
then run clean_merged_local_branches.sh --apply.

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

default_branch="$(
  git symbolic-ref -q "refs/remotes/${REMOTE}/HEAD" 2>/dev/null |
    sed "s@^refs/remotes/${REMOTE}/@@"
)"
if [[ -z "$default_branch" ]]; then
  default_branch="main"
fi
base_ref="${REMOTE}/${default_branch}"

echo "📡 git fetch --prune $REMOTE"
git fetch --prune "$REMOTE"

if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
  current="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$current" != "$default_branch" ]]; then
    echo "🔀 checkout $default_branch (clean worktree)"
    git checkout "$default_branch"
  else
    echo "✓ already on $default_branch"
  fi
  echo "⬇️  git pull --ff-only $REMOTE $default_branch"
  git pull --ff-only "$REMOTE" "$default_branch"
else
  echo "⚠️  Dirty worktree: skipping checkout/pull. Pruning locals only." >&2
fi

echo ""
exec bash "$PROJECT_ROOT/tool/clean_merged_local_branches.sh" \
  --gone \
  --merged-base "$base_ref" \
  --apply \
  --remote "$REMOTE"
