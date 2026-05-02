#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync_agent_assets.sh --dry-run | --apply

Sync repo-managed Cursor and Codex adapter templates into ~/.cursor and ~/.codex.
Templates live under tool/agent_host_templates/ by default (versioned in this
repo), or set AGENT_TEMPLATES_ROOT to another directory.

If no template tree exists, this script exits 0 and prints a skip message.

Modes:
  --dry-run   Show which managed files would update.
  --apply     Copy repo-managed adapters into host locations.
EOF
}

mode=""
failures=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      mode="dry-run"
      shift
      ;;
    --apply)
      mode="apply"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$mode" ]]; then
  usage >&2
  exit 2
fi

# shellcheck source=./agent_asset_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/agent_asset_lib.sh"

if ! has_agent_templates; then
  echo "Agent asset sync skipped (no local templates found at: $agent_templates_root)."
  exit 0
fi

if ! require_agent_asset_runtime; then
  echo "Agent asset sync failed because required runtime tools were missing." >&2
  exit 1
fi

report_and_maybe_apply() {
  local src_rel="$1"
  local dst="$2"
  local status status_code
  set +e
  status="$(copy_file_if_needed "$src_rel" "$dst")"
  status_code=$?
  set -e
  echo "$status"
  if (( status_code != 0 )); then
    failures=1
    return 0
  fi
  if [[ "$mode" == "apply" && "${status%%|*}" == "update" ]]; then
    apply_copy_file "$src_rel" "$dst"
  fi
}

# shellcheck disable=SC2154
for mapping in "${managed_cursor_files[@]}" "${managed_codex_files[@]}"; do
  src_rel="${mapping%%|*}"
  dst="${mapping##*|}"
  report_and_maybe_apply "$src_rel" "$dst"
done

while IFS= read -r worktree_agent; do
  [[ -n "$worktree_agent" ]] || continue
  report_and_maybe_apply "codex/AGENTS.md" "$worktree_agent"
done < <(list_optional_codex_worktree_agent_targets)

rules_status="$(check_codex_rules_block)" || true
echo "$rules_status"
if [[ "$mode" == "apply" && "${rules_status%%|*}" != "ok" ]]; then
  apply_codex_rules_block
fi
if [[ "${rules_status%%|*}" == "missing-source" ]]; then
  failures=1
fi

if (( failures != 0 )); then
  echo "Agent asset sync failed because one or more repo-managed source files were missing." >&2
  exit 1
fi

echo "Agent asset sync completed."
