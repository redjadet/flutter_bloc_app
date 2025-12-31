#!/usr/bin/env bash
# Check for hard-coded strings in Text widgets (should use context.l10n.* instead)
# Pattern: Text('...') or Text("...") with user-facing strings

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for hard-coded strings in presentation layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match Text('...'), SelectableText('...'), or TextSpan(text: '...') but exclude:
# - context.l10n.* usage
# - Test files
# - Comments
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "Text\\(\\s*['\"]|SelectableText\\(\\s*['\"]|TextSpan\\([^\\)]*text:\\s*['\"]" lib/features lib/shared lib/app 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "context\.l10n\." \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    | rg -v "Text\\(\\s*['\"][[:space:]]*['\"]\\)" \
    || true)
else
  VIOLATIONS=$(grep -rn "Text(\|SelectableText(\|TextSpan(.*text:" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "context\.l10n\." \
    | grep -v "^[[:space:]]*//" \
    | grep -v "Text(['\"][[:space:]]*['\"])" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Hard-coded strings in Text widgets (use context.l10n.* instead)"
  echo "Note: All user-facing strings should be localized via context.l10n.*"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No hard-coded strings found in Text widgets"
  exit 0
fi
