#!/usr/bin/env bash
# Unified entry for AI agent host maintenance and common agent workflows.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/agent_maintain.sh <command> [options]

One entrypoint for Cursor/Codex host upkeep and recurring agent workflows.
Underlying scripts stay the source of truth; this script only routes and
composes them.

Commands (low-level):
  session, bootstrap     Read-only session map (tool/agent_session_bootstrap.sh)
  sync                   Repo host templates -> ~/.cursor / ~/.codex
                         --apply to write; default dry-run
  setup                  Full host setup orchestrator
                         --apply [--install] [--trim-mode MODE] [--sync-only]
  install                Global vendor skills (dart/flutter/ios/ai bundles)
                         Passes through to tool/install_global_agent_skills.sh
  update                 Refresh globals (npx skills update -g)
                         --check for updates only
  find QUERY...          Search skills catalog
  tools, tool-route      Recommend repo/MCP/browser tools from intent + paths
                         Example: tools --intent "runtime crash" --paths apps/mobile/lib/app.dart
  trim                   Dedupe ~/.agents/skills vs ~/.cursor/skills
                         --apply [--mode balanced|full|flutter-repo|...]
  drift                  Host-template drift check
  kb, knowledge          Agent map / KB invariants
  harness|harness-maintain  Cursor/Codex harness scorecard + risk register gates
  memory                 agent_memory_auto_maintain.sh (--verify, --if-changed, ...)
  inventory              Regenerate skill inventory + budget report
                         --enforce to fail on budget breach
  trackers               Validate tasks/*/todo.md contract
  review                 Cross-host diff review (tool/request_codex_feedback.sh)
  codex-feedback         Alias for review

Workflow presets (compose multiple steps):
  routine                Light upkeep: sync, drift, update --check, memory --verify,
                         inventory report
                         --apply runs sync --apply (still no network install)
  preflight              Session bootstrap + drift + trackers (read-only + checks)
  host-full              setup --apply --install --trim-mode full (network)
  auto                   Scope-based closeout: preflight + host/kb + docs-sync (see host_maintenance_automation.md)
  closeout               Alias for auto (run before claiming any task done)
  docs-sync              Auto-update validation catalog + doc links (scope-based)
  after-host-edit        sync --apply + kb (after tool/agent_host_templates/** edits)

Meta:
  list                   One-line summary of all commands
  help, -h, --help       This message

Examples:
  ./bin/agent-maintain session
  ./bin/agent-maintain sync --apply
  ./bin/agent-maintain routine --apply
  ./bin/agent-maintain setup --apply --install --trim-mode full
  ./bin/agent-maintain find flutter bloc
  ./bin/agent-maintain inventory --enforce

After mutating host files: reload Cursor (Developer: Reload Window).
Canon: AGENTS.md, docs/agent_environment_setup.md, docs/agents_quick_reference.md
EOF
}

list_commands() {
  cat <<'EOF'
agent-maintain commands
  session bootstrap     Session read-only map
  sync                  Host template sync (dry-run | --apply)
  setup                 Orchestrated host setup
  install               Global vendor skills install
  update                Global skills update (--check)
  find                  Catalog search
  tools tool-route      Intent/path-based tool recommendations
  trim                  Dedupe global skills (--apply)
  drift                 Template drift check
  kb knowledge          KB / AGENTS invariants
  harness harness-maintain  Harness scorecard + risk register gates
  memory                Memory auto-maintain lane
  inventory             Skill inventory + budgets
  trackers              Task tracker contract
  review codex-feedback Cross-host review
  routine               Composed light upkeep
  preflight             Composed session preflight
  host-full             Composed full host install + trim
  auto                  Scope-based agent closeout (host + docs)
  closeout              Same as auto — run before task finish
  docs-sync             Validation-doc + markdown link auto-updates
  after-host-edit       Post template-edit sync + kb
EOF
}

collect_changed_paths() {
  if [[ -n "${AGENT_MAINTAIN_CHANGED_PATHS_FILE:-}" && -f "${AGENT_MAINTAIN_CHANGED_PATHS_FILE}" ]]; then
    sed '/^$/d' "${AGENT_MAINTAIN_CHANGED_PATHS_FILE}" | sort -u
    return 0
  fi
  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 1
  fi
  {
    git diff --name-only --diff-filter=ACMRTUXBD 2>/dev/null || true
    git diff --name-only --cached --diff-filter=ACMRTUXBD 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | sed '/^$/d' | sort -u
}

scope_has_host_template_edits() {
  local path
  while IFS= read -r path; do
    case "$path" in
      tool/agent_host_templates/*) return 0 ;;
    esac
  done < <(collect_changed_paths || true)
  return 1
}

scope_has_agent_kb_edits() {
  local path
  while IFS= read -r path; do
    case "$path" in
      AGENTS.md|\
      docs/agent_kb/*|\
      docs/agent_knowledge_base.md|\
      docs/agent_environment_setup.md|\
      docs/agent_host_notes.md|\
      docs/agents_quick_reference.md|\
      docs/validation_scripts/operations_host_skills.md|\
      tool/agent_maintain.sh|\
      tool/agent_asset_lib.sh|\
      tool/agent_session_bootstrap.sh|\
      tool/agent_tool_router.sh|\
      tool/setup_cursor_agent_environment.sh|\
      tool/sync_agent_assets.sh|\
      tool/check_agent_knowledge_base.sh|\
      bin/agent-maintain)
        return 0
        ;;
    esac
  done < <(collect_changed_paths || true)
  return 1
}

scope_has_validation_tooling_edits() {
  local path
  while IFS= read -r path; do
    case "$path" in
      tool/delivery_checklist.sh|\
      tool/validate_validation_docs.sh|\
      tool/fix_validation_docs.sh|\
      tool/agent_maintain.sh|\
      tool/agent_tool_router.sh|\
      tool/check_*.sh|\
      bin/agent-maintain|\
      bin/checklist|\
      bin/checklist-fast)
        return 0
        ;;
    esac
  done < <(collect_changed_paths || true)
  return 1
}

scope_has_markdown_docs_edits() {
  local path
  while IFS= read -r path; do
    case "$path" in
      AGENTS.md|\
      README.md|\
      SECURITY.md|\
      DESIGN.md|\
      llms.txt|\
      docs/*)
        return 0
        ;;
    esac
  done < <(collect_changed_paths || true)
  return 1
}

scope_has_harness_edits() {
  local path
  while IFS= read -r path; do
    case "$path" in
      AGENTS.md|\
      .cursor/rules/*|\
      tool/agent_host_templates/*|\
      tool/agent_host_templates/*/*|\
      tool/agent_host_templates/*/*/*|\
      tool/agent_host_templates/*/*/*/*|\
      docs/ai/*|\
      docs/architecture/feature_structure_contract.md|\
      docs/architecture/reference_features.md|\
      docs/architecture/use_case_dto_policy.md|\
      docs/bloc_standards.md|\
      docs/bloc/*|\
      docs/review/*|\
      docs/feature_implementation_guide.md|\
      docs/testing/matrix_required_by_change.md|\
      tool/check_harness_scorecard_gate.sh|\
      tool/update_harness_score_badge.sh|\
      tool/check_ai_failure_risk_register.sh|\
      tool/check_clean_architecture_imports.sh|\
      tool/check_feature_folder_contract.sh|\
      tool/scaffold_feature_contract.sh|\
      tool/agent_maintain.sh|\
      tool/agent_tool_router.sh|\
      bin/agent-maintain|\
      docs/agent_kb/host_maintenance_automation.md)
        return 0
        ;;
    esac
  done < <(collect_changed_paths || true)
  return 1
}

scope_has_engineering_edits() {
  local path
  while IFS= read -r path; do
    case "$path" in
      AGENTS.md|\
      README.md|\
      docs/engineering/engineering_quality_scorecard.md|\
      docs/ai/context_loading.md|\
      docs/ai/ai_failure_risks.md|\
      docs/agents_quick_reference.md|\
      docs/CODE_QUALITY.md|\
      tool/check_engineering_quality_scorecard_gate.sh|\
      tool/update_engineering_quality_badge.sh|\
      tool/check_engineering_core_coverage.sh|\
      tool/agent_maintain.sh)
        return 0
        ;;
    esac
  done < <(collect_changed_paths || true)
  return 1
}

scope_has_design_md_edits() {
  local path
  while IFS= read -r path; do
    [[ "$path" == "DESIGN.md" ]] && return 0
  done < <(collect_changed_paths || true)
  return 1
}

collect_changed_doc_paths() {
  local path
  while IFS= read -r path; do
    case "$path" in
      AGENTS.md|\
      README.md|\
      SECURITY.md|\
      DESIGN.md|\
      llms.txt|\
      docs/*.md|\
      docs/*/*.md|\
      docs/*/*/*.md)
        printf '%s\n' "$path"
        ;;
    esac
  done < <(collect_changed_paths || true)
}

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

