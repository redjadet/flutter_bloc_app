#!/usr/bin/env bash
# Warn-only: domain-layer fromJson/toJson (wire shape in domain).
# Theme: architecture | Severity: warn
# See docs/engineering/flutter-anti-patterns.md AP-11 and reduce_surprise_patterns.md

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

source "$PROJECT_ROOT/tool/check_helpers.sh"

echo "🔍 Checking domain wire leaks (warn-only)..."

hits=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  echo "⚠️  $line"
  hits=$((hits + 1))
done < <(
  rg -n "fromJson|toJson" lib/features/*/domain -g '*.dart' 2>/dev/null || true
)

if [[ "$hits" -eq 0 ]]; then
  echo "✅ ok|domain-wire-leaks|violations=0"
  exit 0
fi

echo "⚠️  warn|domain-wire-leaks|violations=$hits"
exit 0
