#!/usr/bin/env bash
# Check for Equatable usage where Freezed is preferred
# Per project policy: "Immutable states (freezed > Equatable)." Use Freezed for
# new cubit/Bloc state and immutable domain models. See docs/freezed_usage_analysis.md

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for Equatable usage (Freezed preferred)..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Find Dart files in lib/ that declare a class extending or mixing Equatable.
# Pattern: "class Name ... extends Equatable" or "class Name ... with Equatable"
# Exclude generated files. Exclude comment-only lines (/// or //).
if command -v rg &> /dev/null; then
  RAW=$(rg -n "class\s+\w+.*(extends|with)\s+Equatable" lib/ \
    --glob "*.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.gr.dart" \
    2>/dev/null || true)
else
  RAW=$(grep -rn "class\s\+\w\+.*\(extends\|with\)\s\+Equatable" lib/ \
    --include="*.dart" 2>/dev/null || true)
  if [ -n "$RAW" ]; then
    RAW=$(echo "$RAW" | grep -v "\.freezed\.dart" | grep -v "\.g\.dart" | grep -v "\.gr\.dart" || true)
  fi
fi

# Drop lines that are comments (/// or //)
VIOLATIONS=""
if [ -n "$RAW" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    rest="${line#*:}"
    rest="${rest#*:}"
    if [[ "$rest" =~ ^[[:space:]]*// ]]; then
      continue
    fi
    VIOLATIONS+="${line}"$'\n'
  done <<< "$RAW"
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Equatable used where Freezed is preferred (state/domain models)."
  echo "   See docs/freezed_usage_analysis.md and docs/equatable_to_freezed_conversion.md"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No Equatable classes in lib/ (Freezed preferred for state/domain models)"
  exit 0
fi
