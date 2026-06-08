#!/usr/bin/env bash
# Validate the AI-agent knowledge base map and required source-of-truth links.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if [[ -z "${CI:-}" && "${AGENT_MEMORY_AUTO_MAINTAIN:-1}" != "0" ]]; then
  bash "$PROJECT_ROOT/tool/agent_memory_auto_maintain.sh" --if-changed
fi

MAX_AGENTS_LINES="${MAX_AGENTS_LINES:-120}"
MAX_AGENT_DOC_LINES="${MAX_AGENT_DOC_LINES:-200}"

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

require_line_budget() {
  local path="$1"
  local max_lines="${2:-$MAX_AGENT_DOC_LINES}"
  if [ ! -f "$path" ]; then
    fail "Cannot check missing line-budget file: $path"
    return
  fi

  local lines
  lines="$(wc -l <"$path" | tr -d '[:space:]')"
  if [ "$lines" -gt "$max_lines" ]; then
    fail "$path has $lines lines; keep frequently used agent docs at or below $max_lines lines"
  fi
}

# Gitignored local per-host trackers; enforce budget only when present (CI/fresh clones skip).
require_line_budget_if_present() {
  local path="$1"
  local max_lines="${2:-$MAX_AGENT_DOC_LINES}"
  if [ ! -f "$path" ]; then
    return 0
  fi

  local lines
  lines="$(wc -l <"$path" | tr -d '[:space:]')"
  if [ "$lines" -gt "$max_lines" ]; then
    fail "$path has $lines lines; keep frequently used agent docs at or below $max_lines lines"
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

require_absent() {
  local path="$1"
  if [ -e "$path" ]; then
    fail "$path must not exist; use shared host-neutral source instead"
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
  "bin/agent-maintain"
  "tool/agent_maintain.sh"
  "docs/agent_kb/host_maintenance_automation.md"
  "docs/agent_knowledge_base.md"
  "docs/agent_kb/self_improvement.md"
  "docs/ai_code_review_protocol.md"
  "docs/agents_quick_reference.md"
  "docs/agent_host_notes.md"
  "docs/README.md"
  "docs/design_system.md"
  "docs/architecture_details.md"
  "docs/CODE_QUALITY.md"
  "docs/engineering/validation_routing_fast_vs_full.md"
  "docs/ai/skill_routing.md"
  "docs/plans/README.md"
  "docs/changes/README.md"
  "docs/audits/README.md"
)

for path in "${required_files[@]}"; do
  require_file "$path"
done

line_budget_files=(
  "AGENTS.md"
  "docs/agent_knowledge_base.md"
  "docs/agent_kb/self_improvement.md"
  "docs/ai/context_loading.md"
  "docs/ai/skill_routing.md"
  "docs/ai_code_review_protocol.md"
  "docs/agents_quick_reference.md"
  "docs/agent_project_context.md"
  "docs/agent_environment_setup.md"
  "docs/validation_scripts.md"
  "docs/validation_scripts/operations_host_skills.md"
)

for path in "${line_budget_files[@]}"; do
  require_line_budget "$path"
done

local_line_budget_files=(
  "tasks/codex/todo.md"
  "tasks/cursor/todo.md"
)

for path in "${local_line_budget_files[@]}"; do
  require_line_budget_if_present "$path"
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
  require_contains "AGENTS.md" "DESIGN.md"
  require_contains "AGENTS.md" "docs/design_system.md"
  require_contains "AGENTS.md" "docs/agent_host_notes.md"
  require_contains "AGENTS.md" "host_maintenance_automation.md"
  require_contains "AGENTS.md" "agent-maintain preflight"
  require_contains "AGENTS.md" "agent-maintain closeout"
  require_contains "docs/agent_kb/tool_orchestration.md" "host_maintenance_automation.md"

  # Guard map-only invariant: host-specific guidance lives in docs/agent_host_notes.md.
  require_not_contains "AGENTS.md" "## Codex"
  require_not_contains "AGENTS.md" "## Cursor"
  require_not_contains "AGENTS.md" "## Delegation"
  require_not_contains "AGENTS.md" "## Learned User Preferences"
  require_not_contains "AGENTS.md" "## Learned Workspace Facts"
  require_contains "AGENTS.md" "operator_preferences_durable.md"
  require_contains "AGENTS.md" "docs/ai/skill_routing.md"
else
  echo "AGENTS.md not present; skipping local injected-map size/link checks."
fi

require_contains "docs/agent_knowledge_base.md" "Progressive Disclosure"
require_contains "docs/agent_knowledge_base.md" "Self-Improvement"
require_contains "docs/agent_knowledge_base.md" "Adaptive Execution"
require_contains "docs/agent_knowledge_base.md" "Agent Legibility"
require_contains "docs/agent_knowledge_base.md" "Missing Capability Loop"
require_contains "docs/agent_knowledge_base.md" "Memory Compounding"
require_contains "docs/agent_knowledge_base.md" "System Of Record Layout"
require_contains "docs/agent_knowledge_base.md" "DESIGN.md"
require_contains "docs/agent_knowledge_base.md" "design_system.md"
require_contains "docs/agent_knowledge_base.md" "Plans As Artifacts"
require_contains "docs/agent_knowledge_base.md" "Invariant Enforcement"
require_contains "docs/agent_knowledge_base.md" "Codex And Cursor"
require_contains "docs/agent_knowledge_base.md" "Final Agent Contract"
require_contains "docs/agent_knowledge_base.md" "Host Parity"
require_contains "docs/agent_knowledge_base.md" "Mechanical Enforcement"
require_contains "docs/agent_knowledge_base.md" "tasks/codex/todo.md"
require_contains "docs/agent_knowledge_base.md" "tasks/cursor/todo.md"
require_contains "docs/agent_knowledge_base.md" "tasks/lessons.md"
if git check-ignore -q tasks/lessons.md 2>/dev/null; then
  fail "tasks/lessons.md must be tracked in git (not gitignored)"
fi
require_file "tasks/lessons.md"
require_contains "docs/agent_knowledge_base.md" "reusable conclusions"
require_contains "docs/agent_knowledge_base.md" "Semantic lint"
require_all_contains \
  "docs/agent_kb/self_improvement.md" \
  "no verifier, no persistence" \
  "Reflection" \
  "Memory" \
  "Scaffold evolution" \
  "model fine-tuning" \
  "Expected benefit" \
  "version history"
require_contains "docs/README.md" "agent_knowledge_base.md"
require_contains "docs/README.md" "DESIGN.md"
require_contains "docs/README.md" "design_system.md"
validation_docs=(
  "docs/validation_scripts.md"
)
while IFS= read -r shard; do
  validation_docs+=("$shard")
done < <(find docs/validation_scripts -maxdepth 1 -name '*.md' -print 2>/dev/null | sort)

require_validation_docs_contains() {
  local needle="$1"
  for path in "${validation_docs[@]}"; do
    if [ -f "$path" ] && grep -qF "$needle" "$path"; then
      return 0
    fi
  done
  fail "validation_scripts router or shards must reference: $needle"
}

require_validation_docs_contains "check_agent_knowledge_base.sh"
require_validation_docs_contains "check_design_md.sh"
require_validation_docs_contains "memory-compounding"
require_validation_docs_contains "closed-loop invariants"

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
  "Report after checking" \
  "## Multi-Agent Hub" \
  "Benefit: team" \
  "Benefit: single" \
  "tasks/cursor/team/<run-id>/" \
  "Coordinator" \
  "Specialists" \
  "Researcher" \
  "Analyst" \
  "Implementer" \
  "Reviewer" \
  "untrusted"

require_all_contains \
  "docs/ai_code_review_protocol.md" \
  "Before report" \
  "DESIGN.md" \
  "design_system.md" \
  "Scope discipline" \
  "Self-verification" \
  "Self-verify"

require_all_contains \
  "docs/agents_quick_reference.md" \
  "DESIGN.md" \
  "design_system.md" \
  "below 95%" \
  "execute end-to-end, verify, report proof" \
  "Behavior changes start in source docs" \
  "Multi-Agent Hub" \
  "Benefit: team" \
  "Benefit: single" \
  "tasks/cursor/team/<run-id>/" \
  "agent_knowledge_base.md#multi-agent-hub"

if ! bash "tool/check_agent_memory_compounding.sh"; then
  fail "Agent memory-compounding guard failed"
fi

if ! bash "tool/check_continual_learning_index.sh"; then
  fail "Continual-learning index guard failed"
fi

if [ -d "tool/agent_host_templates" ]; then
  require_all_contains \
    "AGENTS.md" \
    "AGENTS.md" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "docs/agents_quick_reference.md" \
    "docs/README.md" \
    "tasks/codex/todo.md"
  require_all_contains \
    "AGENTS.md" \
    "95% confident" \
    "Surgical diff" \
    "Report proof"

  require_absent "tool/agent_host_templates/codex/skills/flutter-bloc-app-quick-reference/SKILL.md"
  require_absent "tool/agent_host_templates/codex/skills/flutter-bloc-app-delivery-workflow/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-quick-reference/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-delivery-workflow/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-repo-context/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-principles-baseline/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-references/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-canonical-rules/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-canonical-rules-architecture/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-canonical-rules-presentation/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-canonical-rules-async/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-canonical-rules-platform/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-validation-testing/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-common-pitfalls/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-modularity/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-shared-patterns/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-figma/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/figma-this-repo/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/agents-supabase/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/brainstorming/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/caveman-compress/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/systematic-debugging/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/test-driven-development/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/verification-before-completion/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/writing-plans/SKILL.md"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-quick-reference/SKILL.md" \
    "AGENTS.md" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "docs/agent_knowledge_base.md" \
    "docs/agents_quick_reference.md" \
    "docs/ai_code_review_protocol.md" \
    "tool/check_agent_knowledge_base.sh" \
    "tool/check_design_md.sh" \
    "tool/run_mix_lint.sh" \
    "tool/check_agent_asset_drift.sh" \
    "tool/sync_agent_assets.sh --dry-run" \
    "flutter-cross-platform-modern"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md" \
    "AGENTS.md" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "tasks/codex/todo.md" \
    "tasks/cursor/todo.md" \
    "tool/check_agent_knowledge_base.sh"
  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md" \
    "agent-maintain preflight" \
    "agent-maintain closeout" \
    "host_maintenance_automation.md" \
    "95% confident" \
    "Surgical diff" \
    "Self-verify final response" \
    "Report only after Verify"

  require_absent "tool/agent_host_templates/codex/skills/flutter-cross-platform-modern/SKILL.md"
  require_absent "tool/agent_host_templates/cursor/skills/flutter-cross-platform-modern/SKILL.md"
  require_all_contains \
    "tool/agent_host_templates/shared/skills/flutter-cross-platform-modern/SKILL.md" \
    "AGENTS.md" \
    "docs/ai/context_loading.md" \
    "docs/agent_project_context.md" \
    "docs/agents_quick_reference.md" \
    "docs/engineering/validation_routing_fast_vs_full.md" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "docs/testing/widget_test_playbook.md" \
    "PlatformAdaptive" \
    "dart:io" \
    "./bin/router_feature_validate" \
    "./bin/integration_preflight" \
    "./bin/checklist"

  require_all_contains \
    "tool/agent_host_templates/cursor/rules/agents-global.mdc" \
    "AGENTS.md" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "docs/agents_quick_reference.md" \
    "tool/check_agent_knowledge_base.sh"
  require_all_contains \
    "tool/agent_host_templates/cursor/rules/design-system.mdc" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "AppStyles" \
    "tool/check_design_md.sh" \
    "tool/run_mix_lint.sh"
  require_all_contains \
    "tool/agent_host_templates/cursor/rules/agents-global.mdc" \
    "95% confident" \
    "Surgical diff" \
    "Self-verify before report"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md" \
    "Multi-agent" \
    "Benefit: team" \
    "Benefit: single" \
    "tasks/cursor/team/<run-id>/" \
    "agent_knowledge_base.md#multi-agent-hub"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-repo-context/SKILL.md" \
    "AGENTS.md" \
    "CODEMAP.md" \
    "docs/agents_quick_reference.md"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-validation-testing/SKILL.md" \
    "docs/agents_quick_reference.md" \
    "docs/engineering/validation_routing_fast_vs_full.md" \
    "docs/validation_scripts.md" \
    "docs/testing_overview.md"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-canonical-rules/SKILL.md" \
    "agents-principles-baseline" \
    "agents-common-pitfalls" \
    "agents-canonical-rules-architecture"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-principles-baseline/SKILL.md" \
    "docs/clean_architecture.md" \
    "docs/solid_principles.md" \
    "docs/dry_principles.md" \
    "docs/CODE_QUALITY.md"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-figma/SKILL.md" \
    "DESIGN.md" \
    "docs/design_system.md" \
    "figma-sync" \
    "get_design_context"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-supabase/SKILL.md" \
    "supabase/migrations/*.sql" \
    "docs/offline_first/supabase_migrations.md" \
    "supabase/README.md"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/systematic-debugging/SKILL.md" \
    "root cause" \
    "changes doc"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/writing-plans/SKILL.md" \
    "tasks/cursor/todo.md" \
    "tasks/codex/todo.md" \
    "docs/ai/context_loading.md"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-meta-behavior/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/ai_code_review_protocol.md" \
    "tasks/lessons.md"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-meta-behavior/SKILL.md" \
    "Task roles (multi-agent hub)" \
    "Researcher" \
    "Analyst" \
    "Implementer" \
    "Reviewer" \
    "subagent_type: explore" \
    "subagent_type: generalPurpose" \
    "subagent_type: code-reviewer" \
    "Redact" \
    "untrusted"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-cursor-integration/SKILL.md" \
    "AGENTS.md" \
    "docs/agent_knowledge_base.md" \
    "docs/agents_quick_reference.md" \
    "docs/ai_code_review_protocol.md" \
    "tool/sync_agent_assets.sh"

  require_all_contains \
    "tool/agent_host_templates/cursor/skills/agents-cursor-integration/SKILL.md" \
    "tasks/cursor/team/<run-id>/" \
    "agent_knowledge_base.md#multi-agent-hub"

  require_contains "tool/agent_asset_lib.sh" "agents-skill-routing/SKILL.md"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-skill-routing/SKILL.md" \
    "docs/ai/skill_routing.md" \
    "agents-quick-reference" \
    "agents-delivery-workflow" \
    "agents-canonical-rules" \
    "./bin/agent-maintain find"

  require_all_contains \
    "docs/ai/context_loading.md" \
    "skill_routing.md" \
    "agents-skill-routing"

  require_all_contains \
    "docs/agents_quick_reference.md" \
    "ai/skill_routing.md" \
    "agents-skill-routing"

  require_all_contains \
    "tool/agent_host_templates/shared/skills/agents-quick-reference/SKILL.md" \
    "skill_routing.md" \
    "agents-skill-routing" \
    "multi-agent hub" \
    "tasks/cursor/team/<run-id>/" \
    "agent_knowledge_base.md#multi-agent-hub" \
    "flutter-cross-platform-modern"

else
  echo "Host-template source checks skipped (tool/agent_host_templates not present)."
fi

if [ "$failures" -ne 0 ]; then
  exit 1
fi

echo "Agent knowledge base checks passed."
