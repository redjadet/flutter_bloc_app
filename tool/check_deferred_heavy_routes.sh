#!/usr/bin/env bash
# Warn/fail: deferred route imports must stay in allowlisted router files only.
# Theme: navigation-architecture | Severity: fail by default (CHECK_DEFERRED_HEAVY_ROUTES_MODE=fail)
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
MODE="${CHECK_DEFERRED_HEAVY_ROUTES_MODE:-fail}"
ALLOWLIST=(
  "lib/app/router/route_groups.dart"
  "lib/app/router/routes_core.dart"
  "tool/fixtures/deferred_heavy_routes/router/good.dart"
)
echo "🔍 Checking deferred heavy route allowlist (mode=$MODE)..."
usage() {
  cat <<'EOF'
Usage: tool/check_deferred_heavy_routes.sh [--paths PATH...]
EOF
}
SCAN_PATHS=("lib/app/router")
case "$MODE" in
  warn|fail) ;;
  *)
    echo "❌ CHECK_DEFERRED_HEAVY_ROUTES_MODE must be warn or fail (got: $MODE)" >&2
    exit 2
    ;;
esac
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  SCAN_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  exit 2
fi
is_allowlisted() {
  local file="$1"
  local allowed
  for allowed in "${ALLOWLIST[@]}"; do
    [ "$file" = "$allowed" ] && return 0
  done
  return 1
}
collect_violations() {
  local root dartfile out=""
  for root in "${SCAN_PATHS[@]}"; do
    while IFS= read -r dartfile; do
      [ -f "$dartfile" ] || continue
      rg -q 'deferred\s+as\s+' "$dartfile" 2>/dev/null || continue
      is_allowlisted "$dartfile" && continue
      out+="${dartfile}:1: deferred import outside allowlisted router manifest"$'\n'
    done < <(find "$root" -name '*.dart' -type f 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored:"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "❌ Deferred heavy routes: ${count} violation(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d'
  echo "Allowlist: ${ALLOWLIST[*]}"
  if [ "$MODE" = "warn" ]; then
    echo "⚠️  CHECK_DEFERRED_HEAVY_ROUTES_MODE=warn — exiting 0"
    exit 0
  fi
  exit 1
fi
echo "✅ Deferred imports match router allowlist"
exit 0
