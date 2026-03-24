#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASELINE_JSON="$PROJECT_ROOT/analysis/agent_scorecard/summaries/integration-baseline.json"

MAX_FLAKE_RATE="${MAX_FLAKE_RATE:-0.20}"
MIN_SUCCESS_RATE="${MIN_SUCCESS_RATE:-0.90}"
MAX_UNCATEGORIZED_FAILURES="${MAX_UNCATEGORIZED_FAILURES:-0}"

if [ ! -f "$BASELINE_JSON" ]; then
  echo "Missing baseline file: $BASELINE_JSON" >&2
  echo "Run: bash tool/build_integration_baseline.sh 14" >&2
  exit 1
fi

/usr/bin/python3 - "$BASELINE_JSON" "$MAX_FLAKE_RATE" "$MIN_SUCCESS_RATE" "$MAX_UNCATEGORIZED_FAILURES" <<'PY'
import json
import sys

baseline_path = sys.argv[1]
max_flake_rate = float(sys.argv[2])
min_success_rate = float(sys.argv[3])
max_uncategorized = int(sys.argv[4])

with open(baseline_path, "r", encoding="utf-8") as f:
    data = json.load(f)

flake = float(data.get("flake_rerun_rate", 1.0))
success = float(data.get("success_rate", 0.0))
uncat = int(data.get("uncategorized_failure_count", 999999))

print("Integration rollout threshold check")
print(f"- success_rate: {success:.2%} (required >= {min_success_rate:.2%})")
print(f"- flake_rerun_rate: {flake:.2%} (required <= {max_flake_rate:.2%})")
print(f"- uncategorized_failure_count: {uncat} (required <= {max_uncategorized})")

errors = []
if success < min_success_rate:
    errors.append("success rate below threshold")
if flake > max_flake_rate:
    errors.append("flake rerun rate above threshold")
if uncat > max_uncategorized:
    errors.append("uncategorized failure count above threshold")

if errors:
    print("FAIL: " + "; ".join(errors))
    sys.exit(1)

print("PASS: rollout threshold criteria met")
PY
