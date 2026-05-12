#!/usr/bin/env bash
# Report deep feature imports from the app composition layer.
#
# Policy target (Phase 3): prefer `package:flutter_bloc_app/features/<f>/<f>.dart`
# barrels for stable entrypoints. Current tree still uses many direct
# presentation/data/domain imports from `lib/app/` — this script is **report-only**
# (always exit 0) until barrels are expanded and imports are migrated.
#
# Usage: bash tool/check_feature_barrel_exports.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📎 Feature barrel / deep-import report (lib/app → features/* layers)"
echo

if ! command -v rg &>/dev/null; then
  echo "Install ripgrep for this report."
  exit 0
fi

hits=$(rg -n "package:flutter_bloc_app/features/[^/]+/(presentation|data|domain)/" lib/app --glob "*.dart" 2>/dev/null || true)
count=$(printf '%s\n' "$hits" | sed '/^$/d' | wc -l | tr -d ' ')

echo "Deep imports (app layer into feature presentation/data/domain): ${count} lines"
echo "---"
if [[ -n "$hits" ]]; then
  printf '%s\n' "$hits" | head -40
  if [[ "$count" -gt 40 ]]; then
    echo "... (truncated; full: rg -n \"package:flutter_bloc_app/features/[^/]+/(presentation|data|domain)/\" lib/app)"
  fi
else
  echo "(none)"
fi

echo
echo "Barrel files present: bash tool/modular_metrics.sh (Feature barrels section)"
echo "Exit 0 (report only). Use docs/modularity.md Phase 3 for migration guidance."

exit 0
