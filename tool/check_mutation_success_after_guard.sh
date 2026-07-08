#!/usr/bin/env bash
# Fail: after a successful mutation, return false when RequestIdGuard is inactive.
set -euo pipefail
TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"
source "$TOOL_DIR/check_helpers.sh"

echo "🔍 Checking mutation success after request-id guard supersession..."

SCAN_PATHS=("lib")
GUARD_RE='!.*(_isRequestStillActive|Guard\.isCurrent|_requestIdGuard\.isCurrent|loadRequestIdGuard\.isCurrent)'

STAGED_MODE=0

usage() {
  cat <<'EOF'
Usage: tool/check_mutation_success_after_guard.sh [--staged | --paths PATH...]

Default scope: lib/**/*.dart files that reference RequestIdGuard helpers.
--staged limits to staged lib/**/*.dart (full lib/ when guard script or
request_id_guard.dart is staged). Used by githooks/pre-commit.
--paths supports fixture self-tests.
EOF
}

collect_staged_lib_dart() {
  local file
  local -n out_ref="$1"
  out_ref=()
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      lib/*.dart)
        if [ -f "$file" ]; then
          out_ref+=("$file")
        fi
        ;;
    esac
  done < <(git diff --cached --name-only --diff-filter=ACMRTUXB 2>/dev/null || true)
}

staged_triggers_full_lib_scan() {
  local file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      lib/shared/utils/request_id_guard.dart|\
      packages/utilities/lib/src/request_id_guard.dart|\
      tool/check_mutation_success_after_guard.sh|\
      tool/fixtures/mutation_success_after_guard/*)
        return 0
        ;;
    esac
  done < <(git diff --cached --name-only --diff-filter=ACMRTUXB 2>/dev/null || true)
  return 1
}

staged_has_relevant_changes() {
  local file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      lib/*.dart|\
      lib/shared/utils/request_id_guard.dart|\
      packages/utilities/lib/src/request_id_guard.dart|\
      tool/check_mutation_success_after_guard.sh|\
      tool/fixtures/mutation_success_after_guard/*)
        return 0
        ;;
    esac
  done < <(git diff --cached --name-only --diff-filter=ACMRTUXB 2>/dev/null || true)
  return 1
}

resolve_staged_scan_paths() {
  local -a staged_lib=()
  collect_staged_lib_dart staged_lib

  if ! staged_has_relevant_changes; then
    echo "ℹ️  No staged lib/guard paths; skipping mutation-success guard"
    exit 0
  fi

  if staged_triggers_full_lib_scan || [ "${#staged_lib[@]}" -eq 0 ]; then
    echo "ℹ️  Staged guard-wide change; scanning lib/"
    SCAN_PATHS=("lib")
    return 0
  fi

  echo "ℹ️  Staged lib Dart files: ${#staged_lib[@]}"
  SCAN_PATHS=("${staged_lib[@]}")
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--staged" ]]; then
  STAGED_MODE=1
  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ --staged requires a git worktree" >&2
    exit 2
  fi
  resolve_staged_scan_paths
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  SCAN_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

window_returns_false() {
  local window="$1"
  if printf '%s\n' "$window" | grep -qE 'return[[:space:]]+false'; then
    return 0
  fi
  if printf '%s\n' "$window" | grep -qE 'return[[:space:]]*;?[[:space:]]*$' \
    && printf '%s\n' "$window" | grep -qE '^[[:space:]]*false[[:space:]]*;'; then
    return 0
  fi
  return 1
}

collect_violations() {
  local root dartfile out="" lineno line window
  for root in "${SCAN_PATHS[@]}"; do
    if [ -f "$root" ]; then
      dartfile="$root"
      lineno=0
      while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        if [[ "$line" =~ $GUARD_RE ]]; then
          window="$(sed -n "${lineno},$((lineno + 6))p" "$dartfile")"
          if window_returns_false "$window"; then
            out+="${dartfile}:${lineno}: return false after inactive request-id guard (keep mutation success)"$'\n'
          fi
        fi
      done <"$dartfile"
      continue
    fi

    while IFS= read -r dartfile; do
      [ -n "$dartfile" ] || continue
      lineno=0
      while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        if [[ "$line" =~ $GUARD_RE ]]; then
          window="$(sed -n "${lineno},$((lineno + 6))p" "$dartfile")"
          if window_returns_false "$window"; then
            out+="${dartfile}:${lineno}: return false after inactive request-id guard (keep mutation success)"$'\n'
          fi
        fi
      done <"$dartfile"
    done < <(
      rg -l '_isRequestStillActive|Guard\.isCurrent|_requestIdGuard\.isCurrent|loadRequestIdGuard\.isCurrent' \
        "$root" -g '*.dart' -g '*.part.dart' 2>/dev/null || true
    )
  done
  printf '%s' "$out"
}

VIOLATIONS="$(filter_ignored "$(collect_violations)")"
if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored:"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "❌ Mutation success after guard: ${count} violation(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | head -5
  echo "Remediation: after successful mutation, if guard inactive return success (true / bare return), not false."
  echo "See docs/reliability_error_handling_performance.md and messaging_cubit.dart."
  exit 1
fi

echo "✅ No mutation-success-after-guard violations"
exit 0
