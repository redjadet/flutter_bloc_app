#!/usr/bin/env bash
# Self-test for tool/check_row_action_overflow.sh awk heuristics.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

source "$PROJECT_ROOT/tool/check_helpers.sh"

scan_file() {
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

BAD_FILE="tool/fixtures/action_row/bad_row_two_buttons.dart"
GOOD_FILE="tool/fixtures/action_row/good_overflow_bar.dart"
GOOD_DUAL_FILE="tool/fixtures/action_row/good_dual_cta_responsive.dart"

bad_out=$(scan_file "$BAD_FILE" || true)
if [ -z "$bad_out" ]; then
  echo "❌ Fixture failed: expected violation for $BAD_FILE"
  exit 1
fi

good_out=$(scan_file "$GOOD_FILE" || true)
if [ -n "$good_out" ]; then
  echo "❌ Fixture failed: expected no violation for $GOOD_FILE"
  echo "$good_out"
  exit 1
fi

good_dual_out=$(scan_file "$GOOD_DUAL_FILE" || true)
if [ -n "$good_dual_out" ]; then
  echo "❌ Fixture failed: expected no violation for $GOOD_DUAL_FILE"
  echo "$good_dual_out"
  exit 1
fi

echo "✅ Row action overflow fixtures passed"
