#!/usr/bin/env bash
# Guard continual-learning index stays small and top-level only.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
index_path="$repo_root/.cursor/hooks/state/continual-learning-index.json"

if [[ ! -f "$index_path" ]]; then
  echo "ok|missing-index|$index_path"
  exit 0
fi

bytes="$(wc -c <"$index_path" | tr -d '[:space:]')"

# Keep below Cursor Read tool hard limit (100k chars) with headroom.
max_bytes="${CONTINUAL_LEARNING_INDEX_MAX_BYTES:-95000}"
if [[ "$bytes" -gt "$max_bytes" ]]; then
  echo "❌ continual-learning-index too large|bytes=$bytes|max=$max_bytes|$index_path" >&2
  echo "fix: ./tool/fix_continual_learning_index.sh" >&2
  exit 1
fi

if grep -qF -- "/subagents/" "$index_path"; then
  echo "❌ continual-learning-index must not track subagents|$index_path" >&2
  echo "fix: ./tool/fix_continual_learning_index.sh" >&2
  exit 1
fi

# Encourage minified JSON (allow one trailing newline).
lines="$(wc -l <"$index_path" | tr -d '[:space:]')"
if [[ "$lines" -gt 1 ]]; then
  echo "❌ continual-learning-index must be single-line JSON|lines=$lines|$index_path" >&2
  echo "fix: ./tool/fix_continual_learning_index.sh" >&2
  exit 1
fi

echo "ok|continual-learning-index|bytes=$bytes"

