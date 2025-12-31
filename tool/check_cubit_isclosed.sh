#!/usr/bin/env bash
# Check for missing isClosed checks before emit() in cubits
# Common pattern: emit() in async callbacks without isClosed check

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for missing isClosed checks before emit() in cubits..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Find cubit files
if command -v rg &> /dev/null; then
  FILES=$(rg -l "extends.*Cubit|extends.*Bloc" lib/features lib/shared lib/core 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    || true)
else
  FILES=$(grep -rl "extends.*Cubit\|extends.*Bloc" lib/features lib/shared lib/core 2>/dev/null \
    | grep -v "/test/" \
    || true)
fi

VIOLATIONS=""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  # Use awk to find emit() calls without isClosed check in async contexts
  results=$(
    awk -v file="$file" '
      BEGIN { in_async=0; emit_line=0; has_isclosed_check=0; in_callback=0 }
      {
        line=$0
        # Detect async contexts (callbacks, stream subscriptions, timers)
        if (line ~ /\.listen\(|\.then\(|\.catchError\(|\.whenComplete\(|Future\.delayed\(|Timer|TimerService|StreamSubscription|addPostFrameCallback/) {
          in_async=1
          in_callback=1
          has_isclosed_check=0
        }
        # Check for isClosed check
        if (line ~ /if[[:space:]]*\([^)]*isClosed[^)]*\)|if[[:space:]]*\([^)]*!.*isClosed[^)]*\)/) {
          has_isclosed_check=1
        }
        # Check for emit() call
        if (line ~ /emit\(/) {
          emit_line=NR
          if (in_callback && !has_isclosed_check) {
            # Check if this line or previous has check-ignore
            if (line !~ /check-ignore/ && prev !~ /check-ignore/) {
              print file ":" NR ":" line
            }
          }
        }
        # Reset when we see a new method or class
        if (line ~ /^[[:space:]]*(void|Future|Widget|class|enum|mixin|@override)[[:space:]]/ && NR > emit_line + 5) {
          in_async=0
          in_callback=0
          emit_line=0
          has_isclosed_check=0
        }
        # Reset after closing brace if we are in a callback
        if (in_callback && line ~ /^[[:space:]]*}[[:space:]]*$/) {
          in_callback=0
          has_isclosed_check=0
        }
        prev=line
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
  echo "❌ Violations found: Missing isClosed check before emit() in async callbacks"
  echo "Note: Always check 'if (isClosed) return;' before emit() in async callbacks"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ All emit() calls properly check isClosed in async contexts"
  exit 0
fi
