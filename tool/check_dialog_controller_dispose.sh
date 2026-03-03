#!/usr/bin/env bash
# Heuristic: flag TextEditingController used with showDialog/showAdaptiveDialog
# and disposed in finally or immediately after await. This can cause
# "TextEditingController was used after being disposed" when the dialog
# route is still tearing down.
# Fix: use a StatefulWidget for dialog content and dispose the controller
# in State.dispose().

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for dialog + controller dispose anti-pattern..."

IGNORED=""
source "$PROJECT_ROOT/tool/check_helpers.sh"

FILES=""
if command -v rg &> /dev/null; then
  FILES=$(rg -l "TextEditingController" lib/ \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    2>/dev/null | while read -r f; do
      if rg -q "showDialog|showAdaptiveDialog" "$f" 2>/dev/null; then
        echo "$f"
      fi
    done || true)
else
  FILES=$(grep -rl "TextEditingController" lib/ 2>/dev/null | while read -r f; do
    grep -q "showDialog\|showAdaptiveDialog" "$f" 2>/dev/null && echo "$f"
  done || true)
fi

VIOLATIONS=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if ! grep -q "finally\|}\s*finally" "$file" 2>/dev/null; then
    continue
  fi
  if ! grep -q "\.dispose()" "$file" 2>/dev/null; then
    continue
  fi
  results=$(
    awk -v file="$file" '
      /TextEditingController\s*\(/ { has_controller=1; controller_line=NR }
      /showDialog|showAdaptiveDialog/ { if (has_controller) has_dialog=1; dialog_line=NR }
      /finally\s*\{|}\s*finally\s*\{/ { has_finally=1; finally_line=NR }
      /\.dispose\s*\(\)/ { if (has_finally && NR > finally_line) has_dispose_in_finally=1; dispose_line=NR }
      END {
        if (has_controller && has_dialog && has_finally && has_dispose_in_finally) {
          print file ":" (dispose_line ? dispose_line : 0) ": dispose() in finally after showDialog with TextEditingController (use StatefulWidget for dialog content, dispose in State.dispose)"
        }
      }
    ' "$file"
  )
  if [ -n "$results" ]; then
    VIOLATIONS+="${results}"$'\n'
  fi
done <<< "$FILES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Possible TextEditingController used after disposed:"
  echo "   Dispose controller in dialog route in finally/after await can race with route teardown."
  echo "$VIOLATIONS"
  echo "   Fix: Use a StatefulWidget for the dialog content; create controller in initState, dispose in State.dispose()."
  exit 1
else
  echo "✅ No dialog + controller dispose anti-pattern detected"
  exit 0
fi
