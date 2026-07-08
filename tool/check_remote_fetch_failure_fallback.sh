#!/usr/bin/env bash
# Remote read ops must not use onFailureFallback that returns empty/default data.
# See docs/offline_first/dont_overwrite_guide.md § Remote fetch failures.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

MODE="${CHECK_REMOTE_FETCH_FAILURE_FALLBACK_MODE:-auto}"

usage() {
  cat <<'EOF'
Usage: tool/check_remote_fetch_failure_fallback.sh [--paths PATH...]

Fails when _executeForUser/runWithAuthUser read ops (fetchAll, load, …) use
onFailureFallback. Those fallbacks look like successful empty remote snapshots
and can trigger offline-first mass-delete on transient fetch errors.

Env: CHECK_REMOTE_FETCH_FAILURE_FALLBACK_MODE=always|auto (default auto)
EOF
}

collect_changed_files() {
  local file
  local -n out_ref="$1"
  out_ref=()
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    out_ref+=("$file")
  done < <(
    {
      git diff --name-only --diff-filter=ACMRTUXB
      git diff --cached --name-only --diff-filter=ACMRTUXB
      git ls-files --others --exclude-standard
    } | sort -u | sed '/^$/d'
  )
}

should_run_auto() {
  local file
  local -a changed_files=()

  if [ -n "${CI:-}" ]; then
    return 0
  fi

  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  collect_changed_files changed_files
  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  for file in "${changed_files[@]}"; do
    case "$file" in
      lib/features/*/data/*|\
      apps/mobile/lib/features/*/data/*|\
      lib/app/firebase/*|\
      apps/mobile/lib/app/firebase/*|\
      test/features/*/data/*offline_first*|\
      apps/mobile/test/features/*/data/*offline_first*|\
      test/features/*/data/realtime_*|\
      tool/check_remote_fetch_failure_fallback.*|\
      docs/offline_first/*|\
      docs/validation_scripts/*)
        return 0
        ;;
    esac
  done

  return 1
}

scan_paths=("apps/mobile/lib/features" "apps/mobile/lib/app/firebase")
explicit_paths=0

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  scan_paths=("$@")
  explicit_paths=1
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

case "$MODE" in
  always)
    ;;
  auto)
    if [[ "$explicit_paths" -eq 0 ]] && ! should_run_auto; then
      echo "Skipping remote fetch failure fallback guard (no relevant local changes; override with CHECK_REMOTE_FETCH_FAILURE_FALLBACK_MODE=always)"
      exit 0
    fi
    ;;
  *)
    echo "ERROR: Invalid CHECK_REMOTE_FETCH_FAILURE_FALLBACK_MODE='$MODE' (expected always or auto)." >&2
    exit 1
    ;;
esac

echo "🔍 Checking remote read ops do not swallow fetch errors (onFailureFallback)..."

python3 "$PROJECT_ROOT/tool/check_remote_fetch_failure_fallback.py" "${scan_paths[@]}"
