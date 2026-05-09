#!/usr/bin/env bash
# Check for raw Material button widgets (should use PlatformAdaptive instead)
# Raw widgets: ElevatedButton, OutlinedButton, TextButton (and their .icon variants)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for raw Material buttons in presentation layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep.
# Important: Match widget constructors only. Do not flag style helpers like
# OutlinedButton.styleFrom / ElevatedButton.styleFrom.
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "(^|[^.\\w])(ElevatedButton|OutlinedButton|TextButton)(\\.icon)?\\s*\\(" lib/features 2>/dev/null \
    --glob "**/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "/[^/]+_demo/" \
    | rg -v "PlatformAdaptive" \
    | rg -v "/test/" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rnE "(^|[^.\w])(ElevatedButton|OutlinedButton|TextButton)(\.icon)?[[:space:]]*\\(" lib/features 2>/dev/null \
    | grep -vE "/[^/]+_demo/" \
    | grep -v "/test/" \
    | grep -v "PlatformAdaptive" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Raw Material buttons (use PlatformAdaptive instead)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No raw Material buttons found"
  exit 0
fi
