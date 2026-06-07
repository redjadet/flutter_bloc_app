#!/usr/bin/env bash
# Fix continual-learning index: drop subagents, migrate to relative keys, minify.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
index_path="$repo_root/.cursor/hooks/state/continual-learning-index.json"

if [[ ! -f "$index_path" ]]; then
  echo "ok|missing-index|$index_path"
  exit 0
fi

python3 - "$index_path" <<'PY'
import json
import os
import sys
from pathlib import Path

path = Path(sys.argv[1])
obj = json.loads(path.read_text(encoding="utf-8"))
transcripts = obj.get("transcripts")
if not isinstance(transcripts, dict):
    transcripts = {}

root = os.environ.get("CURSOR_AGENT_TRANSCRIPTS_ROOT", "").rstrip("/\\")

def to_relative_key(key: str) -> str:
    normalized = key.replace("\\", "/")
    if root and normalized.startswith(root.replace("\\", "/") + "/"):
        return normalized[len(root.replace("\\", "/")) + 1 :]
    marker = "/agent-transcripts/"
    if marker in normalized:
        return normalized.split(marker, 1)[1]
    if not normalized.startswith("/") and ":/" not in normalized:
        return normalized
    parts = normalized.split("/")
    if len(parts) >= 2:
        return f"{parts[-2]}/{parts[-1]}"
    return parts[-1]

migrated = {}
for key, value in transcripts.items():
    if "/subagents/" in key.replace("\\", "/"):
        continue
    rel = to_relative_key(key)
    existing = migrated.get(rel)
    if existing is None:
        migrated[rel] = value
        continue
    old_mtime = existing.get("mtimeMs") if isinstance(existing, dict) else None
    new_mtime = value.get("mtimeMs") if isinstance(value, dict) else None
    if isinstance(old_mtime, (int, float)) and isinstance(new_mtime, (int, float)):
        if new_mtime > old_mtime:
            migrated[rel] = value
    else:
        migrated[rel] = value

obj["transcripts"] = migrated
path.write_text(json.dumps(obj, separators=(",", ":"), sort_keys=True), encoding="utf-8")
print(f"ok|fixed|bytes={path.stat().st_size}|entries={len(migrated)}")
PY
