#!/usr/bin/env bash
# Warn/fail: State classes using WidgetsBindingObserver must removeObserver in dispose.
# Theme: lifecycle | Severity: warn by default (CHECK_LIFECYCLE_OBSERVER_MODE=warn)
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
MODE="${CHECK_LIFECYCLE_OBSERVER_MODE:-warn}"
echo "🔍 Checking WidgetsBindingObserver dispose hygiene (mode=$MODE)..."
usage() {
  cat <<'EOF'
Usage: tool/check_lifecycle_observer_dispose.sh [--paths PATH...]
EOF
}
SCAN_PATHS=("lib")
case "$MODE" in
  warn|fail) ;;
  *)
    echo "❌ CHECK_LIFECYCLE_OBSERVER_MODE must be warn or fail (got: $MODE)" >&2
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
collect_violations() {
  local root dartfile line_no out=""
  for root in "${SCAN_PATHS[@]}"; do
    while IFS= read -r dartfile; do
      [ -f "$dartfile" ] || continue
      rg -q 'WidgetsBindingObserver' "$dartfile" 2>/dev/null || continue
      rg -q 'addObserver\s*\(\s*this\s*\)' "$dartfile" 2>/dev/null || continue
      rg -q 'removeObserver\s*\(\s*this\s*\)' "$dartfile" 2>/dev/null && continue
      line_no=$(rg -n 'addObserver\s*\(\s*this\s*\)' "$dartfile" 2>/dev/null | head -1 | cut -d: -f1)
      line_no="${line_no:-1}"
      out+="${dartfile}:${line_no}: WidgetsBindingObserver without removeObserver(this) in dispose"$'\n'
    done < <(find "$root" -name '*.dart' -type f 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored:"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "❌ Lifecycle observer dispose: ${count} violation(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | head -5
  if [ "$MODE" = "warn" ]; then
    echo "⚠️  CHECK_LIFECYCLE_OBSERVER_MODE=warn — exiting 0"
    exit 0
  fi
  exit 1
fi
echo "✅ No lifecycle observer dispose violations"
exit 0
