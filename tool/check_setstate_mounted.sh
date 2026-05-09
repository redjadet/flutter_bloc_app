#!/usr/bin/env bash
# Check for missing mounted checks before setState() after await
# Common pattern: await ...; setState(...) without mounted/context.mounted check

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for missing mounted checks before setState() after await..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
if command -v rg &> /dev/null; then
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
  results=$(
    awk -v file="$file" '
      BEGIN { in_async=0; await_line=0; has_mounted_check=0 }
      {
        line=$0
        if (line ~ /await[[:space:]]+[^;]+;/) {
          in_async=1
          await_line=NR
          has_mounted_check=0
        }
        if (in_async && line ~ /if[[:space:]]*\([^)]*(context\.mounted|mounted)[^)]*\)/) {
          has_mounted_check=1
        }
        if (in_async && line ~ /setState[[:space:]]*\(/) {
          if (!has_mounted_check && NR > await_line) {
            if (line !~ /check-ignore/ && prev !~ /check-ignore/) {
              print file ":" NR ":" line
            }
          }
        }
        if (line ~ /^[[:space:]]*(void|Future|Widget|class|enum|mixin|@override)[[:space:]]/ && NR > await_line + 10) {
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
  echo "❌ Violations found: Missing mounted check before setState() after await"
  echo "Note: After 'await', check 'if (!mounted) return;' before setState()"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ All setState() calls properly check mounted after await"
  exit 0
fi
