#!/usr/bin/env bash
# Refresh AI discovery snapshot metadata and bounded metric sections.
# Usage: bash tool/refresh_ai_reports.sh

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

usage() {
  cat <<'EOF'
Usage: bash tool/refresh_ai_reports.sh

Refreshes ai_snapshot frontmatter on active discovery snapshots, regenerates
bounded metrics blocks in the dependency, feature, and hotspot reports, updates
the report index and AI refresh stamp, and captures modular-metrics evidence.
Narrative guidance remains human-maintained.
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
feature_root="apps/mobile/lib/features"
metrics_file="ai/reports/.modular_metrics_latest.txt"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

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
  local tmp="$tmp_dir/frontmatter"
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
  local tmp="$tmp_dir/stripped"
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

replace_marked_block() {
  local target="$1"
  local start_marker="$2"
  local end_marker="$3"
  local content_file="$4"
  local tmp="$tmp_dir/replaced"

  if ! grep -Fqx "$start_marker" "$target" || ! grep -Fqx "$end_marker" "$target"; then
    echo "refresh-ai-reports|missing-markers|$target" >&2
    return 1
  fi

  awk -v start_marker="$start_marker" -v end_marker="$end_marker" \
    -v content_file="$content_file" '
      $0 == start_marker {
        print
        while ((getline line < content_file) > 0) print line
        close(content_file)
        in_block=1
        start_seen=1
        next
      }
      $0 == end_marker {
        if (!in_block) exit 2
        in_block=0
        end_seen=1
        print
        next
      }
      !in_block { print }
      END {
        if (!start_seen || !end_seen || in_block) exit 3
      }
    ' "$target" >"$tmp"
  mv "$tmp" "$target"
}

replace_prefixed_line() {
  local target="$1"
  local prefix="$2"
  local replacement="$3"
  local tmp="$tmp_dir/line"

  awk -v prefix="$prefix" -v replacement="$replacement" '
    index($0, prefix) == 1 { print replacement; replaced=1; next }
    { print }
    END { if (!replaced) exit 1 }
  ' "$target" >"$tmp"
  mv "$tmp" "$target"
}

bash "$WORKSPACE_ROOT/tool/modular_metrics.sh" >"$tmp_dir/modular_metrics.txt"
bash "$WORKSPACE_ROOT/tool/modular_metrics.sh" --cross-feature-only \
  >"$tmp_dir/cross_feature_metrics.txt"
cat "$tmp_dir/modular_metrics.txt" "$tmp_dir/cross_feature_metrics.txt" >"$metrics_file"
echo "refresh-ai-reports|metrics|$metrics_file"

feature_metrics="$tmp_dir/feature_metrics.txt"
awk '
  /^--- Per-feature Dart LOC / { in_section=1; next }
  /^--- Feature barrels / { exit }
  in_section && /^[[:space:]]+[[:alnum:]_]+: [0-9]+$/ {
    line=$0
    sub(/^[[:space:]]+/, "", line)
    gsub(/: /, ":", line)
    print line
  }
' "$tmp_dir/modular_metrics.txt" >"$feature_metrics"

if [[ ! -s "$feature_metrics" ]]; then
  echo "refresh-ai-reports|missing-feature-metrics" >&2
  exit 1
fi

dependency_block="$tmp_dir/dependency_block.md"
{
  echo "| Feature | LOC | Barrel |"
  echo "| --- | ---: | --- |"
  while IFS=: read -r feature loc; do
    barrel="no"
    [[ -f "$feature_root/$feature/$feature.dart" ]] && barrel="yes"
    printf '| %s | %s | %s |\n' "$feature" "$loc" "$barrel"
  done <"$feature_metrics"
} >"$dependency_block"

hotspot_rows="$tmp_dir/hotspot_rows.txt"
find "$feature_root" -type f -name '*.dart' ! -name '*.g.dart' \
  ! -name '*.freezed.dart' -exec wc -l {} + \
  | awk '$2 != "total" { print $1 "\t" $2 }' \
  | LC_ALL=C sort -rn -k1,1 \
  | sed -n '1,20p' >"$hotspot_rows"

hotspot_total="$(awk -F: '{ total += $2 } END { print total + 0 }' "$feature_metrics")"
hotspot_block="$tmp_dir/hotspot_block.md"
{
  echo "| Rank | LOC | File | Feature |"
  echo "| ---: | ---: | --- | --- |"
  rank=0
  while IFS=$'\t' read -r loc path; do
    [[ -z "$path" ]] && continue
    rank=$((rank + 1))
    relative_path="${path#$feature_root/}"
    feature="${relative_path%%/*}"
    printf '| %s | %s | `%s` | %s |\n' "$rank" "$loc" "$relative_path" "$feature"
  done <"$hotspot_rows"
  printf '\n**Total feature Dart (non-generated):** ~%s LOC across `%s`.\n' \
    "$hotspot_total" "$feature_root"
} >"$hotspot_block"

feature_count="$(find "$feature_root" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
feature_inventory="$tmp_dir/feature_inventory.md"
printf '**Feature inventory (generated):** %s directories under `%s` at source HEAD `%s`.\n' \
  "$feature_count" "$feature_root" "$git_head" >"$feature_inventory"

replace_marked_block "ai/reports/dependency_map.md" \
  "<!-- refresh_ai_reports:feature_metrics:start -->" \
  "<!-- refresh_ai_reports:feature_metrics:end -->" "$dependency_block"
replace_marked_block "ai/reports/context_hotspots.md" \
  "<!-- refresh_ai_reports:hotspots:start -->" \
  "<!-- refresh_ai_reports:hotspots:end -->" "$hotspot_block"
replace_marked_block "ai/reports/feature_map.md" \
  "<!-- refresh_ai_reports:feature_inventory:start -->" \
  "<!-- refresh_ai_reports:feature_inventory:end -->" "$feature_inventory"

for snapshot in "${active_snapshots[@]}"; do
  if [[ ! -f "$snapshot" ]]; then
    echo "refresh-ai-reports|skip-missing|$snapshot"
    continue
  fi
  body_file="$tmp_dir/body"
  strip_frontmatter "$snapshot"
  cp "$snapshot" "$body_file"
  write_frontmatter "$snapshot" "$body_file"
  echo "refresh-ai-reports|frontmatter|$snapshot"
done

if [[ -f ai/reports/README.md ]]; then
  readme_body="$tmp_dir/reports_readme_body"
  strip_frontmatter ai/reports/README.md
  cp ai/reports/README.md "$readme_body"
  generated_line='**Generated:** '"${today}"' via `bash tool/refresh_ai_reports.sh` and `bash tool/modular_metrics.sh` (HEAD `'"${git_head}"'`).'
  if grep -q '^\*\*Generated:\*\*' "$readme_body"; then
    replace_prefixed_line "$readme_body" "**Generated:**" "$generated_line"
  else
    printf '\n%s\n' "$generated_line" >>"$readme_body"
  fi
  write_frontmatter ai/reports/README.md "$readme_body"
fi

if [[ -f ai/README.md ]] && grep -q '^last_refreshed:' ai/README.md; then
  replace_prefixed_line ai/README.md "last_refreshed:" "last_refreshed: $today"
fi

echo "refresh-ai-reports|done|generated_at=$generated_at|git_head=$git_head"
