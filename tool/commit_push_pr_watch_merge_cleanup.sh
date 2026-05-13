#!/usr/bin/env bash
# Wait for GitHub Actions checks on the current branch's PR (or a given PR number),
# merge when green, then run local post-merge cleanup (default branch checkout + prune).
#
# Merge defaults when you pass no merge flags: --squash --delete-branch
# (same as commit_push_pr_merge_and_cleanup.sh).
#
# Usage:
#   bash tool/commit_push_pr_watch_merge_cleanup.sh
#   bash tool/commit_push_pr_watch_merge_cleanup.sh 205
#   bash tool/commit_push_pr_watch_merge_cleanup.sh --interval 30 --fail-fast
#   bash tool/commit_push_pr_watch_merge_cleanup.sh --remote upstream 42 -- --merge --delete-branch
#
# Also: python3 tool/commit_push_pr_deploy.py watch-merge-cleanup [options] [PR] [merge args...]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REMOTE="origin"
PR=""
INTERVAL_FLAGS=()
FAIL_FAST_FLAGS=()
MERGE_ARGS=()

usage() {
  cat <<'EOF'
Watch CI on a PR, merge when all checks finish successfully, then local cleanup.

Steps:
  1) gh pr checks [--watch]  (current branch's PR, or PR number if given)
  2) gh pr merge …           (default: --squash --delete-branch)
  3) tool/commit_push_pr_post_merge.sh  (checkout default branch, pull, prune locals)

Options (this script):
  --remote NAME     Remote for post-merge cleanup (default: origin).
  -i, --interval N  Seconds between polls (passed to gh pr checks --watch).
  --fail-fast       Exit watch on first failing check (gh pr checks --fail-fast).

Put script options (--remote, --interval, --fail-fast) before an optional PR number
and merge flags (defaults: --squash --delete-branch).

Examples:
  bash tool/commit_push_pr_watch_merge_cleanup.sh
  bash tool/commit_push_pr_watch_merge_cleanup.sh 205
  bash tool/commit_push_pr_watch_merge_cleanup.sh -- --merge --delete-branch

Requires: gh (authenticated), git. See gh pr checks --help and gh pr merge --help.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --remote)
      [[ "${2:-}" ]] || { echo "❌ --remote needs a name" >&2; exit 2; }
      REMOTE="$2"
      shift 2
      ;;
    -i | --interval)
      [[ "${2:-}" ]] || { echo "❌ --interval needs a number" >&2; exit 2; }
      INTERVAL_FLAGS=(-i "$2")
      shift 2
      ;;
    --fail-fast)
      FAIL_FAST_FLAGS=(--fail-fast)
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      MERGE_ARGS+=("$@")
      break
      ;;
    *)
      if [[ -z "$PR" && "$1" =~ ^[0-9]+$ ]]; then
        PR="$1"
        shift
      else
        MERGE_ARGS+=("$1")
        shift
      fi
      ;;
  esac
done

if [[ "${#MERGE_ARGS[@]}" -eq 0 ]]; then
  MERGE_ARGS=(--squash --delete-branch)
fi

CHECK_CMD=(gh pr checks)
if [[ -n "$PR" ]]; then
  CHECK_CMD+=("$PR")
fi
CHECK_CMD+=(--watch "${INTERVAL_FLAGS[@]}" "${FAIL_FAST_FLAGS[@]}")

echo "⏳ ${CHECK_CMD[*]}"
"${CHECK_CMD[@]}"

MERGE_CMD=(bash "$PROJECT_ROOT/tool/commit_push_pr_merge_and_cleanup.sh" --remote "$REMOTE")
if [[ -n "$PR" ]]; then
  MERGE_CMD+=("$PR")
fi
MERGE_CMD+=("${MERGE_ARGS[@]}")

echo ""
echo "🔀 ${MERGE_CMD[*]}"
exec "${MERGE_CMD[@]}"
