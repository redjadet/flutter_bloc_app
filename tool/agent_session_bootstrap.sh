#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/agent_session_bootstrap.sh [--intent <text>] [--base <git-ref>] [--paths <file>...]

Read-only bootstrap for AI agent sessions.

Prints:
- repo location and (when available) git context
- canonical docs to read next (AGENTS.md + docs index)
- validation routing pointers (fast/full + router/integration)
- scope detection summary (explicit paths > git diff > unknown-scope fallback)
- deterministic tool recommendations from intent + scope

Never mutates the working tree.
EOF
}

base_ref=""
intent=""
declare -a explicit_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --intent)
      intent="${2:-}"
      if [[ -z "$intent" ]]; then
        echo "usage-error|--intent requires text" >&2
        exit 2
      fi
      shift 2
      ;;
    --base)
      base_ref="${2:-}"
      if [[ -z "$base_ref" ]]; then
        echo "usage-error|--base requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        explicit_paths+=("$1")
        shift
      done
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

# shellcheck disable=SC1091
source "$repo_root/tool/resolve_flutter_dart.sh"

echo "bootstrap|repo_root|$repo_root"

has_git=0
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  has_git=1
fi

if [[ "$has_git" -eq 1 ]]; then
  head_ref="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  head_sha="$(git rev-parse --short HEAD 2>/dev/null || true)"
  if [[ -n "$head_ref" && "$head_ref" != "HEAD" ]]; then
    echo "bootstrap|git_branch|$head_ref"
  else
    echo "bootstrap|git_branch|detached"
  fi
  if [[ -n "$head_sha" ]]; then
    echo "bootstrap|git_head|$head_sha"
  fi
else
  echo "bootstrap|git_context|unavailable"
fi

echo ""
echo "read_core|AGENTS.md"
echo "read_core|docs/ai/context_loading.md"
echo "read_core|docs/ai/skill_routing.md"
echo "read_if_harness_policy|docs/agent_knowledge_base.md"
echo "read_if_review|docs/ai_code_review_protocol.md"
echo "read_if_commands_validation|docs/agents_quick_reference.md"
echo "read_if_owner_unknown|docs/README.md"
echo "read_if_ui_design|DESIGN.md"
echo "read_if_ui_design|docs/design_system.md"
echo "read_if_validation_detail|docs/engineering/validation_routing_fast_vs_full.md"
echo "read_if_l10n|docs/localization.md"
echo ""

echo "validation_pointer|fast|./bin/checklist-fast"
echo "validation_pointer|full|./bin/checklist"
echo "validation_pointer|router|./bin/router_feature_validate"
echo "validation_pointer|integration|./bin/integration_tests"
echo "validation_pointer|design|./tool/check_design_md.sh"
echo "host_setup_pointer|preview|bash tool/setup_cursor_agent_environment.sh"
echo "host_setup_pointer|apply|bash tool/setup_cursor_agent_environment.sh --apply"
echo "host_setup_pointer|cursor_command|/setup-cursor-agent-environment"
echo "host_maintain_pointer|session_start|./bin/agent-maintain preflight"
echo "host_maintain_pointer|before_finish|./bin/agent-maintain closeout"
echo "host_maintain_pointer|after_template_edit|./bin/agent-maintain after-host-edit"
echo "host_maintain_policy|docs/agent_kb/host_maintenance_automation.md"
echo ""

echo "context_ladder|canonical|docs/ai/context_loading.md (numbered cold-start only)"
echo "context_discovery|layers|docs/agent_kb/memory_and_context_ladder.md (file discovery; unnumbered)"
echo "context_ladder|3|structural graph: ./tool/refresh_code_review_graph.sh --status-only or --if-needed"
if [[ -f "$repo_root/.code-review-graph/graph.db" ]]; then
  echo "context_graph|cache|present"
  if [[ -f "$repo_root/.code-review-graph/last_head" ]]; then
    graph_head="$(cat "$repo_root/.code-review-graph/last_head" 2>/dev/null || true)"
    if [[ -n "$graph_head" ]]; then
      echo "context_graph|last_head|$graph_head"
    fi
  fi
else
  echo "context_graph|cache|missing"
fi
echo ""

print_flutter_resolution_report || true
echo ""

declare -a scope_paths=()
if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  echo "scope|mode|explicit-paths"
  for p in "${explicit_paths[@]}"; do
    scope_paths+=("$p")
    echo "scope|path|$p"
  done
elif [[ "$has_git" -eq 1 ]]; then
  echo "scope|mode|git-diff"
  if [[ -n "$base_ref" ]]; then
    echo "scope|base|$base_ref"
    if git rev-parse "$base_ref" >/dev/null 2>&1; then
      while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        scope_paths+=("$f")
        echo "scope|path|$f"
      done < <(git diff --name-only "$base_ref...HEAD" --diff-filter=ACMRTUXB | sed '/^$/d')
    else
      echo "unknown-scope|treating as broad|invalid-base-ref"
    fi
  else
    while IFS= read -r f; do
      [[ -n "$f" ]] || continue
      scope_paths+=("$f")
      echo "scope|path|$f"
    done < <({
      git diff --name-only --diff-filter=ACMRTUXBD 2>/dev/null || true
      git diff --name-only --cached --diff-filter=ACMRTUXBD 2>/dev/null || true
      git ls-files --others --exclude-standard 2>/dev/null || true
    } | sed '/^$/d' | LC_ALL=C sort -u)
  fi
else
  echo "unknown-scope|treating as broad|no-git"
fi

echo ""
if [[ -n "$intent" ]]; then
  echo "tool_route|intent|provided"
fi
if [[ "${#scope_paths[@]}" -gt 0 ]]; then
  bash "$repo_root/tool/agent_tool_router.sh" --intent "${intent:-scope-only}" --paths "${scope_paths[@]}"
else
  bash "$repo_root/tool/agent_tool_router.sh" --intent "${intent:-scope-only}"
fi

echo ""
echo "done|bootstrap"
