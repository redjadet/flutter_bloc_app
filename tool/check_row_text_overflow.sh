#!/usr/bin/env bash
# Check for Row + Icon + Text without Flexible/Expanded/IconLabelRow (RenderFlex overflow risk).
# Use IconLabelRow or wrap Text in Flexible/Expanded for icon+label rows.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for Row+Icon+Text overflow risk (use IconLabelRow or Flexible/Expanded)..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Find Dart files in lib that contain Row( and Icon( and Text( (exclude generated)
if command -v rg &> /dev/null; then
  CANDIDATES=$(rg -l "Row\(" lib 2>/dev/null \
    --glob "*.dart" \
    --glob "!**/*.g.dart" \
    --glob "!**/*.freezed.dart" \
    --glob "!**/*.gr.dart" \
    | xargs -I{} sh -c 'rg -q "Icon\(" "{}" && rg -q "Text\(" "{}" && echo "{}"' 2>/dev/null || true)
else
  CANDIDATES=$(grep -rl "Row(" lib 2>/dev/null \
    | grep "\.dart$" \
    | grep -v "\.g\.dart" \
    | grep -v "\.freezed\.dart" \
    | grep -v "\.gr\.dart" \
    | while read -r f; do
        grep -q "Icon(" "$f" && grep -q "Text(" "$f" && echo "$f"
      done || true)
fi

VIOLATIONS=""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  case "$file" in
    */icon_label_row.dart) continue ;;
  esac
  results=$(
    awk -v file="$file" '
      BEGIN { row_line=0; in_block=0; block_end=0; has_icon=0; has_text=0; has_flex=0; has_expanded=0; has_icon_label=0 }
      {
        line = $0
        if (line ~ /Row\s*\(/) {
          row_line = NR
          in_block = 1
          block_end = NR + 55
          has_icon = 0
          has_text = 0
          has_flex = 0
          has_expanded = 0
          has_icon_label = 0
        }
        if (in_block && NR <= block_end) {
          if (line ~ /Icon\s*\(/) has_icon = 1
          if (line ~ /Text\s*\(/) has_text = 1
          if (line ~ /Flexible\s*\(/) has_flex = 1
          if (line ~ /Expanded\s*\(/) has_expanded = 1
          if (line ~ /IconLabelRow\s*\(/) has_icon_label = 1
          if (NR == block_end) {
            if (has_icon && has_text && !has_flex && !has_expanded && !has_icon_label) {
              print file ":" row_line ": Row with Icon and Text without Flexible/Expanded/IconLabelRow"
            }
            in_block = 0
          }
        }
      }
      END {
        if (in_block && has_icon && has_text && !has_flex && !has_expanded && !has_icon_label) {
          print file ":" row_line ": Row with Icon and Text without Flexible/Expanded/IconLabelRow"
        }
      }
    ' "$file"
  )
  if [ -n "$results" ]; then
    VIOLATIONS+="${results}"$'\n'
  fi
done <<< "$CANDIDATES"

VIOLATIONS=$(echo "$VIOLATIONS" | sort -u)
VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Row+Icon+Text overflow risk: use IconLabelRow or wrap Text in Flexible/Expanded"
  echo "   See: lib/shared/widgets/icon_label_row.dart"
  echo ""
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No Row+Icon+Text overflow risk found"
  exit 0
fi
