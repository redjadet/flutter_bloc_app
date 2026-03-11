#!/usr/bin/env bash
# Runs focused Todo List keyboard/layout regression tests.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Running Todo List keyboard/layout regression tests..."

TEST_FILE="test/features/todo_list/presentation/pages/todo_list_page_test.dart"

test_names=(
  "uses only todo list scrolling when items are present"
  "keeps search field focus when keyboard insets change"
  "keeps search focus in landscape when keyboard insets transiently clear"
  "does not overflow with iPhone-like fractional constraints and keyboard"
  "does not overflow on short-height wide layout"
)

for test_name in "${test_names[@]}"; do
  echo "  • $test_name"
done

escape_regex() {
  printf '%s' "$1" | sed -E 's/[][(){}.^$*+?|\\]/\\&/g'
}

regex_parts=()
for test_name in "${test_names[@]}"; do
  regex_parts+=("$(escape_regex "$test_name")")
done

test_name_regex="$(IFS='|'; echo "${regex_parts[*]}")"

flutter test --no-pub "$TEST_FILE" --name "$test_name_regex"

echo "✅ Todo List keyboard/layout regressions passed"
