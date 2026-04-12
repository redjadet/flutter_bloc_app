#!/usr/bin/env bash
# Runs Python heuristic: local `final|var x = TextEditingController(` inside async blocks
# in files that use showDialog/showAdaptiveDialog — dispose timing hazard.
# See tool/check_dialog_text_controller_lifecycle.py

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

exec python3 "$PROJECT_ROOT/tool/check_dialog_text_controller_lifecycle.py"
