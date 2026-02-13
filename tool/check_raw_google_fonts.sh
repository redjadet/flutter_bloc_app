#!/usr/bin/env bash
# Check for per-widget GoogleFonts usage (should be defined in core/theme/ or app_config)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for per-widget GoogleFonts usage..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "GoogleFonts\\." lib 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    --glob "!**/core/app_config.dart" \
    --glob "!**/core/theme/app_theme.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "GoogleFonts\." lib 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "core/app_config.dart" \
    | grep -v "core/theme/app_theme.dart" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Per-widget GoogleFonts usage"
  echo "Note: Define fonts in lib/core/theme/ and use Theme.of(context).textTheme"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No per-widget GoogleFonts usage found"
  exit 0
fi
