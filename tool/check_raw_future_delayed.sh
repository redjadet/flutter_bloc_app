#!/usr/bin/env bash
# Check for Future.delayed in production lib/ (prefer TimerService for cancellation and test control)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for Future.delayed in lib/ (use TimerService where cancellation/test control matters)..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Match Future.delayed( or Future<void>.delayed( in lib/, exclude generated and allow-listed paths
# Allow-listed: mock/demo/samples; retry_policy (cancelToken polling); navigation (safeGo); todo_list_page_handlers (UI); walletconnect_service (demo placeholder)
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "Future<void>\.delayed\(|Future\.delayed\(" lib/ 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    --glob "!**/timer_service.dart" \
    --glob "!**/mock_*.dart" \
    --glob "!**/*_demo_*.dart" \
    --glob "!**/delayed_chart_repository.dart" \
    --glob "!**/isolate_samples.dart" \
    --glob "!**/retry_policy.dart" \
    --glob "!**/navigation.dart" \
    --glob "!**/todo_list_page_handlers.dart" \
    --glob "!**/walletconnect_service.dart" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "Future<void>\.delayed(\|Future\.delayed(" lib/ 2>/dev/null \
    | grep -v "\.g\.dart" \
    | grep -v "\.freezed\.dart" \
    | grep -v "timer_service\.dart" \
    | grep -v "mock_" \
    | grep -v "_demo_" \
    | grep -v "delayed_chart_repository\.dart" \
    | grep -v "isolate_samples\.dart" \
    | grep -v "retry_policy\.dart" \
    | grep -v "navigation\.dart" \
    | grep -v "todo_list_page_handlers\.dart" \
    | grep -v "walletconnect_service\.dart" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Future.delayed usage in lib/ (prefer TimerService for cancellation and test control)"
  echo "$VIOLATIONS"
  echo "See docs/engineering/delayed_work_guide.md for the preferred pattern."
  exit 1
else
  echo "✅ No disallowed Future.delayed usage in lib/"
  exit 0
fi
