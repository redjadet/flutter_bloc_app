#!/usr/bin/env bash
# Check for missing const constructors in StatelessWidget
# Helps optimize widget rebuilds

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for missing const constructors in StatelessWidget..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Use ripgrep if available, otherwise grep
# Find StatelessWidget classes and flag constructors missing const (heuristic)
if command -v rg &> /dev/null; then
  CLASS_MATCHES=$(rg -n "class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+extends[[:space:]]+StatelessWidget" lib/features lib/shared lib/app 2>/dev/null \
    --glob "*/presentation/**" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | rg -v "test" \
    | rg -v "^[[:space:]]*//" \
    || true)
else
  CLASS_MATCHES=$(grep -rn "extends[[:space:]]\+StatelessWidget" lib/features lib/shared lib/app 2>/dev/null \
    | grep -v "/test/" \
    | grep -v "^[[:space:]]*//" \
    || true)
fi

VIOLATIONS=""

while IFS= read -r match; do
  [ -z "$match" ] && continue
  file="${match%%:*}"
  class_name=$(printf "%s" "$match" | sed -n 's/.*class[[:space:]]\+\([A-Za-z_][A-Za-z0-9_]*\)[[:space:]]\+extends[[:space:]]\+StatelessWidget.*/\1/p')
  [ -z "$class_name" ] && continue

  if command -v rg &> /dev/null; then
    constructors=$(rg -n "^[[:space:]]*(const[[:space:]]+)?${class_name}\\(" "$file" 2>/dev/null || true)
  else
    constructors=$(grep -n "^[[:space:]]*${class_name}(" "$file" 2>/dev/null || true)
  fi

  while IFS= read -r ctor; do
    [ -z "$ctor" ] && continue
    line_no="${ctor%%:*}"
    content="${ctor#*:}"
    if printf "%s" "$content" | grep -q "factory[[:space:]]\+${class_name}"; then
      continue
    fi
    if printf "%s" "$content" | grep -q "^[[:space:]]*const[[:space:]]\+${class_name}"; then
      continue
    fi
    VIOLATIONS+="${file}:${line_no}: Constructor could be const"$'\n'
  done <<< "$constructors"
done <<< "$CLASS_MATCHES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "⚠️  Potential missing const constructors in StatelessWidget (heuristic)"
  echo "Note: This is a heuristic check. Review manually for const optimization opportunities"
  echo ""
  echo "$VIOLATIONS"
  # Do not fail the checklist (heuristic only, similar to side_effects_build.sh)
  exit 0
else
  echo "✅ No obvious missing const constructors found"
  exit 0
fi
