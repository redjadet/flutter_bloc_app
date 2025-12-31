#!/usr/bin/env bash
# Check for missing context.mounted checks after async operations
# Common pattern: await ...; Navigator.of(context) or context.read() without mounted check

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for missing context.mounted checks after async operations..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Look for patterns like: await ...; Navigator.of(context) or context.read() without context.mounted check
if command -v rg &> /dev/null; then
  # Find files with await followed by context usage
  FILES=$(rg -l "await" lib/features lib/shared lib/app 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    || true)
else
  FILES=$(grep -rl "await" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "/test/" \
    || true)
fi

VIOLATIONS=""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  # Use awk to find await followed by context usage without mounted check
  results=$(
    awk -v file="$file" '
      BEGIN { in_async=0; await_line=0; has_mounted_check=0 }
      {
        line=$0
        # Check if line has await
        if (line ~ /await[[:space:]]+[^;]+;/) {
          in_async=1
          await_line=NR
          has_mounted_check=0
        }
        # Check for context.mounted check after await
        if (in_async && line ~ /context\.mounted|mounted[[:space:]]*==[[:space:]]*false|!.*mounted/) {
          has_mounted_check=1
        }
        # Check for context usage after await (Navigator, context.read, context.watch, etc.)
        if (in_async && line ~ /Navigator\.|context\.(read|watch|select|push|pop|go)|ScaffoldMessenger\.of\(context\)|showDialog|showModalBottomSheet/) {
          if (!has_mounted_check && NR > await_line) {
            # Check if this line or previous has check-ignore
            if (line !~ /check-ignore/ && prev !~ /check-ignore/) {
              print file ":" NR ":" line
            }
          }
        }
        # Reset when we see a new function or class
        if (line ~ /^[[:space:]]*(void|Future|Widget|class|enum|mixin)[[:space:]]/ && NR > await_line + 10) {
          in_async=0
          await_line=0
          has_mounted_check=0
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
  echo "❌ Violations found: Missing context.mounted check after async operations"
  echo "Note: After 'await', always check 'if (!context.mounted) return;' before using context"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ All async operations properly check context.mounted"
  exit 0
fi
