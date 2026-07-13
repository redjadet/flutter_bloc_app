#!/usr/bin/env bash
# Prune stale git worktrees and topic branches already finished on the base branch.
#
# Covers what clean_merged_local_branches.sh misses:
#   - squash-merged topics (via gh MERGED PRs)
#   - optional CLOSED unmerged PR heads (--closed-prs)
#   - remote topic deletion (batched git push --delete)
#   - extra worktrees whose HEAD is already an ancestor of the base
#
# Defaults to dry-run. Pass --apply to execute.
# Requires: git. Optional: gh (for PR-based squash/closed detection).
#
# Usage:
#   ./bin/prune-git-stale
#   ./bin/prune-git-stale --closed-prs --keep mapbox-demo-improvements-2026-03-23
#   ./bin/prune-git-stale --closed-prs --keep mapbox-demo-improvements-2026-03-23 --apply

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REMOTE="origin"
BASE_REF="" # resolved after fetch (default: $REMOTE/main or remote HEAD)
DRY_RUN=1
DO_CLOSED=0
DO_WORKTREES=1
DO_REMOTES=1
DO_LOCALS=1
FORCE_DIRTY_WORKTREES=1
KEEP_BRANCHES=()

usage() {
  cat <<'EOF'
tool/prune_git_stale.sh — prune merged/closed topic branches + stale worktrees.

Always (preview or apply):
  git fetch --prune <remote>
  detect: true-merged, [gone] locals, gh MERGED heads, ancestor worktrees
  optional: gh CLOSED unmerged heads (--closed-prs)

Options:
  --remote NAME          Remote (default: origin)
  --base REF             Base ref after fetch (default: <remote>/main, else remote HEAD)
  --closed-prs           Also delete CLOSED (unmerged) PR head branches
  --keep NAME            Keep branch (repeatable; exact short name, no origin/)
  --skip-worktrees       Do not remove extra worktrees
  --skip-remotes         Do not delete remote branches
  --skip-locals          Do not delete local branches
  --no-force-worktrees   Skip dirty extra worktrees instead of force-remove
  --dry-run              Print actions only (default)
  --apply                Perform deletions
  -h, --help             Show this help

Protected: current branch, main, master, develop, and --keep names.
Remote protected: main/master/develop and the remote HEAD branch.

Examples:
  bash tool/prune_git_stale.sh
  bash tool/prune_git_stale.sh --closed-prs --keep mapbox-demo-improvements-2026-03-23
  bash tool/prune_git_stale.sh --closed-prs --keep mapbox-demo-improvements-2026-03-23 --apply
  ./bin/prune-git-stale --apply
EOF
}

die() {
  echo "❌ $*" >&2
  exit 2
}

info() {
  echo "$*"
}

short_branch() {
  local name="$1"
  name="${name#refs/heads/}"
  name="${name#refs/remotes/}"
  if [[ "$name" == "$REMOTE/"* ]]; then
    name="${name#"$REMOTE"/}"
  fi
  printf '%s\n' "$name"
}

is_keep() {
  local b="$1"
  local k
  for k in "${KEEP_BRANCHES[@]+"${KEEP_BRANCHES[@]}"}"; do
    [[ "$b" == "$k" ]] && return 0
  done
  return 1
}

is_protected_local() {
  local b="$1"
  case "$b" in
    main | master | develop) return 0 ;;
  esac
  [[ "$b" == "$CURRENT_BRANCH" ]] && return 0
  is_keep "$b" && return 0
  return 1
}

is_protected_remote_short() {
  local b="$1"
  case "$b" in
    main | master | develop | HEAD) return 0 ;;
  esac
  [[ -n "${REMOTE_HEAD_BRANCH:-}" && "$b" == "$REMOTE_HEAD_BRANCH" ]] && return 0
  is_keep "$b" && return 0
  return 1
}

array_contains() {
  local needle="$1"
  shift
  local x
  for x in "$@"; do
    [[ "$x" == "$needle" ]] && return 0
  done
  return 1
}

add_unique() {
  # add_unique ARRAY_NAME value
  local -n _arr="$1"
  local val="$2"
  [[ -z "$val" ]] && return 0
  local x
  for x in "${_arr[@]+"${_arr[@]}"}"; do
    [[ "$x" == "$val" ]] && return 0
  done
  _arr+=("$val")
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --apply) DRY_RUN=0 ;;
    --dry-run) DRY_RUN=1 ;;
    --closed-prs) DO_CLOSED=1 ;;
    --skip-worktrees) DO_WORKTREES=0 ;;
    --skip-remotes) DO_REMOTES=0 ;;
    --skip-locals) DO_LOCALS=0 ;;
    --no-force-worktrees) FORCE_DIRTY_WORKTREES=0 ;;
    --remote)
      [[ "${2:-}" ]] || die "--remote requires a name"
      REMOTE="$2"
      shift
      ;;
    --base)
      [[ "${2:-}" ]] || die "--base requires a ref"
      BASE_REF="$2"
      shift
      ;;
    --keep)
      [[ "${2:-}" ]] || die "--keep requires a branch name"
      KEEP_BRANCHES+=("$(short_branch "$2")")
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

