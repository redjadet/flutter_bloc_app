#!/usr/bin/env bash
# Check for InheritedWidget / provider reads inside initState().
# These reads are lifecycle-unsafe; move them to didChangeDependencies() or
# build() and gate one-time startup with a flag when needed.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for InheritedWidget/provider reads in initState()..."

IGNORED=""
source "$PROJECT_ROOT/tool/check_helpers.sh"

if command -v rg &> /dev/null; then
  FILES=$(rg -l "initState[[:space:]]*\(" lib/ 2>/dev/null \
    --glob "*.dart" \
    --glob "!*.g.dart" \
    --glob "!*.freezed.dart" \
    --glob "!*.gr.dart" \
    || true)
else
  FILES=$(grep -rl "initState(" lib/ 2>/dev/null \
    | grep "\.dart$" \
    | grep -v "\.g\.dart" \
    | grep -v "\.freezed\.dart" \
    | grep -v "\.gr\.dart" \
    || true)
fi

VIOLATIONS=""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  results=$(
    awk -v file="$file" '
      function update_brace_depth(text,   open_count, close_count, copy) {
        copy = text
        open_count = gsub(/\{/, "{", copy)
        copy = text
        close_count = gsub(/\}/, "}", copy)
        return open_count - close_count
      }

      BEGIN {
        in_init = 0
        brace_depth = 0
      }
      {
        line = $0
        stripped = line
        started_this_line = 0
        gsub(/\/\/.*$/, "", stripped)

        if (!in_init &&
            stripped ~ /initState[[:space:]]*\([[:space:]]*\)[[:space:]]*\{/) {
          in_init = 1
          brace_depth = update_brace_depth(stripped)
          started_this_line = 1
        }

        if (in_init) {
          has_inherited_read = \
            (stripped ~ /context\.l10n/ || \
             stripped ~ /Theme\.of[[:space:]]*\([^)]*context[^)]*\)/ || \
             stripped ~ /Localizations\.of[[:space:]]*\([^)]*context[^)]*\)/ || \
             stripped ~ /AppLocalizations\.of[[:space:]]*\([^)]*context[^)]*\)/ || \
             stripped ~ /context\.(bloc|cubit|read|watch|watchCubit|watchBloc|state|watchState|selectState|tryBloc|tryCubit)[[:space:]]*\(/ || \
             stripped ~ /BlocProvider\.of[[:space:]]*</ || \
             stripped ~ /context\.ensureSyncStartedIfAvailable[[:space:]]*\(/ || \
             stripped ~ /CubitHelpers\.(isCubitAvailable|getCurrentState|safeExecute|safeExecuteWithResult)[^;]*context/)

          if (has_inherited_read && line !~ /check-ignore/) {
            print file ":" NR ":" line
          }

          if (!started_this_line) {
            brace_depth += update_brace_depth(stripped)
          }
          if (brace_depth <= 0) {
            in_init = 0
            brace_depth = 0
          }
        }
      }
    ' "$file"
  )
  if [ -n "$results" ]; then
    VIOLATIONS+="${results}"$'\n'
  fi
done <<< "$FILES"

VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Do not read inherited values or bloc providers in initState()"
  echo "   Move startup that depends on context to didChangeDependencies()"
  echo "   and guard it with a one-shot flag when needed."
  echo ""
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ No inherited/provider reads found in initState()"
exit 0
