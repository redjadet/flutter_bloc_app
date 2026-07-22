#!/usr/bin/env bash
# Verify scorecard summaries were generated from the current event inputs.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash tool/check_agent_scorecard_freshness.sh

Fails when generated scorecard summaries do not match the active event stream
and archived event inputs. Refresh with: ./tool/build_agent_scorecard_summary.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
active_file="$repo_root/analysis/agent_scorecard/scorecard-events.jsonl"
archive_dir="$repo_root/analysis/agent_scorecard/archive"
summary_json="$repo_root/analysis/agent_scorecard/summaries/scorecard-summary.json"
summary_md="$repo_root/analysis/agent_scorecard/summaries/scorecard-summary.md"

python3 - "$active_file" "$archive_dir" "$summary_json" "$summary_md" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

active_file = Path(sys.argv[1])
archive_dir = Path(sys.argv[2])
summary_json = Path(sys.argv[3])
summary_md = Path(sys.argv[4])

if not summary_json.is_file() or not summary_md.is_file():
    raise SystemExit(
        "agent-scorecard-freshness|fail|missing summary; run ./tool/build_agent_scorecard_summary.sh"
    )

hasher = hashlib.sha256()
source_files = []
if active_file.is_file():
    source_files.append(active_file)
if archive_dir.is_dir():
    source_files.extend(sorted(archive_dir.glob("scorecard-events-*.jsonl.gz")))

for source_file in source_files:
    hasher.update(source_file.name.encode("utf-8"))
    hasher.update(b"\0")
    hasher.update(source_file.read_bytes())
    hasher.update(b"\0")
expected = hasher.hexdigest()

try:
    summary = json.loads(summary_json.read_text(encoding="utf-8"))
except json.JSONDecodeError as error:
    raise SystemExit(f"agent-scorecard-freshness|fail|invalid JSON summary: {error}")

actual = summary.get("source_fingerprint")
if actual != expected:
    raise SystemExit(
        "agent-scorecard-freshness|fail|summary inputs changed; "
        "run ./tool/build_agent_scorecard_summary.sh"
    )

summary_text = summary_md.read_text(encoding="utf-8")
if f"Source fingerprint: `{expected}`" not in summary_text:
    raise SystemExit(
        "agent-scorecard-freshness|fail|Markdown summary fingerprint stale; "
        "run ./tool/build_agent_scorecard_summary.sh"
    )

print(
    "agent-scorecard-freshness|pass|"
    f"inputs={len(source_files)}|fingerprint={expected}"
)
PY
