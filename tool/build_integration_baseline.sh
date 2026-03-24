#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCORECARD_FILE="$PROJECT_ROOT/analysis/agent_scorecard/scorecard-events.jsonl"
OUT_DIR="$PROJECT_ROOT/analysis/agent_scorecard/summaries"
OUT_JSON="$OUT_DIR/integration-baseline.json"
OUT_MD="$OUT_DIR/integration-baseline.md"
DAYS="${1:-14}"

mkdir -p "$OUT_DIR"

python3 - "$SCORECARD_FILE" "$OUT_JSON" "$OUT_MD" "$DAYS" <<'PY'
import json
import statistics
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

scorecard_file = Path(sys.argv[1])
out_json = Path(sys.argv[2])
out_md = Path(sys.argv[3])
days = int(sys.argv[4])

window_start = datetime.now(timezone.utc) - timedelta(days=days)
events = []
if scorecard_file.exists():
    for line in scorecard_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        if ev.get("command") != "integration_tests":
            continue
        try:
            started_at = datetime.fromisoformat(ev["started_at"].replace("Z", "+00:00"))
        except Exception:
            continue
        if started_at < window_start:
            continue
        events.append(ev)

total = len(events)
ok = sum(1 for e in events if e.get("status") == "ok")
durations = [int(e.get("duration_ms", 0)) for e in events]
integration_failures = [e for e in events if e.get("integration_pass") is False]
retry_attempts = [e for e in events if int(e.get("attempt", 1)) > 1]

result = {
    "window_days": days,
    "total_integration_runs": total,
    "success_rate": (ok / total) if total else 0.0,
    "median_duration_ms": statistics.median(durations) if durations else 0,
    "p95_duration_ms": statistics.quantiles(durations, n=100)[94] if len(durations) >= 100 else (max(durations) if durations else 0),
    "flake_rerun_rate": (len(retry_attempts) / total) if total else 0.0,
    "uncategorized_failure_count": len(integration_failures),
}

out_json.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")

lines = [
    "# Integration Baseline",
    "",
    f"- Window: last `{days}` days",
    f"- Total integration runs: `{result['total_integration_runs']}`",
    f"- Success rate: `{result['success_rate']:.2%}`",
    f"- Median duration: `{int(result['median_duration_ms'])}ms`",
    f"- p95 duration: `{int(result['p95_duration_ms'])}ms`",
    f"- Flake rerun rate: `{result['flake_rerun_rate']:.2%}`",
    f"- Uncategorized integration failures: `{result['uncategorized_failure_count']}`",
]
out_md.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote:"
echo "  $OUT_JSON"
echo "  $OUT_MD"
