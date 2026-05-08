#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

out_path="${1:-$repo_root/docs/audits/transcript_inventory_$(date +%F).json}"

if [[ -z "${CURSOR_AGENT_TRANSCRIPTS_ROOT:-}" ]]; then
  echo "missing-env|CURSOR_AGENT_TRANSCRIPTS_ROOT|set to Cursor transcript root" >&2
  exit 2
fi

dart "$repo_root/tool/transcript_inventory.dart" "$out_path"

echo "ok|transcript_inventory|$out_path"