command -v git >/dev/null || die "git required"
TOPLEVEL="$(git rev-parse --show-toplevel)"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if ! git rev-parse -q --verify "$CURRENT_BRANCH" >/dev/null; then
  die "detached HEAD; checkout a branch before running"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  info "ℹ️  Dry-run (no changes). Pass --apply to execute."
fi

info "📡 git fetch --prune $REMOTE"
git fetch --prune "$REMOTE"

REMOTE_HEAD_BRANCH=""
if git rev-parse -q --verify "$REMOTE/HEAD" >/dev/null; then
  REMOTE_HEAD_BRANCH="$(git symbolic-ref -q --short "$REMOTE/HEAD" 2>/dev/null || true)"
  REMOTE_HEAD_BRANCH="$(short_branch "${REMOTE_HEAD_BRANCH:-}")"
fi

if [[ -z "$BASE_REF" ]]; then
  if git rev-parse -q --verify "$REMOTE/main" >/dev/null; then
    BASE_REF="$REMOTE/main"
  elif [[ -n "$REMOTE_HEAD_BRANCH" ]]; then
    BASE_REF="$REMOTE/$REMOTE_HEAD_BRANCH"
  else
    die "could not resolve base ref; pass --base $REMOTE/main"
  fi
fi
git rev-parse -q --verify "$BASE_REF" >/dev/null || die "base ref not found: $BASE_REF"

info "remote=$REMOTE base=$BASE_REF top=$TOPLEVEL on_branch=$CURRENT_BRANCH closed_prs=$DO_CLOSED"
if [[ "${#KEEP_BRANCHES[@]}" -gt 0 ]]; then
  info "keep: ${KEEP_BRANCHES[*]}"
fi
info ""

MERGED_PR_HEADS=()
CLOSED_PR_HEADS=()
OPEN_PR_HEADS=()
HAS_GH=0
if command -v gh >/dev/null 2>&1; then
  HAS_GH=1
  info "🔎 Loading PR heads via gh (batched)…"
  # shellcheck disable=SC2207
  OPEN_PR_HEADS=($(
    gh pr list --state open --limit 500 --json headRefName \
      --jq '.[].headRefName' 2>/dev/null | sort -u || true
  ))
  # shellcheck disable=SC2207
  MERGED_PR_HEADS=($(
    gh pr list --state merged --limit 500 --json headRefName \
      --jq '.[].headRefName' 2>/dev/null | sort -u || true
  ))
  if [[ "$DO_CLOSED" -eq 1 ]]; then
    # shellcheck disable=SC2207
    CLOSED_PR_HEADS=($(
      gh pr list --search 'is:closed is:unmerged' --limit 500 --json headRefName \
        --jq '.[].headRefName' 2>/dev/null | sort -u || true
    ))
  fi
  info "  open=${#OPEN_PR_HEADS[@]} merged=${#MERGED_PR_HEADS[@]} closed-unmerged=${#CLOSED_PR_HEADS[@]}"
else
  info "⚠️  gh not found — squash/closed PR detection skipped (git-merge + gone only)"
fi

has_open_pr() {
  [[ "$HAS_GH" -eq 1 ]] || return 1
  array_contains "$1" ${OPEN_PR_HEADS[@]+"${OPEN_PR_HEADS[@]}"}
}

is_merged_pr_head() {
  [[ "$HAS_GH" -eq 1 ]] || return 1
  # Renovate (and others) reuse head names — never treat an open head as finished.
  has_open_pr "$1" && return 1
  array_contains "$1" ${MERGED_PR_HEADS[@]+"${MERGED_PR_HEADS[@]}"}
}

is_closed_pr_head() {
  [[ "$HAS_GH" -eq 1 && "$DO_CLOSED" -eq 1 ]] || return 1
  has_open_pr "$1" && return 1
  array_contains "$1" ${CLOSED_PR_HEADS[@]+"${CLOSED_PR_HEADS[@]}"}
}

LOCAL_DELETE=()
REMOTE_DELETE=()
WORKTREE_REMOVE=()

# --- worktrees (extra checkouts whose HEAD is already on base) ---
if [[ "$DO_WORKTREES" -eq 1 ]]; then
  info ""
  info "== Extra worktrees (HEAD ancestor of $BASE_REF) =="
  wt_path=""
  wt_head=""
  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        wt_path="${line#worktree }"
        wt_head=""
        ;;
      HEAD\ *)
        wt_head="${line#HEAD }"
        ;;
      '')
        if [[ -n "$wt_path" && "$wt_path" != "$TOPLEVEL" && -n "$wt_head" ]]; then
          if git merge-base --is-ancestor "$wt_head" "$BASE_REF" 2>/dev/null; then
            dirty="$(git -C "$wt_path" status --porcelain 2>/dev/null || true)"
            if [[ -n "$dirty" && "$FORCE_DIRTY_WORKTREES" -eq 0 ]]; then
              info "  skip (dirty, --no-force-worktrees): $wt_path"
            else
              info "  - $wt_path ($wt_head)${dirty:+ [dirty→force]}"
              add_unique WORKTREE_REMOVE "$wt_path"
            fi
          else
            info "  keep (not on base): $wt_path"
          fi
        fi
        wt_path=""
        wt_head=""
        ;;
    esac
  done < <(git worktree list --porcelain; echo)
  if [[ "${#WORKTREE_REMOVE[@]}" -eq 0 ]]; then
    info "(none)"
  fi
