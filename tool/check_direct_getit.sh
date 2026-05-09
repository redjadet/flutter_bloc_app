#!/usr/bin/env bash
# Check for direct GetIt access in presentation widgets
# Should inject dependencies via constructors or cubits instead

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for direct GetIt usage in presentation layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match "getIt<" but exclude test files and debug/tooling widgets
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "getIt<" lib/features 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "/[^/]+_demo/" \
    | rg -v "test" \
    | rg -v "debug" \
    | rg -v "tooling" \
    | rg -v ":[0-9]+:[[:space:]]*//" \
    | rg -v ":[0-9]+:[[:space:]]*///" \
    || true)
else
  VIOLATIONS=$(grep -rn "getIt<" lib/features 2>/dev/null \
    | grep "/presentation/" \
    | grep -E -v "/[^/]+_demo/" \
    | grep -v "/test/" \
    | grep -v "debug" \
    | grep -v "tooling" \
    | grep -vE ":[0-9]+:[[:space:]]*//" \
    | grep -vE ":[0-9]+:[[:space:]]*///" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Direct GetIt access in presentation (inject via constructors/cubits)"
  echo "$VIOLATIONS"
  echo "Note: Debug/tooling widgets are exceptions and should be documented"
  exit 1
else
  echo "✅ No direct GetIt usage in presentation layer"
  exit 0
fi
