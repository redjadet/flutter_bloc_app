#!/usr/bin/env bash
# Validate agent safety contracts stay complete and wired into harness surfaces.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_agent_safety_contracts.sh [--owner-path PATH]

Deterministic guard for agent safety contracts.

Checks:
- owner doc defines SAFETY-01..06 and SAFETY-REPORT
- maps, host templates, and risk register link to the owner doc
- validation catalog lists this checker

Options:
  --owner-path PATH  Validate an alternate owner doc (fixtures only)
EOF
}

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

owner_path="docs/agent_kb/agent_safety_contracts.md"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--owner-path" ]]; then
  owner_path="${2:-}"
  if [[ -z "$owner_path" ]]; then
    echo "❌ --owner-path requires a file path" >&2
    exit 2
  fi
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

failures=0

fail() {
  echo "❌ $*" >&2
  failures=1
}

require_contains() {
  local path="$1"
  local needle="$2"

  if [[ ! -f "$path" ]]; then
    fail "Missing required safety-contract file: $path"
    return
  fi

  if ! grep -qF "$needle" "$path"; then
    fail "$path must reference: $needle"
  fi
}

owner_tokens=(
  "SAFETY-01"
  "SAFETY-02"
  "SAFETY-03"
  "SAFETY-04"
  "SAFETY-05"
  "SAFETY-06"
  "SAFETY-REPORT"
  "same-turn approval"
  "No destructive or external actions were performed"
  "git reset --hard"
  "git clean"
  "force-push"
  "worktree removal"
  "git_and_branching_strategy.md"
  "security_and_secrets.md"
  "clean_architecture.md"
)

for token in "${owner_tokens[@]}"; do
  require_contains "$owner_path" "$token"
done

if [[ "$owner_path" == "docs/agent_kb/agent_safety_contracts.md" ]]; then
  require_contains "AGENTS.md" "agent_safety_contracts.md"
  require_contains "docs/agent_knowledge_base.md" "agent_safety_contracts.md"
  require_contains "docs/ai/context_loading.md" "agent_safety_contracts.md"
  require_contains "docs/ai/agent_operating_manual.md" "agent_safety_contracts.md"
  require_contains "docs/agents_quick_reference.md" "check_agent_safety_contracts.sh"
  require_contains "docs/agent_kb/legibility_and_finish_gate.md" "SAFETY-REPORT"
  require_contains "docs/ai/ai_failure_risks.md" "agent_safety_contracts.md"
  require_contains "tool/agent_host_templates/cursor/rules/agent-execution.mdc" "agent_safety_contracts.md"
  require_contains "tool/agent_host_templates/shared/skills/agents-common-pitfalls/SKILL.md" "agent_safety_contracts.md"
  require_contains "tool/agent_host_templates/shared/skills/agents-common-pitfalls/SKILL.md" "RISK-SCOPE-CREEP"
  require_contains "tool/agent_host_templates/shared/skills/agents-common-pitfalls/SKILL.md" "RISK-MISSING-TARGET"
  require_contains "tool/agent_host_templates/shared/skills/agents-common-pitfalls/SKILL.md" "RISK-UNAPPROVED-GIT"
  require_contains "tool/agent_host_templates/shared/skills/agents-common-pitfalls/SKILL.md" "SAFETY-REPORT"
  require_contains "docs/validation_scripts/catalog.md" "check_agent_safety_contracts.sh"
fi

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "✅ Agent safety contracts are complete"
