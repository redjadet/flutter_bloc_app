#!/usr/bin/env bash
# Runs focused regression tests for previously fixed race-condition/lifecycle bugs.
#
# Usage:
#   tool/check_regression_guards.sh
#   CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh
#   CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths lib/shared/utils/request_id_guard.dart
#
# --paths overrides git-derived changed files in auto mode (fixture / local repro).

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REGRESSION_GUARDS_MODE="${CHECK_REGRESSION_GUARDS_MODE:-always}"
MANUAL_CHANGED_FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths)
      shift
      if [[ $# -eq 0 ]]; then
        echo "❌ --paths requires at least one path" >&2
        exit 1
      fi
      while [[ $# -gt 0 && "$1" != --* ]]; do
        MANUAL_CHANGED_FILES+=("$1")
        shift
      done
      ;;
    -h|--help)
      sed -n '1,12p' "$0" | tail -n +2
      exit 0
      ;;
    *)
      echo "❌ Unknown argument: $1 (try --paths or --help)" >&2
      exit 1
      ;;
  esac
done

ALL_TESTS=(
  "test/account_section_test.dart"
  "test/core/bootstrap/bootstrap_coordinator_additional_test.dart"
  "test/features/counter/presentation/pages/counter_page_snackbar_timeout_test.dart"
  "test/features/graphql_demo/data/graphql_demo_exception_mapper_test.dart"
  "test/features/graphql_demo/data/supabase_graphql_demo_repository_test.dart"
  "test/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit_test.dart"
  "test/features/profile/data/offline_first_profile_repository_test.dart"
  "test/features/supabase_auth/presentation/cubit/supabase_auth_cubit_test.dart"
  "test/features/websocket/data/echo_websocket_repository_test.dart"
  "test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart"
  "test/features/todo_list/data/offline_first_todo_repository_test.dart"
  "test/features/todo_list/data/realtime_database_todo_repository_test.dart"
  "test/features/todo_list/presentation/pages/todo_list_page_test.dart"
  "test/shared/firebase/run_with_auth_user_test.dart"
  "test/shared/http/auth_token_interceptor_test.dart"
  "test/shared/http/auth_token_manager_test.dart"
  "test/shared/http/retry_interceptor_test.dart"
  "test/shared/http/telemetry_interceptor_test.dart"
  "test/core/di/register_http_services_test.dart"
  "test/core/supabase/edge_then_tables_test.dart"
  "test/shared/inherited_widget_lifecycle_regression_test.dart"
  "test/shared/widgets/sync_status_banner_test.dart"
  "test/shared/sync/background_sync_coordinator_test.dart"
  "test/shared/widgets/row_overflow_regression_test.dart"
  "test/shared/widgets/action_bar_layout_regression_test.dart"
  "test/features/counter/data/offline_first_counter_repository_test.dart"
  "test/features/iot_demo/presentation/pages/iot_demo_page_test.dart"
  "test/features/realtime_market/data/simulated_market_feed_test.dart"
  "test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart"
  "test/features/online_therapy_demo/edge_cases_test.dart::reports success when superseded"
  "test/features/online_therapy_demo/presentation/cubit/call_cubit_test.dart"
  "test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart"
  "test/chat_cubit_test.dart"
)

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

add_test_once() {
  local -n tests_ref="$1"
  local candidate="$2"
  local existing

  for existing in "${tests_ref[@]}"; do
    if [ "$existing" = "$candidate" ]; then
      return 0
    fi
  done

  tests_ref+=("$candidate")
}

select_regression_guard_tests() {
  local -n out_ref="$1"
  local -a changed_files=()
  local file

  out_ref=()

  if [ -n "${CI:-}" ]; then
    out_ref=("${ALL_TESTS[@]}")
    return 0
  fi

  if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    out_ref=("${ALL_TESTS[@]}")
    return 0
  fi

  if [ "${#MANUAL_CHANGED_FILES[@]}" -gt 0 ]; then
    changed_files=("${MANUAL_CHANGED_FILES[@]}")
  else
    collect_changed_files changed_files
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    out_ref=("${ALL_TESTS[@]}")
    return 0
  fi

  for file in "${changed_files[@]}"; do
    case "$file" in
      tool/check_regression_guards.sh|\
      docs/validation_scripts.md|\
      AGENTS.md|\
      analysis_options.yaml|\
      pubspec.yaml|\
      pubspec.lock)
        out_ref=("${ALL_TESTS[@]}")
        return 0
        ;;
      lib/features/online_therapy_demo/*|\
      test/features/online_therapy_demo/*|\
      lib/shared/utils/request_id_guard.dart|\
      tool/check_mutation_success_after_guard.sh)
        add_test_once out_ref "test/features/online_therapy_demo/edge_cases_test.dart::reports success when superseded"
        add_test_once out_ref "test/features/online_therapy_demo/presentation/cubit/call_cubit_test.dart"
        add_test_once out_ref "test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart"
        ;;
      lib/features/chat/*|\
      test/features/chat/*|\
      test/chat_cubit_test.dart)
        add_test_once out_ref "test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart"
        add_test_once out_ref "test/chat_cubit_test.dart"
        ;;
      lib/shared/*|\
      test/shared/*|\
      lib/shared/sync/*|\
      test/shared/sync/*|\
      lib/core/*|\
      test/core/*)
        out_ref=("${ALL_TESTS[@]}")
        return 0
        ;;
      lib/features/settings/*|\
      test/account_section_test.dart)
        add_test_once out_ref "test/account_section_test.dart"
        ;;
      lib/features/counter/*|\
      test/features/counter/*)
        add_test_once out_ref "test/features/counter/presentation/pages/counter_page_snackbar_timeout_test.dart"
        add_test_once out_ref "test/features/counter/data/offline_first_counter_repository_test.dart"
        ;;
      lib/features/graphql_demo/*|\
      test/features/graphql_demo/*)
        add_test_once out_ref "test/features/graphql_demo/data/graphql_demo_exception_mapper_test.dart"
        add_test_once out_ref "test/features/graphql_demo/data/supabase_graphql_demo_repository_test.dart"
        ;;
      lib/features/in_app_purchase_demo/*|\
      test/features/in_app_purchase_demo/*)
        add_test_once out_ref "test/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit_test.dart"
        ;;
      lib/features/profile/*|\
      test/features/profile/*)
        add_test_once out_ref "test/features/profile/data/offline_first_profile_repository_test.dart"
        ;;
      lib/features/supabase_auth/*|\
      test/features/supabase_auth/*)
        add_test_once out_ref "test/features/supabase_auth/presentation/cubit/supabase_auth_cubit_test.dart"
        ;;
      lib/features/websocket/*|\
      test/features/websocket/*)
        add_test_once out_ref "test/features/websocket/data/echo_websocket_repository_test.dart"
        ;;
      lib/features/todo_list/*|\
      test/features/todo_list/*)
        add_test_once out_ref "test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart"
        add_test_once out_ref "test/features/todo_list/data/offline_first_todo_repository_test.dart"
        add_test_once out_ref "test/features/todo_list/data/realtime_database_todo_repository_test.dart"
        add_test_once out_ref "test/features/todo_list/presentation/pages/todo_list_page_test.dart"
        ;;
      lib/features/iot_demo/*|\
      test/features/iot_demo/*)
        add_test_once out_ref "test/features/iot_demo/presentation/pages/iot_demo_page_test.dart"
        ;;
      lib/features/realtime_market/*|\
      test/features/realtime_market/*)
        add_test_once out_ref "test/features/realtime_market/data/simulated_market_feed_test.dart"
        ;;
      lib/features/staff_app_demo/*|\
      test/features/staff_app_demo/*|\
      tool/check_row_action_overflow.sh|\
      tool/check_action_bar_layout.sh)
        add_test_once out_ref "test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart"
        add_test_once out_ref "test/shared/widgets/action_bar_layout_regression_test.dart"
        add_test_once out_ref "test/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section_layout_test.dart"
        ;;
    esac
  done

  if [ "${#out_ref[@]}" -eq 0 ]; then
    out_ref=("${ALL_TESTS[@]}")
  fi
}

run_regression_test() {
  local spec="$1"
  local file="${spec%%::*}"
  local filter="${spec#*::}"

  if [[ "$spec" == *"::"* ]]; then
    flutter test --no-pub --name "$filter" "$file"
  else
    flutter test --no-pub "$file"
  fi
}

case "$REGRESSION_GUARDS_MODE" in
  always)
    tests=("${ALL_TESTS[@]}")
    ;;
  auto)
    tests=()
    select_regression_guard_tests tests
    ;;
  *)
    echo "ERROR: Invalid CHECK_REGRESSION_GUARDS_MODE='$REGRESSION_GUARDS_MODE' (expected always or auto)." >&2
    exit 1
    ;;
esac

echo "🔍 Running regression guard tests..."

for test_file in "${tests[@]}"; do
  echo "  • $test_file"
done

for test_file in "${tests[@]}"; do
  run_regression_test "$test_file"
done

echo "✅ Regression guard tests passed"
