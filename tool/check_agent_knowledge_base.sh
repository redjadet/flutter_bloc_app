#!/usr/bin/env bash
# Validate the AI-agent knowledge base map and required source-of-truth links.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

MAX_AGENTS_LINES="${MAX_AGENTS_LINES:-120}"

failures=0

fail() {
  echo "❌ $*" >&2
  failures=1
}

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    fail "Missing required agent knowledge file: $path"
  fi
}

require_contains() {
  local path="$1"
  local needle="$2"
  if [ ! -f "$path" ]; then
    fail "Cannot scan missing file: $path"
    return
  fi
  if ! grep -qF "$needle" "$path"; then
    fail "$path must reference: $needle"
  fi
}

required_files=(
  "docs/agent_knowledge_base.md"
  "docs/ai_code_review_protocol.md"
  "docs/agents_quick_reference.md"
  "docs/README.md"
  "docs/architecture_details.md"
  "docs/CODE_QUALITY.md"
  "docs/engineering/validation_routing_fast_vs_full.md"
  "docs/plans/README.md"
  "docs/changes/README.md"
  "docs/audits/README.md"
)

for path in "${required_files[@]}"; do
  require_file "$path"
done

if [ -f "AGENTS.md" ]; then
  agents_lines="$(wc -l <"AGENTS.md" | tr -d '[:space:]')"
  if [ "$agents_lines" -gt "$MAX_AGENTS_LINES" ]; then
    fail "AGENTS.md has $agents_lines lines; keep it at or below $MAX_AGENTS_LINES as a map, not a manual"
  fi
  require_contains "AGENTS.md" "docs/agent_knowledge_base.md"
  require_contains "AGENTS.md" "docs/ai_code_review_protocol.md"
  require_contains "AGENTS.md" "docs/agents_quick_reference.md"
  require_contains "AGENTS.md" "docs/README.md"
else
  echo "AGENTS.md not present; skipping local injected-map size/link checks."
fi

require_contains "docs/agent_knowledge_base.md" "Progressive Disclosure"
require_contains "docs/agent_knowledge_base.md" "Agent Legibility"
require_contains "docs/agent_knowledge_base.md" "Missing Capability Loop"
require_contains "docs/agent_knowledge_base.md" "System Of Record Layout"
require_contains "docs/agent_knowledge_base.md" "Plans As Artifacts"
require_contains "docs/agent_knowledge_base.md" "Invariant Enforcement"
require_contains "docs/agent_knowledge_base.md" "Codex And Cursor"
require_contains "docs/agent_knowledge_base.md" "Final Agent Contract"
require_contains "docs/agent_knowledge_base.md" "Host Parity"
require_contains "docs/agent_knowledge_base.md" "Mechanical Enforcement"
require_contains "docs/agent_knowledge_base.md" "tasks/codex/todo.md"
require_contains "docs/agent_knowledge_base.md" "tasks/cursor/todo.md"
require_contains "docs/agent_knowledge_base.md" "tasks/lessons.md"
require_contains "docs/README.md" "agent_knowledge_base.md"
require_contains "docs/validation_scripts.md" "check_agent_knowledge_base.sh"

if [ "$failures" -ne 0 ]; then
  exit 1
fi

echo "Agent knowledge base checks passed."
