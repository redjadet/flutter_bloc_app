#!/bin/bash
# Wrapper script to run flutter analyze from the app package root.
# mix_lint + file_length_lint run via native analyzer plugins (see analysis_options.yaml).
# Invoke from workspace root: bash tool/analyze.sh [--no-pub]

set -e

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"

analyze_failed=0

echo "Running flutter analyze..."
if ! (cd "$APP_ROOT" && flutter analyze "$@"); then
  analyze_failed=1
fi

echo ""
plugin_failed=0
if ! CHECKLIST_RUN_MIX_LINT=1 bash "$TOOL_DIR/run_mix_lint.sh"; then
  plugin_failed=1
fi
if ! CHECKLIST_RUN_FILE_LENGTH_LINT=1 bash "$TOOL_DIR/run_file_length_lint.sh"; then
  plugin_failed=1
fi

if [ "$analyze_failed" -ne 0 ] || [ "$plugin_failed" -ne 0 ]; then
  exit 1
fi

echo "✅ Analysis + mix_lint + file_length_lint complete!"
