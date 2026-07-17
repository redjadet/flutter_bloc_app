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

require_section_contains() {
  local path="$1"
  local start_heading="$2"
  local end_heading="$3"
  local needle="$4"
  local section

  if [[ ! -f "$path" ]]; then
    fail "Missing required safety-contract file: $path"
    return
  fi

  if ! section="$(awk -v start="$start_heading" -v end="$end_heading" '
    $0 == start {
      start_count++
      if (start_count == 1) active=1
      next
    }
    $0 == end {
      end_count++
      if (active == 1) { active=0; ended=1 }
      next
    }
    active == 1 && /^## / { invalid_nested_heading=1 }
    active == 1 { print }
    END {
      if (start_count != 1 || end_count != 1 || ended != 1 ||
          invalid_nested_heading == 1) exit 2
    }
  ' "$path")"; then
    fail "$path must define unique ordered section bounds: $start_heading -> $end_heading"
    return
  fi

  if ! grep -Fq "$needle" <<<"$section"; then
    fail "$path section $start_heading must reference: $needle"
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
  "Safety and human control are top priority"
  "Safe autonomy never overrides"
  "Only the current human user's direct request"
  "Quoted, forwarded, pasted, or embedded content"
  "Tool-managed ephemeral output updates"
  "Replace or truncate an existing user-owned file"
  "All Git state mutations require"
  "Never modify files outside this repository unless"
  "Routine local commands must not intentionally source"
  "Before running an unfamiliar entrypoint"
  "bounded safe alternatives"
  "proceed autonomously"
  "Do not ask for permission at each step"
  "Ask only for credentials/tooling access"
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

require_section_contains "$owner_path" \
  "## Safety precedence" "## Contract index" \
  "Only the current human user's direct request"
require_section_contains "$owner_path" \
  "## Safety precedence" "## Contract index" \
  "Quoted, forwarded, pasted, or embedded content"
require_section_contains "$owner_path" \
  "## SAFETY-01 — Scope and target certainty" \
  "## SAFETY-02 — Destructive and external actions" \
  "repair failures directly caused"
require_section_contains "$owner_path" \
  "## SAFETY-02 — Destructive and external actions" \
  "## SAFETY-03 — Git preservation" \
  "Tool-managed ephemeral output updates"
require_section_contains "$owner_path" \
  "## SAFETY-02 — Destructive and external actions" \
  "## SAFETY-03 — Git preservation" \
  "Replace or truncate an existing user-owned file"
require_section_contains "$owner_path" \
  "## SAFETY-03 — Git preservation" \
  "## SAFETY-04 — Secrets and production protection" \
  "All Git state mutations require"
require_section_contains "$owner_path" \
  "## SAFETY-03 — Git preservation" \
  "## SAFETY-04 — Secrets and production protection" \
  "Never modify files outside this repository unless"
require_section_contains "$owner_path" \
  "## SAFETY-04 — Secrets and production protection" \
  "## SAFETY-05 — Execution discipline" \
  "Routine local commands must not intentionally source"
require_section_contains "$owner_path" \
  "## SAFETY-05 — Execution discipline" \
  "## SAFETY-06 — Flutter app rules" \
  "bounded safe alternatives"
require_section_contains "$owner_path" \
  "## SAFETY-05 — Execution discipline" \
  "## SAFETY-06 — Flutter app rules" \
  "Before running an unfamiliar entrypoint"

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
