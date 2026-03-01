#!/usr/bin/env bash
# Check for direct Uri.parse usage with dynamic baseUrl-like values.
# Prefer a validated parser helper (Uri.tryParse + scheme/host checks).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for unvalidated dynamic baseUrl parsing..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Match Uri.parse(...) calls where the argument appears to be a dynamic
# baseUrl-style identifier/expression (not a string literal).
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n \
    "Uri\\.parse\\(\\s*[^\"'][^)]*[Bb]ase[Uu][Rr][Ll][^)]*\\)" \
    lib/features lib/core lib/shared lib/app 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rnE \
    "Uri\\.parse\\(\\s*[^\"'][^)]*[Bb]ase[Uu][Rr][Ll][^)]*\\)" \
    lib/features lib/core lib/shared lib/app 2>/dev/null \
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
  echo "❌ Violations found: Uri.parse(...) with dynamic baseUrl-like value"
  echo "$VIOLATIONS"
  echo ""
  echo "Use a validated helper instead:"
  echo "  1. Uri.tryParse(...)"
  echo "  2. Verify scheme/host (typically http/https + non-empty host)"
  echo "  3. Normalize base path for resolve(...) if needed"
  echo ""
  echo "If this usage is intentionally safe, add: // check-ignore: reason"
  exit 1
else
  echo "✅ No unvalidated dynamic baseUrl parsing found"
  exit 0
fi
