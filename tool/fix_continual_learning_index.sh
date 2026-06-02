#!/usr/bin/env bash
# Fix continual-learning index: drop subagents, minify, keep schema.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
index_path="$repo_root/.cursor/hooks/state/continual-learning-index.json"

if [[ ! -f "$index_path" ]]; then
  echo "ok|missing-index|$index_path"
  exit 0
fi

python3 - "$index_path" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
obj = json.loads(path.read_text(encoding="utf-8"))
transcripts = obj.get("transcripts")
if isinstance(transcripts, dict):
    obj["transcripts"] = {k: v for k, v in transcripts.items() if "/subagents/" not in k}

# Keep stable, compact encoding (single-line).
path.write_text(json.dumps(obj, separators=(",", ":"), sort_keys=True), encoding="utf-8")
print(f"ok|fixed|bytes={path.stat().st_size}|entries={len(obj.get('transcripts', {})) if isinstance(obj.get('transcripts'), dict) else 'n/a'}")
PY

