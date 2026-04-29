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

require_not_contains() {
  local path="$1"
  local needle="$2"
  if [ ! -f "$path" ]; then
    fail "Cannot scan missing file: $path"
    return
  fi
  if grep -qF "$needle" "$path"; then
    fail "$path must not contain host-specific detail ($needle); keep it map-only and pointer-led"
  fi
}

require_all_contains() {
  local path="$1"
  shift

  require_file "$path"
  for needle in "$@"; do
    require_contains "$path" "$needle"
  done
}

required_files=(
  "docs/agent_knowledge_base.md"
  "docs/ai_code_review_protocol.md"
  "docs/agents_quick_reference.md"
  "docs/agent_host_notes.md"
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
  require_contains "AGENTS.md" "docs/agent_host_notes.md"

  # Guard map-only invariant: host-specific guidance lives in docs/agent_host_notes.md.
  require_not_contains "AGENTS.md" "## Codex"
  require_not_contains "AGENTS.md" "## Cursor"
  require_not_contains "AGENTS.md" "## Delegation"
else
  echo "AGENTS.md not present; skipping local injected-map size/link checks."
fi

require_contains "docs/agent_knowledge_base.md" "Progressive Disclosure"
require_contains "docs/agent_knowledge_base.md" "Adaptive Execution"
require_contains "docs/agent_knowledge_base.md" "Agent Legibility"
require_contains "docs/agent_knowledge_base.md" "Missing Capability Loop"
require_contains "docs/agent_knowledge_base.md" "Memory Compounding"
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
require_contains "docs/agent_knowledge_base.md" "reusable conclusions"
require_contains "docs/agent_knowledge_base.md" "Semantic lint"
require_contains "docs/README.md" "agent_knowledge_base.md"
require_contains "docs/validation_scripts.md" "check_agent_knowledge_base.sh"
require_contains "docs/validation_scripts.md" "memory-compounding"
require_contains "docs/validation_scripts.md" "closed-loop invariants"

require_all_contains \
  "AGENTS.md" \
  "95% confident" \
  "Surgical diff" \
  "changed line" \
  "Report proof"

require_all_contains \
  "docs/agent_knowledge_base.md" \
  "95% confident" \
  "Surgical diffs" \
  "Before report" \
  "Report after checking"

require_all_contains \
  "docs/ai_code_review_protocol.md" \
  "Before report" \
  "Scope discipline" \
  "Self-verification" \
  "Self-verify"

require_all_contains \
  "docs/agents_quick_reference.md" \
  "below 95%" \
  "execute end-to-end, verify, report proof" \
  "Behavior changes start in source docs"

if ! bash "tool/check_agent_memory_compounding.sh"; then
  fail "Agent memory-compounding guard failed"
fi

if [ -d "tool/agent_host_templates" ]; then
  require_all_contains \
    "tool/agent_host_templates/codex/AGENTS.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "docs/agents_quick_reference.md" \
    "docs/README.md" \
    "tasks/codex/todo.md"
  require_all_contains \
    "tool/agent_host_templates/codex/AGENTS.md" \
    "95% confident" \
    "Surgical diff" \
    "Self-check final response" \
    "Prove result"

  require_all_contains \
    "tool/agent_host_templates/codex/skills/flutter-bloc-app-quick-reference/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/agents_quick_reference.md" \
    "docs/ai_code_review_protocol.md" \
    "tool/check_agent_knowledge_base.sh" \
    "tool/check_agent_asset_drift.sh" \
    "tool/sync_agent_assets.sh --dry-run"

  require_all_contains \
    "tool/agent_host_templates/codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "tasks/codex/todo.md" \
    "tool/check_agent_knowledge_base.sh"
  require_all_contains \
    "tool/agent_host_templates/codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md" \
    "95% confident" \
    "Surgical diff" \
    "Self-verify final response" \
    "Report only after Verify"

  require_all_contains \
    "tool/agent_host_templates/cursor/rules/agents-global.mdc" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "docs/agents_quick_reference.md" \
    "tool/check_agent_knowledge_base.sh"
  require_all_contains \
    "tool/agent_host_templates/cursor/rules/agents-global.mdc" \
    "95% confident" \
    "Surgical diff" \
    "Self-verify before report"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-quick-reference/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/agents_quick_reference.md" \
    "docs/ai_code_review_protocol.md" \
    "tool/check_agent_knowledge_base.sh" \
    "tool/check_agent_asset_drift.sh" \
    "tool/sync_agent_assets.sh --dry-run"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-delivery-workflow/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/agents_quick_reference.md" \
    "docs/ai_code_review_protocol.md" \
    "tasks/cursor/todo.md" \
    "tool/check_agent_knowledge_base.sh"
  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-delivery-workflow/SKILL.md" \
    "95% confident" \
    "Surgical diff" \
    "Self-verify final response" \
    "Report only after Verify"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-meta-behavior/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "tasks/lessons.md"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-cursor-integration/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/agents_quick_reference.md" \
    "docs/ai_code_review_protocol.md" \
    "tool/sync_agent_assets.sh"
else
  echo "Host-template source checks skipped (tool/agent_host_templates not present)."
fi

if [ "$failures" -ne 0 ]; then
  exit 1
fi

echo "Agent knowledge base checks passed."
