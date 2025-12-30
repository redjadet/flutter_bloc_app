#!/usr/bin/env bash
# Check for Flutter imports in domain layer (violates clean architecture)
# Domain layer must be Flutter-agnostic

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for Flutter imports in domain layer..."

IGNORED=""

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

# Use ripgrep if available, otherwise grep
# Check for actual Flutter framework imports (package:flutter/ or package:flutter";), not internal package imports
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "^import ['\"]package:flutter/" lib/features 2>/dev/null \
    --glob "*/domain/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  VIOLATIONS=$(grep -rn "^import ['\"]package:flutter/" lib/features 2>/dev/null \
    | grep "/domain/" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Flutter imports in domain layer"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No Flutter imports in domain layer"
  exit 0
fi
