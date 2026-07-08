#!/usr/bin/env bash
# Check for per-widget GoogleFonts usage (should be defined in app/theme/ or app_config)

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$APP_ROOT"

echo "🔍 Checking for per-widget GoogleFonts usage..."

IGNORED=""

source "$WORKSPACE_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "GoogleFonts\\." lib 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    --glob "!**/app/theme/app_theme.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "GoogleFonts\." lib 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "app/theme/app_theme.dart" \
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
  echo "Note: Define fonts in lib/app/theme/ and use Theme.of(context).textTheme"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No per-widget GoogleFonts usage found"
  exit 0
fi
