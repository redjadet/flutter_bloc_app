#!/usr/bin/env bash
# Delete regenerable Flutter/Dart build caches under this repo (disk reclaim).
#
# Safe targets only (gitignored / rebuildable):
#   .dart_tool/, **/build/, package .dart_tool/, Android .gradle/,
#   demos **/__pycache__/, coverage lcov/summary outputs, /artifacts/
#
# Refuses any path that still contains tracked git files.
# Does NOT run `flutter clean` (can hang on xcodebuild). Does NOT touch source,
# secrets, .git, Pods, or pub-cache outside the repo.
#
# Safety: dry-run by default. Pass --apply to delete.
#
# Usage:
#   bash tool/clean_build_caches.sh
#   bash tool/clean_build_caches.sh --apply
#   ./bin/clean-build-caches --apply --yes

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

DRY_RUN=1
ASSUME_YES=0
QUIET=0

usage() {
  cat <<'EOF'
tool/clean_build_caches.sh — reclaim disk by deleting regenerable build caches.

Deletes (when present):
  - root .dart_tool/ and build/
  - apps/**/build/, apps/**/.dart_tool/, apps/**/android/.gradle/
  - packages/**/build/, packages/**/.dart_tool/
  - custom_lints/**/build/, custom_lints/**/.dart_tool/
  - demos/**/__pycache__/
  - gitignored coverage outputs (lcov*.info, coverage_summary.md) and /artifacts/

Never deletes: tracked files, source, secrets, .git, CocoaPods, pub-cache outside repo.

Options:
  --dry-run       List paths + sizes only (default).
  --apply         Delete listed paths.
  --yes, -y       Skip confirmation prompt with --apply (for automation).
  --quiet, -q     Less chatter; still prints summary.
  -h, --help      Show this help.

Examples:
  bash tool/clean_build_caches.sh
  bash tool/clean_build_caches.sh --apply
  ./bin/clean-build-caches --apply --yes

After --apply, restore deps:
  bash tool/workspace_pub_get.sh
EOF
}

die() {
  echo "❌ $*" >&2
  exit 2
}

log() {
  [[ "$QUIET" -eq 1 ]] && return 0
  printf '%s\n' "$*"
}

human_size() {
  local bytes="$1"
  if command -v numfmt >/dev/null 2>&1; then
    numfmt --to=iec --suffix=B "$bytes" 2>/dev/null && return 0
  fi
  # Portable fallback (macOS/BSD)
  awk -v b="$bytes" 'BEGIN {
    split("B KB MB GB TB", u, " ");
    s = b + 0;
    i = 1;
    while (s >= 1024 && i < 5) { s /= 1024; i++ }
    if (i == 1) printf "%d%s\n", s, u[i];
    else printf "%.1f%s\n", s, u[i];
  }'
}

dir_bytes() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo 0
    return 0
  fi
  # du -sk is portable; convert KiB -> bytes
  local kib
  kib="$(du -sk "$path" 2>/dev/null | awk '{print $1}')"
  echo $((kib * 1024))
}

# Collect unique existing cache roots into TARGETS array (bash 3.2–safe).
TARGETS=()
SKIPPED=()

target_seen() {
  local want="$1" t
  for t in "${TARGETS[@]+"${TARGETS[@]}"}"; do
    [[ "$t" == "$want" ]] && return 0
  done
  return 1
}

has_tracked_under() {
  local path="$1"
  local rel="${path#"$PROJECT_ROOT"/}"
  # Any tracked path under rel (file or tree) → unsafe to wipe wholesale
  local hit
  hit="$(git -C "$PROJECT_ROOT" ls-files -z -- "$rel" 2>/dev/null | head -c 1 || true)"
  [[ -n "$hit" ]]
}

