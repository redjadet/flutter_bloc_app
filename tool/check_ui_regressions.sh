#!/bin/bash
# Focused UI regression lane (cheap widget tests).
# Used by ./bin/checklist (tool/delivery_checklist.sh CHECK_SCRIPTS).
#
# Env:
#   CHECK_UI_REGRESSION_MODE=auto|0|1
#
# auto: run only when local change set touches UI sizing/layout surfaces.

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
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
        lib/features/profile/presentation/*|\
        lib/features/settings/presentation/*|\
        lib/features/*/presentation/widgets/*|\
        lib/features/*/presentation/helpers/*dialog*|\
        lib/features/*/*dialog*.dart|\
        lib/features/*/presentation/forms/*|\
        lib/features/*/*actions_bar*.dart|\
        lib/features/*/*action_bar*.dart|\
        lib/shared/widgets/common_form_field.dart|\
        test/features/settings/presentation/widgets/*|\
        test/shared/widgets/action_bar_layout_regression_test.dart|\
        test/features/staff_app_demo/presentation/widgets/*|\
        tool/check_row_action_overflow.sh|\
        tool/check_action_bar_layout.sh)
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

run_ui_regressions() {
  flutter test test/features/settings/presentation/widgets/integrations_section_test.dart
  flutter test test/shared/widgets/action_bar_layout_regression_test.dart
  flutter test test/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section_layout_test.dart
}

rm -rf build/unit_test_assets

if ! run_ui_regressions 2> >(tee /tmp/check_ui_regressions.stderr >&2); then
  if grep -Eq "build/unit_test_assets|NativeAssetsManifest\\.json|build/native_assets/macos/native_assets\\.json" /tmp/check_ui_regressions.stderr; then
    echo "check_ui_regressions: flutter unit_test_assets/native-assets failed; cleaning build assets and retrying once"
    rm -rf build/unit_test_assets build/native_assets
    run_ui_regressions
  else
    exit 1
  fi
fi

echo "✅ UI regression lane passed"
