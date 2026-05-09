#!/usr/bin/env bash
# Check for presentation importing data-layer types (DIP violation).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for data-layer imports in presentation..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "package:flutter_bloc_app/features/.*/data/" lib/features 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  VIOLATIONS=$(grep -rn "package:flutter_bloc_app/features/.*/data/" lib/features 2>/dev/null \
    | grep "/presentation/" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Presentation imports data-layer types"
  echo "$VIOLATIONS"
  echo "Use domain/shared interfaces and inject via DI"
  exit 1
else
  echo "✅ No data-layer imports in presentation"
  exit 0
fi
