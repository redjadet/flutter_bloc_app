#!/usr/bin/env bash
# Check for direct Hive.openBox usage (should use HiveService/HiveRepositoryBase instead)

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

echo "🔍 Checking for direct Hive.openBox usage..."

IGNORED=""

source "$TOOL_DIR/check_helpers.sh"

# Use ripgrep if available, otherwise grep
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "Hive\.openBox" lib/features lib/shared lib/app 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "Hive\.openBox" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Direct Hive.openBox usage (use HiveService/HiveRepositoryBase instead)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No direct Hive.openBox usage found"
  exit 0
fi
