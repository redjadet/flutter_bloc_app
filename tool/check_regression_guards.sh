#!/usr/bin/env bash
# Runs focused regression tests for previously fixed race-condition/lifecycle bugs.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

REGRESSION_GUARDS_MODE="${CHECK_REGRESSION_GUARDS_MODE:-always}"

ALL_TESTS=(
  "test/account_section_test.dart"
  "test/core/bootstrap/bootstrap_coordinator_additional_test.dart"
  "test/features/counter/presentation/pages/counter_page_snackbar_timeout_test.dart"
  "test/features/graphql_demo/data/graphql_demo_exception_mapper_test.dart"
  "test/features/graphql_demo/data/supabase_graphql_demo_repository_test.dart"
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
  "test/shared/widgets/row_overflow_regression_test.dart"
  "test/features/counter/data/offline_first_counter_repository_test.dart"
  "test/features/iot_demo/presentation/pages/iot_demo_page_test.dart"
  "test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart"
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

  collect_changed_files changed_files
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
      pubspec.lock|\
      lib/shared/*|\
      test/shared/*|\
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
      lib/features/staff_app_demo/*|\
      test/features/staff_app_demo/*)
        add_test_once out_ref "test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart"
        ;;
    esac
  done

  if [ "${#out_ref[@]}" -eq 0 ]; then
    out_ref=("${ALL_TESTS[@]}")
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

flutter test --no-pub "${tests[@]}"

echo "✅ Regression guard tests passed"
