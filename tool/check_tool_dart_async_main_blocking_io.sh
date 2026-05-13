#!/usr/bin/env bash
# Dart CLI tools with async main() must not call blocking dart:io *Sync APIs
# (event-loop jank; easy to forget await after refactor). Prefer async
# counterparts: await file.stat(), await file.readAsString(), etc.
#
# Scope: only tool/**/*.dart files whose entrypoint is async main.
# Sync-only CLIs (e.g. codegen) are intentionally excluded.
#
# Suppress only with check-ignore on the same or previous line (tool/check_helpers.sh).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking tool/ Dart (async main) for blocking dart:io *Sync calls..."

source "$PROJECT_ROOT/tool/check_helpers.sh"

usage() {
  cat <<'EOF'
Usage: tool/check_tool_dart_async_main_blocking_io.sh [--paths PATH...]

Checks tool/**/*.dart by default. --paths is for focused fixture or file checks.
EOF
}

SCAN_PATHS=("tool")
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

# High-signal blocking dart:io / FileSystemEntity sync surface (not exhaustive).
SYNC_PATTERN='\b(lastModifiedSync|statSync|existsSync|readAsStringSync|readAsBytesSync|readAsLinesSync|writeAsStringSync|writeAsBytesSync|createSync|deleteSync|renameSync|copySync|listSync|typeSync)\s*\('
GREP_SYNC_PATTERN='(^|[^[:alnum:]_])(lastModifiedSync|statSync|existsSync|readAsStringSync|readAsBytesSync|readAsLinesSync|writeAsStringSync|writeAsBytesSync|createSync|deleteSync|renameSync|copySync|listSync|typeSync)[[:space:]]*\('

# Async entrypoint: main(...) async { ... }
ASYNC_MAIN_PATTERN='\bmain\s*\([^)]*\)\s*async'
GREP_ASYNC_MAIN_PATTERN='main[[:space:]]*\([^)]*\)[[:space:]]*async'

collect_violations() {
  local dartfile
  local hits
  local out=""
  while IFS= read -r dartfile; do
    [ -z "$dartfile" ] && continue
    if command -v rg &> /dev/null; then
      if ! rg -q "$ASYNC_MAIN_PATTERN" "$dartfile" 2>/dev/null; then
        continue
      fi
      hits=$(rg -nH "$SYNC_PATTERN" "$dartfile" 2>/dev/null | rg -v '^[^:]+:[0-9]+:[[:space:]]*//' || true)
    else
      if ! grep -qE "$GREP_ASYNC_MAIN_PATTERN" "$dartfile" 2>/dev/null; then
        continue
      fi
      hits=$(grep -nHE "$GREP_SYNC_PATTERN" "$dartfile" 2>/dev/null | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//' || true)
    fi
    if [ -n "$hits" ]; then
      out+="${hits}"$'\n'
    fi
  done < <(find "${SCAN_PATHS[@]}" -name '*.dart' -type f -print 2>/dev/null)
  printf '%s' "$out"
}

VIOLATIONS="$(collect_violations)"
VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Async main() in tool/ must not use blocking *Sync dart:io calls."
  echo "   Use async APIs (e.g. await File(...).readAsString(), await file.exists(), Directory.list())."
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ No blocking *Sync in tool/ Dart entrypoints with async main"
exit 0
