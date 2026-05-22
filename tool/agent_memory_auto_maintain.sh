#!/usr/bin/env bash
# Safe automatic agent-memory maintenance (invariants + optional local doc link fix).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/agent_memory_auto_maintain.sh [options]

Runs safe, deterministic agent-memory upkeep. Does not compress docs, trim global
skills, mutate Codex compiled memory, or mutate host assets unless another
script does (e.g. sync --apply).

Modes (combine):
  --verify           Run memory-compounding / ladder invariant guard (default)
  --fix-links        Normalize markdown links on agent-scope paths (local only)
  --if-changed       When git shows agent-scope edits, run --fix-links (local)
  --codex-memory-health
                      Report Codex MEMORY.md health and maintenance pointers

CI: --fix-links and --if-changed never mutate files (skip with notice).
Opt-out: AGENT_MEMORY_AUTO_MAINTAIN=0
Optional report hook: AGENT_MEMORY_CODEX_HEALTH=1

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
do_codex_memory_health=0

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
    --codex-memory-health)
      do_codex_memory_health=1
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

if (( ! do_verify && ! do_fix_links && ! do_if_changed && ! do_codex_memory_health )); then
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

file_bytes() {
  local path="$1"
  wc -c <"$path" | tr -d '[:space:]'
}

file_lines() {
  local path="$1"
  wc -l <"$path" | tr -d '[:space:]'
}

run_codex_memory_health() {
  local memory_root="${CODEX_MEMORY_ROOT:-$HOME/.codex/memories}"
  local automation_root="${CODEX_MEMORY_AUTOMATION_ROOT:-$HOME/.codex/automations/maintain-codex-memory-registry}"
  local memory_file="$memory_root/MEMORY.md"
  local summary_file="$memory_root/memory_summary.md"
  local automation_file="$automation_root/automation.toml"
  local automation_log="$automation_root/memory.md"
  local memory_soft_limit="${CODEX_MEMORY_SOFT_LIMIT_BYTES:-300000}"
  local summary_soft_limit="${CODEX_MEMORY_SUMMARY_SOFT_LIMIT_BYTES:-80000}"
  local log_soft_limit="${CODEX_MEMORY_AUTOMATION_LOG_SOFT_LIMIT_BYTES:-40000}"

  echo "agent-memory-maintain|codex-memory-health|begin"

  if [[ ! -d "$memory_root" ]]; then
    echo "agent-memory-maintain|codex-memory-health|skip|missing-memory-root|$memory_root"
    echo "agent-memory-maintain|codex-memory-health|done"
    return 0
  fi

  if [[ -r "$memory_file" ]]; then
    local memory_bytes memory_line_count
    memory_bytes="$(file_bytes "$memory_file")"
    memory_line_count="$(file_lines "$memory_file")"
    echo "agent-memory-maintain|codex-memory-health|MEMORY.md|bytes=$memory_bytes|lines=$memory_line_count"
    if (( memory_bytes > memory_soft_limit )); then
      echo "agent-memory-maintain|codex-memory-health|candidate|MEMORY.md exceeds ${memory_soft_limit} bytes; run existing local memory-registry automation before adding new rules"
    fi
  else
    echo "agent-memory-maintain|codex-memory-health|warn|MEMORY.md not readable|$memory_file"
  fi

  if [[ -r "$summary_file" ]]; then
    local summary_bytes summary_line_count
    summary_bytes="$(file_bytes "$summary_file")"
    summary_line_count="$(file_lines "$summary_file")"
    echo "agent-memory-maintain|codex-memory-health|memory_summary.md|bytes=$summary_bytes|lines=$summary_line_count"
    if (( summary_bytes > summary_soft_limit )); then
      echo "agent-memory-maintain|codex-memory-health|candidate|memory_summary.md exceeds ${summary_soft_limit} bytes; refresh compact injected brief after compiled-memory cleanup"
    fi
  else
    echo "agent-memory-maintain|codex-memory-health|warn|memory_summary.md not readable|$summary_file"
  fi

  if [[ -r "$automation_file" ]]; then
    if grep -qF 'id = "maintain-codex-memory-registry"' "$automation_file"; then
      echo "agent-memory-maintain|codex-memory-health|automation|present|$automation_file"
    else
      echo "agent-memory-maintain|codex-memory-health|warn|automation id not found|$automation_file"
    fi
  else
    echo "agent-memory-maintain|codex-memory-health|warn|automation not readable|$automation_file"
  fi

  if [[ -r "$automation_log" ]]; then
    local log_bytes
    log_bytes="$(file_bytes "$automation_log")"
    echo "agent-memory-maintain|codex-memory-health|automation-log|bytes=$log_bytes|$automation_log"
    if (( log_bytes > log_soft_limit )); then
      echo "agent-memory-maintain|codex-memory-health|candidate|automation log exceeds ${log_soft_limit} bytes; summarize old run notes inside automation memory"
    fi
  fi

  echo "agent-memory-maintain|codex-memory-health|policy|report-only; no edits to ~/.codex/memories"
  echo "agent-memory-maintain|codex-memory-health|done"
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

if (( do_codex_memory_health )) || [[ "${AGENT_MEMORY_CODEX_HEALTH:-0}" == "1" ]]; then
  run_codex_memory_health
fi

echo "agent-memory-maintain|done"
