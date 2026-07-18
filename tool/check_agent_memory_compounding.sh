#!/usr/bin/env bash
# Validate repo-native AI-agent memory-compounding guidance stays automatic and safe.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_agent_memory_compounding.sh

Deterministic guard for AI-agent memory-compounding doctrine.

Checks:
- source doc defines Memory Compounding
- source doc defines Context Navigation Ladder
- reusable conclusions route to durable repo memory, not chat-only notes
- low-token codebase awareness routes through code-review-graph before broad reads
- autonomous cron/action guidance requires explicit user approval
- quick reference and host templates expose the behavior
- bootstrap keeps exactly three core docs and all conditional owner routes

Exit codes:
  0 pass
  1 fail
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

failures=0
bootstrap_path="${AGENT_BOOTSTRAP_PATH:-tool/agent_session_bootstrap.sh}"

fail() {
  echo "❌ $*" >&2
  failures=1
}

require_contains() {
  local path="$1"
  local needle="$2"

  if [[ ! -f "$path" ]]; then
    fail "Missing required memory-compounding file: $path"
    return
  fi

  if ! grep -qF "$needle" "$path"; then
    fail "$path must reference: $needle"
  fi
}

require_contains "docs/agent_knowledge_base.md" "## Memory Compounding"
require_contains "docs/agent_knowledge_base.md" "## Context Navigation Ladder"
require_contains "docs/agent_knowledge_base.md" "File reusable conclusions"
require_contains "docs/agent_knowledge_base.md" "Do not dump chat transcripts"
require_contains "docs/agent_knowledge_base.md" "explicit user approval"
require_contains "docs/agent_knowledge_base.md" "separate RAG layer"
require_contains "docs/agent_knowledge_base.md" "code-review-graph"
require_contains "docs/agent_knowledge_base.md" "targeted raw-file reads"
require_contains "docs/agent_knowledge_base.md" "Semantic lint"
require_contains "docs/agents_quick_reference.md" "Reusable agent conclusion"
require_contains "docs/agents_quick_reference.md" "Context navigation ladder"
require_contains "docs/agents_quick_reference.md" "semantic lint"
require_contains "AGENTS.md" "Verified reusable agent conclusion"
require_contains "AGENTS.md" "context ladder"
if ! grep -qF "check_agent_memory_compounding.sh" docs/validation_scripts.md docs/validation_scripts/*.md 2>/dev/null; then
  fail "validation_scripts router or shards must reference: check_agent_memory_compounding.sh"
fi
require_contains "$bootstrap_path" 'read_core|AGENTS.md'
require_contains "$bootstrap_path" 'read_core|docs/ai/context_loading.md'
require_contains "$bootstrap_path" 'read_core|docs/ai/skill_routing.md'
require_contains "$bootstrap_path" 'read_if_harness_policy|docs/agent_knowledge_base.md'
require_contains "$bootstrap_path" 'read_if_review|docs/ai_code_review_protocol.md'
require_contains "$bootstrap_path" 'read_if_commands_validation|docs/agents_quick_reference.md'
require_contains "$bootstrap_path" 'read_if_owner_unknown|docs/README.md'
require_contains "$bootstrap_path" 'read_if_ui_design|DESIGN.md'
require_contains "$bootstrap_path" 'read_if_ui_design|docs/design_system.md'
require_contains "$bootstrap_path" 'read_if_validation_detail|docs/engineering/validation_routing_fast_vs_full.md'
require_contains "$bootstrap_path" 'read_if_l10n|docs/engineering/localization.md'
require_contains "$bootstrap_path" "context_ladder|3|structural graph"

core_count="$(grep -cF 'echo "read_core|' "$bootstrap_path" 2>/dev/null || true)"
if [[ "$core_count" -ne 3 ]]; then
  fail "$bootstrap_path must define exactly 3 read_core entries; found $core_count"
fi

if [[ -d "tool/agent_host_templates" ]]; then
  require_contains "tool/agent_host_templates/shared/skills/agents-quick-reference/SKILL.md" "reusable agent conclusion"
  require_contains "tool/agent_host_templates/shared/skills/agents-quick-reference/SKILL.md" "Context ladder"
  require_contains "tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md" "File verified reusable conclusions"
  require_contains "tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md" "context ladder"
  require_contains "tool/agent_host_templates/cursor/rules/agents-global.mdc" "File verified reusable conclusions"
  require_contains "tool/agent_host_templates/cursor/rules/agents-global.mdc" "context ladder"
fi

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "Agent memory-compounding checks passed."
