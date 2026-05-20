#!/usr/bin/env bash
# Blocking dart:io *Sync in presentation layer (UI isolate jank).
# Theme: blocking-main-isolate | Severity: fail
# Scope: lib/**/presentation/** only (not all lib/)

set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
echo "🔍 Checking presentation layer for blocking dart:io *Sync calls..."
SCAN_PATHS=("lib")
usage() {
  cat <<'EOF'
Usage: tool/check_sync_io_in_presentation.sh [--paths PATH...]

Default scope: lib/**/presentation/**. --paths supports fixture runs.
EOF
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  SCAN_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi
SYNC_PATTERN='\b(lastModifiedSync|statSync|existsSync|readAsStringSync|readAsBytesSync|readAsLinesSync|writeAsStringSync|writeAsBytesSync|createSync|deleteSync|renameSync|copySync|listSync|typeSync)\s*\('
GREP_SYNC_PATTERN='(^|[^[:alnum:]_])(lastModifiedSync|statSync|existsSync|readAsStringSync|readAsBytesSync|readAsLinesSync|writeAsStringSync|writeAsBytesSync|createSync|deleteSync|renameSync|copySync|listSync|typeSync)[[:space:]]*\('
collect_violations() {
  local root dartfile hits out=""
  for root in "${SCAN_PATHS[@]}"; do
    if [ -f "$root" ]; then
      dartfile="$root"
      case "$dartfile" in */presentation/*) ;; *) continue ;; esac
      if command -v rg &>/dev/null; then
        hits=$(rg -nH "$SYNC_PATTERN" "$dartfile" 2>/dev/null | rg -v '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      else
        hits=$(grep -nHE "$GREP_SYNC_PATTERN" "$dartfile" 2>/dev/null | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      fi
      [ -n "$hits" ] && out+="${hits}"$'
'
      continue
    fi
    [ -d "$root" ] || continue
    while IFS= read -r dartfile; do
      case "$dartfile" in */presentation/*) ;; *) continue ;; esac
      if command -v rg &>/dev/null; then
        hits=$(rg -nH "$SYNC_PATTERN" "$dartfile" 2>/dev/null | rg -v '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      else
        hits=$(grep -nHE "$GREP_SYNC_PATTERN" "$dartfile" 2>/dev/null | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//' || true)
      fi
      [ -n "$hits" ] && out+="${hits}"$'\n'
    done < <(find "$root" -name '*.dart' -type f -print 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored (check-ignore):"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  echo "❌ Presentation layer must not use blocking dart:io *Sync."
  echo "$VIOLATIONS"; exit 1
fi
echo "✅ No blocking *Sync in presentation layer"; exit 0
