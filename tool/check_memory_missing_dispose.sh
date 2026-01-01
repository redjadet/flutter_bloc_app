#!/usr/bin/env bash
# Heuristic: flag controller usage without dispose() in presentation widgets.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for controller usage without dispose()..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

CONTROLLER_PATTERN="TextEditingController|AnimationController|ScrollController|PageController|TabController|FocusNode"
INSTANTIATION_PATTERN="TextEditingController\\(|AnimationController\\(|ScrollController\\(|PageController\\(|TabController\\(|FocusNode\\("

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
  if rg -q "$INSTANTIATION_PATTERN" "$file" 2>/dev/null; then
    if ! rg -q "extends\\s+State<" "$file" 2>/dev/null; then
      continue
    fi
    if ! rg -q "\\bdispose\\s*\\(" "$file" 2>/dev/null; then
      local_match=$(rg -n -m 1 "$INSTANTIATION_PATTERN" "$file" 2>/dev/null || true)
      if [ -n "$local_match" ]; then
        VIOLATIONS+="${local_match}\n"
      else
        VIOLATIONS+="${file}:1: controller without dispose()\n"
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
  echo "❌ Potential memory leak: controller without dispose()"
  echo "$VIOLATIONS"
  echo "Dispose controllers in State.dispose()"
  exit 1
else
  echo "✅ No missing dispose() candidates detected"
  exit 0
fi
