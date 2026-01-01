#!/usr/bin/env bash
# Check for compute() usage in lifecycle methods (build(), performLayout(), etc.)
# This is a heuristic check - warns but doesn't fail (non-blocking)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for compute() usage in lifecycle methods (heuristic)..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# This is a heuristic check - we look for files that contain both
# lifecycle method signatures (build, performLayout) and compute() calls
# We can't easily parse Dart syntax accurately with shell scripts,
# so this serves as a warning to review manually

VIOLATIONS=""

if command -v rg &> /dev/null; then
  # Find files with lifecycle methods
  FILES_WITH_LIFECYCLE=$(rg -l "\\b(build|performLayout)\\s*\\(" lib/features lib/core lib/shared lib/app 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    --glob "!test" \
    | grep -v "test" || true)

  for file in $FILES_WITH_LIFECYCLE; do
    if rg -q "\\bcompute\\s*\\(" "$file" 2>/dev/null; then
      # File contains both lifecycle methods and compute()
      # Get line numbers where compute() appears
      COMPUTE_LINES=$(rg -n "\\bcompute\\s*\\(" "$file" 2>/dev/null | cut -d: -f1 || true)
      if [ -n "$COMPUTE_LINES" ]; then
        # Simple heuristic: if compute() appears in the file, warn
        # More sophisticated parsing would require Dart analysis
        FIRST_LINE=$(echo "$COMPUTE_LINES" | head -1)
        VIOLATIONS="${VIOLATIONS}${file}:${FIRST_LINE}: Possible compute() usage in file with lifecycle methods - please review manually"$'\n'
      fi
    fi
  done
fi

# Remove trailing newline
VIOLATIONS=$(echo "$VIOLATIONS" | sed '/^$/d' || true)

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "⚠️  Warnings found: Possible compute() usage in files with lifecycle methods (heuristic check)"
  echo "$VIOLATIONS"
  echo ""
  echo "Note: compute() should not be called in build(), performLayout(), or synchronous callbacks"
  echo "Isolates should be triggered from async operations in repositories/cubits"
  echo "This is a heuristic check - please review manually"
  echo "See: docs/compute_isolate_review.md"
  # Warning only - exit 0 (non-blocking)
  exit 0
else
  echo "✅ No compute() usage detected in files with lifecycle methods"
  exit 0
fi
