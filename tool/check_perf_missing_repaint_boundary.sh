#!/usr/bin/env bash
# Heuristic: flag heavy widgets without RepaintBoundary in presentation.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for heavy widgets missing RepaintBoundary..."

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
HEAVY_PATTERN="CustomPaint\\(|ShaderMask\\(|BackdropFilter\\(|ImageFiltered\\(|ClipPath\\("

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if rg -q "$HEAVY_PATTERN" "$file" 2>/dev/null; then
    if ! rg -q "RepaintBoundary" "$file" 2>/dev/null; then
      local_match=$(rg -n -m 1 "$HEAVY_PATTERN" "$file" 2>/dev/null || true)
      if [ -n "$local_match" ]; then
        VIOLATIONS+="${local_match}\n"
      else
        VIOLATIONS+="${file}:1: heavy widget without RepaintBoundary\n"
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
  echo "❌ Potential perf issue: heavy widgets without RepaintBoundary"
  echo "$VIOLATIONS"
  echo "Consider wrapping expensive subtrees in RepaintBoundary"
  exit 1
else
  echo "✅ No obvious RepaintBoundary candidates detected"
  exit 0
fi
