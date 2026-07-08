#!/usr/bin/env bash
# Check for Row + multiple action buttons without OverflowBar, Wrap, or Expanded/Flexible.
# Use OverflowBar for intrinsic-width action groups; Wrap for many chips; Expanded for equal split CTAs.

set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

SCOPE="${CHECK_ROW_ACTION_OVERFLOW_SCOPE:-primary}"
MODE="${CHECK_ROW_ACTION_OVERFLOW_MODE:-fail}"
ALSO_ALL="${CHECK_ROW_ACTION_OVERFLOW_ALSO_ALL:-1}"

echo "🔍 Checking for Row+multi-button action overflow risk (OverflowBar, Wrap, or Expanded)..."

IGNORED=""

source "$TOOL_DIR/check_helpers.sh"

collect_primary_scope_files() {
  {
    find lib/features/profile/presentation -name '*.dart' 2>/dev/null || true
    find lib/features/settings/presentation -name '*.dart' 2>/dev/null || true
    find lib/features -path '*/presentation/widgets/*.dart' 2>/dev/null || true
    find lib/features -path '*/presentation/widgets/*dialog*.dart' 2>/dev/null || true
    find lib/features -name '*dialog*.dart' 2>/dev/null || true
    find lib/features -path '*/presentation/forms/*.dart' 2>/dev/null || true
    find lib/features -name '*actions_bar*.dart' 2>/dev/null || true
    find lib/features -name '*action_bar*.dart' 2>/dev/null || true
    printf '%s\n' "$WORKSPACE_ROOT/packages/design_system/lib/src/widgets/common_form_field.dart"
    printf '%s\n' "$WORKSPACE_ROOT/packages/design_system/lib/src/widgets/responsive_action_bar.dart"
    printf '%s\n' lib/features/staff_app_demo/presentation/pages/staff_app_demo_forms_page.dart
  } | grep -vE '\.(g|freezed|gr)\.dart$' | sort -u
}

collect_all_lib_files() {
  if command -v rg &> /dev/null; then
    rg --files -g '*.dart' lib 2>/dev/null \
      | grep -vE '\.(g|freezed|gr)\.dart$' \
      | sort -u
  else
    find lib -name '*.dart' 2>/dev/null \
      | grep -vE '\.(g|freezed|gr)\.dart$' \
      | sort -u
  fi
}

collect_candidate_files() {
  local scope_name="$1"
  local scope_files
  if [ "$scope_name" = "all" ]; then
    scope_files=$(collect_all_lib_files)
  else
    scope_files=$(collect_primary_scope_files)
  fi

  if command -v rg &> /dev/null; then
    printf '%s' "$scope_files" \
      | while IFS= read -r file; do
          [ -z "$file" ] && continue
          [ -f "$file" ] || continue
          if rg -q 'Row\(' "$file" 2>/dev/null \
            && rg -q '(OutlinedButton|FilledButton|ElevatedButton|TextButton|CupertinoButton|PlatformAdaptive\.(filledButton|outlinedButton|textButton))' "$file" 2>/dev/null; then
            echo "$file"
          fi
        done
  else
    printf '%s' "$scope_files" \
      | while IFS= read -r file; do
          [ -z "$file" ] && continue
          [ -f "$file" ] || continue
          if grep -q 'Row(' "$file" \
            && grep -qE '(OutlinedButton|FilledButton|ElevatedButton|TextButton|CupertinoButton|PlatformAdaptive\.(filledButton|outlinedButton|textButton))' "$file"; then
            echo "$file"
          fi
        done
  fi
}

scan_file_for_violations() {
  local file="$1"
  awk -v file="$file" '
    BEGIN {
      row_line = 0
      in_block = 0
      block_end = 0
      btn_count = 0
      has_mitigation = 0
    }
    {
      line = $0
      if (line ~ /(^|[^a-zA-Z0-9_])Row[[:space:]]*\(/) {
        if (in_block && btn_count >= 2 && !has_mitigation) {
          print file ":" row_line ": Row with multiple buttons without OverflowBar, Wrap, or Expanded/Flexible"
        }
        row_line = NR
        in_block = 1
        block_end = NR + 80
        btn_count = 0
        has_mitigation = 0
      }
      if (in_block && NR <= block_end) {
        if (line ~ /(Outlined|Filled|Elevated|Text|Cupertino)Button[[:space:]]*\(/)
          btn_count++
        if (line ~ /PlatformAdaptive\.(filledButton|outlinedButton|textButton)[[:space:]]*\(/)
          btn_count++
        if (line ~ /OverflowBar[[:space:]]*\(/ \
            || line ~ /ResponsiveActionOverflowBar[[:space:]]*\(/ \
            || line ~ /ResponsiveDualCtaRow[[:space:]]*\(/ \
            || line ~ /Wrap[[:space:]]*\(/ \
            || line ~ /Expanded[[:space:]]*\(/ \
            || line ~ /Flexible[[:space:]]*\(/)
          has_mitigation = 1
        if (NR == block_end) {
          if (btn_count >= 2 && !has_mitigation) {
            print file ":" row_line ": Row with multiple buttons without OverflowBar, Wrap, or Expanded/Flexible"
          }
          in_block = 0
        }
      }
    }
    END {
      if (in_block && btn_count >= 2 && !has_mitigation) {
        print file ":" row_line ": Row with multiple buttons without OverflowBar, Wrap, or Expanded/Flexible"
      }
    }
  ' "$file"
}

run_scope_scan() {
  local scope_name="$1"
  echo ""
  echo "── scope=$scope_name ──"
  local candidates
  candidates=$(collect_candidate_files "$scope_name")

  local violations=""
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    local results
    results=$(scan_file_for_violations "$file")
    if [ -n "$results" ]; then
      violations+="${results}"$'\n'
    fi
  done <<< "$candidates"

  violations=$(echo "$violations" | sort -u)
  violations=$(filter_ignored "$violations")

  if [ -n "${IGNORED:-}" ]; then
    echo "ℹ️  Ignored (check-ignore):"
    echo "$IGNORED"
  fi

  if [ -n "$violations" ]; then
    echo "❌ Row+multi-button action overflow risk (scope=$scope_name)"
    echo "   See: docs/design_system.md (action layout decision tree)"
    echo ""
    echo "$violations"
    return 1
  fi

  echo "✅ No Row+multi-button action overflow risk found (scope=$scope_name)"
  return 0
}

if ! run_scope_scan primary; then
  if [ "$MODE" = "warn" ]; then
    echo ""
    echo "⚠️  CHECK_ROW_ACTION_OVERFLOW_MODE=warn — exiting 0"
    exit 0
  fi
  exit 1
fi

if [ "$ALSO_ALL" = "1" ]; then
  if ! run_scope_scan all; then
    if [ "$MODE" = "warn" ]; then
      echo ""
      echo "⚠️  CHECK_ROW_ACTION_OVERFLOW_MODE=warn — exiting 0"
      exit 0
    fi
    exit 1
  fi
fi

if [ -f "$TOOL_DIR/check_row_action_overflow_fixtures.sh" ]; then
  bash "$TOOL_DIR/check_row_action_overflow_fixtures.sh"
fi

exit 0
