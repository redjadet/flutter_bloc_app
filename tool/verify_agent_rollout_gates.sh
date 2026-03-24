#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SUMMARY_JSON="$PROJECT_ROOT/analysis/agent_scorecard/summaries/scorecard-summary.json"
WEEKLY_JSON="$PROJECT_ROOT/analysis/agent_scorecard/summaries/scorecard-weekly-compare.json"

if [[ ! -f "$SUMMARY_JSON" ]]; then
  echo "Missing summary file: $SUMMARY_JSON" >&2
  exit 1
fi

python3 - "$SUMMARY_JSON" "$WEEKLY_JSON" <<'PY'
import json
import sys
from pathlib import Path

summary = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
weekly_path = Path(sys.argv[2])
weekly = json.loads(weekly_path.read_text(encoding="utf-8")) if weekly_path.exists() else None

total = int(summary.get("total_events", 0))
parse_success = float(summary.get("scorecard_parse_success", 0.0))

print("Rollout gate check:")
print(f"- total_events: {total}")
print(f"- scorecard_parse_success: {parse_success:.3f}")

if total < 50:
    print("- gate_note: insufficient baseline sample for full rollout decision (need >=50 events)")
else:
    print("- gate_note: baseline volume is sufficient for gate evaluation")

if parse_success < 0.99:
    raise SystemExit("Gate fail: scorecard_parse_success < 0.99")

if weekly:
    delta = weekly.get("delta", {})
    print(f"- weekly_delta_success_rate: {float(delta.get('success_rate', 0.0)):+.4f}")
    print(f"- weekly_delta_p50_duration_ms: {int(delta.get('p50_duration_ms', 0)):+d}")

print("Gate script completed.")
PY
