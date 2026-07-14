#!/usr/bin/env bash
# Validate AI discovery snapshots for stale paths and required metadata.
# Usage: bash tool/check_ai_snapshot_freshness.sh [--strict-head]

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

usage() {
  cat <<'EOF'
Usage: bash tool/check_ai_snapshot_freshness.sh [--strict-head] [--paths <file>...]

Checks active ai/ discovery snapshots for:
- forbidden legacy path patterns
- required ai_snapshot frontmatter keys
- resolvable canon_links paths

Options:
  --strict-head  Fail when git_head metadata differs from current HEAD
  --paths        Check only the given files (fixture/testing)
EOF
}

strict_head=false
declare -a explicit_paths=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --strict-head)
      strict_head=true
      shift
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        explicit_paths+=("$1")
        shift
      done
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

patterns_file="tool/fixtures/harness/ai_snapshot_forbidden_patterns.txt"
if [[ ! -f "$patterns_file" ]]; then
  echo "❌ Missing forbidden pattern fixture: $patterns_file" >&2
  exit 1
fi

active_snapshots=(
  "ai/CONTEXT_MAP.md"
  "ai/reports/architecture_overview.md"
  "ai/reports/data_flow_map.md"
  "ai/reports/dependency_map.md"
  "ai/reports/feature_map.md"
  "ai/reports/context_hotspots.md"
  "ai/reports/anti_patterns.md"
  "ai/reports/ai_recommendations.md"
)

if [[ "${#explicit_paths[@]}" -gt 0 ]]; then
  active_snapshots=("${explicit_paths[@]}")
fi

required_keys=(
  "generated_at:"
  "git_head:"
  "app_root:"
  "canon_links:"
)

failures=0
fail() {
  echo "❌ $*" >&2
  failures=$((failures + 1))
}

current_head="$(git rev-parse HEAD 2>/dev/null || echo unknown)"

for snapshot in "${active_snapshots[@]}"; do
  if [[ ! -f "$snapshot" ]]; then
    fail "missing active snapshot: $snapshot"
    continue
  fi

  frontmatter="$(awk '
    BEGIN { in_front=0; seen=0 }
    /^---$/ {
      if (seen == 0) { in_front=1; seen=1; next }
      if (in_front == 1) { exit }
    }
    in_front == 1 { print }
  ' "$snapshot")"

  if [[ -z "$frontmatter" ]]; then
    fail "$snapshot missing ai_snapshot YAML frontmatter"
  else
    for key in "${required_keys[@]}"; do
      if ! grep -q "$key" <<<"$frontmatter"; then
        fail "$snapshot missing frontmatter key: $key"
      fi
    done

    meta_head="$(awk -F'"' '/^[[:space:]]*git_head:/ { print $2; exit }' <<<"$frontmatter")"
    if [[ "$strict_head" == true && -n "$meta_head" && "$meta_head" != "$current_head" ]]; then
      fail "$snapshot git_head ($meta_head) != current HEAD ($current_head)"
    fi

    while IFS= read -r link; do
      [[ -z "$link" ]] && continue
      if [[ ! -e "$link" ]]; then
        fail "$snapshot canon_links missing path: $link"
      fi
    done < <(awk '
      BEGIN { in_canon=0 }
      /^  canon_links:/ { in_canon=1; next }
      in_canon && /^    - / { print substr($0, 7); next }
      in_canon && /^  [a-z_]+:/ { exit }
    ' <<<"$frontmatter")
  fi

  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    [[ "$pattern" =~ ^# ]] && continue
    if grep -Eq "$pattern" "$snapshot"; then
      fail "$snapshot matches forbidden pattern: $pattern"
    fi
  done < "$patterns_file"
done

if [[ "$failures" -ne 0 ]]; then
  echo "ai-snapshot-freshness|fail|$failures"
  exit 1
fi

echo "✅ AI snapshot freshness checks passed."
exit 0
