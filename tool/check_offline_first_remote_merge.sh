#!/usr/bin/env bash
# Regression guard: offline-first repos must not overwrite newer unsynced local
# state with older remote (e.g. remote watch). Prevents UI flicker (e.g. counter
# up then down then up). See AGENTS.md §5 Offline-first repositories and
# test/features/counter/data/offline_first_counter_repository_test.dart.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

MERGE_GUARD_MODE="${CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE:-always}"
COUNTER_TEST="test/features/counter/data/offline_first_counter_repository_test.dart"
IOT_TEST="test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart"

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

should_run_remote_merge_guard_auto() {
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
      lib/shared/sync/*|\
      lib/features/counter/data/*|\
      lib/features/iot_demo/data/*|\
      test/features/counter/data/*|\
      test/features/iot_demo/data/*|\
      tool/check_offline_first_remote_merge.sh|\
      docs/offline_first/*|\
      docs/engineering/offline_first_flutter_architecture_with_conflict_resolution.md|\
      docs/validation_scripts.md|\
      AGENTS.md)
        return 0
        ;;
    esac
  done

  return 1
}

select_remote_merge_tests() {
  local -n out_ref="$1"
  local file
  local -a changed_files=()
  local needs_counter=0
  local needs_iot=0
  local needs_all=0

  out_ref=()

  if [ -n "${CI:-}" ]; then
    out_ref=("$COUNTER_TEST" "$IOT_TEST")
    return 0
  fi

  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    out_ref=("$COUNTER_TEST" "$IOT_TEST")
    return 0
  fi

  collect_changed_files changed_files
  if [ "${#changed_files[@]}" -eq 0 ]; then
    out_ref=("$COUNTER_TEST" "$IOT_TEST")
    return 0
  fi

  for file in "${changed_files[@]}"; do
    case "$file" in
      lib/shared/sync/*|\
      tool/check_offline_first_remote_merge.sh|\
      docs/offline_first/*|\
      docs/engineering/offline_first_flutter_architecture_with_conflict_resolution.md|\
      docs/validation_scripts.md|\
      AGENTS.md)
        needs_all=1
        ;;
      lib/features/counter/data/*|\
      test/features/counter/data/*)
        needs_counter=1
        ;;
      lib/features/iot_demo/data/*|\
      test/features/iot_demo/data/*)
        needs_iot=1
        ;;
    esac
  done

  if [ "$needs_all" -eq 1 ] || { [ "$needs_counter" -eq 0 ] && [ "$needs_iot" -eq 0 ]; }; then
    out_ref=("$COUNTER_TEST" "$IOT_TEST")
    return 0
  fi

  if [ "$needs_counter" -eq 1 ]; then
    out_ref+=("$COUNTER_TEST")
  fi
  if [ "$needs_iot" -eq 1 ]; then
    out_ref+=("$IOT_TEST")
  fi
}

case "$MERGE_GUARD_MODE" in
  always)
    ;;
  auto)
    if ! should_run_remote_merge_guard_auto; then
      echo "Skipping offline-first remote-merge regression tests (no relevant local changes; override with CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE=always)"
      exit 0
    fi
    ;;
  *)
    echo "ERROR: Invalid CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE='$MERGE_GUARD_MODE' (expected always or auto)." >&2
    exit 1
    ;;
esac

echo "🔍 Running offline-first remote-merge regression tests (don't overwrite newer local with older remote)..."

tests=()
select_remote_merge_tests tests

for test_file in "${tests[@]}"; do
  echo "  • $test_file"
done

flutter test --no-pub "${tests[@]}"

echo "✅ Offline-first remote-merge regression tests passed"
