#!/usr/bin/env bash
# Check for common side effects in build() method
# Looks for common patterns like ensureConfigured(), service.start(), unawaited()

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for side effects in build() method..."

VIOLATIONS=""
IGNORED=""

# Check for ensureConfigured() in build method
if command -v rg &> /dev/null; then
  FILES=$(rg -l "Widget build" lib/ lib/app/ 2>/dev/null || true)
else
  FILES=$(grep -rl "Widget build" lib/ lib/app/ 2>/dev/null || true)
fi

while IFS= read -r file; do
  [ -z "$file" ] && continue
  results=$(
    awk -v file="$file" '
      function trim(s){ sub(/^[ \t]+/,"",s); sub(/[ \t]+$/,"",s); return s }
      function count_braces(s,   i,c){ for(i=1;i<=length(s);i++){ c+= (substr(s,i,1)=="{") - (substr(s,i,1)=="}") } return c }
      {
        line=$0
        if (in_build) {
          if (!started && index(line,"{")>0) {
            started=1
          }
          if (line ~ /ensureConfigured\(|\.start\(|unawaited\(/) {
            reason=""
            if (index(line,"check-ignore")) {
              reason=line
              sub(/.*check-ignore[: ]*/,"",reason)
            } else if (index(prev,"check-ignore")) {
              reason=prev
              sub(/.*check-ignore[: ]*/,"",reason)
            }
            reason=trim(reason)
            if (index(line,"check-ignore") || index(prev,"check-ignore")) {
              if (reason=="") reason="no reason provided"
              print "IGNORED|" file ":" NR ":" line "|reason:" reason
            } else {
              print file ":" NR ":" line
            }
          }
          depth += count_braces(line)
          if (started && depth<=0) { in_build=0; started=0; depth=0 }
        }
        if (!in_build && line ~ /Widget build/) {
          in_build=1
          started = index(line,"{")>0 ? 1 : 0
          depth = count_braces(line)
        }
        prev=line
      }
    ' "$file"
  )
  if [ -n "$results" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      if [[ "$line" == IGNORED\|* ]]; then
        entry="${line#IGNORED|}"
        entry_file="${entry%%|reason:*}"
        reason="${entry##*|reason:}"
        IGNORED+="${entry_file} | reason: ${reason}"$'\n'
      else
        VIOLATIONS+="${line}"$'\n'
      fi
    done <<< "$results"
  fi
done <<< "$FILES"

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
  echo ""
fi

if [ -n "$VIOLATIONS" ]; then
  echo "⚠️  Potential side effects in build() method detected (heuristic)"
  echo "Note: This is a heuristic check. Review manually for:"
  echo "  - ensureConfigured() calls"
  echo "  - service.start() calls"
  echo "  - unawaited() calls"
  echo ""
  echo "$VIOLATIONS"
  echo ""
  echo "Side effects should be in initState() of StatefulWidget, not build()"
  # Do not fail the checklist (heuristic only).
  exit 0
else
  echo "✅ No obvious side effects in build() method"
  exit 0
fi
