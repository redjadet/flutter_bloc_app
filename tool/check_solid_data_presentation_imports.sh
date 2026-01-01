#!/usr/bin/env bash
# Check for data-layer importing presentation (layering violation).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for presentation imports in data layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "package:flutter_bloc_app/features/.*/presentation/" lib/features 2>/dev/null \
    --glob "*/data/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  VIOLATIONS=$(grep -rn "package:flutter_bloc_app/features/.*/presentation/" lib/features 2>/dev/null \
    | grep "/data/" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Data layer imports presentation"
  echo "$VIOLATIONS"
  echo "Move shared types to domain/shared and invert dependencies"
  exit 1
else
  echo "✅ No presentation imports in data layer"
  exit 0
fi
