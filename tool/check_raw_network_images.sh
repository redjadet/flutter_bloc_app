#!/usr/bin/env bash
# Check for raw network image usage (should use CachedNetworkImageWidget)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for raw network image usage..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "Image\\.network\\(|NetworkImage\\(|CachedNetworkImage\\(" lib 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    --glob "!**/cached_network_image_widget.dart" \
    | rg -v "CachedNetworkImageWidget" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "Image\\.network(\\|NetworkImage(\\|CachedNetworkImage(" lib 2>/dev/null \
    | grep -v "cached_network_image_widget.dart" \
    | grep -v "CachedNetworkImageWidget" \
    | grep -v "/test/" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Raw network image usage (use CachedNetworkImageWidget)"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No raw network image usage found"
  exit 0
fi
