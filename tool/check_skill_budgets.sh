#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

inventory_path="${1:-docs/audits/skill_inventory_latest.json}"
mode="${2:-report}"

if [ ! -f "$inventory_path" ]; then
  # Fallback: if caller used default path and it's missing, try newest dated inventory.
  if [ "${1:-}" = "" ] || [ "$inventory_path" = "docs/audits/skill_inventory_latest.json" ]; then
    inventory_path="$(ls -t docs/audits/skill_inventory_*.json 2>/dev/null | head -n 1 || true)"
  fi
fi

if [ -z "${inventory_path:-}" ] || [ ! -f "$inventory_path" ]; then
  echo "skill budgets: inventory not found: ${inventory_path:-<empty>}" >&2
  echo "hint: dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json" >&2
  exit 2
fi

enforce_flag=""
if [ "$mode" = "enforce" ]; then
  enforce_flag="--enforce"
fi

dart tool/skill_budget_check.dart "$inventory_path" $enforce_flag
