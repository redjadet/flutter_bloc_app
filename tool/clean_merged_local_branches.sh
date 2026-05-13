#!/usr/bin/env bash
# Safely delete local branches that are already merged or abandoned on the remote.
#
# What it does (opt-in modes):
#   --gone          Local branches whose upstream was deleted on the remote
#                   (git shows "[gone]" after fetch --prune). Typical after a merged
#                   PR that deleted the remote branch.
#   --merged-base X Local branches fully merged into revision X (e.g. origin/main).
#                   True merges only; squash merges are NOT detected here—use
#                   --gone after the remote topic branch is deleted, or delete the
#                   remote topic branch first then --gone.
#
# Safety:
#   Defaults to dry-run (prints actions only). Pass --apply to execute.
#   Never deletes the current branch, main, master, or develop.
#   Removes linked git worktrees (except the main repo checkout) before deleting a branch.
#
# Usage:
#   bash tool/clean_merged_local_branches.sh --gone
#   bash tool/clean_merged_local_branches.sh --gone --merged-base origin/main
#   bash tool/clean_merged_local_branches.sh --gone --apply --remote origin

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REMOTE="origin"
DRY_RUN=1
DO_GONE=0
DO_MERGED=0
BASE_REF=""

usage() {
  cat <<'EOF'
tool/clean_merged_local_branches.sh — delete merged or abandoned local branches (safe defaults).

Modes (use one or both):
  --gone                 Delete locals whose upstream was deleted on remote ([gone]).
  --merged-base REF      Delete locals fully merged into REF (e.g. origin/main).
                         True merges only; squash topics need remote branch deleted then --gone.

Options:
  --remote NAME          Remote to fetch/prune (default: origin).
  --dry-run              Print actions only (default).
  --apply                Perform deletions.

Protected: current branch, main, master, develop. Removes extra worktrees before branch -D.

Examples:
  bash tool/clean_merged_local_branches.sh --gone
  bash tool/clean_merged_local_branches.sh --gone --merged-base origin/main --apply
EOF
}

die() {
  echo "❌ $*" >&2
  exit 2
}

is_protected() {
  local b="$1"
  case "$b" in
    main | master | develop) return 0 ;;
  esac
  [[ "$b" == "$CURRENT_BRANCH" ]] && return 0
  return 1
}

# Print absolute path of worktree that holds branch $1, or empty if none / main only.
worktree_path_for_branch() {
  local want="$1"
  local path="" ref=""
  while IFS= read -r line; do
    case "$line" in
      worktree\ *) path="${line#worktree }" ;;
      branch\ refs/heads/*)
        ref="${line#branch refs/heads/}"
        if [[ "$ref" == "$want" ]]; then
          printf '%s\n' "$path"
          return 0
        fi
        ;;
    esac
  done < <(git worktree list --porcelain 2>/dev/null)
  return 1
}

TOPLEVEL="$(git rev-parse --show-toplevel)"

delete_branch_safe() {
  local branch="$1"
  local mode="$2" # -d or -D

  if is_protected "$branch"; then
    echo "  skip (protected): $branch"
    return 0
  fi

  local wt
  wt="$(worktree_path_for_branch "$branch" || true)"
  if [[ -n "$wt" && "$wt" != "$TOPLEVEL" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "  [dry-run] git worktree remove --force $wt"
    else
      echo "  worktree remove: $wt"
      git worktree remove --force "$wt"
    fi
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] git branch $mode $branch"
  else
    echo "  git branch $mode $branch"
    git branch "$mode" "$branch"
  fi
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --apply)
      DRY_RUN=0
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --gone)
      DO_GONE=1
      ;;
    --merged-base)
      DO_MERGED=1
      [[ "${2:-}" ]] || die "--merged-base requires a ref (e.g. origin/main)"
      BASE_REF="$2"
      shift
      ;;
    --remote)
      [[ "${2:-}" ]] || die "--remote requires a name"
      REMOTE="$2"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1 (try --help)"
      ;;
  esac
  shift
done

if [[ "$DO_GONE" -eq 0 && "$DO_MERGED" -eq 0 ]]; then
  die "pick at least one of --gone or --merged-base REF (see --help)"
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if ! git rev-parse -q --verify "$CURRENT_BRANCH" >/dev/null; then
  die "detached HEAD; checkout a branch before running"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "ℹ️  Dry-run (no changes). Pass --apply to execute."
fi
echo "remote=$REMOTE base=${BASE_REF:-<none>} top=$TOPLEVEL on_branch=$CURRENT_BRANCH"
echo ""

echo "📡 git fetch --prune $REMOTE"
git fetch --prune "$REMOTE"

if [[ "$DO_GONE" -eq 1 ]]; then
  echo ""
  echo "== Branches with upstream [gone] =="
  mapfile -t GONE_BRANCHES < <(
    git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads |
      awk '$2 == "[gone]" { print $1 }' | sort -u
  )
  if [[ "${#GONE_BRANCHES[@]}" -eq 0 || -z "${GONE_BRANCHES[0]:-}" ]]; then
    echo "(none)"
  else
    for b in "${GONE_BRANCHES[@]}"; do
      [[ -z "$b" ]] && continue
      if is_protected "$b"; then
        echo "  skip (protected): $b"
        continue
      fi
      echo "- $b"
      delete_branch_safe "$b" "-D"
    done
  fi
fi

if [[ "$DO_MERGED" -eq 1 ]]; then
  echo ""
  echo "== Branches merged into $BASE_REF =="
  if ! git rev-parse -q --verify "$BASE_REF" >/dev/null; then
    die "ref not found: $BASE_REF (fetch $REMOTE first)"
  fi
  mapfile -t MERGED_BRANCHES < <(
    git branch --merged "$BASE_REF" | sed 's/^[* ] //' | sort -u
  )
  merged_shown=0
  for b in "${MERGED_BRANCHES[@]}"; do
    [[ -z "$b" ]] && continue
    if ! git show-ref -q --verify "refs/heads/$b"; then
      continue
    fi
    if is_protected "$b"; then
      continue
    fi
    merged_shown=1
    echo "- $b"
    # Merged: prefer -d; if it fails (e.g. rare edge), user can use --gone + -D.
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "  [dry-run] git branch -d $b"
    else
      if ! git branch -d "$b"; then
        echo "  ⚠️  git branch -d $b failed (try deleting remote topic branch, then --gone --apply)" >&2
      fi
    fi
  done
  if [[ "$merged_shown" -eq 0 ]]; then
    echo "(none)"
  fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo ""
  echo "Done (dry-run). Re-run with --apply to delete."
else
  echo ""
  echo "Done."
fi
