#!/usr/bin/env bash
# Report-only/warn inventory: BlocBuilder/BlocConsumer without buildWhen.
# Theme: rebuild | Severity: warn by default (CHECK_BLOC_REBUILD_SCOPING_MODE=warn)
# Not wired into delivery_checklist CHECK_SCRIPTS — QG-D03 spike.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/tool/check_helpers.sh"
MODE="${CHECK_BLOC_REBUILD_SCOPING_MODE:-warn}"
IGNORED=""
echo "🔍 Checking BlocBuilder/Consumer rebuild scoping candidates (mode=$MODE)..."
usage() {
  cat <<'EOF'
Usage: tool/check_bloc_rebuild_scoping.sh [--paths PATH...]

Default scope: lib/features/**/presentation/** excluding *_demo features.
Reports BlocBuilder / BlocConsumer constructor calls without buildWhen.
Warn mode exits 0 when only candidates are found.
EOF
}
SCAN_PATHS=("lib/features")
case "$MODE" in
  warn|fail) ;;
  *)
    echo "❌ CHECK_BLOC_REBUILD_SCOPING_MODE must be warn or fail (got: $MODE)" >&2
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
    *bloc_rebuild_scoping*) return 0 ;;
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
      function count_parens(s,   i,c){ for(i=1;i<=length(s);i++){ c+= (substr(s,i,1)=="(") - (substr(s,i,1)==")") } return c }
      {
        line=$0
        if (in_call) {
          if (line ~ /buildWhen[[:space:]]*:/) has_build_when=1
          depth += count_parens(line)
          if (depth<=0) {
            if (!has_build_when) {
              if (line ~ /check-ignore/ || prev ~ /check-ignore/) {
                print "IGNORED|" file ":" start_nr ":" start_line
              } else {
                print file ":" start_nr ":" start_line
              }
            }
            in_call=0; depth=0; has_build_when=0
          }
        }
        if (!in_call && line ~ /(^|[^A-Za-z0-9_])Bloc(Builder|Consumer)[[:space:]]*(<[^>]*>)?[[:space:]]*\(/) {
          in_call=1
          start_nr=NR
          start_line=line
          has_build_when = (line ~ /buildWhen[[:space:]]*:/)
          depth = count_parens(line)
          if (depth<=0) {
            if (!has_build_when) {
              if (line ~ /check-ignore/ || prev ~ /check-ignore/) {
                print "IGNORED|" file ":" start_nr ":" start_line
              } else {
                print file ":" start_nr ":" start_line
              }
            }
            in_call=0; depth=0; has_build_when=0
          }
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
  local root dartfile out="" piece
  for root in "${SCAN_PATHS[@]}"; do
    if [ -f "$root" ]; then
      should_scan_file "$root" || continue
      piece=$(scan_file "$root")
      [ -n "$piece" ] && out+="${piece}"$'\n'
      continue
    fi
    while IFS= read -r dartfile; do
      [ -f "$dartfile" ] || continue
      should_scan_file "$dartfile" || continue
      piece=$(scan_file "$dartfile")
      [ -n "$piece" ] && out+="${piece}"$'\n'
    done < <(find "$root" -name '*.dart' -type f 2>/dev/null)
  done
  printf '%s' "$out"
}
VIOLATIONS="$(filter_ignored "$(collect_violations)")"
[ -n "${IGNORED:-}" ] && { echo "ℹ️  Ignored:"; echo "$IGNORED"; }
if [ -n "$VIOLATIONS" ]; then
  count=$(printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "⚠️  BlocBuilder/Consumer without buildWhen: ${count} candidate(s)"
  printf '%s\n' "$VIOLATIONS" | sed '/^$/d' | head -20
  echo "Note: intentional full-state rebuilds may be valid; inventory only until classified."
  if [ "$MODE" = "warn" ]; then
    echo "⚠️  CHECK_BLOC_REBUILD_SCOPING_MODE=warn — exiting 0"
    exit 0
  fi
  exit 1
fi
echo "✅ No BlocBuilder/Consumer rebuild-scoping candidates"
exit 0
