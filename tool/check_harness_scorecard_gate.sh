#!/usr/bin/env bash
# Static gate for Cursor/Codex harness max-score claims.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_harness_scorecard_gate.sh

Validate that Cursor/Codex harness scorecard owners, proof gates, and high-use
agent docs stay wired together. This is a static/no-network gate; run
agent-maintain closeout separately for host sync.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

missing=()

require_file() {
  local path="$1"
  [[ -f "$path" ]] || missing+=("missing file: $path")
}

require_contains() {
  local path="$1"
  local needle="$2"
  if [[ ! -f "$path" ]]; then
    missing+=("missing file: $path")
    return
  fi
  if ! grep -qF -- "$needle" "$path"; then
    missing+=("$path missing: $needle")
  fi
}

require_file "docs/ai/harness_scorecard.md"
require_file "docs/ai/harness_auto_maintenance.md"
require_file "docs/ai/ai_failure_risks.md"
require_file "docs/architecture/feature_structure_contract.md"
require_file "docs/architecture/reference_features.md"
require_file "docs/architecture/use_case_dto_policy.md"
require_file "docs/bloc_standards.md"
require_file "docs/testing/matrix_required_by_change.md"
require_file "docs/review/architecture_checklist.md"
require_file "docs/review/bloc_checklist.md"
require_file "docs/review/security_checklist.md"
require_file "docs/review/performance_checklist.md"
require_file "docs/bloc/cubit_file_template.md"
require_file "docs/architecture/feature_brief_scaffold_example.md"
require_file "tool/check_ai_failure_risk_register.sh"
require_file "tool/check_clean_architecture_imports.sh"
require_file "tool/check_feature_folder_contract.sh"
require_file "tool/scaffold_feature_contract.sh"
require_file "tool/update_harness_score_badge.sh"
require_file "tool/agent_host_templates/shared/skills/agents-feature-delivery/SKILL.md"
require_file "tool/agent_host_templates/shared/skills/agents-bloc-standards/SKILL.md"
require_file "tool/agent_host_templates/shared/skills/agents-create-cubit/SKILL.md"

require_contains "AGENTS.md" "docs/ai/harness_scorecard.md"
require_contains "AGENTS.md" "docs/ai/harness_auto_maintenance.md"
require_contains "AGENTS.md" "docs/ai/ai_failure_risks.md"
require_contains "README.md" "Harness score"
require_contains "README.md" "docs/ai/harness_scorecard.md"
require_contains "docs/ai/harness_scorecard.md" "harness_auto_maintenance.md"
require_contains "docs/ai/ai_failure_risks.md" "RISK-HARNESS-SCORE-DROP"
require_contains "docs/ai/ai_failure_risks.md" "harness_auto_maintenance.md"
require_contains "tool/agent_maintain.sh" "scope_has_harness_edits"
require_contains "tool/agent_maintain.sh" "harness-maintain"
require_contains "tool/agent_maintain.sh" "update_harness_score_badge.sh"
require_contains "docs/agent_kb/host_maintenance_automation.md" "harness-maintain"
require_contains "docs/agents_quick_reference.md" "Harness max-score claim"
require_contains "docs/agents_quick_reference.md" "AI failure-risk register"
require_contains "docs/ai/skill_routing.md" "agents-feature-delivery"
require_contains "docs/ai/skill_routing.md" "agents-bloc-standards"
require_contains "docs/ai/harness_scorecard.md" "bash tool/check_ai_failure_risk_register.sh"
require_contains "docs/ai/harness_scorecard.md" "./bin/checklist-fast --no-reuse"
require_contains "docs/ai/harness_scorecard.md" "./bin/agent-maintain closeout"
require_contains "docs/ai/harness_scorecard.md" "ai_failure_risks.md"
require_contains "docs/ai/harness_scorecard.md" "check_feature_folder_contract.sh"
require_contains "docs/ai/harness_scorecard.md" "reference_features.md"
require_contains "docs/architecture/feature_structure_contract.md" "reference_features.md"
require_contains "docs/ai/harness_scorecard.md" "review/security_checklist.md"
require_contains "docs/ai/harness_scorecard.md" "review/performance_checklist.md"
require_contains "docs/ai/skill_routing.md" "agents-create-cubit"
require_contains "tool/agent_asset_lib.sh" "agents-create-cubit"
require_contains "docs/ai/ai_failure_risks.md" "## Pre-Flight"
require_contains "docs/ai/ai_failure_risks.md" "RISK-ASYNC-LIFECYCLE"
require_contains "docs/ai/ai_failure_risks.md" "RISK-SECURITY-GAP"
require_contains "docs/ai/ai_failure_risks.md" "RISK-VALIDATION-SHORTCUT"
require_contains "docs/ai/ai_failure_risks.md" "./bin/agent-maintain closeout"
require_contains "docs/ai/context_loading.md" "ai_failure_risks.md"
require_contains "docs/ai/skill_routing.md" "agents-common-pitfalls"
require_contains "AGENTS.md" "agents-common-pitfalls"
require_file "tool/agent_host_templates/shared/skills/agents-common-pitfalls/SKILL.md"
require_contains "tool/agent_asset_lib.sh" "agents-feature-delivery"
require_contains "tool/agent_asset_lib.sh" "agents-bloc-standards"

if ((${#missing[@]} > 0)); then
  echo "❌ Harness scorecard gate failed:" >&2
  printf '  - %s\n' "${missing[@]}" >&2
  exit 1
fi

bash "$repo_root/tool/update_harness_score_badge.sh" --check >/dev/null
bash "$repo_root/tool/check_ai_failure_risk_register.sh" >/dev/null

echo "✅ Harness scorecard gate passed"
