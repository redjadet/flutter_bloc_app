#!/usr/bin/env bash
# Fail when HiveRepositoryBase mutations use getBox() then write outside
# runWithBox (lost-update under the per-box mutex). See #834.
set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

MODE="${CHECK_HIVE_GETBOX_RMW_MODE:-always}"
ALLOWLIST="tool/fixtures/hive_getbox_rmw/allowlist.txt"
FIXTURE_DIR="tool/fixtures/hive_getbox_rmw"

usage() {
  cat <<'EOF'
Usage: tool/check_hive_getbox_rmw.sh [--paths PATH...]

Detects await getBox() followed by box writes / _save outside runWithBox.
Known debt is allowlisted; new violations fail. Stale allowlist entries fail.

Env: CHECK_HIVE_GETBOX_RMW_MODE=always|auto (default always)
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
      apps/mobile/lib/features/*/data/*|\
      packages/storage/lib/*|\
      tool/check_hive_getbox_rmw.sh|\
      tool/check_hive_getbox_rmw.py|\
      tool/fixtures/hive_getbox_rmw/*|\
      docs/security/storage_rules.md|\
      docs/offline_first/*)
        return 0
        ;;
    esac
  done
  return 1
}

EXPLICIT_PATHS=()
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--paths" ]]; then
  shift
  if [[ "$#" -eq 0 ]]; then
    echo "❌ --paths requires at least one path" >&2
    exit 2
  fi
  EXPLICIT_PATHS=("$@")
elif [[ "$#" -gt 0 ]]; then
  echo "❌ Unknown argument: $1" >&2
  usage >&2
  exit 2
fi

if [[ "$MODE" == "auto" && ${#EXPLICIT_PATHS[@]} -eq 0 ]]; then
  if ! should_run_auto; then
    echo "ℹ️  Skipping hive getBox RMW guard (no relevant changes)"
    exit 0
  fi
fi

echo "🔍 Checking Hive getBox RMW stays inside runWithBox..."

# Fixture self-test when present.
if [[ -f "$FIXTURE_DIR/bad_repository.dart" && -f "$FIXTURE_DIR/good_repository.dart" ]]; then
  if python3 "$TOOL_DIR/check_hive_getbox_rmw.py" --no-allowlist --paths "$FIXTURE_DIR/bad_repository.dart" >/dev/null; then
    echo "❌ Fixture self-test failed: bad_repository.dart should violate"
    exit 1
  fi
  if ! python3 "$TOOL_DIR/check_hive_getbox_rmw.py" --no-allowlist --paths "$FIXTURE_DIR/good_repository.dart"; then
    echo "❌ Fixture self-test failed: good_repository.dart should pass"
    exit 1
  fi
  echo "✅ Fixture self-test passed"
fi

if [[ ${#EXPLICIT_PATHS[@]} -gt 0 ]]; then
  python3 "$TOOL_DIR/check_hive_getbox_rmw.py" --allowlist "$ALLOWLIST" --paths "${EXPLICIT_PATHS[@]}"
else
  python3 "$TOOL_DIR/check_hive_getbox_rmw.py" --allowlist "$ALLOWLIST"
fi
