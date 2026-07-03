#!/usr/bin/env bash
# Runs Python heuristic: local `final|var x = TextEditingController(` inside async blocks
# in files that use showDialog/showAdaptiveDialog — dispose timing hazard.
# See tool/check_dialog_text_controller_lifecycle.py

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

exec python3 "$WORKSPACE_ROOT/tool/check_dialog_text_controller_lifecycle.py"
