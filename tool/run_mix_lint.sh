#!/usr/bin/env bash
# Run mix_lint via custom_lint.
# The project uses a local fork at custom_lints/mix_lint so it can run with
# analyzer 8 and custom_lint 0.8 alongside other analyzer plugins.
# Run from project root: ./tool/run_mix_lint.sh
# See docs/mix_design_system_plan.md (mix_lint section).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

resolve_flutter_dart() {
  local flutter_bin
  local flutter_root
  local dart_bin

  flutter_bin="$(command -v flutter || true)"
  if [ -z "$flutter_bin" ]; then
    echo "❌ 'flutter' command not found in PATH." >&2
    exit 1
  fi

  flutter_root="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
  dart_bin="$flutter_root/bin/dart"

  if [ ! -x "$dart_bin" ]; then
    echo "❌ Flutter-managed Dart SDK not found at: $dart_bin" >&2
    exit 1
  fi

  echo "$dart_bin"
}

DART_BIN="$(resolve_flutter_dart)"
echo "Running custom_lint (includes local mix_lint rules)..."
"$DART_BIN" run custom_lint "$@"
