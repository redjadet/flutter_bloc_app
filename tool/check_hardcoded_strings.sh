#!/usr/bin/env bash
# Check for hard-coded user-facing strings (should use context.l10n.* instead)
# Patterns include Text('...'), TextSpan(text: '...'), AppMessage(title/message:
# '...'), and CommonErrorView(message: '...').

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for hard-coded user-facing strings in presentation layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match Text('...'), SelectableText('...'), TextSpan(text: '...'),
# AppMessage(title/message: '...'), or CommonErrorView(message: '...') but
# exclude:
# - context.l10n.* usage
# - Test files
# - Comments
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -nU "Text\\(\\s*['\"]|SelectableText\\(\\s*['\"]|TextSpan\\([^\\)]*text:\\s*['\"]|AppMessage\\([\\s\\S]{0,180}(title|message):\\s*['\"]|CommonErrorView\\([\\s\\S]{0,180}message:\\s*['\"]" lib/features lib/shared lib/app 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "lib/shared/widgets/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "context\.l10n\." \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    | rg -v ":[0-9]+:[[:space:]]*///" \
    | rg -v "Text\\(\\s*['\"][[:space:]]*['\"]\\)" \
    || true)
else
  VIOLATIONS=$(grep -rn "Text(\|SelectableText(\|TextSpan(.*text:\|AppMessage(\|CommonErrorView(" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "context\.l10n\." \
    | grep -v "^[[:space:]]*//" \
    | grep -vE ":[0-9]+:[[:space:]]*///" \
    | grep -v "Text(['\"][[:space:]]*['\"])" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Hard-coded user-facing strings (use context.l10n.* instead)"
  echo "Note: All user-facing strings should be localized via context.l10n.*"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No hard-coded user-facing strings found"
  exit 0
fi
