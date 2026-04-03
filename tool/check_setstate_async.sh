#!/usr/bin/env bash
# Fail when setState() is called with an async callback.
#
# Flutter expects the setState() callback to be synchronous (return void).
# `setState(() async { ... })` returns a Future and triggers runtime warnings/
# Crashlytics noise. Do async work outside setState, then synchronously update.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for async setState() callbacks..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Common violation shapes:
# - setState(() async { ... })
# - setState(() async => ...)
PATTERN_1='setState[[:space:]]*\\([[:space:]]*\\([[:space:]]*\\)[[:space:]]*async'
PATTERN_2='setState[[:space:]]*\\([[:space:]]*\\([[:space:]]*\\)[[:space:]]*async[[:space:]]*=>'

VIOLATIONS=""

if command -v rg &> /dev/null; then
  matches="$(
    rg -n --no-heading --fixed-strings "" lib 2>/dev/null \
      --glob "!**/*.g.dart" \
      --glob "!**/*.freezed.dart" \
      --glob "!**/*.gr.dart" \
      --glob "!**/generated/**" \
      --glob "!**/*.mocks.dart" \
      | cat
  )"
  # We can't easily apply the regex to the whole file stream above; run rg
  # twice directly with the regex patterns.
  results="$(
    rg -n --no-heading -P "$PATTERN_1|$PATTERN_2" lib 2>/dev/null \
      --glob "!**/*.g.dart" \
      --glob "!**/*.freezed.dart" \
      --glob "!**/*.gr.dart" \
      --glob "!**/generated/**" \
      --glob "!**/*.mocks.dart" \
      || true
  )"
else
  results="$(
    grep -RIn "setState(" lib 2>/dev/null | grep -E "setState[[:space:]]*\\([[:space:]]*\\([[:space:]]*\\)[[:space:]]*async" || true
  )"
fi

if [ -n "${results:-}" ]; then
  VIOLATIONS="$results"
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
  echo ""
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: setState() callback must not be async"
  echo ""
  echo "$VIOLATIONS"
  echo ""
  echo "Fix pattern:"
  echo "  final value = await ...;"
  echo "  if (!mounted) return;"
  echo "  setState(() { ... });"
  exit 1
fi

echo "✅ No async setState() callbacks found"
