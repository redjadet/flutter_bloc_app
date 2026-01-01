#!/usr/bin/env bash
# Heuristic: flag StreamController usage without close() in the same file.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for StreamController without close()..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

FILES=""
if command -v rg &> /dev/null; then
  FILES=$(rg --files lib \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    || true)
else
  FILES=$(find lib -type f -name "*.dart" 2>/dev/null || true)
fi

VIOLATIONS=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if rg -q "StreamController<|StreamController\\(" "$file" 2>/dev/null; then
    if ! rg -q "\\.close\\(" "$file" 2>/dev/null; then
      local_match=$(rg -n -m 1 "StreamController<|StreamController\\(" "$file" 2>/dev/null || true)
      if [ -n "$local_match" ]; then
        VIOLATIONS+="${local_match}\n"
      else
        VIOLATIONS+="${file}:1: StreamController without close()\n"
      fi
    fi
  fi
done <<< "$FILES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Potential memory leak: StreamController without close()"
  echo "$VIOLATIONS"
  echo "Ensure controllers are closed in dispose()/close()"
  exit 1
else
  echo "✅ No StreamController leak candidates detected"
  exit 0
fi
