#!/usr/bin/env bash
# Shared helpers for validation scripts.

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

# Resolve scan paths after check_helpers cd's into APP_ROOT (apps/mobile).
# Workspace-root paths (tool/fixtures/...) still resolve for harness fixtures.
resolve_scan_root() {
  local p="$1"
  if [[ "$p" = /* ]]; then
    printf '%s\n' "$p"
    return
  fi
  if [[ -e "$WORKSPACE_ROOT/$p" ]]; then
    printf '%s\n' "$WORKSPACE_ROOT/$p"
    return
  fi
  if [[ -e "$PROJECT_ROOT/$p" ]]; then
    printf '%s\n' "$PROJECT_ROOT/$p"
    return
  fi
  printf '%s\n' "$p"
}

filter_ignored() {
  local input="$1"
  local output=""
  IGNORED=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local file="${line%%:*}"
    local rest="${line#*:}"
    local lineno="${rest%%:*}"
    if [[ "$lineno" =~ ^[0-9]+$ ]]; then
      local current
      local previous=""
      local reason=""
      current=$(sed -n "${lineno}p" "$file")
      if [ "$lineno" -gt 1 ]; then
        previous=$(sed -n "$((lineno - 1))p" "$file")
      fi
      if [[ "$current" == *"check-ignore"* ]]; then
        reason=$(printf "%s" "$current" | sed -n 's/.*check-ignore[: ]*//p')
      elif [[ "$previous" == *"check-ignore"* ]]; then
        reason=$(printf "%s" "$previous" | sed -n 's/.*check-ignore[: ]*//p')
      fi
      reason=$(printf "%s" "$reason" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [[ "$current" == *"check-ignore"* || "$previous" == *"check-ignore"* ]]; then
        if [ -z "$reason" ]; then
          reason="no reason provided"
        fi
        IGNORED+="${line} | reason: ${reason}"$'\n'
        continue
      fi
    fi
    output+="${line}"$'\n'
  done <<< "$input"
  printf "%s" "$output"
}
