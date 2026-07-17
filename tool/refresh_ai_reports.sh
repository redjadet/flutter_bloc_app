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
       bash tool/refresh_ai_reports.sh --self-test

Refreshes ai_snapshot frontmatter on active discovery snapshots, regenerates
bounded metrics blocks in the dependency, feature, and hotspot reports, updates
the report index and AI refresh stamp, and captures modular-metrics evidence.
All outputs are staged before installation, with rollback on a normal install
failure or interruption. Narrative guidance remains human-maintained.

Options:
  --self-test  Verify frontmatter refresh remains whitespace-idempotent.
EOF
}

self_test=0
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--self-test" && "$#" -eq 1 ]]; then
  self_test=1
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
stage_dir="$tmp_dir/stage"
backup_dir="$tmp_dir/backup"
lock_dir=""
installing=0
installed_targets=()
install_targets=()

cleanup() {
  local status=$?
  local target
  set +e

  if [[ "$installing" -eq 1 ]]; then
    for target in "${installed_targets[@]}"; do
      if [[ -f "$backup_dir/$target" ]]; then
        cp "$backup_dir/$target" "$target"
      else
        rm -f "$target"
      fi
    done
  fi

  for target in "${install_targets[@]}"; do
    rm -f "$target.refresh.$$"
  done
  if [[ -n "$lock_dir" ]]; then
    rm -f "$lock_dir/pid"
    rmdir "$lock_dir" 2>/dev/null || true
  fi
  rm -rf "$tmp_dir"
  return "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

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
  local output="$2"
  if ! awk '
    NR == 1 {
      if ($0 != "---") { passthrough=1; print; next }
      in_front=1
      seen=1
      next
    }
    passthrough == 1 { print; next }
    in_front == 1 && /^---$/ {
      in_front=0
      closed=1
      trim_body=1
      next
    }
    in_front == 0 {
      if (trim_body == 1 && $0 ~ /^[[:space:]]*$/) next
      trim_body=0
      print
    }
    END { if (seen == 1 && closed != 1) exit 3 }
  ' "$file" >"$output"
  then
    rm -f "$output"
    echo "refresh-ai-reports|malformed-frontmatter|$file" >&2
    return 1
  fi
}

run_self_test() {
  local sample="$tmp_dir/frontmatter_sample.md"
  local body_file="$tmp_dir/frontmatter_body.md"
  local expected="$tmp_dir/frontmatter_expected.md"
  local no_frontmatter="$tmp_dir/no_frontmatter.md"
  local no_frontmatter_expected="$tmp_dir/no_frontmatter_expected.md"
  local malformed="$tmp_dir/malformed_frontmatter.md"
  local malformed_expected="$tmp_dir/malformed_frontmatter_expected.md"
  local blank_count

  printf '%s\n' \
    '---' \
    'ai_snapshot:' \
    '  generated_at: "old"' \
    '---' \
    '' \
    '' \
    '# Body' >"$sample"

  for iteration in 1 2; do
    strip_frontmatter "$sample" "$body_file"
    write_frontmatter "$sample" "$body_file"
    blank_count="$(awk '
      /^---$/ { delimiters++; next }
      delimiters == 2 {
        if ($0 ~ /^[[:space:]]*$/) { blanks++; next }
        print blanks + 0
        exit
      }
    ' "$sample")"
    if [[ "$blank_count" != "1" ]] || ! grep -Fqx '# Body' "$sample"; then
      echo "refresh-ai-reports|self-test|failed" >&2
      return 1
    fi
    if [[ "$iteration" -eq 1 ]]; then
      cp "$sample" "$expected"
    elif ! cmp -s "$expected" "$sample"; then
      echo "refresh-ai-reports|self-test|non-idempotent" >&2
      return 1
    fi
  done

  printf '%s\n' '# Intro' '' '---' 'body section' '---' '# Tail' \
    >"$no_frontmatter"
  cp "$no_frontmatter" "$no_frontmatter_expected"
  strip_frontmatter "$no_frontmatter" "$body_file"
  if ! cmp -s "$no_frontmatter_expected" "$body_file"; then
    echo "refresh-ai-reports|self-test|body-delimiter-corruption" >&2
    return 1
  fi

  printf '%s\n' '---' 'ai_snapshot:' '# Body without closing delimiter' \
    >"$malformed"
  cp "$malformed" "$malformed_expected"
  if strip_frontmatter "$malformed" "$body_file" 2>/dev/null; then
    echo "refresh-ai-reports|self-test|accepted-malformed-frontmatter" >&2
    return 1
  fi
  if ! cmp -s "$malformed_expected" "$malformed"; then
    echo "refresh-ai-reports|self-test|malformed-input-mutated" >&2
    return 1
  fi

  echo "refresh-ai-reports|self-test|ok"
}

if [[ "$self_test" -eq 1 ]]; then
  run_self_test
  exit 0
fi

