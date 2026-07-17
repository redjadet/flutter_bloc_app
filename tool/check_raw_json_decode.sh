#!/usr/bin/env bash
# Check for raw jsonDecode/jsonEncode usage (should use decodeJsonMap/decodeJsonList/encodeJsonIsolate for large payloads)

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$APP_ROOT"

echo "🔍 Checking for raw jsonDecode/jsonEncode usage..."

IGNORED=""

source "$WORKSPACE_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Match "jsonDecode" or "jsonEncode" but exclude:
# - test files
# - isolate_json.dart (the implementation file)
# - Generated files (*.g.dart, *.freezed.dart)
# - Comments
if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "\\b(jsonDecode|jsonEncode)\\(" lib/features lib/app 2>/dev/null \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    --glob "!lib/app/utils/isolate_json.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  VIOLATIONS=$(grep -rn "\\bjsonDecode(\\|\\bjsonEncode(" lib/features lib/app 2>/dev/null \
    | grep -v "lib/app/utils/isolate_json.dart" \
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
  echo "❌ Violations found: Raw jsonDecode/jsonEncode usage (use decodeJsonMap/decodeJsonList/encodeJsonIsolate for large payloads >8KB)"
  echo "$VIOLATIONS"
  echo ""
  echo "Note: For large payloads (>8KB), use:"
  echo "  - decodeJsonMap() for Map<String, dynamic>"
  echo "  - decodeJsonList() for List<dynamic>"
  echo "  - encodeJsonIsolate() for encoding large objects"
  echo ""
  echo "For small payloads (<8KB), you may add: // check-ignore: small payload (<8KB)"
  echo "Examples of small payloads: request bodies, config files, error responses"
  echo "See: lib/app/utils/isolate_json.dart and docs/performance/compute_isolate_review.md"
  exit 1
else
  echo "✅ No raw jsonDecode/jsonEncode usage found"
  exit 0
fi
