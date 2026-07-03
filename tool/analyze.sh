#!/bin/bash
# Wrapper script to run flutter analyze
# mix_lint + file_length_lint run via native analyzer plugins (see analysis_options.yaml).

set -e

SCRIPT_DIR="$(dirname "$0")"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/workspace_paths.sh"
cd "$APP_ROOT"
analyze_failed=0

echo "Running flutter analyze..."
if ! flutter analyze "$@"; then
  analyze_failed=1
fi

echo ""
plugin_failed=0
if ! CHECKLIST_RUN_MIX_LINT=1 bash "$SCRIPT_DIR/run_mix_lint.sh"; then
  plugin_failed=1
fi
if ! CHECKLIST_RUN_FILE_LENGTH_LINT=1 bash "$SCRIPT_DIR/run_file_length_lint.sh"; then
  plugin_failed=1
fi

if [ "$analyze_failed" -ne 0 ] || [ "$plugin_failed" -ne 0 ]; then
  exit 1
fi

echo "✅ Analysis + mix_lint + file_length_lint complete!"


