#!/usr/bin/env bash
# Presentation must not use Isolate.run: closures defined on State/widgets often
# capture non-sendable Flutter objects and crash at runtime ("illegal argument in
# isolate message"). Use package:flutter/foundation.dart compute() with a
# top-level or static callback and a sendable message instead.

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./check_helpers.sh disable=SC1091
source "$TOOL_DIR/check_helpers.sh"

usage() {
  cat <<'EOF'
Usage: bash tool/check_no_isolate_run_in_presentation.sh [--paths PATH...]

Without --paths, scans app/package source roots. --paths supports focused
fixture or changed-path validation.
EOF
}

echo "🔍 Checking for Isolate.run in presentation layer..."

IGNORED=""
SEARCH_ROOTS=()

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  for root in "$@"; do
    SEARCH_ROOTS+=("$(resolve_scan_root "$root")")
  done
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
else
  for root in "$PROJECT_ROOT/lib" "$WORKSPACE_ROOT/packages"; do
    if [[ -d "$root" ]]; then
      SEARCH_ROOTS+=("$root")
    fi
  done
fi

if [[ "${#SEARCH_ROOTS[@]}" -eq 0 ]]; then
  echo "❌ No app/package source roots found"
  exit 1
fi

for root in "${SEARCH_ROOTS[@]}"; do
  if [[ ! -e "$root" ]]; then
    echo "❌ Source path not found: $root" >&2
    exit 1
  fi
done

if command -v rg &> /dev/null; then
  VIOLATIONS=$(rg -n --with-filename "\bIsolate\.run\s*\(" "${SEARCH_ROOTS[@]}" \
    --glob "**/presentation/*.dart" \
    --glob "**/presentation/**/*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    2>/dev/null \
    || true)
else
  VIOLATIONS=$(find "${SEARCH_ROOTS[@]}" -path "*/presentation/*.dart" \
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
  echo "See docs/validation_scripts/catalog.md (Compute/Isolate) and package:ilkersevim_json_isolate."
  exit 1
else
  echo "✅ No Isolate.run usage in presentation"
  exit 0
fi
