#!/usr/bin/env bash
# Navigation APIs must not appear in domain or data layers (Clean Architecture).
# Theme: navigation-architecture | Severity: fail
# Suppress: check-ignore on same or previous line (tool/check_helpers.sh).
#
# Scope: lib/features/**/{domain,data}/**, lib/shared/**/{domain,data}/**

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

source "$PROJECT_ROOT/tool/check_helpers.sh"

echo "🔍 Checking navigation APIs outside presentation layer..."

usage() {
  cat <<'EOF'
Usage: tool/check_navigation_outside_presentation.sh [--paths PATH...]

Default scope: feature/shared domain and data trees. --paths for fixture runs.
EOF
}

SCAN_PATHS=(
  "lib/features"
  "lib/shared"
)
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  SCAN_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

NAV_PATTERN='package:go_router/|(^|[^[:alnum:]_])go_router([^[:alnum:]_]|$)|\bcontext\.(go|push|pushReplacement|pop)\b|\bGoRouter\b|\bGoRoute\b'

collect_violations() {
  local root
  local hits
  local out=""
  for root in "${SCAN_PATHS[@]}"; do
    if [ -f "$root" ]; then
      dartfile="$root"
      case "$dartfile" in
        */domain/*|*/data/*) ;;
        *) continue ;;
      esac
      if command -v rg &>/dev/null; then
        hits=$(rg -nH "$NAV_PATTERN" "$dartfile" 2>/dev/null           | rg -v '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      else
        hits=$(grep -nHE "$NAV_PATTERN" "$dartfile" 2>/dev/null           | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      fi
      [ -n "$hits" ] && out+="${hits}"$'
'
      continue
    fi
    [ -d "$root" ] || continue
    while IFS= read -r dartfile; do
      [ -f "$dartfile" ] || continue
      case "$dartfile" in
        */domain/*|*/data/*) ;;
        *) continue ;;
      esac
      if command -v rg &>/dev/null; then
        hits=$(rg -nH "$NAV_PATTERN" "$dartfile" 2>/dev/null \
          | rg -v '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      else
        hits=$(grep -nHE "$NAV_PATTERN" "$dartfile" 2>/dev/null \
          | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      fi
      if [ -n "$hits" ]; then
        out+="${hits}"$'\n'
      fi
    done < <(find "$root" -name '*.dart' -type f -print 2>/dev/null)
  done
  printf '%s' "$out"
}

VIOLATIONS="$(collect_violations)"
VIOLATIONS="$(filter_ignored "$VIOLATIONS")"

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Navigation APIs found in domain/data layers:"
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ No navigation APIs in domain/data layers"
exit 0
