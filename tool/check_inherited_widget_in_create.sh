#!/usr/bin/env bash
# Check for InheritedWidget reads (context.l10n, Theme.of(context)) inside
# BlocProvider/Provider create callbacks.
# Such usage throws "Tried to listen to an InheritedWidget in a life-cycle
# that will never be called again." Read l10n/theme in build() and pass in.
# See AGENTS.md "InheritedWidget in one-time lifecycles".

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for InheritedWidget usage in BlocProvider/Provider create..."

IGNORED=""
source "$PROJECT_ROOT/tool/check_helpers.sh"

# Find Dart files in lib that might contain provider create callbacks.
if command -v rg &> /dev/null; then
  FILES=$(rg -l "(BlocProvider|Provider)\s*\(|create:[[:space:]]*" lib/ 2>/dev/null \
    --glob "*.dart" \
    --glob "!*.g.dart" \
    --glob "!*.freezed.dart" \
    --glob "!*.gr.dart" \
    || true)
else
  FILES=$(grep -rl "create:" lib/ 2>/dev/null \
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
      BEGIN { in_create=0; create_start=0 }
      {
        line=$0
        stripped = line
        gsub(/\/\/.*$/, "", stripped)
        if (!in_create && stripped ~ /(^|[[:space:]])create:[[:space:]]*/) {
          in_create=1
          create_start=NR
        }
        if (in_create && NR >= create_start && NR <= create_start + 20) {
          has_inherited_read = \
            (stripped ~ /context\.l10n/ || \
            stripped ~ /Theme\.of[[:space:]]*\([^)]*context[^)]*\)/ || \
            stripped ~ /Localizations\.of[[:space:]]*\([^)]*context[^)]*\)/ || \
            stripped ~ /AppLocalizations\.of[[:space:]]*\([^)]*context[^)]*\)/)
          if (has_inherited_read) {
            if (line !~ /check-ignore/) {
              print file ":" NR ":" line
            }
          }
        }
        create_callback_closed = \
          (in_create && NR > create_start && \
          (stripped ~ /child:[[:space:]]*/ || \
          stripped ~ /^[[:space:]]*[)}][[:space:]]*,?[[:space:]]*$/))
        if (create_callback_closed) {
          in_create=0
        }
        if (in_create && NR > create_start + 20) in_create=0
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
  echo "❌ Do not use context.l10n or theme/localization reads in Provider create"
  echo "   Read l10n in build() and pass into create, e.g. create: (_) => MyCubit(l10n: l10n)"
  echo ""
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ No InheritedWidget reads in create callbacks"
exit 0
