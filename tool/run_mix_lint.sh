#!/usr/bin/env bash
# Run mix_lint via the native analyzer plugin (mix_lint 2.x / analysis_server_plugin).
# json_serializable 6.14+ requires analyzer >=10; custom_lint is no longer used for mix_lint.
# Run from project root: ./tool/run_mix_lint.sh
# See docs/mix_design_system_plan.md (mix_lint section).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/tool/resolve_flutter_dart.sh"

DART_BIN="$(resolve_flutter_dart)"

if [ "${SKIP_MIX_LINT:-0}" = "1" ] || [ "${CHECKLIST_RUN_MIX_LINT:-1}" = "0" ]; then
  echo "Skipping mix_lint (SKIP_MIX_LINT/CHECKLIST_RUN_MIX_LINT)."
  exit 0
fi

echo "Running mix_lint (analyzer plugin via dart analyze)..."
set +e
analyze_output="$("$DART_BIN" analyze --format machine . 2>&1)"
analyze_status=$?
set -e

plugin_errors="$(printf '%s\n' "$analyze_output" | grep -E 'An error occurred while executing an analyzer plugin|PLUGIN_ERROR' || true)"
if [ -n "$plugin_errors" ]; then
  echo "$plugin_errors"
  echo "❌ mix_lint analyzer plugin failed (see above)."
  exit 1
fi

mix_hits="$(printf '%s\n' "$analyze_output" | grep -E '\|mix_' | grep '/lib/' || true)"

if [ -n "$mix_hits" ]; then
  echo "$mix_hits"
  echo "❌ mix_lint reported issues (see lines above)."
  exit 1
fi

if [ "$analyze_status" -ne 0 ]; then
  echo "⚠️  dart analyze exited $analyze_status but no mix_lint diagnostics were found under lib/."
  echo "    Treating as mix_lint pass; fix other analyzer issues separately."
fi

echo "✅ mix_lint passed (no mix_* diagnostics under lib/)."
