#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: check_agent_asset_drift.sh

Check whether managed Cursor/Codex host assets match local templates under
tool/agent_host_templates/ (or AGENT_TEMPLATES_ROOT). Those paths are
gitignored; fresh clones often have no templates yet.

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

check_mapping() {
  local src_rel="$1"
  local dst="$2"
  local status
  status="$(copy_file_if_needed "$src_rel" "$dst")" || true
  echo "$status"
  if [[ "${status%%|*}" != "ok" ]]; then
    failures=1
  fi
}

# shellcheck disable=SC2154
for mapping in "${managed_cursor_files[@]}" "${managed_codex_files[@]}"; do
  check_mapping "${mapping%%|*}" "${mapping##*|}"
done

rules_status="$(check_codex_rules_block)" || true
echo "$rules_status"
if [[ "${rules_status%%|*}" != "ok" ]]; then
  failures=1
fi

if ! check_toolchain_mentions; then
  failures=1
fi

if (( failures != 0 )); then
  echo "Agent asset drift detected." >&2
  exit 1
fi

echo "Agent assets are in sync."
