#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./tool/compress_agent_doc.sh PATH [PATH ...]

Compress shared agent-facing markdown docs with the local-first caveman compressor.
Creates FILE.original.md backups next to each file.

Notes:
- Intended for agent/canon docs, not general user-facing markdown.
- Aborts for a file if FILE.original.md already exists.
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

resolve_compressor_dir() {
  local -a candidates=(
    "${CAVEMAN_COMPRESS_DIR:-}"
    "$HOME/.codex/skills/caveman-compress"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -n "$candidate" && -f "$candidate/scripts/__main__.py" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  candidate="$(find "$HOME/.codex/plugins/cache/openai-curated/caveman" -path '*/skills/compress/scripts/__main__.py' -print -quit 2>/dev/null || true)"
  if [[ -n "$candidate" ]]; then
    dirname "$(dirname "$candidate")"
    return 0
  fi

  return 1
}

compressor_dir="$(resolve_compressor_dir)" || {
  echo "compress_agent_doc: caveman compressor not found" >&2
  echo "Set CAVEMAN_COMPRESS_DIR or install caveman-compress under ~/.codex/skills" >&2
  exit 2
}

status=0
for input_path in "$@"; do
  if [[ ! -f "$input_path" ]]; then
    echo "compress_agent_doc: file not found: $input_path" >&2
    status=1
    continue
  fi

  abs_path="$(cd "$(dirname "$input_path")" && pwd)/$(basename "$input_path")"
  echo "compress_agent_doc: $abs_path"
  if ! (cd "$compressor_dir" && python3 -m scripts "$abs_path"); then
    status=1
  fi
done

exit "$status"
