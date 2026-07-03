#!/usr/bin/env bash
# Feature folder shape gate. See docs/architecture/feature_structure_contract.md.
# Theme: architecture | Severity: fail on fixture/strict; warn on legacy lib drift.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

source "$PROJECT_ROOT/tool/check_helpers.sh"

LEGACY_ALLOWLIST_FILE="$WORKSPACE_ROOT/tool/config/legacy_feature_folder_allowlist.txt"

is_allowlisted_legacy_path() {
  local path="$1"
  local entry trimmed
  [[ -f "$LEGACY_ALLOWLIST_FILE" ]] || return 1
  while IFS= read -r entry || [[ -n "$entry" ]]; do
    entry="${entry%%#*}"
    trimmed="${entry#"${entry%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    [[ -n "$trimmed" ]] || continue
    if [[ "$path" == "$trimmed" || "$path" == "$trimmed/"* ]]; then
      return 0
    fi
  done <"$LEGACY_ALLOWLIST_FILE"
  return 1
}

filter_allowlisted_lines() {
  local body="$1"
  local line filtered=""
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    case "$line" in
      ===*)
        continue
        ;;
    esac
    if is_allowlisted_legacy_path "$line"; then
      continue
    fi
    filtered+="${line}"$'\n'
  done <<<"$body"
  printf '%s' "${filtered%$'\n'}"
}

usage() {
  cat <<'EOF'
Usage: tool/check_feature_folder_contract.sh [--paths PATH...] [--strict]

Default scope: lib/features. --paths supports fixture/focused runs.
Rules:
  - Cubit/state files must live under presentation/cubit/ (or legacy cubits/)
  - No banned top-level feature layers: application/, infrastructure/, viewmodels/
Legacy drift under lib/features is allowlisted via tool/config/legacy_feature_folder_allowlist.txt unless --strict.
EOF
}

SCAN_PATHS=("lib/features")
STRICT=0
FOCUSED=0

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths)
      shift
      FOCUSED=1
      SCAN_PATHS=()
      while [[ $# -gt 0 && "$1" != --* ]]; do
        SCAN_PATHS+=("$1")
        shift
      done
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    *)
      echo "❌ Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$FOCUSED" -eq 1 && "${#SCAN_PATHS[@]}" -eq 0 ]]; then
  echo "❌ --paths requires at least one path" >&2
  exit 2
fi

declare -a RESOLVED_SCAN_PATHS=()
for scan_path in "${SCAN_PATHS[@]}"; do
  RESOLVED_SCAN_PATHS+=("$(resolve_scan_root "$scan_path")")
done
SCAN_PATHS=("${RESOLVED_SCAN_PATHS[@]}")

collect_cubit_state_files() {
  local root
  for root in "${SCAN_PATHS[@]}"; do
    if [[ -f "$root" ]]; then
      case "$root" in
        *_cubit.dart|*_state.dart)
          case "$root" in
            *.freezed.dart|*.g.dart) ;;
            *) printf '%s\n' "$root" ;;
          esac
          ;;
      esac
      continue
    fi
    [[ -d "$root" ]] || continue
    find "$root" -type f \( -name '*_cubit.dart' -o -name '*_state.dart' \) \
      ! -name '*.freezed.dart' ! -name '*.g.dart' -print 2>/dev/null || true
  done
}

echo "🔍 Checking feature folder contract..."

ERRORS=""
WARNINGS=""

append_block() {
  local bucket="$1"
  local title="$2"
  local body="$3"
  if [[ -n "$body" ]]; then
    if [[ "$bucket" == error ]]; then
      ERRORS+=$'\n'"=== ${title} ==="$'\n'"${body}"$'\n'
    else
      WARNINGS+=$'\n'"=== ${title} ==="$'\n'"${body}"$'\n'
    fi
  fi
}

while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  rel="${file#./}"
  case "$rel" in
    */presentation/*_cubit.dart|*/presentation/*_state.dart)
      case "$rel" in
        */presentation/cubit/*|*/presentation/cubits/*|*/presentation/pages/*|*/presentation/widgets/*)
          ;;
        *)
          append_block error \
            "Cubit/state must not sit at presentation/ root" \
            "$rel"
          ;;
      esac
      ;;
  esac
done < <(collect_cubit_state_files)

for root in "${SCAN_PATHS[@]}"; do
  [[ -d "$root" ]] || continue

  banned_layers=(application infrastructure viewmodels providers)
  for layer in "${banned_layers[@]}"; do
    hits="$(find "$root" -type d -path "*/$layer" -print 2>/dev/null || true)"
    if [[ -n "$hits" ]]; then
      append_block error "Banned feature layer directory: $layer" "$hits"
    fi
  done

  legacy_cubits="$(find "$root" -type d -path '*/presentation/cubits' -print 2>/dev/null || true)"
  if [[ -n "$legacy_cubits" ]]; then
    append_block warning \
      "Legacy presentation/cubits/ (new code uses presentation/cubit/ only)" \
      "$legacy_cubits"
  fi
done

is_lib_scope=0
if [[ "$FOCUSED" -eq 0 && "${#SCAN_PATHS[@]}" -eq 1 && "${SCAN_PATHS[0]}" == "lib/features" ]]; then
  is_lib_scope=1
fi

apply_legacy_allowlist=0
if [[ "$is_lib_scope" -eq 1 && "$STRICT" -eq 0 ]]; then
  apply_legacy_allowlist=1
  WARNINGS="$(filter_allowlisted_lines "$WARNINGS")"
  ERRORS="$(filter_allowlisted_lines "$ERRORS")"
fi

if [[ -n "$WARNINGS" ]]; then
  echo "$WARNINGS"
fi

if [[ -n "$ERRORS" ]]; then
  if [[ "$apply_legacy_allowlist" -eq 1 ]]; then
    echo "❌ Feature folder contract violations (not in legacy allowlist):" >&2
    echo "   Update tool/config/legacy_feature_folder_allowlist.txt only after migration." >&2
  else
    echo "❌ Feature folder contract violations:" >&2
  fi
  echo "$ERRORS" >&2
  exit 1
fi

echo "✅ Feature folder contract passed"
