#!/usr/bin/env bash
# Check for potential unnecessary rebuilds in stateful widgets
# Pattern: setState() called for all changes including camera/position updates
# This is a heuristic check that looks for patterns that might cause blinking

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for potential unnecessary rebuilds in stateful widgets..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Find stateful widget files
if command -v rg &> /dev/null; then
  FILES=$(rg --files lib \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    || true)
else
  FILES=$(find lib -type f -name "*.dart" 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "\.g\.dart" \
    | grep -v "\.freezed\.dart" \
    || true)
fi

VIOLATIONS=""

while IFS= read -r file; do
  [ -z "$file" ] && continue

  # Look for setState() calls that might be triggered by camera/position updates
  # Check for patterns like: if (changes.hasAnyChange) { setState(() {}); }
  # near camera/position related code
  if rg -q "setState" "$file" 2>/dev/null && rg -q "camera|CameraPosition|position" "$file" 2>/dev/null; then
    # Check if setState is called unconditionally for all changes
    if rg -q "hasAnyChange.*setState|setState.*hasAnyChange" "$file" 2>/dev/null; then
      # Check if there's a comment explaining it or if camera is excluded
      if ! rg -q "check-ignore|Exclude camera|Camera changes are handled|don'\''t need setState" "$file" 2>/dev/null; then
        # This might be a violation - flag it
        setstate_line=$(rg -n "hasAnyChange.*setState|setState.*hasAnyChange" "$file" 2>/dev/null | head -1 | cut -d: -f2 || echo "")
        if [ -n "$setstate_line" ]; then
          VIOLATIONS+="${file}:${setstate_line}: setState() triggered by hasAnyChange near camera/position code - ensure camera changes don't trigger rebuilds\n"
        fi
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
  echo "⚠️  Potential unnecessary rebuilds detected"
  echo "Note: Camera/position changes in state handlers should not trigger setState()"
  echo "Example fix:"
  echo "  // ❌ Bad: setState() for all changes including camera"
  echo "  if (changes.hasAnyChange) { setState(() {}); }"
  echo ""
  echo "  // ✅ Good: Exclude camera changes from rebuilds"
  echo "  if (changes.mapTypeChanged || changes.markersChanged) { setState(() {}); }"
  echo ""
  echo "$VIOLATIONS"
  echo ""
  echo "Note: This is a heuristic check - review manually to confirm"
  exit 0  # Warning only, not an error
else
  echo "✅ No obvious unnecessary rebuild patterns detected"
  exit 0
fi
