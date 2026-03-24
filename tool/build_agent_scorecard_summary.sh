#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCORECARD_ROOT="$PROJECT_ROOT/analysis/agent_scorecard"
ACTIVE_FILE="$SCORECARD_ROOT/scorecard-events.jsonl"
ARCHIVE_DIR="$SCORECARD_ROOT/archive"
SUMMARY_DIR="$SCORECARD_ROOT/summaries"
SUMMARY_JSON="$SUMMARY_DIR/scorecard-summary.json"
SUMMARY_MD="$SUMMARY_DIR/scorecard-summary.md"

mkdir -p "$SUMMARY_DIR" "$ARCHIVE_DIR"

python3 - "$ACTIVE_FILE" "$ARCHIVE_DIR" "$SUMMARY_JSON" "$SUMMARY_MD" <<'PY'
import gzip
import json
import statistics
import sys
from collections import defaultdict
from pathlib import Path

active_file = Path(sys.argv[1])
archive_dir = Path(sys.argv[2])
summary_json = Path(sys.argv[3])
summary_md = Path(sys.argv[4])

events = []
seen = set()
line_stats = {
    "total_non_empty_lines": 0,
    "parsed_json_lines": 0,
    "invalid_json_lines": 0,
}

def ingest_line(raw_line: str):
    line = raw_line.strip()
    if not line:
        return
    line_stats["total_non_empty_lines"] += 1
    try:
        event = json.loads(line)
    except json.JSONDecodeError:
        line_stats["invalid_json_lines"] += 1
        return
    line_stats["parsed_json_lines"] += 1
    key = event.get("dedupe_key")
    if not key or key in seen:
        return
    seen.add(key)
    events.append(event)

if active_file.exists():
    with active_file.open("r", encoding="utf-8") as handle:
        for raw in handle:
            ingest_line(raw)

for gz_file in sorted(archive_dir.glob("scorecard-events-*.jsonl.gz")):
    with gzip.open(gz_file, "rt", encoding="utf-8") as handle:
        for raw in handle:
            ingest_line(raw)

summary = {
    "total_events": len(events),
    "commands": {},
    "status_counts": defaultdict(int),
    "risk_counts": defaultdict(int),
    "delegate_usage_rate": 0.0,
    "scorecard_parse_success": 1.0,
    "line_stats": line_stats,
}

durations = []
delegate_used = 0
command_stats = defaultdict(lambda: {"count": 0, "ok": 0, "failed": 0, "durations": []})

for event in events:
    status = event.get("status", "unknown")
    risk = event.get("risk_class", "unknown")
    command = event.get("command", "unknown")
    try:
        duration = int(event.get("duration_ms", 0))
    except (TypeError, ValueError):
        duration = 0

    summary["status_counts"][status] += 1
    summary["risk_counts"][risk] += 1
    durations.append(duration)

    if event.get("delegate_used", False):
        delegate_used += 1

    command_stats[command]["count"] += 1
    command_stats[command]["durations"].append(duration)
    if status == "ok":
        command_stats[command]["ok"] += 1
    elif status in {"failed", "invalid"}:
        command_stats[command]["failed"] += 1

summary["delegate_usage_rate"] = (delegate_used / len(events)) if events else 0.0
summary["p50_duration_ms"] = statistics.median(durations) if durations else 0
summary["p95_duration_ms"] = statistics.quantiles(durations, n=100)[94] if len(durations) >= 100 else (max(durations) if durations else 0)
if line_stats["total_non_empty_lines"] > 0:
    summary["scorecard_parse_success"] = line_stats["parsed_json_lines"] / line_stats["total_non_empty_lines"]
else:
    summary["scorecard_parse_success"] = 1.0

for command, stats in command_stats.items():
    durations_list = stats["durations"]
    summary["commands"][command] = {
        "count": stats["count"],
        "ok": stats["ok"],
        "failed": stats["failed"],
        "success_rate": (stats["ok"] / stats["count"]) if stats["count"] else 0.0,
        "p50_duration_ms": statistics.median(durations_list) if durations_list else 0,
    }

summary["status_counts"] = dict(summary["status_counts"])
summary["risk_counts"] = dict(summary["risk_counts"])

summary_json.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")

lines = [
    "# Agent Scorecard Summary",
    "",
    f"- Total events: `{summary['total_events']}`",
    f"- Parse success: `{summary['scorecard_parse_success']:.2%}`",
    f"- Invalid JSON lines: `{summary['line_stats']['invalid_json_lines']}`",
    f"- Delegate usage rate: `{summary['delegate_usage_rate']:.2%}`",
    f"- p50 duration: `{int(summary['p50_duration_ms'])}ms`",
    f"- p95 duration: `{int(summary['p95_duration_ms'])}ms`",
    "",
    "## Status Counts",
    "",
]
for key, value in sorted(summary["status_counts"].items()):
    lines.append(f"- `{key}`: `{value}`")

lines.extend(["", "## Risk Counts", ""])
for key, value in sorted(summary["risk_counts"].items()):
    lines.append(f"- `{key}`: `{value}`")

lines.extend(["", "## Command Breakdown", ""])
for command, stats in sorted(summary["commands"].items()):
    lines.append(
        f"- `{command}`: count `{stats['count']}`, success `{stats['success_rate']:.2%}`, p50 `{int(stats['p50_duration_ms'])}ms`"
    )

summary_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote:"
echo "  $SUMMARY_JSON"
echo "  $SUMMARY_MD"
