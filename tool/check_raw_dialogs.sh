#!/usr/bin/env bash
# Check for raw dialog APIs (should use showAdaptiveDialog)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for raw dialog APIs..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "showDialog\\(|showGeneralDialog\\(|showCupertinoDialog\\(" lib 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "showAdaptiveDialog" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "showDialog(\\|showGeneralDialog(\\|showCupertinoDialog(" lib 2>/dev/null \
    | grep -v "showAdaptiveDialog" \
    | grep -v "/test/" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Raw dialog APIs (use showAdaptiveDialog)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No raw dialog API usage found"
  exit 0
fi
