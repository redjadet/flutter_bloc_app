#!/usr/bin/env bash
# Run mix_lint via custom_lint.
# The project uses a local fork at custom_lints/mix_lint so it can run with
# analyzer 8 and custom_lint 0.8 alongside other analyzer plugins.
# Run from project root: ./tool/run_mix_lint.sh
# See docs/mix_design_system_plan.md (mix_lint section).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
echo "Running custom_lint (includes local mix_lint rules)..."
dart run custom_lint "$@"
