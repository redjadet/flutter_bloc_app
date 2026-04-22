#!/usr/bin/env bash
# Check for presentation builders indexing live Cubit/BLoC state lists directly.
#
# In sliver/list builders, async state changes can leave a stale builder index
# while the live state list has already shrunk. Snapshot state lists into a local
# immutable list, use that snapshot for itemCount and itemBuilder, and guard
# stale indexes before indexing.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for live state-list indexing in presentation builders..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

FILES=""
if command -v rg &> /dev/null; then
  FILES=$(rg --files lib \
    --glob "*/presentation/**" \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  FILES=$(find lib -type f -name "*.dart" -path "*/presentation/*" 2>/dev/null || true)
fi

VIOLATIONS=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  results=$(
    awk -v file="$file" '
      /state[[:space:]]*\.[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\[[[:space:]]*index([[:space:]]*[-+][[:space:]]*[0-9]+)?[[:space:]]*\]/ {
        print file ":" NR ": direct state list indexing with builder index"
      }
      /state[[:space:]]*\.[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\.elementAt[[:space:]]*\([[:space:]]*index[[:space:]]*\)/ {
        print file ":" NR ": direct state list elementAt(index) in presentation"
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
  echo "❌ Live state-list indexing risk in presentation builders"
  echo ""
  echo "$VIOLATIONS"
  echo ""
  echo "Snapshot state lists before builder constructors, use the snapshot for itemCount,"
  echo "and guard stale indexes before indexing:"
  echo "  final items = List.of(state.items, growable: false);"
  echo "  itemCount: items.length,"
  echo "  if (index >= items.length) return const SizedBox.shrink();"
  exit 1
else
  echo "✅ No live state-list indexing risk found"
  exit 0
fi
