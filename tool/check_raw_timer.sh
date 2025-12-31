#!/usr/bin/env bash
# Check for raw Timer usage (should use TimerService instead)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for raw Timer usage..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match "Timer(" but exclude "TimerService", test files, and the TimerService implementation itself
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "Timer\(" lib/features lib/core lib/shared lib/app 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "TimerService" \
    | rg -v "lib/core/time/timer_service.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "Timer(" lib/features lib/core lib/shared lib/app 2>/dev/null \
    | grep -v "TimerService" \
    | grep -v "lib/core/time/timer_service.dart" \
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
  echo "❌ Violations found: Raw Timer usage (use TimerService instead)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No raw Timer usage found"
  exit 0
fi
