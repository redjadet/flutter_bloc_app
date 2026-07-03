#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"

cd "$PROJECT_ROOT"

tmp_dir="${TMPDIR:-/tmp}"
min_kb=$((2 * 1024 * 1024)) # 2GB
avail_kb="$(df -Pk "$tmp_dir" | awk 'NR==2 {print $4}')"
if [[ "$avail_kb" =~ ^[0-9]+$ ]] && [ "$avail_kb" -lt "$min_kb" ]; then
  echo "[check_flutter_layout_overflows] Not enough free space in $tmp_dir to run tests."
  echo "[check_flutter_layout_overflows] Need at least ~2GB free. Current available KB=$avail_kb."
  echo "[check_flutter_layout_overflows] Free disk space, then re-run ./bin/checklist."
  exit 1
fi

echo "[check_flutter_layout_overflows] Running high-signal tests with overflow guard."

# Keep this check cheap: run only high-signal layout smoke suites.
# Global overflow guard lives in `test/flutter_test_config.dart`.
flutter test --no-pub -r compact \
  test/shared/widgets/common_status_view_layout_test.dart \
  test/integration_preflight/web_bootstrap_smoke_test.dart \
  test/features/calculator/presentation/pages/calculator_page_test.dart

