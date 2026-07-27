#!/usr/bin/env bash
# Reject raw print()/debugPrint() in apps and packages lib trees.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/check_helpers.sh"

echo "🔍 Checking for raw print()/debugPrint() usage..."

IGNORED=""

scan_roots=(
  "$WORKSPACE_ROOT/apps"
  "$WORKSPACE_ROOT/packages"
)

if command -v rg &> /dev/null; then
  VIOLATIONS=$(
    rg -n "\\b(print|debugPrint)\\(" "${scan_roots[@]}" 2>/dev/null \
      --glob '**/lib/**/*.dart' \
      --glob '!**/*.g.dart' \
      --glob '!**/*.freezed.dart' \
      --glob '!**/*.gr.dart' \
      --glob '!**/test/**' \
      || true
  )
  VIOLATIONS=$(printf '%s\n' "$VIOLATIONS" | rg -v '^[[:space:]]*//' || true)
else
  VIOLATIONS=$(
    find "${scan_roots[@]}" -type f -path '*/lib/*.dart' \
      ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.gr.dart' \
      ! -path '*/test/*' \
      -print0 2>/dev/null \
      | xargs -0 grep -nE '\b(print|debugPrint)\(' 2>/dev/null \
      | grep -v '^[[:space:]]*//' \
      || true
  )
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Raw print()/debugPrint() usage (use AppLogger instead)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No raw print() usage found"
  exit 0
fi
