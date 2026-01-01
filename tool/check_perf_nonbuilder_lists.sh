#!/usr/bin/env bash
# Check for ListView/GridView with children (eager build) in presentation.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for non-builder ListView/GridView in presentation..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

FILES=""
if command -v rg &> /dev/null; then
  FILES=$(rg --files lib/features \
    --glob "*/presentation/**" \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  FILES=$(find lib/features -type f -name "*.dart" -path "*/presentation/*" 2>/dev/null || true)
fi

VIOLATIONS=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if rg -q "ListView\\(|GridView\\(" "$file" 2>/dev/null; then
    if rg -q "children\\s*:" "$file" 2>/dev/null; then
      if ! rg -q "ListView\\.builder|ListView\\.separated|ListView\\.custom|GridView\\.builder|GridView\\.custom" "$file" 2>/dev/null; then
        VIOLATIONS+="${file}:1: non-builder ListView/GridView with children\n"
      fi
    fi
  fi
done <<< "$FILES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Potential perf issue: non-builder ListView/GridView with children"
  echo "$VIOLATIONS"
  echo "Prefer builder-based lists for large or dynamic data sets"
  exit 1
else
  echo "✅ No non-builder ListView/GridView usage detected"
  exit 0
fi
