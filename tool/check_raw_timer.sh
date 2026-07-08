#!/usr/bin/env bash
# Check for raw Timer usage (should use TimerService instead)

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$APP_ROOT"

echo "🔍 Checking for raw Timer usage..."

IGNORED=""

source "$WORKSPACE_ROOT/tool/check_helpers.sh"

TIMER_IMPL_RELPATH="../../packages/core/lib/src/time/timer_service.dart"

# Use ripgrep if available, otherwise grep.
# Match raw `Timer(` (word boundary) but exclude "TimerService", test files, and
# the TimerService implementation itself. We intentionally avoid matching helper
# names like `registerTimer(`.
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "\bTimer\(" lib/features lib/shared lib/app 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "TimerService" \
    | rg -v "$TIMER_IMPL_RELPATH" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  # grep does not support \b; emulate a word boundary by requiring a non-word
  # character (or start-of-line) before Timer(.
  VIOLATIONS=$(grep -rnE "(^|[^[:alnum:]_])Timer\\(" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "TimerService" \
    | grep -v "$TIMER_IMPL_RELPATH" \
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
