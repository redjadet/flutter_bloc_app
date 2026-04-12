#!/bin/bash
# Wrapper script to run flutter test with coverage and automatically update coverage reports
# This ensures coverage reports are always up-to-date after running tests
#
# Usage: tool/test_coverage.sh [additional flutter test arguments]
# Example: tool/test_coverage.sh test/features/counter/
#
# This script:
# 1. Runs `flutter test --coverage` with any provided arguments
#    - When called without arguments (e.g., from ./bin/checklist), runs ALL tests including:
#      - Unit tests, bloc tests, widget tests, golden tests
#      - Common bugs prevention tests (test/shared/common_bugs_prevention_test.dart)
#    - A full run also saves reusable baseline coverage to `coverage/lcov.base.info`
# 2. Automatically runs `dart run tool/update_coverage_summary.dart` to update coverage reports
# 3. Updates coverage/coverage_summary.md and ALL documentation files with latest coverage percentage:
#    - README.md (badge URL and text mentions)
#    - docs/testing_overview.md
#    - docs/CODE_QUALITY.md
#    - docs/feature_overview.md

set -e

# Pixel goldens are stable on macOS (where baselines are updated) but diverge on
# Linux CI due to font/Skia differences. Exclude them on Linux; the workflow
# runs `flutter test --tags golden` on macOS.
golden_exclude_for_linux=""
if [[ "$(uname -s)" == "Linux" ]]; then
  golden_exclude_for_linux=",golden"
fi

detect_cpu_count() {
  local cpu_count

  if command -v getconf >/dev/null 2>&1; then
    cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)"
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
      echo "$cpu_count"
      return
    fi
  fi

  if command -v sysctl >/dev/null 2>&1; then
    cpu_count="$(sysctl -n hw.ncpu 2>/dev/null || true)"
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
      echo "$cpu_count"
      return
    fi
  fi

  if command -v nproc >/dev/null 2>&1; then
    cpu_count="$(nproc 2>/dev/null || true)"
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
      echo "$cpu_count"
      return
    fi
  fi

  echo 4
}

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/resolve_flutter_dart.sh"

DART_BIN="$(resolve_flutter_dart)"
DEFAULT_COVERAGE_JOBS="$(detect_cpu_count)"
if [ "$DEFAULT_COVERAGE_JOBS" -gt 8 ]; then
  DEFAULT_COVERAGE_JOBS=8
fi
if [ "$DEFAULT_COVERAGE_JOBS" -lt 2 ]; then
  DEFAULT_COVERAGE_JOBS=2
fi

COVERAGE_JOBS="${COVERAGE_JOBS:-$DEFAULT_COVERAGE_JOBS}"
if ! [[ "$COVERAGE_JOBS" =~ ^[0-9]+$ ]] || [ "$COVERAGE_JOBS" -lt 1 ]; then
  echo "⚠️  Invalid COVERAGE_JOBS='$COVERAGE_JOBS'; using $DEFAULT_COVERAGE_JOBS"
  COVERAGE_JOBS="$DEFAULT_COVERAGE_JOBS"
fi

BASE_COVERAGE_PATH="coverage/lcov.base.info"
FINAL_COVERAGE_PATH="coverage/lcov.info"

echo "Running flutter test with coverage (concurrency=$COVERAGE_JOBS)..."
if [ "$#" -eq 0 ]; then
  flutter test \
    --no-pub \
    --coverage \
    --coverage-path="$BASE_COVERAGE_PATH" \
    --concurrency="$COVERAGE_JOBS" \
    --exclude-tags "skip-checklist${golden_exclude_for_linux}"
  cp "$BASE_COVERAGE_PATH" "$FINAL_COVERAGE_PATH"
else
  flutter test \
    --no-pub \
    --coverage \
    --coverage-path="$FINAL_COVERAGE_PATH" \
    --concurrency="$COVERAGE_JOBS" \
    "$@"
fi

echo ""
echo "Updating coverage summary..."
"$DART_BIN" run tool/update_coverage_summary.dart

echo ""
echo "✅ Test coverage complete! Reports updated in coverage/"
