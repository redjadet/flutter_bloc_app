#!/usr/bin/env bash
# Runs focused regression tests for previously fixed race-condition/lifecycle bugs.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Running regression guard tests..."

tests=(
  "test/account_section_test.dart"
  "test/features/counter/presentation/pages/counter_page_snackbar_timeout_test.dart"
  "test/features/todo_list/data/offline_first_todo_repository_test.dart"
  "test/features/todo_list/data/realtime_database_todo_repository_test.dart"
  "test/features/todo_list/presentation/pages/todo_list_page_test.dart"
  "test/shared/firebase/run_with_auth_user_test.dart"
  "test/shared/inherited_widget_lifecycle_regression_test.dart"
)

for test_file in "${tests[@]}"; do
  echo "  • $test_file"
done

flutter test "${tests[@]}"

echo "✅ Regression guard tests passed"
