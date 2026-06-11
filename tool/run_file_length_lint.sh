#!/usr/bin/env bash
# Enforce file_too_long using physical line counts (mirrors file_length_lint plugin config).
# Avoids dart analyze on `.` which can hang/crash with native plugins in CI.
# Regression: python3 tool/run_file_length_lint_test.py
# Run from project root: ./tool/run_file_length_lint.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ "${SKIP_FILE_LENGTH_LINT:-0}" = "1" ] || [ "${CHECKLIST_RUN_FILE_LENGTH_LINT:-1}" = "0" ]; then
  echo "Skipping file_length_lint (SKIP_FILE_LENGTH_LINT/CHECKLIST_RUN_FILE_LENGTH_LINT)."
  exit 0
fi

echo "Running file_length_lint (physical line count via analysis_options.yaml)..."
exec python3 "$ROOT/tool/check_file_length_physical.py"
