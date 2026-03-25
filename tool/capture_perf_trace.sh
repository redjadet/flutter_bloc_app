#!/usr/bin/env bash
set -euo pipefail

# Captures integration_test traceAction() output from iOS simulator runs and
# copies the generated integration response JSON into artifacts/perf/.
#
# Usage:
#   CHECKLIST_INTEGRATION_DEVICE=<udid> tool/capture_perf_trace.sh
#   CHECKLIST_INTEGRATION_DEVICE=<udid> tool/capture_perf_trace.sh integration_test/perf/perf_smoke_flows_test.dart

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TARGET="${1:-integration_test/perf/perf_smoke_flows_test.dart}"

mkdir -p artifacts/perf

DEVICE_ID="${CHECKLIST_INTEGRATION_DEVICE:-${INTEGRATION_TEST_DEVICE:-}}"
if [[ -z "$DEVICE_ID" ]]; then
  echo "[capture_perf_trace] CHECKLIST_INTEGRATION_DEVICE is required for stable comparisons." >&2
  echo "[capture_perf_trace] Example:" >&2
  echo "[capture_perf_trace]   CHECKLIST_INTEGRATION_DEVICE=<iphone_simulator_udid> $0" >&2
  exit 2
fi

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
LOG_PATH="artifacts/perf/flutter_test_${STAMP}.log"
OUT_JSON="artifacts/perf/perf_report_data_${STAMP}.json"

echo "[capture_perf_trace] Running on device: $DEVICE_ID"
echo "[capture_perf_trace] Target: $TARGET"
echo "[capture_perf_trace] Log: $LOG_PATH"

set +e
flutter test --no-pub -d "$DEVICE_ID" "$TARGET" 2>&1 | tee "$LOG_PATH"
EXIT_CODE="${PIPESTATUS[0]}"
set -e

if [[ "$EXIT_CODE" != "0" ]]; then
  echo "[capture_perf_trace] flutter test failed with exit code $EXIT_CODE" >&2
  exit "$EXIT_CODE"
fi

# Extract the last emitted PERF blob.
if ! rg -n "__PERF_REPORT_DATA__=" "$LOG_PATH" >/dev/null 2>&1; then
  echo "[capture_perf_trace] PERF marker not found in log: $LOG_PATH" >&2
  exit 3
fi

python3 - "$LOG_PATH" "$OUT_JSON" <<'PY'
import json
import sys

log_path = sys.argv[1]
out_path = sys.argv[2]
marker = "__PERF_REPORT_DATA__="

last = None
with open(log_path, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        if marker in line:
            payload = line.split(marker, 1)[1].strip()
            last = payload

if last is None:
    raise SystemExit(1)

data = json.loads(last)
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, sort_keys=True)
    f.write("\n")
print(out_path)
PY

echo "[capture_perf_trace] Saved: $OUT_JSON"

