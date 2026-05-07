#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

inventory_path="${1:-docs/audits/skill_inventory_latest.json}"
mode="${2:-report}"

if [ ! -f "$inventory_path" ]; then
  echo "skill budgets: inventory not found: $inventory_path" >&2
  echo "hint: dart run tool/skill_inventory.dart $inventory_path" >&2
  exit 2
fi

enforce_flag=""
if [ "$mode" = "enforce" ]; then
  enforce_flag="--enforce"
fi

dart run tool/skill_budget_check.dart "$inventory_path" $enforce_flag

