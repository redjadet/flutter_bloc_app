#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./tool/compress_agent_doc.sh [--overwrite-backups] PATH [PATH ...]

Compress shared agent-facing markdown docs with the local-first caveman compressor.
Creates FILE.original.md backups next to each file.

Options:
  --overwrite-backups  Replace existing FILE.original.md backups before compressing.

Environment:
  CAVEMAN_COMPRESS_OVERWRITE_BACKUPS=1  Same as --overwrite-backups.

Notes:
- Intended for agent/canon docs, not general user-facing markdown.
- Without --overwrite-backups, compressor aborts for a file if FILE.original.md
  already exists.
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

overwrite_backups="${CAVEMAN_COMPRESS_OVERWRITE_BACKUPS:-0}"
input_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --overwrite-backups)
      overwrite_backups=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        input_paths+=("$1")
        shift
      done
      ;;
    -*)
      echo "compress_agent_doc: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      input_paths+=("$1")
      shift
      ;;
  esac
done

if [[ "${#input_paths[@]}" -lt 1 ]]; then
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
for input_path in "${input_paths[@]}"; do
  if [[ ! -f "$input_path" ]]; then
    echo "compress_agent_doc: file not found: $input_path" >&2
    status=1
    continue
  fi

  base_name="$(basename "$input_path")"
  if [[ "$base_name" == README*.md ]]; then
    echo "compress_agent_doc: README files are excluded: $input_path" >&2
    status=1
    continue
  fi

  abs_path="$(cd "$(dirname "$input_path")" && pwd)/$(basename "$input_path")"
  backup_dir="$(dirname "$abs_path")"
  backup_name="$(basename "$abs_path")"
  backup_path="$backup_dir/${backup_name%.*}.original.md"
  if [[ -f "$backup_path" ]]; then
    if [[ "$overwrite_backups" == "1" || "$overwrite_backups" == "true" || "$overwrite_backups" == "yes" ]]; then
      echo "compress_agent_doc: overwriting existing backup: $backup_path"
      rm -f "$backup_path"
    else
      echo "compress_agent_doc: backup exists: $backup_path" >&2
      echo "compress_agent_doc: pass --overwrite-backups to replace it" >&2
      status=1
      continue
    fi
  fi

  echo "compress_agent_doc: $abs_path"
  if ! (cd "$compressor_dir" && python3 -m scripts "$abs_path"); then
    status=1
  fi
done

exit "$status"
