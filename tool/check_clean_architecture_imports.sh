#!/usr/bin/env bash
# Clean Architecture import/export gate for feature/shared layers.
# Theme: architecture | Severity: fail
# Suppress: check-ignore on same or previous line.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

source "$PROJECT_ROOT/tool/check_helpers.sh"

echo "🔍 Checking Clean Architecture import boundaries..."

usage() {
  cat <<'EOF'
Usage: tool/check_clean_architecture_imports.sh [--paths PATH...]

Default scope: apps/mobile/lib/features and lib/shared (via APP_ROOT). --paths
supports fixture/focused runs (workspace-root paths like tool/fixtures/... resolve).
Rules:
  domain: no Flutter/SDK/DI/app/data/presentation imports
  presentation: no data-layer imports
  data: no presentation-layer imports
  shared: no feature imports
EOF
}

SCAN_PATHS=("lib/features" "lib/shared")
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

declare -a RESOLVED_SCAN_PATHS=()
for scan_path in "${SCAN_PATHS[@]}"; do
  RESOLVED_SCAN_PATHS+=("$(resolve_scan_root "$scan_path")")
done
SCAN_PATHS=("${RESOLVED_SCAN_PATHS[@]}")

normalize_import_path() {
  local base_dir="$1"
  local spec="$2"
  awk -v base="$base_dir" -v spec="$spec" 'BEGIN {
    path = base "/" spec
    n = split(path, parts, "/")
    out_n = 0
    for (i = 1; i <= n; i++) {
      part = parts[i]
      if (part == "" || part == ".") {
        continue
      }
      if (part == "..") {
        if (out_n > 0) {
          out_n--
        }
        continue
      }
      out[++out_n] = part
    }
    for (i = 1; i <= out_n; i++) {
      printf "%s%s", (i == 1 ? "" : "/"), out[i]
    }
    printf "\n"
  }'
}

collect_files() {
  local root
  for root in "${SCAN_PATHS[@]}"; do
    if [[ -f "$root" ]]; then
      case "$root" in
        *.dart) printf '%s\n' "$root" ;;
      esac
      continue
    fi
    [[ -d "$root" ]] || continue
    find "$root" -name '*.dart' -type f \
      ! -name '*.g.dart' \
      ! -name '*.freezed.dart' \
      ! -name '*.gr.dart' \
      -print 2>/dev/null
  done
}

VIOLATIONS=""

while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.g.dart|*.freezed.dart|*.gr.dart) continue ;;
  esac

  layer=""
  case "$file" in
    */domain/*) layer="domain" ;;
    */data/*) layer="data" ;;
    */presentation/*) layer="presentation" ;;
    lib/shared/*|*/lib/shared/*|*/clean_architecture_imports/shared/*) layer="shared" ;;
  esac

  [[ -n "$layer" ]] || continue

  while IFS=: read -r lineno line; do
    [[ -n "$lineno" && -n "$line" ]] || continue
    [[ "$line" =~ ^[[:space:]]*(import|export)[[:space:]]+[\"\']([^\"\']+)[\"\'] ]] || continue
    spec="${BASH_REMATCH[2]}"
    resolved=""
    if [[ "$spec" == .* ]]; then
      resolved="$(normalize_import_path "$(dirname "$file")" "$spec")"
    fi

    reason=""
    case "$layer" in
      domain)
        if [[ "$spec" =~ ^package:flutter/ ]]; then
          reason="domain must not import Flutter"
        elif [[ "$spec" =~ ^package:(get_it|hive|supabase|dio|retrofit) ]]; then
          reason="domain must not import SDK/DI/data infrastructure"
        elif [[ "$spec" =~ ^package:flutter_bloc_app/(app/|core/di/) ]]; then
          reason="domain must not import app or DI"
        elif [[ "$spec" =~ ^package:flutter_bloc_app/features/[^\"\']+/(data|presentation)/ ]]; then
          reason="domain must not import feature data/presentation"
        elif [[ -n "$resolved" && "$resolved" =~ (^|/)lib/features/[^/]+/(data|presentation)/ ]]; then
          reason="domain must not import relative data/presentation"
        elif [[ -n "$resolved" && "$resolved" =~ (^|/)lib/(app|core/di)/ ]]; then
          reason="domain must not import relative app or DI"
        fi
        ;;
      presentation)
        if [[ "$spec" =~ ^package:flutter_bloc_app/features/[^\"\']+/data/ ]]; then
          reason="presentation must not import data layer"
        elif [[ -n "$resolved" && "$resolved" =~ (^|/)lib/features/[^/]+/data/ ]]; then
          reason="presentation must not import relative data layer"
        fi
        ;;
      data)
        if [[ "$spec" =~ ^package:flutter_bloc_app/features/[^\"\']+/presentation/ ]]; then
          reason="data must not import presentation layer"
        elif [[ -n "$resolved" && "$resolved" =~ (^|/)lib/features/[^/]+/presentation/ ]]; then
          reason="data must not import relative presentation layer"
        fi
        ;;
      shared)
        if [[ "$spec" =~ ^package:flutter_bloc_app/features/ ]]; then
          reason="shared must not import features"
        elif [[ -n "$resolved" && "$resolved" =~ (^|/)lib/features/ ]]; then
          reason="shared must not import relative features"
        fi
        ;;
    esac

    if [[ -n "$reason" ]]; then
      VIOLATIONS+="${file}:${lineno}:${reason}: ${line}"$'\n'
    fi
  done < <(grep -nE "^[[:space:]]*(import|export)[[:space:]]+['\"]" "$file" 2>/dev/null || true)
done < <(collect_files)

VIOLATIONS="$(filter_ignored "$VIOLATIONS")"

if [[ -n "${IGNORED:-}" ]]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [[ -n "$VIOLATIONS" ]]; then
  echo "❌ Clean Architecture import violations:"
  echo "$VIOLATIONS"
  exit 1
fi

echo "✅ Clean Architecture imports are valid"
exit 0
