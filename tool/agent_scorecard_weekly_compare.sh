#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACTIVE_FILE="$PROJECT_ROOT/analysis/agent_scorecard/scorecard-events.jsonl"
ARCHIVE_DIR="$PROJECT_ROOT/analysis/agent_scorecard/archive"
SUMMARY_DIR="$PROJECT_ROOT/analysis/agent_scorecard/summaries"
OUT_JSON="$SUMMARY_DIR/scorecard-weekly-compare.json"
OUT_MD="$SUMMARY_DIR/scorecard-weekly-compare.md"

mkdir -p "$SUMMARY_DIR" "$ARCHIVE_DIR"

python3 - "$ACTIVE_FILE" "$ARCHIVE_DIR" "$OUT_JSON" "$OUT_MD" <<'PY'
import gzip
import json
import statistics
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

active_file = Path(sys.argv[1])
archive_dir = Path(sys.argv[2])
out_json = Path(sys.argv[3])
out_md = Path(sys.argv[4])

events = []
seen = set()

def add_event(raw: str):
    raw = raw.strip()
    if not raw:
        return
    try:
        event = json.loads(raw)
    except json.JSONDecodeError:
        return
    key = event.get("dedupe_key")
    if not key or key in seen:
        return
    seen.add(key)
    events.append(event)

if active_file.exists():
    for line in active_file.read_text(encoding="utf-8").splitlines():
        add_event(line)

for file in sorted(archive_dir.glob("scorecard-events-*.jsonl.gz")):
    with gzip.open(file, "rt", encoding="utf-8") as handle:
        for line in handle:
            add_event(line)

now = datetime.now(timezone.utc)
cur_start = now - timedelta(days=7)
prev_start = now - timedelta(days=14)

def bucket(ev):
    try:
        t = datetime.fromisoformat(ev["started_at"].replace("Z", "+00:00"))
    except Exception:
        return None
    if t >= cur_start:
        return "current"
    if prev_start <= t < cur_start:
        return "previous"
    return None

stats = {
    "current": {"total": 0, "ok": 0, "delegate_used": 0, "durations": []},
    "previous": {"total": 0, "ok": 0, "delegate_used": 0, "durations": []},
}

for ev in events:
    b = bucket(ev)
    if not b:
        continue
    st = stats[b]
    st["total"] += 1
    if ev.get("status") == "ok":
        st["ok"] += 1
    if ev.get("delegate_used"):
        st["delegate_used"] += 1
    st["durations"].append(int(ev.get("duration_ms", 0)))

def summarize(st):
    total = st["total"]
    return {
        "total": total,
        "success_rate": (st["ok"] / total) if total else 0.0,
        "delegate_rate": (st["delegate_used"] / total) if total else 0.0,
        "p50_duration_ms": statistics.median(st["durations"]) if st["durations"] else 0,
    }

cur = summarize(stats["current"])
prev = summarize(stats["previous"])

result = {
    "current_window": cur,
    "previous_window": prev,
    "delta": {
        "success_rate": cur["success_rate"] - prev["success_rate"],
        "delegate_rate": cur["delegate_rate"] - prev["delegate_rate"],
        "p50_duration_ms": cur["p50_duration_ms"] - prev["p50_duration_ms"],
        "total": cur["total"] - prev["total"],
    },
}

out_json.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")

lines = [
    "# Agent Scorecard Week-over-Week",
    "",
    "## Current Window (Last 7 Days)",
    f"- Total: `{cur['total']}`",
    f"- Success rate: `{cur['success_rate']:.2%}`",
    f"- Delegate usage rate: `{cur['delegate_rate']:.2%}`",
    f"- p50 duration: `{int(cur['p50_duration_ms'])}ms`",
    "",
    "## Previous Window (Days 8-14)",
    f"- Total: `{prev['total']}`",
    f"- Success rate: `{prev['success_rate']:.2%}`",
    f"- Delegate usage rate: `{prev['delegate_rate']:.2%}`",
    f"- p50 duration: `{int(prev['p50_duration_ms'])}ms`",
    "",
    "## Delta (Current - Previous)",
    f"- Success rate delta: `{result['delta']['success_rate']:+.2%}`",
    f"- Delegate rate delta: `{result['delta']['delegate_rate']:+.2%}`",
    f"- p50 duration delta: `{int(result['delta']['p50_duration_ms']):+d}ms`",
    f"- Volume delta: `{result['delta']['total']:+d}`",
]

out_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote:"
echo "  $OUT_JSON"
echo "  $OUT_MD"
