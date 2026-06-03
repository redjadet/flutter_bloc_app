#!/usr/bin/env bash
# Fail: cubit .listen without obvious subscription lifecycle.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
echo "🔍 Checking cubit stream subscription hygiene..."
SCAN_PATHS=("lib")
usage() {
  cat <<'EOF'
Usage: tool/check_cubit_subscription_cancel.sh [--paths PATH...]

Default scope: lib/**/*cubit*.dart. --paths supports fixture runs.
EOF
}
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
file_has_lifecycle() {
  grep -qE 'StreamSubscription|registerSubscription|CubitSubscriptionMixin|subscriptions\.cancel' "$1" 2>/dev/null
}
collect_violations() {
  local root dartfile listen_line out=""
  for root in "${SCAN_PATHS[@]}"; do
    while IFS= read -r dartfile; do
      case "$dartfile" in *cubit*) ;; *) continue ;; esac
      listen_line="$(grep -n '\.listen(' "$dartfile" 2>/dev/null | head -1 || true)"
      [ -n "$listen_line" ] || continue
      file_has_lifecycle "$dartfile" && continue
      out+="${dartfile}:${listen_line%%:*}: .listen without subscription lifecycle helper"$'\n'
    done < <(find "$root" -name '*.dart' -type f 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored:"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "❌ Cubit subscription cancel: ${count} violation(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | head -5
  echo "Remediation: CubitSubscriptionMixin or cancel in close()."
  exit 1
fi

echo "✅ No cubit subscription cancel violations"
exit 0
