#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: check_agent_asset_drift.sh

Check whether managed Cursor/Codex host assets match repo sources. Cursor
assets and Codex skills/rules come from tool/agent_host_templates/ (or
AGENT_TEMPLATES_ROOT); Codex AGENTS.md comes from root AGENTS.md.

If no template tree exists, this script exits 0 and prints a skip message.
Otherwise it also verifies README toolchain markers in matching policy docs.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if (( $# > 0 )); then
  echo "Unexpected argument: $1" >&2
  usage >&2
  exit 2
fi

# shellcheck source=./agent_asset_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/agent_asset_lib.sh"

if ! has_agent_templates; then
  echo "Agent asset drift check skipped (no local templates found at: $agent_templates_root)."
  exit 0
fi

if ! require_agent_asset_runtime; then
  echo "Agent asset drift check failed because required runtime tools were missing." >&2
  exit 1
fi

failures=0

normalize_status_line() {
  local raw="$1"
  local line
  local extracted=""

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ (ok|update|missing-source|missing-target|toolchain-drift|workspace-rule-duplicate|workspace-skill-duplicate)\|.*$ ]]; then
      extracted="${BASH_REMATCH[0]}"
    fi
  done <<< "$raw"

  printf '%s' "$extracted"
}

check_mapping() {
  local src_rel="$1"
  local dst="$2"
  local raw_status
  local status

  raw_status="$(copy_file_if_needed "$src_rel" "$dst")" || true
  status="$(normalize_status_line "$raw_status")"
  echo "${status:-$raw_status}"
  if [[ "${status%%|*}" != "ok" ]]; then
    failures=1
  fi
}

# shellcheck disable=SC2154
for mapping in "${managed_cursor_files[@]}" "${managed_codex_files[@]}"; do
  check_mapping "${mapping%%|*}" "${mapping##*|}"
done

while IFS= read -r worktree_agent; do
  [[ -n "$worktree_agent" ]] || continue
  check_mapping "__repo_root__/AGENTS.md" "$worktree_agent"
done < <(list_optional_codex_worktree_agent_targets)

rules_raw_status="$(check_codex_rules_block)" || true
rules_status="$(normalize_status_line "$rules_raw_status")"
echo "${rules_status:-$rules_raw_status}"
if [[ "${rules_status%%|*}" != "ok" ]]; then
  failures=1
fi

toolchain_raw_status="$(check_toolchain_mentions)" || true
toolchain_status="$(normalize_status_line "$toolchain_raw_status")"
echo "${toolchain_status:-$toolchain_raw_status}"
if [[ "${toolchain_status%%|*}" != "ok" ]]; then
  failures=1
fi

rule_dup_raw_status="$(check_workspace_managed_rule_duplicates)" || true
rule_dup_status="$(normalize_status_line "$rule_dup_raw_status")"
echo "${rule_dup_status:-$rule_dup_raw_status}"
if [[ "${rule_dup_status%%|*}" != "ok" ]]; then
  failures=1
fi

dup_raw_status="$(check_workspace_managed_skill_duplicates)" || true
dup_status="$(normalize_status_line "$dup_raw_status")"
echo "${dup_status:-$dup_raw_status}"
if [[ "${dup_status%%|*}" != "ok" ]]; then
  failures=1
fi

if (( failures != 0 )); then
  echo "Agent asset drift detected." >&2
  exit 1
fi

echo "Agent assets are in sync."
