#!/bin/bash
# Focused UI regression lane (cheap widget tests).
# Used by ./bin/checklist (tool/delivery_checklist.sh CHECK_SCRIPTS).
#
# Env:
#   CHECK_UI_REGRESSION_MODE=auto|0|1
#
# auto: run only when local change set touches UI sizing/layout surfaces.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

MODE="${CHECK_UI_REGRESSION_MODE:-auto}"

case "$MODE" in
  0)
    echo "check_ui_regressions: skipped (CHECK_UI_REGRESSION_MODE=0)"
    exit 0
    ;;
  1|auto)
    ;;
  *)
    echo "ERROR: Invalid CHECK_UI_REGRESSION_MODE='$MODE' (expected auto, 0, or 1)." >&2
    exit 2
    ;;
esac

should_run=1
if [ "$MODE" = "auto" ]; then
  should_run=0

  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    changed="$(
      {
        git diff --name-only --diff-filter=ACMRTUXB
        git diff --cached --name-only --diff-filter=ACMRTUXB
        git ls-files --others --exclude-standard
      } | sort -u
    )"
  else
    changed=""
    should_run=1
  fi

  if [ -n "${changed:-}" ]; then
    while IFS= read -r file; do
      [ -z "$file" ] && continue
      case "$file" in
        lib/shared/ui/*|\
        lib/shared/extensions/responsive/*|\
        lib/shared/extensions/responsive.dart|\
        lib/shared/widgets/*|\
        lib/features/settings/presentation/widgets/*|\
        test/features/settings/presentation/widgets/*)
          should_run=1
          break
          ;;
      esac
    done <<<"$changed"
  fi
fi

if [ "$should_run" != "1" ]; then
  echo "check_ui_regressions: no relevant changes; skipping"
  exit 0
fi

echo "🧩 UI regression lane (focused widget tests)..."

flutter test \
  test/features/settings/presentation/widgets/integrations_section_test.dart

echo "✅ UI regression lane passed"
