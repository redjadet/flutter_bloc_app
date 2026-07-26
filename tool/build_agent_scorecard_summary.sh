#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCORECARD_ROOT="$PROJECT_ROOT/analysis/agent_scorecard"
ACTIVE_FILE="$SCORECARD_ROOT/scorecard-events.jsonl"
ARCHIVE_DIR="$SCORECARD_ROOT/archive"
SUMMARY_DIR="$SCORECARD_ROOT/summaries"
SUMMARY_JSON="$SUMMARY_DIR/scorecard-summary.json"
SUMMARY_MD="$SUMMARY_DIR/scorecard-summary.md"

usage() {
  cat <<'EOF'
Usage: ./tool/build_agent_scorecard_summary.sh [--self-test]

Build scorecard JSON/Markdown summaries from active + archived events.
--self-test runs fixture assertions (half-away-from-zero p50 display, count==outcomes) and exits.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--self-test" ]]; then
  python3 - <<'PY'
import math
import statistics
from collections import defaultdict

def round_duration_ms(value) -> int:
    """Round durations for display: half away from zero (not truncation/bankers)."""
    value = float(value)
    if value >= 0:
        return int(math.floor(value + 0.5))
    return int(math.ceil(value - 0.5))


def aggregate_commands(events):
    command_stats = defaultdict(
        lambda: {
            "count": 0,
            "ok": 0,
            "failed": 0,
            "cancelled": 0,
            "aborted": 0,
            "other": 0,
            "durations": [],
        }
    )
    for event in events:
        status = event.get("status", "unknown")
        command = event.get("command", "unknown")
        try:
            duration = int(event.get("duration_ms", 0))
        except (TypeError, ValueError):
            duration = 0
        stats = command_stats[command]
        stats["count"] += 1
        stats["durations"].append(duration)
        if status == "ok":
            stats["ok"] += 1
        elif status in {"failed", "invalid"}:
            stats["failed"] += 1
        elif status == "cancelled":
            stats["cancelled"] += 1
        elif status == "aborted":
            stats["aborted"] += 1
        else:
            stats["other"] += 1

    commands = {}
    for command, stats in command_stats.items():
        durations_list = stats["durations"]
        outcome_sum = (
            stats["ok"]
            + stats["failed"]
            + stats["cancelled"]
            + stats["aborted"]
            + stats["other"]
        )
        if stats["count"] != outcome_sum:
            raise AssertionError(
                f"{command}: count {stats['count']} != outcomes {outcome_sum}"
            )
        commands[command] = {
            "count": stats["count"],
            "ok": stats["ok"],
            "failed": stats["failed"],
            "cancelled": stats["cancelled"],
            "aborted": stats["aborted"],
            "other": stats["other"],
            "success_rate": (stats["ok"] / stats["count"]) if stats["count"] else 0.0,
            "p50_duration_ms": statistics.median(durations_list) if durations_list else 0,
        }
    return commands


def format_command_line(command, stats):
    return (
        f"- `{command}`: count `{stats['count']}`, "
        f"success `{stats['success_rate']:.2%}`, "
        f"p50 `{round_duration_ms(stats['p50_duration_ms'])}ms`"
    )


# Bug 1: half-up, not int() truncation / bankers round().
assert round_duration_ms(28718.5) == 28719
assert round_duration_ms(250724.5) == 250725
assert round_duration_ms(61108) == 61108
assert round_duration_ms(483414.8) == 483415
assert round_duration_ms(0) == 0

# Bug 2: cancelled/aborted/other must be counted so count == sum(outcomes).
events = [
    {"command": "integration_tests", "status": "ok", "duration_ms": 100},
    {"command": "integration_tests", "status": "failed", "duration_ms": 200},
    {"command": "integration_tests", "status": "cancelled", "duration_ms": 50},
    {"command": "integration_tests", "status": "aborted", "duration_ms": 75},
    {"command": "integration_tests", "status": "invalid", "duration_ms": 10},
]
commands = aggregate_commands(events)
it = commands["integration_tests"]
assert it["count"] == 5
assert it["ok"] == 1
assert it["failed"] == 2  # failed + invalid
assert it["cancelled"] == 1
assert it["aborted"] == 1
assert it["other"] == 0
assert it["count"] == it["ok"] + it["failed"] + it["cancelled"] + it["aborted"] + it["other"]

# Odd-sized list → median is middle value; even → average may be .5
even_events = [
    {"command": "checklist", "status": "ok", "duration_ms": 28718},
    {"command": "checklist", "status": "ok", "duration_ms": 28719},
]
checklist = aggregate_commands(even_events)["checklist"]
assert checklist["p50_duration_ms"] == 28718.5
line = format_command_line("checklist", checklist)
assert "p50 `28719ms`" in line, line

print("build_agent_scorecard_summary|self-test|pass")
PY
  exit 0
fi

mkdir -p "$SUMMARY_DIR" "$ARCHIVE_DIR"

python3 - "$ACTIVE_FILE" "$ARCHIVE_DIR" "$SUMMARY_JSON" "$SUMMARY_MD" <<'PY'
import gzip
import json
import math
import statistics
import sys
from collections import defaultdict
from pathlib import Path

active_file = Path(sys.argv[1])
archive_dir = Path(sys.argv[2])
summary_json = Path(sys.argv[3])
summary_md = Path(sys.argv[4])

def round_duration_ms(value) -> int:
    """Round durations for display: half away from zero (not truncation/bankers)."""
    value = float(value)
    if value >= 0:
        return int(math.floor(value + 0.5))
    return int(math.ceil(value - 0.5))

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

source_hasher = __import__("hashlib").sha256()
source_files = []
if active_file.exists():
    source_files.append(active_file)
source_files.extend(sorted(archive_dir.glob("scorecard-events-*.jsonl.gz")))
for source_file in source_files:
    source_hasher.update(source_file.name.encode("utf-8"))
    source_hasher.update(b"\0")
    source_hasher.update(source_file.read_bytes())
    source_hasher.update(b"\0")
summary["source_fingerprint"] = source_hasher.hexdigest()
summary["source_file_count"] = len(source_files)

durations = []
delegate_used = 0
command_stats = defaultdict(
    lambda: {
        "count": 0,
        "ok": 0,
        "failed": 0,
        "cancelled": 0,
        "aborted": 0,
        "other": 0,
        "durations": [],
    }
)

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

    stats = command_stats[command]
    stats["count"] += 1
    stats["durations"].append(duration)
    if status == "ok":
        stats["ok"] += 1
    elif status in {"failed", "invalid"}:
        # invalid is a failed outcome for success_rate; keep folded into failed.
        stats["failed"] += 1
    elif status == "cancelled":
        stats["cancelled"] += 1
    elif status == "aborted":
        stats["aborted"] += 1
    else:
        stats["other"] += 1

summary["delegate_usage_rate"] = (delegate_used / len(events)) if events else 0.0
summary["p50_duration_ms"] = statistics.median(durations) if durations else 0
summary["p95_duration_ms"] = statistics.quantiles(durations, n=100)[94] if len(durations) >= 100 else (max(durations) if durations else 0)
if line_stats["total_non_empty_lines"] > 0:
    summary["scorecard_parse_success"] = line_stats["parsed_json_lines"] / line_stats["total_non_empty_lines"]
else:
    summary["scorecard_parse_success"] = 1.0

for command, stats in command_stats.items():
    durations_list = stats["durations"]
    outcome_sum = (
        stats["ok"]
        + stats["failed"]
        + stats["cancelled"]
        + stats["aborted"]
        + stats["other"]
    )
    if stats["count"] != outcome_sum:
        raise SystemExit(
            f"scorecard-summary|fail|{command}: count {stats['count']} != "
            f"outcomes {outcome_sum}"
        )
    summary["commands"][command] = {
        "count": stats["count"],
        "ok": stats["ok"],
        "failed": stats["failed"],
        "cancelled": stats["cancelled"],
        "aborted": stats["aborted"],
        "other": stats["other"],
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
    f"- p50 duration: `{round_duration_ms(summary['p50_duration_ms'])}ms`",
    f"- p95 duration: `{round_duration_ms(summary['p95_duration_ms'])}ms`",
    f"- Source fingerprint: `{summary['source_fingerprint']}`",
    "",
    "## Status Counts",
    "",
]
for key, value in sorted(summary["status_counts"].items()):
    lines.append(f"- `{key}`: `{value}`")

lines.extend(["", "## Risk Counts", ""])
for key, value in sorted(summary["risk_counts"].items()):
    lines.append(f"- `{key}`: `{value}`")

lines.extend(["", "## Command Breakdown"])
if summary["commands"]:
    lines.append("")
for command, stats in sorted(summary["commands"].items()):
    lines.append(
        f"- `{command}`: count `{stats['count']}`, success `{stats['success_rate']:.2%}`, "
        f"p50 `{round_duration_ms(stats['p50_duration_ms'])}ms`"
    )

summary_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote:"
echo "  $SUMMARY_JSON"
echo "  $SUMMARY_MD"