log() {
  echo "agent-maintain|$*"
}

run_stage() {
  log "run|$*"
  "$@"
}

has_apply=0
declare -a REMAINING_ARGS=()

consume_apply_flags() {
  has_apply=0
  REMAINING_ARGS=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --apply)
        has_apply=1
        shift
        ;;
      *)
        REMAINING_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

cmd_session() {
  run_stage bash "$PROJECT_ROOT/tool/agent_session_bootstrap.sh" "$@"
}

cmd_sync() {
  local -a args=()
  if (( has_apply )); then
    args+=(--apply)
  else
    args+=(--dry-run)
  fi
  run_stage bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" "${args[@]}"
  if (( has_apply )); then
    run_drift_check 1
  else
    run_drift_check 0
  fi
}

cmd_setup() {
  local -a args=()
  if (( has_apply )); then
    args+=(--apply)
  fi
  run_stage bash "$PROJECT_ROOT/tool/setup_cursor_agent_environment.sh" "${args[@]}" "$@"
}

cmd_install() {
  run_stage bash "$PROJECT_ROOT/tool/install_global_agent_skills.sh" "$@"
}

cmd_update() {
  run_stage bash "$PROJECT_ROOT/tool/update_global_agent_skills.sh" "$@"
}

cmd_find() {
  if (($# == 0)); then
    echo "agent-maintain|error|find requires a query" >&2
    exit 2
  fi
  run_stage bash "$PROJECT_ROOT/tool/find_global_agent_skills.sh" "$@"
}

cmd_tools() {
  run_stage bash "$PROJECT_ROOT/tool/agent_tool_router.sh" "$@"
}

cmd_trim() {
  local -a args=()
  if (( has_apply )); then
    args+=(--apply)
  fi
  run_stage bash "$PROJECT_ROOT/tool/trim_duplicate_agent_skills.sh" "${args[@]}" "$@"
}

cmd_drift() {
  run_stage bash "$PROJECT_ROOT/tool/check_agent_asset_drift.sh"
}

cmd_kb() {
  run_stage bash "$PROJECT_ROOT/tool/check_agent_knowledge_base.sh"
}

cmd_harness_maintain() {
  log "workflow|harness-maintain"
  if [[ "${AGENT_MAINTAIN_PLAN_ONLY:-}" == "1" ]]; then
    log "plan|harness-badge|bash tool/update_harness_score_badge.sh"
    log "plan|harness-maintain|bash tool/check_harness_scorecard_gate.sh"
    log "plan|harness-scorecard-gate|includes check_ai_failure_risk_register.sh"
    return 0
  fi
  run_stage bash "$PROJECT_ROOT/tool/update_harness_score_badge.sh"
  run_stage bash "$PROJECT_ROOT/tool/check_harness_scorecard_gate.sh"
}

cmd_harness() {
  cmd_harness_maintain "$@"
}

cmd_engineering_maintain() {
  log "workflow|engineering-maintain"
  if [[ "${AGENT_MAINTAIN_PLAN_ONLY:-}" == "1" ]]; then
    log "plan|engineering-badge|bash tool/update_engineering_quality_badge.sh"
    log "plan|engineering-maintain|bash tool/check_engineering_quality_scorecard_gate.sh"
    return 0
  fi
  run_stage bash "$PROJECT_ROOT/tool/update_engineering_quality_badge.sh"
  run_stage bash "$PROJECT_ROOT/tool/check_engineering_quality_scorecard_gate.sh"
}

cmd_memory() {
  run_stage bash "$PROJECT_ROOT/tool/agent_memory_auto_maintain.sh" "$@"
}

cmd_inventory() {
  local enforce=0
  local -a extra=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --enforce)
        enforce=1
        shift
        ;;
      *)
        extra+=("$1")
        shift
        ;;
    esac
  done

  local inventory_path="$PROJECT_ROOT/docs/audits/skill_inventory_latest.json"
  run_stage dart run "$PROJECT_ROOT/tool/skill_inventory.dart" "$inventory_path" "${extra[@]}"
  if (( enforce )); then
    run_stage bash "$PROJECT_ROOT/tool/check_skill_budgets.sh" "$inventory_path" enforce
  else
    run_stage bash "$PROJECT_ROOT/tool/check_skill_budgets.sh" "$inventory_path" report || true
  fi
}

