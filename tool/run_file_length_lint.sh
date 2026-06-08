#!/usr/bin/env bash
# Run file_length_lint via the native analyzer plugin (analysis_server_plugin).
# Enforces file_too_long at error severity (see analysis_options.yaml plugins + file_length_lint:).
# Run from project root: ./tool/run_file_length_lint.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/tool/resolve_flutter_dart.sh"

DART_BIN="$(resolve_flutter_dart)"

if [ "${SKIP_FILE_LENGTH_LINT:-0}" = "1" ] || [ "${CHECKLIST_RUN_FILE_LENGTH_LINT:-1}" = "0" ]; then
  echo "Skipping file_length_lint (SKIP_FILE_LENGTH_LINT/CHECKLIST_RUN_FILE_LENGTH_LINT)."
  exit 0
fi

echo "Running file_length_lint (analyzer plugin via dart analyze)..."
set +e
analyze_output="$("$DART_BIN" analyze --format machine . 2>&1)"
analyze_status=$?
set -e

plugin_errors="$(printf '%s\n' "$analyze_output" | grep -E 'An error occurred while executing an analyzer plugin|PLUGIN_ERROR' || true)"
if [ -n "$plugin_errors" ]; then
  echo "$plugin_errors"
  echo "❌ file_length_lint analyzer plugin failed (see above)."
  exit 1
fi

# Machine format uses FILE_TOO_LONG (uppercase code id). Analyze package root (`.`);
# `dart analyze lib` alone does not run native plugins reliably.
length_hits="$(printf '%s\n' "$analyze_output" | grep -Ei '\|FILE_TOO_LONG\|' | grep '/lib/' || true)"

if [ -n "$length_hits" ]; then
  echo "$length_hits"
  echo "❌ file_length_lint reported file_too_long violations (see lines above)."
  exit 1
fi

if [ "$analyze_status" -ne 0 ]; then
  echo "⚠️  dart analyze exited $analyze_status but no file_too_long diagnostics were found under lib/."
  echo "    Treating as file_length_lint pass; fix other analyzer issues separately."
fi

echo "✅ file_length_lint passed (no file_too_long diagnostics under lib/)."
