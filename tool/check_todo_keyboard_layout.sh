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
  flutter test "$TEST_FILE" --plain-name "$test_name"
done

echo "✅ Todo List keyboard/layout regressions passed"
