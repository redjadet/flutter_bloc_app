#!/usr/bin/env bash
# Runs focused action-bar / OverflowBar layout regression tests.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Running action-bar layout regression tests..."

TEST_FILES=(
  "test/shared/widgets/action_bar_layout_regression_test.dart"
  "test/shared/widgets/responsive_dual_cta_row_layout_test.dart"
  "test/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section_layout_test.dart"
  "test/features/online_therapy_demo/presentation/pages/online_therapy_demo_client_booking_confirm_page_layout_test.dart"
)

for test_file in "${TEST_FILES[@]}"; do
  echo "  • $test_file"
done

flutter test --no-pub "${TEST_FILES[@]}"

echo "✅ Action-bar layout regressions passed"
