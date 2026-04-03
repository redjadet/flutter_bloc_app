#!/usr/bin/env bash
# Presentation must not use Isolate.run: closures defined on State/widgets often
# capture non-sendable Flutter objects and crash at runtime ("illegal argument in
# isolate message"). Use package:flutter/foundation.dart compute() with a
# top-level or static callback and a sendable message instead.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for Isolate.run in presentation layer..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n "\bIsolate\.run\s*\(" lib \
    --glob "**/presentation/**/*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    2>/dev/null \
    || true)
else
  VIOLATIONS=$(find lib -path "*/presentation/*.dart" \
    ! -name "*.g.dart" \
    ! -name "*.freezed.dart" \
    ! -name "*.gr.dart" \
    -print0 2>/dev/null \
    | xargs -0 grep -nE "\bIsolate\.run\s*\(" 2>/dev/null \
    || true)
fi

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Isolate.run in presentation (use compute + top-level/static callback)"
  echo "$VIOLATIONS"
  echo ""
  echo "See docs/validation_scripts.md (Compute/Isolate) and lib/shared/utils/isolate_json.dart for patterns."
  exit 1
else
  echo "✅ No Isolate.run usage in presentation"
  exit 0
fi
