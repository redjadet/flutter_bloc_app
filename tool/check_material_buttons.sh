#!/usr/bin/env bash
# Check for raw Material buttons (should use PlatformAdaptive instead)
# Raw buttons: ElevatedButton, OutlinedButton, TextButton

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for raw Material buttons in presentation layer..."

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
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "ElevatedButton|OutlinedButton|TextButton" lib/features 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "PlatformAdaptive" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "ElevatedButton\|OutlinedButton\|TextButton" lib/features 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "PlatformAdaptive" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Raw Material buttons (use PlatformAdaptive instead)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No raw Material buttons found"
  exit 0
fi