cmd_trackers() {
  run_stage bash "$PROJECT_ROOT/tool/validate_task_trackers.sh" "$@"
}

cmd_review() {
  run_stage bash "$PROJECT_ROOT/tool/request_codex_feedback.sh" "$@"
}

cmd_routine() {
  log "workflow|routine|apply=$has_apply"
  if (( has_apply )); then
    run_stage bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --apply
    run_drift_check 1
  else
    run_stage bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --dry-run
    run_drift_check 0
  fi
  run_stage bash "$PROJECT_ROOT/tool/update_global_agent_skills.sh" --check || true
  run_stage bash "$PROJECT_ROOT/tool/agent_memory_auto_maintain.sh" --verify
  local inventory_path="$PROJECT_ROOT/docs/audits/skill_inventory_latest.json"
  if [[ -f "$inventory_path" ]]; then
    run_stage bash "$PROJECT_ROOT/tool/check_skill_budgets.sh" "$inventory_path" report || true
  else
    log "skip|inventory|no $inventory_path (run: agent-maintain inventory)"
  fi
  if (( has_apply )); then
    log "hint|reload Cursor (Developer: Reload Window)"
  fi
}

run_drift_check() {
  local strict="${1:-0}"
  if bash "$PROJECT_ROOT/tool/check_agent_asset_drift.sh"; then
    return 0
  fi
  log "warn|drift|managed host assets differ from repo templates"
  log "hint|./bin/agent-maintain sync --apply"
  if (( strict )); then
    return 1
  fi
  return 0
}

