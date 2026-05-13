#!/usr/bin/env bash
# Merge the open PR for this branch (via gh), then run local post-merge cleanup.
#
# Default merge flags (when you pass no gh args): --squash --delete-branch
# (matches upgrade-pr-triage-validate skill). Override by passing any gh pr merge args.
#
# Usage:
#   bash tool/commit_push_pr_merge_and_cleanup.sh
#   bash tool/commit_push_pr_merge_and_cleanup.sh 203
#   bash tool/commit_push_pr_merge_and_cleanup.sh -- --merge --delete-branch
#   bash tool/commit_push_pr_merge_and_cleanup.sh --remote upstream -- 42 --squash
#
# Also: python3 tool/commit_push_pr_deploy.py merge-cleanup [--remote NAME] [gh pr merge args...]
# Or watch CI then merge+cleanup: python3 tool/commit_push_pr_deploy.py watch-merge-cleanup [options] [PR] [merge args...]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REMOTE="origin"
GH_ARGS=()

usage() {
  cat <<'EOF'
Merge current branch PR (or given PR) with gh, then run post-merge local cleanup.

Usage:
  bash tool/commit_push_pr_merge_and_cleanup.sh [--remote NAME] [--] [gh pr merge args...]

With no gh args: runs  gh pr merge --squash --delete-branch  (PR for current branch).

Examples:
  bash tool/commit_push_pr_merge_and_cleanup.sh
  bash tool/commit_push_pr_merge_and_cleanup.sh 203 --squash
  bash tool/commit_push_pr_merge_and_cleanup.sh -- --merge --delete-branch

Requires: gh (authenticated), git. See  gh pr merge --help  for merge flags.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --remote)
      [[ "${2:-}" ]] || { echo "❌ --remote needs a name" >&2; exit 2; }
      REMOTE="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      GH_ARGS+=("$@")
      break
      ;;
    *)
      GH_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "${#GH_ARGS[@]}" -eq 0 ]]; then
  GH_ARGS=(--squash --delete-branch)
fi

echo "🔀 gh pr merge ${GH_ARGS[*]}"
gh pr merge "${GH_ARGS[@]}"

echo ""
exec bash "$PROJECT_ROOT/tool/commit_push_pr_post_merge.sh" --remote "$REMOTE"
