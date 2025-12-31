#!/usr/bin/env bash
# Check for hard-coded colors (should use Theme.of(context).colorScheme instead)
# Colors.black, Colors.white, Colors.grey, etc.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for hard-coded colors in presentation layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match Colors.black, Colors.white, Colors.grey, etc. but exclude test files and colorScheme usage
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "Colors\.(black|white|grey|gray|red|blue|green|yellow|orange|purple|pink|brown|cyan|teal|indigo|amber|lime)" lib/features lib/shared lib/app 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "colorScheme" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "Colors\.\(black\|white\|grey\|gray\|red\|blue\|green\|yellow\|orange\|purple\|pink\|brown\|cyan\|teal\|indigo\|amber\|lime\)" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "colorScheme" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Hard-coded colors (use Theme.of(context).colorScheme instead)"
  echo "Note: Use colorScheme.onSurface, colorScheme.surface, colorScheme.primary, etc."
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No hard-coded colors found"
  exit 0
fi