cmd_preflight() {
  log "workflow|preflight"
  run_stage bash "$PROJECT_ROOT/tool/agent_session_bootstrap.sh" "$@"
  run_drift_check 0
  run_stage bash "$PROJECT_ROOT/tool/validate_task_trackers.sh"
  if scope_has_harness_edits; then
    log "scope|harness|yes"
    log "hint|harness-maintain|./bin/agent-maintain harness-maintain before max-score claim; closeout runs when scoped"
  else
    log "scope|harness|no"
  fi
}

cmd_host_full() {
  if (( ! has_apply )); then
    log "plan|host-full|bash tool/setup_cursor_agent_environment.sh --apply --install --trim-mode full"
    log "hint|pass --apply to run (network + host mutation)"
    exit 0
  fi
  log "workflow|host-full"
  run_stage bash "$PROJECT_ROOT/tool/setup_cursor_agent_environment.sh" \
    --apply --install --trim-mode full "$@"
}

cmd_docs_sync() {
  log "workflow|docs-sync"
  log "policy|docs/agent_kb/host_maintenance_automation.md#doc-closeout"

  local validation_tooling=0
  local markdown_docs=0
  local design_md=0

  if scope_has_validation_tooling_edits; then
    validation_tooling=1
    log "scope|validation_tooling|yes"
    log "auto_action|fix-validation-docs|bash tool/fix_validation_docs.sh"
    log "auto_action|validate-validation-docs|bash tool/validate_validation_docs.sh"
  else
    log "scope|validation_tooling|no"
  fi
  if scope_has_markdown_docs_edits; then
    markdown_docs=1
    log "scope|markdown_docs|yes"
    log "auto_action|fix-doc-links|bash tool/agent_memory_auto_maintain.sh --fix-links"
  else
    log "scope|markdown_docs|no"
  fi
  if scope_has_design_md_edits; then
    design_md=1
    log "scope|design_md|yes"
    log "auto_action|check-design-md|bash tool/check_design_md.sh"
  else
    log "scope|design_md|no"
  fi

  if (( ! validation_tooling && ! markdown_docs && ! design_md )); then
    log "skip|docs-sync|no doc-relevant paths in scope"
    return 0
  fi

  if [[ "${AGENT_MAINTAIN_PLAN_ONLY:-}" == "1" ]]; then
    log "plan|docs-sync|fix-validation-docs + fix-links + gardening + harness gate"
    return 0
  fi

  if (( validation_tooling )); then
    run_stage bash "$PROJECT_ROOT/tool/fix_validation_docs.sh"
    run_stage bash "$PROJECT_ROOT/tool/validate_validation_docs.sh"
  fi

  if (( markdown_docs )); then
    run_stage bash "$PROJECT_ROOT/tool/agent_memory_auto_maintain.sh" --fix-links
  fi

  if (( design_md )); then
    run_stage bash "$PROJECT_ROOT/tool/check_design_md.sh" || \
      log "warn|design-md|check_design_md.sh failed (npx/network?)"
  fi

  if (( validation_tooling || markdown_docs )); then
    local -a doc_paths=()
    local path
    while IFS= read -r path; do
      [[ -n "$path" ]] && doc_paths+=("$path")
    done < <(collect_changed_doc_paths || true)
    if (( ${#doc_paths[@]} > 0 )); then
      run_stage bash "$PROJECT_ROOT/tool/check_docs_gardening.sh" --paths "${doc_paths[@]}"
    else
      run_stage bash "$PROJECT_ROOT/tool/check_docs_gardening.sh"
    fi
    run_stage bash "$PROJECT_ROOT/tool/check_harness_scorecard_gate.sh"
  fi
}

cmd_auto() {
  log "workflow|auto|apply=$has_apply"
  log "policy|docs/agent_kb/host_maintenance_automation.md"

  local host_templates=0
  local agent_kb=0
  if scope_has_host_template_edits; then
    host_templates=1
    log "scope|host_templates|yes"
    log "auto_action|after-host-edit|./bin/agent-maintain after-host-edit"
  else
    log "scope|host_templates|no"
  fi
  if scope_has_agent_kb_edits; then
    agent_kb=1
    log "scope|agent_kb|yes"
    if (( ! host_templates )); then
      log "auto_action|kb|./bin/agent-maintain kb"
    fi
  else
    log "scope|agent_kb|no"
  fi
  if scope_has_harness_edits; then
    log "scope|harness|yes"
    log "auto_action|harness-maintain|./bin/agent-maintain harness-maintain"
  else
    log "scope|harness|no"
  fi
  if scope_has_engineering_edits; then
    log "scope|engineering|yes"
    log "auto_action|engineering-maintain|./bin/agent-maintain engineering-maintain"
  else
    log "scope|engineering|no"
  fi
  log "auto_action|preflight|./bin/agent-maintain preflight"
  log "auto_action|docs-sync|./bin/agent-maintain docs-sync"

  cmd_preflight
  cmd_docs_sync

  if (( host_templates )); then
    cmd_after_host_edit
  elif (( agent_kb )); then
    cmd_kb
  fi

  if scope_has_harness_edits; then
    cmd_harness_maintain
  fi
  if scope_has_engineering_edits; then
    cmd_engineering_maintain
  fi
}

cmd_closeout() {
  log "workflow|closeout|agents run before claiming task done"
  cmd_auto "$@"
}

cmd_after_host_edit() {
  log "workflow|after-host-edit|apply=1"
  if [[ "${AGENT_MAINTAIN_PLAN_ONLY:-}" == "1" ]]; then
    log "plan|after-host-edit|sync --apply + strict drift + kb"
    return 0
  fi
  has_apply=1
  run_stage bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --apply
  run_drift_check 1
  cmd_kb
  log "hint|reload Cursor (Developer: Reload Window)"
}

command="${1:-help}"
if [[ "$command" == "-h" || "$command" == "--help" || "$command" == help ]]; then
  usage
  exit 0
fi

if [[ "$command" != list ]]; then
  shift || true
  consume_apply_flags "$@"
  set -- "${REMAINING_ARGS[@]}"
fi

case "$command" in
  list)
    list_commands
    ;;
  session | bootstrap)
    cmd_session "$@"
    ;;
  sync)
    cmd_sync "$@"
    ;;
  setup)
    cmd_setup "$@"
    ;;
  install)
    cmd_install "$@"
    ;;
  update)
    cmd_update "$@"
    ;;
  find)
    cmd_find "$@"
    ;;
  tools | tool-route)
    cmd_tools "$@"
    ;;
  trim)
    cmd_trim "$@"
    ;;
  drift)
    cmd_drift "$@"
    ;;
  kb | knowledge)
    cmd_kb "$@"
    ;;
  harness | harness-maintain)
    cmd_harness_maintain "$@"
    ;;
  engineering | engineering-maintain)
    cmd_engineering_maintain "$@"
    ;;
  memory)
    cmd_memory "$@"
    ;;
  inventory)
    cmd_inventory "$@"
    ;;
  trackers)
    cmd_trackers "$@"
    ;;
  review | codex-feedback)
    cmd_review "$@"
    ;;
  routine)
    cmd_routine "$@"
    ;;
  preflight)
    cmd_preflight "$@"
    ;;
  host-full)
    cmd_host_full "$@"
    ;;
  auto)
    cmd_auto "$@"
    ;;
  closeout)
    cmd_closeout "$@"
    ;;
  docs-sync)
    cmd_docs_sync "$@"
    ;;
  after-host-edit)
    cmd_after_host_edit "$@"
    ;;
  *)
    echo "agent-maintain|error|unknown command: $command" >&2
    usage >&2
    exit 2
    ;;
esac

log "done|$command"
