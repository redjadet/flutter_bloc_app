#!/usr/bin/env bash
# Check for lifecycle and error-handling patterns that can cause bugs:
# 1. Direct ScaffoldMessenger.hideCurrentSnackBar/clearSnackBars instead of ErrorHandling
# 2. stream.listen() without onError (heuristic)
# 3. After await show*Dialog, using cubit/context/onClose without context.mounted check

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

LIB_DIRS="lib/features lib/shared lib/app"
source "$PROJECT_ROOT/tool/check_helpers.sh"

FAILED=0

# 1. Snackbar: require ErrorHandling
echo "🔍 Checking for direct ScaffoldMessenger snackbar usage (use ErrorHandling)..."
SNACKBAR_VIOLATIONS=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  file="${line%%:*}"
  rest="${line#*:}"
  lineno="${rest%%:*}"
  content="${rest#*:}"
  [[ "$file" == *"error_handling.dart" ]] && continue
  if [[ "$content" != *"ErrorHandling.hideCurrentSnackBar"* ]] && \
     [[ "$content" != *"ErrorHandling.clearSnackBars"* ]]; then
    SNACKBAR_VIOLATIONS+="${file}:${lineno}:${content}"$'\n'
  fi
done < <(rg -n "\.(hideCurrentSnackBar|clearSnackBars)\s*\(" $LIB_DIRS 2>/dev/null --glob '!**/*.g.dart' --glob '!**/*.freezed.dart' --glob '!**/*.gr.dart' || true)

SNACKBAR_VIOLATIONS=$(filter_ignored "$SNACKBAR_VIOLATIONS")
if [ -n "$SNACKBAR_VIOLATIONS" ]; then
  echo "❌ Use ErrorHandling.hideCurrentSnackBar(context) / ErrorHandling.clearSnackBars(context)"
  echo "$SNACKBAR_VIOLATIONS"
  FAILED=1
else
  echo "✅ No direct snackbar usage (ErrorHandling used)"
fi
echo ""
# 2. stream.listen( without onError
echo "🔍 Checking for stream.listen() without onError..."
LISTEN_VIOLATIONS=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  [[ "$file" == *"cubit_subscription_mixin.dart" ]] && continue
  [[ "$file" == *"subscription_manager.dart" ]] && continue
  result=$(awk -v file="$file" '
    BEGIN { listen_line=0; seen_onError=0; paren=0 }
    {
      line=$0
      if (line ~ /\.listen[[:space:]]*\(/) {
        listen_line=NR
        seen_onError = (line ~ /onError[[:space:]]*:/)
        paren=0
        paren = gsub(/\(/, "&", line) - gsub(/\)/, "&", line)
        next
      }
      if (listen_line>0 && NR<=listen_line+25) {
        if (line ~ /onError[[:space:]]*:/) seen_onError=1
        n=split(line, a, ""); for (i=1;i<=n;i++) { if (a[i]=="(") paren++; if (a[i]==")") paren-- }
        if (paren<=0 && listen_line>0) {
          if (!seen_onError && line !~ /check-ignore/) print file ":" listen_line ": .listen( without onError"
          listen_line=0
          seen_onError=0
        }
      }
    }
  ' "$file" 2>/dev/null) || true
  [ -n "$result" ] && LISTEN_VIOLATIONS+="${result}"$'\n'
done < <(rg -l "\.listen\s*\(" $LIB_DIRS 2>/dev/null --glob '!**/*.g.dart' --glob '!**/*.freezed.dart' --glob '!**/*.gr.dart' | rg -v test || true)

LISTEN_VIOLATIONS=$(filter_ignored "$LISTEN_VIOLATIONS")
if [ -n "$LISTEN_VIOLATIONS" ]; then
  echo "❌ stream.listen() should include onError: (Object error, StackTrace stackTrace) { ... }"
  echo "$LISTEN_VIOLATIONS"
  FAILED=1
else
  echo "✅ All .listen() have onError (or ignored)"
fi
echo ""
# 3. After await show*Dialog, require context.mounted before cubit/onClose
echo "🔍 Checking for context.mounted after await show*Dialog..."
DIALOG_VIOLATIONS=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  result=$(awk -v file="$file" '
    BEGIN { after_await_dialog=0; dialog_line=0; seen_mounted=0 }
    {
      line=$0
      if (line ~ /await[[:space:]]+([[:alnum:]_]+\.)*show[[:alnum:]_]*Dialog/) {
        after_await_dialog=1
        dialog_line=NR
        seen_mounted=0
        next
      }
      if (after_await_dialog && (NR - dialog_line) <= 30) {
        if (line ~ /context\.mounted|!context\.mounted/) seen_mounted=1
        if (line ~ /cubit\.|context\.cubit|onClose[[:space:]]*\(/) {
          if (!seen_mounted && line !~ /check-ignore/ && prev !~ /check-ignore/) {
            print file ":" NR ": use of cubit/onClose after await show*Dialog without context.mounted"
          }
        }
        if (line ~ /^[[:space:]]*(void|Future|Widget|class|@override)[[:space:]]/ && (NR - dialog_line) > 5) {
          after_await_dialog=0
          dialog_line=0
          seen_mounted=0
        }
      }
      prev=line
    }
  ' "$file" 2>/dev/null) || true
  [ -n "$result" ] && DIALOG_VIOLATIONS+="${result}"$'\n'
done < <(rg -l "await\s+([A-Za-z_][A-Za-z0-9_]*\.)*show.*Dialog" $LIB_DIRS 2>/dev/null --glob '!**/*.g.dart' --glob '!**/*.freezed.dart' --glob '!**/*.gr.dart' | rg -v test || true)

DIALOG_VIOLATIONS=$(filter_ignored "$DIALOG_VIOLATIONS")
if [ -n "$DIALOG_VIOLATIONS" ]; then
  echo "❌ After await show*Dialog add: if (!context.mounted) return; before cubit or onClose()"
  echo "$DIALOG_VIOLATIONS"
  FAILED=1
else
  echo "✅ All await show*Dialog usages check context.mounted (or ignored)"
fi
echo ""

if [ "$FAILED" -eq 1 ]; then
  echo "💡 Suppress with: // check-ignore: reason on the violation line or line above"
  exit 1
fi
echo "✅ All lifecycle and error-handling checks passed"
exit 0
