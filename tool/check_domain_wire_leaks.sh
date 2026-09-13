#!/usr/bin/env bash
# Warn-only: domain-layer fromJson/toJson (wire shape in domain).
# Theme: architecture | Severity: warn
# See docs/engineering/flutter-anti-patterns.md AP-11 and reduce_surprise_patterns.md

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

# shellcheck disable=SC1091
source "$TOOL_DIR/check_helpers.sh"

DOMAIN_GLOB="${APP_ROOT}/lib/features/*/domain"

echo "🔍 Checking domain wire leaks (warn-only) under ${DOMAIN_GLOB}..."

hits=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  echo "⚠️  $line"
  hits=$((hits + 1))
done < <(
  # Live Melos app shell: apps/mobile/lib/features/*/domain (not stale repo-root lib/).
  rg -n "fromJson|toJson" ${DOMAIN_GLOB} -g '*.dart' 2>/dev/null || true
)

if [[ "$hits" -eq 0 ]]; then
  echo "✅ ok|domain-wire-leaks|violations=0|root=${APP_ROOT}/lib/features"
  exit 0
fi

echo "⚠️  warn|domain-wire-leaks|violations=$hits|root=${APP_ROOT}/lib/features"
exit 0
