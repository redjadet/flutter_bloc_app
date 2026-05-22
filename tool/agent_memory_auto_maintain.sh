#!/usr/bin/env bash
# Safe automatic agent-memory maintenance (invariants + optional local doc link fix).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/agent_memory_auto_maintain.sh [options]

Runs safe, deterministic agent-memory upkeep. Does not compress docs, trim global
skills, or mutate host assets unless another script does (e.g. sync --apply).

Modes (combine):
  --verify           Run memory-compounding / ladder invariant guard (default)
  --fix-links        Normalize markdown links on agent-scope paths (local only)
  --if-changed       When git shows agent-scope edits, run --fix-links (local)

CI: --fix-links and --if-changed never mutate files (skip with notice).
Opt-out: AGENT_MEMORY_AUTO_MAINTAIN=0

Typical wiring (already invoked from repo scripts):
  check_agent_knowledge_base.sh  -> --if-changed (local)
  sync_agent_assets.sh --apply   -> --verify
EOF
}

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

do_verify=0
do_fix_links=0
do_if_changed=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verify)
      do_verify=1
      shift
      ;;
    --fix-links)
      do_fix_links=1
      shift
      ;;
    --if-changed)
      do_if_changed=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "agent-memory-maintain|error|unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if (( ! do_verify && ! do_fix_links && ! do_if_changed )); then
  do_verify=1
fi

if [[ "${AGENT_MEMORY_AUTO_MAINTAIN:-1}" == "0" ]]; then
  echo "agent-memory-maintain|skip|AGENT_MEMORY_AUTO_MAINTAIN=0"
  exit 0
fi

in_ci() {
  [[ -n "${CI:-}" ]]
}

is_agent_scope_path() {
  local path="$1"
  case "$path" in
    AGENTS.md|llms.txt) return 0 ;;
    docs/agent_environment_setup.md) return 0 ;;
    docs/agent_knowledge_base.md) return 0 ;;
    docs/ai/context_loading.md) return 0 ;;
    docs/agents_quick_reference.md) return 0 ;;
    tool/agent_session_bootstrap.sh) return 0 ;;
    tool/check_agent_memory_compounding.sh) return 0 ;;
    tool/agent_memory_auto_maintain.sh) return 0 ;;
    tool/check_agent_knowledge_base.sh) return 0 ;;
  esac
  case "$path" in
    docs/agent_kb/*|docs/agent_kb/*/*|docs/agent_kb/*/*/*) return 0 ;;
    docs/audits/dedup_matrix*.md) return 0 ;;
    docs/changes/*agent*.md|docs/validation_scripts/*.md) return 0 ;;
    tool/agent_host_templates/*|tool/agent_host_templates/*/*|tool/agent_host_templates/*/*/*|tool/agent_host_templates/*/*/*/*) return 0 ;;
  esac
  return 1
}

collect_git_changed_paths() {
  if ! command -v git >/dev/null 2>&1; then
    return 1
  fi
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 1
  fi
  {
    git diff --name-only HEAD 2>/dev/null || true
    git diff --name-only --cached 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | sed '/^$/d' | sort -u
}

collect_agent_scope_markdown() {
  local -a out=()
  local path

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if is_agent_scope_path "$path" && [[ "$path" == *.md && -f "$path" ]]; then
      out+=("$path")
    fi
  done < <(collect_git_changed_paths || true)

  if [[ ${#out[@]} -eq 0 ]]; then
    return 1
  fi

  printf '%s\n' "${out[@]}" | sort -u
}

run_fix_links() {
  local -a files=()
  local file
  local script="$repo_root/tool/normalize_doc_links.py"

  if in_ci; then
    echo "agent-memory-maintain|fix-links|skipped|ci"
    return 0
  fi

  if [[ ! -f "$script" ]]; then
    echo "agent-memory-maintain|fix-links|skipped|no-normalize-script"
    return 0
  fi

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    files+=("$file")
  done < <(collect_agent_scope_markdown || true)

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "agent-memory-maintain|fix-links|skipped|no-agent-scope-markdown"
    return 0
  fi

  echo "agent-memory-maintain|fix-links|begin|count=${#files[@]}"
  python3 "$script" "${files[@]}"
  echo "agent-memory-maintain|fix-links|ok"
}

run_verify() {
  echo "agent-memory-maintain|verify|begin"
  bash "$repo_root/tool/check_agent_memory_compounding.sh"
  echo "agent-memory-maintain|verify|ok"
}

if (( do_if_changed )); then
  if in_ci; then
    echo "agent-memory-maintain|if-changed|ci-skip-fix-links"
  else
    do_fix_links=1
  fi
fi

if (( do_fix_links )); then
  run_fix_links
fi

if (( do_verify )); then
  run_verify
fi

echo "agent-memory-maintain|done"
