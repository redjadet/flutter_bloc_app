#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/agent_session_bootstrap.sh [--base <git-ref>] [--paths <file>...]

Read-only bootstrap for AI agent sessions.

Prints:
- repo location and (when available) git context
- canonical docs to read next (AGENTS.md + docs index)
- validation routing pointers (fast/full + router/integration)
- scope detection summary (explicit paths > git diff > unknown-scope fallback)

Never mutates the working tree.
EOF
}

base_ref=""
declare -a explicit_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
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
echo "read_next|AGENTS.md"
echo "read_next|docs/agent_knowledge_base.md"
echo "read_next|docs/ai_code_review_protocol.md"
echo "read_next|docs/agents_quick_reference.md"
echo "read_next|docs/README.md"
echo "read_next|docs/engineering/validation_routing_fast_vs_full.md"
echo "read_next|docs/localization.md"
echo ""

echo "validation_pointer|fast|./bin/checklist-fast"
echo "validation_pointer|full|./bin/checklist"
echo "validation_pointer|router|./bin/router_feature_validate"
echo "validation_pointer|integration|./bin/integration_tests"
echo ""

scope_mode="unknown"
if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  scope_mode="explicit-paths"
  echo "scope|mode|explicit-paths"
  for p in "${explicit_paths[@]}"; do
    echo "scope|path|$p"
  done
elif [[ "$has_git" -eq 1 ]]; then
  scope_mode="git-diff"
  echo "scope|mode|git-diff"
  if [[ -n "$base_ref" ]]; then
    echo "scope|base|$base_ref"
    if git rev-parse "$base_ref" >/dev/null 2>&1; then
      git diff --name-only "$base_ref...HEAD" --diff-filter=ACMRTUXB | sed '/^$/d' | while IFS= read -r f; do
        echo "scope|path|$f"
      done
    else
      echo "unknown-scope|treating as broad|invalid-base-ref"
    fi
  else
    git diff --name-only --diff-filter=ACMRTUXB | sed '/^$/d' | while IFS= read -r f; do
      echo "scope|path|$f"
    done
  fi
else
  echo "unknown-scope|treating as broad|no-git"
fi

echo ""
echo "done|bootstrap"
