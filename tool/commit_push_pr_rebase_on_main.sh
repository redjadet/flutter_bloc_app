#!/usr/bin/env bash
# First step of /commit-push-pr: fetch latest default branch and rebase current HEAD onto it.
#
# Usage:
#   bash tool/commit_push_pr_rebase_on_main.sh
#   bash tool/commit_push_pr_rebase_on_main.sh --remote upstream --branch main
#
# Also: python3 tool/commit_push_pr_deploy.py rebase-on-main

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REMOTE="origin"
BASE_BRANCH="main"

usage() {
  cat <<'EOF'
Fetch latest base branch and rebase the current branch onto <remote>/<branch>.

Default: origin + main (GitHub default). Use before commit / push / PR.

Requires: clean worktree (or resolve conflicts after rebase). If this branch was
already pushed, update remote with: git push --force-with-lease

Usage: bash tool/commit_push_pr_rebase_on_main.sh [--remote NAME] [--branch NAME]
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --remote)
      [[ "${2:-}" ]] || { echo "❌ --remote needs a name" >&2; exit 2; }
      REMOTE="$2"
      shift 2
      ;;
    --branch)
      [[ "${2:-}" ]] || { echo "❌ --branch needs a name" >&2; exit 2; }
      BASE_BRANCH="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "❌ unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

echo "📡 git fetch $REMOTE $BASE_BRANCH"
git fetch "$REMOTE" "$BASE_BRANCH"

echo "🔀 git rebase $REMOTE/$BASE_BRANCH"
git rebase "$REMOTE/$BASE_BRANCH"

current="$(git branch --show-current)"
echo "✓ Rebased onto $REMOTE/$BASE_BRANCH. If already pushed: git push --force-with-lease $REMOTE $current"
