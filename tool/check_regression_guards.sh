#!/usr/bin/env bash
# Runs focused regression tests for previously fixed race-condition/lifecycle bugs.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Running regression guard tests..."

tests=(
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
)

for test_file in "${tests[@]}"; do
  echo "  • $test_file"
done

flutter test --no-pub "${tests[@]}"

echo "✅ Regression guard tests passed"
