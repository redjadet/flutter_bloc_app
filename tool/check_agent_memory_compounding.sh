#!/usr/bin/env bash
# Validate repo-native AI-agent memory-compounding guidance stays automatic and safe.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_agent_memory_compounding.sh

Deterministic guard for AI-agent memory-compounding doctrine.

Checks:
- source doc defines Memory Compounding
- reusable conclusions route to durable repo memory, not chat-only notes
- autonomous cron/action guidance requires explicit user approval
- quick reference and host templates expose the behavior

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
require_contains "docs/agent_knowledge_base.md" "File reusable conclusions"
require_contains "docs/agent_knowledge_base.md" "Do not dump chat transcripts"
require_contains "docs/agent_knowledge_base.md" "explicit user approval"
require_contains "docs/agent_knowledge_base.md" "separate RAG layer"
require_contains "docs/agent_knowledge_base.md" "Semantic lint"
require_contains "docs/agents_quick_reference.md" "Reusable agent conclusion"
require_contains "docs/agents_quick_reference.md" "semantic lint"
require_contains "AGENTS.md" "Verified reusable agent conclusion"
require_contains "docs/validation_scripts.md" "check_agent_memory_compounding.sh"

if [[ -d "tool/agent_host_templates" ]]; then
  require_contains "tool/agent_host_templates/codex/AGENTS.md" "File verified reusable conclusions"
  require_contains "tool/agent_host_templates/codex/skills/flutter-bloc-app-quick-reference/SKILL.md" "reusable agent conclusion"
  require_contains "tool/agent_host_templates/codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md" "File verified reusable conclusions"
  require_contains "tool/agent_host_templates/cursor/rules/agents-global.mdc" "File verified reusable conclusions"
  require_contains "tool/agent_host_templates/cursor/skills/agents-quick-reference/SKILL.md" "reusable agent conclusion"
  require_contains "tool/agent_host_templates/cursor/skills/agents-delivery-workflow/SKILL.md" "File verified reusable conclusions"
fi

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "Agent memory-compounding checks passed."
