#!/usr/bin/env bash
# Regression guard: offline-first repos must not overwrite newer state with
# stale sync data. Covers remote-watch/pull applying older remote snapshots,
# TOCTOU races between initial local snapshot and per-item save/delete, and
# queued replay pushing older pending snapshots over newer remote state. See
# docs/offline_first/dont_overwrite_guide.md and
# test/features/counter/data/offline_first_counter_repository_test.dart and
# test/features/todo_list/data/offline_first_todo_repository_test.dart.

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

MERGE_GUARD_MODE="${CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE:-always}"
COUNTER_TEST="test/features/counter/data/offline_first_counter_repository_test.dart"
TODO_TEST="test/features/todo_list/data/offline_first_todo_repository_test.dart"
IOT_TEST="test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart"
GUARDED_TESTS=("$COUNTER_TEST" "$TODO_TEST" "$IOT_TEST")

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
      lib/app/sync/*|\
      apps/mobile/lib/app/sync/*|\
      lib/features/counter/data/*|\
      apps/mobile/lib/features/counter/data/*|\
      lib/features/todo_list/data/*|\
      apps/mobile/lib/features/todo_list/data/*|\
      lib/features/todo_list/domain/todo_merge_policy.dart|\
      apps/mobile/lib/features/todo_list/domain/todo_merge_policy.dart|\
      lib/features/iot_demo/data/*|\
      apps/mobile/lib/features/iot_demo/data/*|\
      test/features/counter/data/*|\
      apps/mobile/test/features/counter/data/*|\
      test/features/todo_list/data/*|\
      apps/mobile/test/features/todo_list/data/*|\
      test/features/iot_demo/data/*|\
      apps/mobile/test/features/iot_demo/data/*|\
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
  local needs_todo=0
  local needs_iot=0
  local needs_all=0

  out_ref=()

  if [ -n "${CI:-}" ]; then
    out_ref=("$COUNTER_TEST" "$TODO_TEST" "$IOT_TEST")
    return 0
  fi

  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    out_ref=("$COUNTER_TEST" "$TODO_TEST" "$IOT_TEST")
    return 0
  fi

  collect_changed_files changed_files
  if [ "${#changed_files[@]}" -eq 0 ]; then
    out_ref=("$COUNTER_TEST" "$TODO_TEST" "$IOT_TEST")
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
      lib/features/todo_list/data/*|\
      lib/features/todo_list/domain/todo_merge_policy.dart|\
      test/features/todo_list/data/*)
        needs_todo=1
        ;;
      lib/features/iot_demo/data/*|\
      test/features/iot_demo/data/*)
        needs_iot=1
        ;;
    esac
  done

  if [ "$needs_all" -eq 1 ] || { [ "$needs_counter" -eq 0 ] && [ "$needs_todo" -eq 0 ] && [ "$needs_iot" -eq 0 ]; }; then
    out_ref=("$COUNTER_TEST" "$TODO_TEST" "$IOT_TEST")
    return 0
  fi

  if [ "$needs_counter" -eq 1 ]; then
    out_ref+=("$COUNTER_TEST")
  fi
  if [ "$needs_todo" -eq 1 ]; then
    out_ref+=("$TODO_TEST")
  fi
  if [ "$needs_iot" -eq 1 ]; then
    out_ref+=("$IOT_TEST")
  fi
}

validate_guard_inventory() {
  local test_file
  local discovered_file
  local known=0
  local failed=0
  local -a discovered_files=()

  for test_file in "${GUARDED_TESTS[@]}"; do
    if [ ! -f "$test_file" ]; then
      echo "ERROR: offline-first stale-sync guard references missing test file: $test_file" >&2
      failed=1
    fi
  done

  if command -v rg >/dev/null 2>&1; then
    while IFS= read -r discovered_file; do
      [ -z "$discovered_file" ] && continue
      discovered_files+=("$discovered_file")
    done < <(
      rg -l \
        "does not push stale pending over newer remote|does not overwrite newer|does not overwrite local when there are pending|does not delete local.*when remote fetch fails|does not overwrite local when remote load fails|re-checks local before save|re-checks local before deleting" \
        test/features/*/data/*offline_first*_repository_test.dart \
        2>/dev/null || true
    )
  else
    while IFS= read -r discovered_file; do
      [ -z "$discovered_file" ] && continue
      discovered_files+=("$discovered_file")
    done < <(
      find test/features -path '*/data/*offline_first*_repository_test.dart' -type f \
        -exec grep -lE \
          "does not push stale pending over newer remote|does not overwrite newer|does not overwrite local when there are pending|does not delete local.*when remote fetch fails|does not overwrite local when remote load fails|re-checks local before save|re-checks local before deleting" \
          {} + 2>/dev/null || true
    )
  fi

  for discovered_file in "${discovered_files[@]}"; do
    known=0
    for test_file in "${GUARDED_TESTS[@]}"; do
      if [ "$discovered_file" = "$test_file" ]; then
        known=1
        break
      fi
    done
    if [ "$known" -eq 0 ]; then
      echo "ERROR: stale-sync regression test is not wired into tool/check_offline_first_remote_merge.sh: $discovered_file" >&2
      failed=1
    fi
  done

  return "$failed"
}

if ! validate_guard_inventory; then
  exit 1
fi

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

echo "🔍 Running offline-first remote-merge regression tests (don't overwrite newer state with stale sync data)..."

tests=()
select_remote_merge_tests tests

for test_file in "${tests[@]}"; do
  echo "  • $test_file"
done

flutter test --no-pub "${tests[@]}"

echo "✅ Offline-first remote-merge regression tests passed"
