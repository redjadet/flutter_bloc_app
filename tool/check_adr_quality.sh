#!/usr/bin/env bash
# Validate ADR structure and current architecture ownership references.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash tool/check_adr_quality.sh [--paths ADR...]

Checks ADR metadata, required decision sections, accepted-decision consequences,
and obsolete app core/shared ownership paths.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

declare -a paths=()
if [[ "${1:-}" == "--paths" ]]; then
  shift
  paths=("$@")
elif [[ $# -gt 0 ]]; then
  usage >&2
  exit 2
else
  while IFS= read -r path; do paths+=("$path"); done \
    < <(find docs/adr -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | LC_ALL=C sort)
fi

failures=0
fail() {
  echo "adr-quality|fail|$1" >&2
  failures=1
}

for path in "${paths[@]}"; do
  [[ -f "$path" ]] || { fail "$path|missing"; continue; }
  grep -qE '^# ADR [0-9]{4}: ' "$path" || fail "$path|title"
  grep -qE '^\| Status \| (Proposed|Accepted|Superseded|Deprecated) \|$' "$path" || fail "$path|status"
  grep -qE '^\| Date \| [0-9]{4}-[0-9]{2}-[0-9]{2} \|$' "$path" || fail "$path|date"
  grep -qF '| Scope |' "$path" || fail "$path|scope"
  grep -qF '| Source docs |' "$path" || fail "$path|source-docs"

  for heading in '## Context' '## Decision' '## Alternatives' '## Consequences' '## Review' '## Verification'; do
    grep -qiF "$heading" "$path" || fail "$path|heading:$heading"
  done

  if grep -qF '| Status | Accepted |' "$path"; then
    grep -qiF '### Benefits' "$path" || fail "$path|benefits"
    grep -qiF '### Costs' "$path" || fail "$path|costs"
  fi

  if grep -qE 'apps/mobile/lib/(core|shared)/' "$path"; then
    fail "$path|obsolete-app-ownership"
  fi
done

[[ "$failures" -eq 0 ]] || exit 1
echo "adr-quality|pass|${#paths[@]} records"