add_target() {
  local path="$1"
  [[ -z "$path" ]] && return 0
  # Resolve to absolute under PROJECT_ROOT only
  if [[ "$path" != /* ]]; then
    path="$PROJECT_ROOT/$path"
  fi
  case "$path" in
    "$PROJECT_ROOT"/*) ;;
    *) die "refusing path outside repo: $path" ;;
  esac
  # Never allow wiping the repo root itself
  [[ "$path" == "$PROJECT_ROOT" ]] && die "refusing to delete repo root"
  [[ -e "$path" ]] || return 0
  if has_tracked_under "$path"; then
    SKIPPED+=("${path#"$PROJECT_ROOT"/}")
    return 0
  fi
  target_seen "$path" && return 0
  TARGETS+=("$path")
}

# Add individual gitignored regenerable files under a tree.
add_ignored_under() {
  local tree="$1"
  local rel f
  [[ -d "$PROJECT_ROOT/$tree" ]] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#"$PROJECT_ROOT"/}"
    if git -C "$PROJECT_ROOT" check-ignore -q -- "$rel" 2>/dev/null; then
      add_target "$rel"
    fi
  done < <(find "$PROJECT_ROOT/$tree" -type f -print0 2>/dev/null)
}

collect_targets() {
  add_target ".dart_tool"
  add_target "build"

  # Mixed dirs — only wipe gitignored files inside.
  add_ignored_under "coverage"
  add_ignored_under "artifacts"
  local cov
  for cov in apps/*/coverage; do
    [[ -d "$cov" ]] && add_ignored_under "$cov"
  done

  local d
  # Explicit app / package roots (fast + predictable)
  for d in apps/*/build apps/*/.dart_tool apps/*/android/.gradle; do
    add_target "$d"
  done
  for d in packages/*/build packages/*/.dart_tool; do
    add_target "$d"
  done
  for d in custom_lints/*/build custom_lints/*/.dart_tool; do
    add_target "$d"
  done

  # Nested leftovers (e.g. apps/other_platforms/*/build, demos __pycache__)
  while IFS= read -r -d '' d; do
    add_target "$d"
  done < <(
    find apps packages custom_lints \
      \( -type d \( -name build -o -name .dart_tool -o -name .gradle \) \) \
      -print0 2>/dev/null
  )
  while IFS= read -r -d '' d; do
    add_target "$d"
  done < <(find demos -type d -name '__pycache__' -print0 2>/dev/null)
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --apply)
      DRY_RUN=0
      ;;
    --yes | -y)
      ASSUME_YES=1
      ;;
    --quiet | -q)
      QUIET=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1 (see --help)"
      ;;
  esac
  shift
done

collect_targets

if [[ "${#TARGETS[@]}" -eq 0 ]]; then
  if [[ "${#SKIPPED[@]}" -gt 0 ]]; then
    log "clean_build_caches: nothing regenerable to delete"
    log "skipped (tracked): ${SKIPPED[*]}"
  else
    echo "clean_build_caches: nothing to delete (already clean)"
  fi
  exit 0
fi

# Sort for stable output (bash 3.2–safe; no mapfile)
_sorted=()
while IFS= read -r _line; do
  [[ -n "$_line" ]] && _sorted+=("$_line")
done < <(printf '%s\n' "${TARGETS[@]}" | sort)
TARGETS=("${_sorted[@]}")
unset _sorted _line

TOTAL_BYTES=0
log "clean_build_caches: ${#TARGETS[@]} path(s) under $PROJECT_ROOT"
if [[ "${#SKIPPED[@]}" -gt 0 ]]; then
  for s in "${SKIPPED[@]}"; do
    log "  skip (tracked files): $s"
  done
fi
log ""
for path in "${TARGETS[@]}"; do
  bytes="$(dir_bytes "$path")"
  TOTAL_BYTES=$((TOTAL_BYTES + bytes))
  rel="${path#"$PROJECT_ROOT"/}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "  [dry-run] $(human_size "$bytes")  $rel"
  else
    log "  $(human_size "$bytes")  $rel"
  fi
done
log ""
log "total reclaimable: $(human_size "$TOTAL_BYTES")"

FREE_BEFORE="$(df -h "$PROJECT_ROOT" | awk 'NR==2{print $4}')"
REPO_BEFORE="$(du -sh "$PROJECT_ROOT" 2>/dev/null | awk '{print $1}')"
log "repo size now: $REPO_BEFORE | disk free: $FREE_BEFORE"

if [[ "$DRY_RUN" -eq 1 ]]; then
  log ""
  log "dry-run only. Re-run with --apply to delete."
  exit 0
fi

if [[ "$ASSUME_YES" -ne 1 ]]; then
  printf 'Delete %s path(s) (~%s)? [y/N] ' "${#TARGETS[@]}" "$(human_size "$TOTAL_BYTES")"
  read -r reply
  case "$reply" in
    y | Y | yes | YES) ;;
    *)
      echo "aborted"
      exit 1
      ;;
  esac
fi

DELETED=0
FAILED=0
for path in "${TARGETS[@]}"; do
  rel="${path#"$PROJECT_ROOT"/}"
  if rm -rf "$path"; then
    DELETED=$((DELETED + 1))
    log "  deleted: $rel"
  else
    FAILED=$((FAILED + 1))
    echo "  ❌ failed: $rel" >&2
  fi
done

FREE_AFTER="$(df -h "$PROJECT_ROOT" | awk 'NR==2{print $4}')"
REPO_AFTER="$(du -sh "$PROJECT_ROOT" 2>/dev/null | awk '{print $1}')"

echo ""
echo "clean_build_caches: deleted $DELETED path(s), failed $FAILED"
echo "repo: $REPO_BEFORE -> $REPO_AFTER | disk free: $FREE_BEFORE -> $FREE_AFTER"
echo "next: bash tool/workspace_pub_get.sh"

[[ "$FAILED" -eq 0 ]] || exit 1
