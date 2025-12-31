#!/usr/bin/env bash
# Check for Flutter imports in domain layer (violates clean architecture)
# Domain layer must be Flutter-agnostic

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for Flutter imports in domain layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Check for actual Flutter framework imports (package:flutter/ or package:flutter";), not internal package imports
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "^import ['\"]package:flutter/" lib/features 2>/dev/null \
    --glob "*/domain/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  VIOLATIONS=$(grep -rn "^import ['\"]package:flutter/" lib/features 2>/dev/null \
    | grep "/domain/" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Flutter imports in domain layer"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No Flutter imports in domain layer"
  exit 0
fi