lock_key="$(printf '%s' "$WORKSPACE_ROOT" | cksum | awk '{print $1}')"
lock_dir="${TMPDIR:-/tmp}/refresh-ai-reports-${lock_key}.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  owner_pid="$(sed -n '1p' "$lock_dir/pid" 2>/dev/null || true)"
  if [[ "$owner_pid" =~ ^[0-9]+$ ]] && ! kill -0 "$owner_pid" 2>/dev/null; then
    rm -f "$lock_dir/pid"
    rmdir "$lock_dir" 2>/dev/null || true
  fi
  if ! mkdir "$lock_dir" 2>/dev/null; then
    echo "refresh-ai-reports|already-running|$lock_dir" >&2
    exit 1
  fi
fi
printf '%s\n' "$$" >"$lock_dir/pid"

required_targets=(
  "${active_snapshots[@]}"
  "ai/reports/README.md"
)
for target in "${required_targets[@]}"; do
  if [[ ! -f "$target" ]]; then
    echo "refresh-ai-reports|missing-target|$target" >&2
    exit 1
  fi
done

install_targets=("$metrics_file" "${required_targets[@]}")
if [[ -f ai/README.md ]] && grep -q '^last_refreshed:' ai/README.md; then
  install_targets+=("ai/README.md")
fi

for target in "${install_targets[@]}"; do
  mkdir -p "$stage_dir/$(dirname "$target")"
  if [[ -f "$target" ]]; then
    cp "$target" "$stage_dir/$target"
  fi
done

# Validate every frontmatter-bearing input before generating or installing any
# output. A malformed late snapshot therefore leaves the complete set untouched.
for target in "${required_targets[@]}"; do
  strip_frontmatter "$stage_dir/$target" "$tmp_dir/preflight_body"
done

replace_marked_block() {
  local target="$1"
  local start_marker="$2"
  local end_marker="$3"
  local content_file="$4"
  local tmp="$tmp_dir/replaced"

  if ! awk -v start_marker="$start_marker" -v end_marker="$end_marker" '
    $0 == start_marker {
      starts++
      if (ends > 0) invalid_order=1
    }
    $0 == end_marker {
      ends++
      if (starts != 1) invalid_order=1
    }
    END {
      if (starts != 1 || ends != 1 || invalid_order == 1) exit 1
    }
  ' "$target"; then
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
cat "$tmp_dir/modular_metrics.txt" "$tmp_dir/cross_feature_metrics.txt" \
  >"$stage_dir/$metrics_file"

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

replace_marked_block "$stage_dir/ai/reports/dependency_map.md" \
  "<!-- refresh_ai_reports:feature_metrics:start -->" \
  "<!-- refresh_ai_reports:feature_metrics:end -->" "$dependency_block"
replace_marked_block "$stage_dir/ai/reports/context_hotspots.md" \
  "<!-- refresh_ai_reports:hotspots:start -->" \
  "<!-- refresh_ai_reports:hotspots:end -->" "$hotspot_block"
replace_marked_block "$stage_dir/ai/reports/feature_map.md" \
  "<!-- refresh_ai_reports:feature_inventory:start -->" \
  "<!-- refresh_ai_reports:feature_inventory:end -->" "$feature_inventory"

for snapshot in "${active_snapshots[@]}"; do
  body_file="$tmp_dir/body"
  strip_frontmatter "$stage_dir/$snapshot" "$body_file"
  write_frontmatter "$stage_dir/$snapshot" "$body_file"
done

readme_body="$tmp_dir/reports_readme_body"
strip_frontmatter "$stage_dir/ai/reports/README.md" "$readme_body"
generated_line='**Generated:** '"${today}"' via `bash tool/refresh_ai_reports.sh` and `bash tool/modular_metrics.sh` (HEAD `'"${git_head}"'`).'
if grep -q '^\*\*Generated:\*\*' "$readme_body"; then
  replace_prefixed_line "$readme_body" "**Generated:**" "$generated_line"
else
  printf '\n%s\n' "$generated_line" >>"$readme_body"
fi
write_frontmatter "$stage_dir/ai/reports/README.md" "$readme_body"

if [[ -f "$stage_dir/ai/README.md" ]]; then
  replace_prefixed_line "$stage_dir/ai/README.md" \
    "last_refreshed:" "last_refreshed: $today"
fi

# Back up the complete target set before the first replacement. Installation
# uses same-directory rename; the EXIT trap restores every installed target if
# a later replacement or handled interruption fails.
for target in "${install_targets[@]}"; do
  mkdir -p "$backup_dir/$(dirname "$target")"
  if [[ -f "$target" ]]; then
    cp "$target" "$backup_dir/$target"
  fi
done

installing=1
for target in "${install_targets[@]}"; do
  installed_targets+=("$target")
  cp "$stage_dir/$target" "$target.refresh.$$"
  mv "$target.refresh.$$" "$target"
done
installing=0

echo "refresh-ai-reports|metrics|$metrics_file"
for snapshot in "${active_snapshots[@]}"; do
  echo "refresh-ai-reports|frontmatter|$snapshot"
done

echo "refresh-ai-reports|done|generated_at=$generated_at|git_head=$git_head"
