#!/usr/bin/env bash
# Validate the AI failure risk register stays complete enough for Cursor/Codex.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

usage() {
  cat <<'EOF'
Usage: tool/check_ai_failure_risk_register.sh [--path PATH]

Checks docs/ai/ai_failure_risks.md for required risk IDs and proof commands.
EOF
}

doc_path="docs/ai/ai_failure_risks.md"
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--path" ]]; then
  doc_path="${2:-}"
  if [[ -z "$doc_path" ]]; then
    echo "❌ --path requires a file path" >&2
    exit 2
  fi
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

if [[ ! -f "$doc_path" ]]; then
  echo "❌ Missing AI failure risk register: $doc_path" >&2
  exit 1
fi

required_tokens=(
  "## Pre-Flight"
  "## Priority"
  "## Minimum proof by task"
  "RISK-ARCH-LAYER"
  "RISK-ASYNC-LIFECYCLE"
  "RISK-OFFLINE-OVERWRITE"
  "RISK-INTEGRATION-SEAM"
  "RISK-BLOC-DIVERGENCE"
  "RISK-FEATURE-BRIEF-SKIP"
  "RISK-TEST-GAP"
  "RISK-HOST-DRIFT"
  "RISK-DOC-DRIFT"
  "RISK-CONTEXT-OVERLOAD"
  "RISK-SECRET-LEAK"
  "RISK-SECURITY-GAP"
  "RISK-DESTRUCTIVE-SIDE-EFFECT"
  "RISK-STALE-API"
  "RISK-UI-REGRESSION"
  "RISK-VALIDATION-SHORTCUT"
  "RISK-HARNESS-SCORE-DROP"
  "harness_auto_maintenance.md"
  "harness-maintain"
  "agents-common-pitfalls"
  "reference_features.md"
  "review/security_checklist.md"
  "Prevention"
  "Detection"
  "Recovery"
  "bash ../../tool/check_clean_architecture_imports.sh"
  "bash ../../tool/check_feature_folder_contract.sh"
  "bash ../../tool/check_feature_modularity_leaks.sh"
  "bash ../../tool/check_feature_brief_linked.sh"
  "bash ../../tool/check_harness_scorecard_gate.sh"
  "bash ../../tool/check_agent_asset_drift.sh"
  "./tool/check_tracked_secret_literals.sh"
  "./bin/checklist-fast --no-reuse"
  "./bin/agent-maintain preflight"
  "./bin/agent-maintain closeout"
)

missing=()
for token in "${required_tokens[@]}"; do
  if ! grep -qF -- "$token" "$doc_path"; then
    missing+=("$token")
  fi
done

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "❌ AI failure risk register missing required content:"
  for token in "${missing[@]}"; do
    printf '%s\n' "- $token"
  done
  exit 1
fi

echo "✅ AI failure risk register is complete"
