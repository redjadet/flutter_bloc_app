#!/usr/bin/env bash
# Refresh AI discovery snapshot metadata and metrics evidence.
# Usage: bash tool/refresh_ai_reports.sh

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

usage() {
  cat <<'EOF'
Usage: bash tool/refresh_ai_reports.sh

Refreshes ai_snapshot frontmatter on active discovery snapshots, updates
ai/reports/README.md and ai/README.md refresh stamps, and captures modular
metrics evidence from the workspace root.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "$#" -gt 0 ]]; then
  echo "usage-error|unknown arg: $1" >&2
  usage >&2
  exit 2
fi

generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
git_head="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
today="${generated_at%T*}"

canon_links=(
  "docs/architecture_details.md"
  "CODEMAP.md"
  "docs/feature_overview.md"
)

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

write_frontmatter() {
  local target="$1"
  local body_file="$2"
  local tmp
  tmp="$(mktemp)"
  {
    echo "---"
    echo "ai_snapshot:"
    echo "  generated_at: \"$generated_at\""
    echo "  git_head: \"$git_head\""
    echo "  app_root: \"apps/mobile\""
    echo "  canon_links:"
    for link in "${canon_links[@]}"; do
      echo "    - $link"
    done
    echo "---"
    echo
    cat "$body_file"
  } >"$tmp"
  mv "$tmp" "$target"
}

strip_frontmatter() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  awk '
    BEGIN { in_front=0; seen=0 }
    /^---$/ {
      if (seen == 0) { in_front=1; seen=1; next }
      if (in_front == 1) { in_front=0; next }
    }
    in_front == 0 { print }
  ' "$file" >"$tmp"
  mv "$tmp" "$file"
}

for snapshot in "${active_snapshots[@]}"; do
  if [[ ! -f "$snapshot" ]]; then
    echo "refresh-ai-reports|skip-missing|$snapshot"
    continue
  fi
  body_file="$(mktemp)"
  strip_frontmatter "$snapshot"
  cp "$snapshot" "$body_file"
  write_frontmatter "$snapshot" "$body_file"
  rm -f "$body_file"
  echo "refresh-ai-reports|frontmatter|$snapshot"
done

metrics_file="ai/reports/.modular_metrics_latest.txt"
bash "$WORKSPACE_ROOT/tool/modular_metrics.sh" >"$metrics_file"
bash "$WORKSPACE_ROOT/tool/modular_metrics.sh" --cross-feature-only \
  >>"$metrics_file"
echo "refresh-ai-reports|metrics|$metrics_file"

if [[ -f ai/reports/README.md ]]; then
  readme_body="$(mktemp)"
  strip_frontmatter ai/reports/README.md
  cp ai/reports/README.md "$readme_body"
  if grep -q '^\*\*Generated:\*\*' "$readme_body"; then
    generated_line='**Generated:** '"${today}"' via `bash tool/refresh_ai_reports.sh` and `bash tool/modular_metrics.sh` (HEAD `'"${git_head}"'`).'
    sed -i '' "s|^\*\*Generated:\*\*.*|${generated_line}|" "$readme_body"
  else
    printf '\n**Generated:** %s via `bash tool/refresh_ai_reports.sh` and `bash tool/modular_metrics.sh` (HEAD `%s`).\n' "$today" "$git_head" >>"$readme_body"
  fi
  write_frontmatter ai/reports/README.md "$readme_body"
  rm -f "$readme_body"
fi

if [[ -f ai/README.md ]]; then
  if grep -q '^last_refreshed:' ai/README.md; then
    sed -i '' "s/^last_refreshed:.*/last_refreshed: ${today}/" ai/README.md
  fi
fi

echo "refresh-ai-reports|done|generated_at=$generated_at|git_head=$git_head"
