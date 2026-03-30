#!/usr/bin/env bash
# Enforce centralized memory-pressure handling in the app shell.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking centralized memory-pressure handling..."

source "$PROJECT_ROOT/tool/check_helpers.sh"

VIOLATIONS=""

FILES=$(rg --files lib \
  --glob "*.dart" \
  --glob "!**/*.g.dart" \
  --glob "!**/*.freezed.dart" \
  | grep -v "^lib/app/app_scope.dart$" || true)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  match=$(rg -n "didHaveMemoryPressure\\s*\\(" "$file" 2>/dev/null || true)
  if [ -n "$match" ]; then
    VIOLATIONS+="${match}"$'\n'
  fi
done <<< "$FILES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Memory pressure handling must stay centralized in lib/app/app_scope.dart"
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ Memory pressure handling is centralized"
