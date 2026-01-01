#!/usr/bin/env bash
# Check for shrinkWrap: true in scrollable lists (potential perf issue).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for shrinkWrap: true in presentation lists..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "shrinkWrap:\\s*true" lib/features 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  VIOLATIONS=$(grep -rn "shrinkWrap: *true" lib/features 2>/dev/null \
    | grep "/presentation/" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Potential perf issue: shrinkWrap true in presentation lists"
  echo "$VIOLATIONS"
  echo "Consider builder-based lists or constrained layouts"
  exit 1
else
  echo "✅ No shrinkWrap: true usage in presentation lists"
  exit 0
fi
