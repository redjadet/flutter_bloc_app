#!/usr/bin/env bash
# Warn: CachedNetworkImageWidget with size but no memCacheWidth/memCacheHeight (exit 0).
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
echo "🔍 Checking remote image cache hints (warn-only)..."
SCAN_PATHS=("lib")
usage() {
  cat <<'EOF'
Usage: tool/check_remote_image_cache_hints.sh [--paths PATH...]

Warn-only. Default scope: lib/**/presentation/**. --paths supports fixture runs.
EOF
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  SCAN_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi
scan_file() {
  python3 - "$1" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
token = "CachedNetworkImageWidget("
start = 0
while True:
    index = text.find(token, start)
    if index == -1:
        break
    line = text.count("\n", 0, index) + 1
    depth = 0
    end = index
    for pos in range(index, len(text)):
        char = text[pos]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                end = pos + 1
                break
    block = text[index:end]
    has_literal_size = re.search(r"\b(width|height)\s*:\s*[0-9]", block) is not None
    has_cache_hint = "memCacheWidth" in block or "memCacheHeight" in block
    if has_literal_size and not has_cache_hint:
        print(f"{path}:{line}: CachedNetworkImageWidget with size but no memCacheWidth/memCacheHeight")
    start = max(end, index + len(token))
PY
}
collect_violations() {
  local root dartfile hits out=""
  for root in "${SCAN_PATHS[@]}"; do
    if [ -f "$root" ]; then
      dartfile="$root"
      case "$dartfile" in */presentation/*) ;; *) continue ;; esac
      hits="$(scan_file "$dartfile")"
      [ -n "$hits" ] && out+="${hits}"$'\n'
      continue
    fi
    [ -d "$root" ] || continue
    while IFS= read -r dartfile; do
      case "$dartfile" in */presentation/*) ;; *) continue ;; esac
      hits="$(scan_file "$dartfile")"
      [ -n "$hits" ] && out+="${hits}"$'\n'
    done < <(find "$root" -name '*.dart' -type f 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored:"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "⚠️  Remote image cache hints: ${count} file(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | head -5
  echo "Remediation: add memCacheWidth/memCacheHeight to CachedNetworkImageWidget."
else echo "✅ No remote image cache hint warnings"; fi
exit 0