fi

# --- local candidates ---
if [[ "$DO_LOCALS" -eq 1 ]]; then
  info ""
  info "== Local branches to delete =="
  while IFS= read -r b; do
    [[ -z "$b" || "$b" == "*"* ]] && continue
    b="${b## }"
    b="${b#\* }"
    is_protected_local "$b" && continue
    has_open_pr "$b" && continue

    reason=""
    if git for-each-ref --format='%(upstream:track)' "refs/heads/$b" 2>/dev/null | grep -qx '\[gone\]'; then
      reason="gone"
    elif git merge-base --is-ancestor "refs/heads/$b" "$BASE_REF" 2>/dev/null; then
      reason="merged-into-base"
    elif is_merged_pr_head "$b"; then
      reason="pr-merged"
    elif is_closed_pr_head "$b"; then
      reason="pr-closed"
    else
      continue
    fi
    info "  - $b ($reason)"
    add_unique LOCAL_DELETE "$b"
  done < <(git for-each-ref --format='%(refname:short)' refs/heads | sort -u)
  if [[ "${#LOCAL_DELETE[@]}" -eq 0 ]]; then
    info "(none)"
  fi
fi

# --- remote candidates ---
if [[ "$DO_REMOTES" -eq 1 ]]; then
  info ""
  info "== Remote branches to delete ($REMOTE) =="
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    # Skip remote HEAD symlink (often short name "$REMOTE" or "$REMOTE/HEAD").
    case "$ref" in
      "$REMOTE" | "$REMOTE/HEAD" | HEAD) continue ;;
    esac
    short="$(short_branch "$ref")"
    [[ -z "$short" || "$short" == "$REMOTE" || "$short" == "HEAD" ]] && continue
    is_protected_remote_short "$short" && continue
    has_open_pr "$short" && continue

    reason=""
    if git merge-base --is-ancestor "$ref" "$BASE_REF" 2>/dev/null; then
      reason="merged-into-base"
    elif is_merged_pr_head "$short"; then
      reason="pr-merged"
    elif is_closed_pr_head "$short"; then
      reason="pr-closed"
    else
      continue
    fi
    info "  - $REMOTE/$short ($reason)"
    add_unique REMOTE_DELETE "$short"
  done < <(git for-each-ref --format='%(refname:short)' "refs/remotes/$REMOTE" | sort -u)
  if [[ "${#REMOTE_DELETE[@]}" -eq 0 ]]; then
    info "(none)"
  fi
fi

# --- apply / dry-run summary ---
info ""
info "== Plan =="
info "  worktrees: ${#WORKTREE_REMOVE[@]}"
info "  remotes:   ${#REMOTE_DELETE[@]}"
info "  locals:    ${#LOCAL_DELETE[@]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  info ""
  info "Done (dry-run). Re-run with --apply to delete."
  exit 0
fi

info ""
info "== Apply =="

for wt in "${WORKTREE_REMOVE[@]+"${WORKTREE_REMOVE[@]}"}"; do
  [[ -z "$wt" ]] && continue
  info "  worktree remove --force $wt"
  git worktree remove --force "$wt"
done
git worktree prune -v >/dev/null 2>&1 || true

if [[ "${#REMOTE_DELETE[@]}" -gt 0 ]]; then
  info "  git push $REMOTE --delete ${REMOTE_DELETE[*]}"
  git push "$REMOTE" --delete "${REMOTE_DELETE[@]}"
fi

for b in "${LOCAL_DELETE[@]+"${LOCAL_DELETE[@]}"}"; do
  [[ -z "$b" ]] && continue
  # Drop linked worktree holding the branch if any remain.
  wt="$(
    path=""
    while IFS= read -r line; do
      case "$line" in
        worktree\ *) path="${line#worktree }" ;;
        branch\ refs/heads/*)
          ref="${line#branch refs/heads/}"
          if [[ "$ref" == "$b" && -n "$path" && "$path" != "$TOPLEVEL" ]]; then
            printf '%s\n' "$path"
            break
          fi
          ;;
      esac
    done < <(git worktree list --porcelain 2>/dev/null)
  )"
  if [[ -n "$wt" ]]; then
    info "  worktree remove --force $wt (for $b)"
    git worktree remove --force "$wt"
  fi
  info "  git branch -D $b"
  git branch -D "$b"
done

info ""
info "📡 git fetch --prune $REMOTE (refresh)"
git fetch --prune "$REMOTE"

info ""
info "Done."
info "Remaining locals:"
git branch --list | sed 's/^/  /'
info "Remaining remotes:"
git branch -r | sed 's/^/  /'
info "Worktrees:"
git worktree list | sed 's/^/  /'
