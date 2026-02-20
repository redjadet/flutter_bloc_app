#!/usr/bin/env bash
# Check for null assertion operator (!) usage that may be unguarded.
# Allowlist with: // check-ignore: reason (on same or previous line).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Checking for potentially unguarded null assertion (!) usage in lib/..."

IGNORED=""

source "$PROJECT_ROOT/tool/check_helpers.sh"

# Find lines in lib containing '!' (null assertion candidate), excluding generated files.
if command -v rg &> /dev/null; then
  CANDIDATES=$(rg -n '!' lib \
    --glob '*.dart' \
    --glob '!*.g.dart' \
    --glob '!*.freezed.dart' \
    --glob '!*.gr.dart' \
    2>/dev/null || true)
else
  CANDIDATES=$(grep -rn '!' lib --include='*.dart' 2>/dev/null || true)
fi

# Exclude test and generated paths.
CANDIDATES=$(echo "$CANDIDATES" | grep -v '/test/' | grep -v '\.g\.dart' | grep -v '\.freezed\.dart' | grep -v '\.gr\.dart' || true)

# Exclude: is! (type check), comment-only, same-line guarded.
CANDIDATES=$(echo "$CANDIDATES" | grep -v ' is! ' | grep -Ev ':[0-9]+:[[:space:]]*//' || true)
CANDIDATES=$(echo "$CANDIDATES" | grep -v '!= null' | grep -v '== null' | grep -v '??=' || true)

# Exclude boolean negation: if (!,  && !,  || !,  (! 
CANDIDATES=$(echo "$CANDIDATES" | grep -v 'if (!' | grep -v ' && !' | grep -v ' || !' | grep -v ' (!' || true)

# Exclude GraphQL variable definitions (e.g. $continent: ID!)
CANDIDATES=$(echo "$CANDIDATES" | grep -v ": ID!" | grep -v "query.*!" || true)
# Exclude mock/string data with ! inside quotes
CANDIDATES=$(echo "$CANDIDATES" | grep -v "lastMessage:.*!.*'" | grep -v "reply:.*!.*'" || true)
# Exclude l10n string literals - skip app_localizations*.dart
CANDIDATES=$(echo "$CANDIDATES" | grep -v 'app_localizations.*\.dart' || true)

# Keep only lines that look like null assertion:
# - ! followed by . ; ) , space ? ] (e.g. value!.x, value!])
# - identifier/null-assertion function call (e.g. callback!(...))
VIOLATIONS=$(echo "$CANDIDATES" | grep -E '!\.|!;|!\)|!,|! |!\?|!\]|[A-Za-z0-9_]!\(|\]!\(|\)!\(' || true)

VIOLATIONS=$(printf '%s' "$VIOLATIONS" | sort -u)
VIOLATIONS=$(filter_ignored "$VIOLATIONS")

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Potentially unguarded null assertion (!) usage. Add explicit null check or // check-ignore: reason"
  echo "$VIOLATIONS"
  exit 1
else
  echo "✅ No potentially unguarded null assertion (!) usage found"
  exit 0
fi
