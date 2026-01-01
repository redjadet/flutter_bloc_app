#!/usr/bin/env bash
# Check for compute() usage in domain layer (domain should be Flutter-agnostic)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for compute() usage in domain layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match "compute(" in domain directories
# Domain layer should be Flutter-agnostic and not use compute()
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "\\bcompute\\(" lib/features/*/domain lib/shared/domain 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "\\bcompute(" lib/features/*/domain lib/shared/domain 2>/dev/null \
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
  echo "❌ Violations found: compute() usage in domain layer (domain should be Flutter-agnostic)"
  echo "$VIOLATIONS"
  echo ""
  echo "Note: compute() should only be used in data/presentation layers, not domain layer"
  echo "Domain layer should remain Flutter-agnostic"
  echo "See: docs/compute_isolate_review.md"
  exit 1
else
  echo "✅ No compute() usage in domain layer"
  exit 0
fi

