#!/usr/bin/env bash
# Run mix_lint via the native analyzer plugin (mix_lint 2.x / analysis_server_plugin).
# Uses lib-scoped dart analyze (not `.`) to avoid analysis-server hangs/crashes.
# Run from project root: ./tool/run_mix_lint.sh
# See docs/design_system.md (mix_lint section).
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
ROOT="$APP_ROOT"
cd "$ROOT"

# shellcheck disable=SC1091
source "$WORKSPACE_ROOT/tool/analyzer_plugin_lint_common.sh"

if [ "${SKIP_MIX_LINT:-0}" = "1" ] || [ "${CHECKLIST_RUN_MIX_LINT:-1}" = "0" ]; then
  echo "Skipping mix_lint (SKIP_MIX_LINT/CHECKLIST_RUN_MIX_LINT)."
  exit 0
fi

set +e
run_analyzer_plugin_machine_analysis lib mix_lint
analyze_status=$?
set -e

if [ "$analyze_status" -eq 124 ]; then
  exit 1
fi

analyze_output="$(cat "${ANALYZER_PLUGIN_MACHINE_OUTPUT}")"

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
  if analyzer_plugin_is_crash_output "$analyze_output"; then
    echo "❌ mix_lint failed: analysis server crashed."
    exit 1
  fi
  echo "⚠️  dart analyze exited $analyze_status but no mix_lint diagnostics were found under lib/."
  echo "    Treating as mix_lint pass; fix other analyzer issues separately."
fi

echo "✅ mix_lint passed (no mix_* diagnostics under lib/)."
