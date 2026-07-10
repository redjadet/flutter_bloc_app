#!/usr/bin/env bash
# Warn/fail: context.read/watch in Widget build() causes unnecessary rebuilds.
# Theme: rebuild | Severity: warn by default (CHECK_CONTEXT_READ_WATCH_MODE=warn)
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
MODE="${CHECK_CONTEXT_READ_WATCH_MODE:-warn}"
IGNORED=""
echo "🔍 Checking context.read/watch in presentation build() (mode=$MODE)..."
usage() {
  cat <<'EOF'
Usage: tool/check_context_read_watch.sh [--paths PATH...]

Default scope: lib/features/**/presentation/** excluding *_demo features.
EOF
}
SCAN_PATHS=("lib/features")
case "$MODE" in
  warn|fail) ;;
  *)
    echo "❌ CHECK_CONTEXT_READ_WATCH_MODE must be warn or fail (got: $MODE)" >&2
    exit 2
    ;;
esac
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  SCAN_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  exit 2
fi
RESOLVED_SCAN_PATHS=()
for scan_path in "${SCAN_PATHS[@]}"; do
  RESOLVED_SCAN_PATHS+=("$(resolve_scan_root "$scan_path")")
done
SCAN_PATHS=("${RESOLVED_SCAN_PATHS[@]}")
should_scan_file() {
  local file="$1"
  case "$file" in
    *context_read_watch*) return 0 ;;
    *_demo/*) return 1 ;;
    */presentation/*) return 0 ;;
  esac
  return 1
}
scan_file() {
  local dartfile="$1"
  local results out=""
  results=$(
    awk -v file="$dartfile" '
      function count_braces(s,   i,c){ for(i=1;i<=length(s);i++){ c+= (substr(s,i,1)=="{") - (substr(s,i,1)=="}") } return c }
      {
        line=$0
        if (in_build) {
          if (!started && index(line,"{")>0) started=1
          if (line ~ /context\.(read|watch)(<[^>]+>)?\(/) {
            if (line ~ /check-ignore/ || prev ~ /check-ignore/) {
              print "IGNORED|" file ":" NR ":" line
            } else {
              print file ":" NR ":" line
            }
          }
          depth += count_braces(line)
          if (started && depth<=0) { in_build=0; started=0; depth=0 }
        }
        if (!in_build && line ~ /Widget build\(/) {
          in_build=1
          started = index(line,"{")>0 ? 1 : 0
          depth = count_braces(line)
        }
        prev=line
      }
    ' "$dartfile"
  )
  if [ -z "$results" ]; then
    return 0
  fi
  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    if [[ "$entry" == IGNORED\|* ]]; then
      IGNORED+="${entry#IGNORED|}"$'\n'
    else
      out+="${entry}"$'\n'
    fi
  done <<< "$results"
  printf '%s' "$out"
}
collect_violations() {
  local root dartfile out=""
  for root in "${SCAN_PATHS[@]}"; do
    if [ -f "$root" ]; then
      should_scan_file "$root" || continue
      out+=$(scan_file "$root")
      continue
    fi
    while IFS= read -r dartfile; do
      [ -f "$dartfile" ] || continue
      should_scan_file "$dartfile" || continue
      out+=$(scan_file "$dartfile")
    done < <(find "$root" -name '*.dart' -type f 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored:"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "❌ Context read/watch in build(): ${count} violation(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | head -10
  echo "Remediation: use BlocBuilder/BlocSelector or read in callbacks, not build()."
  if [ "$MODE" = "warn" ]; then
    echo "⚠️  CHECK_CONTEXT_READ_WATCH_MODE=warn — exiting 0"
    exit 0
  fi
  exit 1
fi
echo "✅ No context.read/watch in presentation build()"
exit 0
