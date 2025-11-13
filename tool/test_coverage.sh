#!/bin/bash
# Wrapper script to run flutter test with coverage and automatically update coverage reports
# This ensures coverage reports are always up-to-date after running tests
#
# Usage: tool/test_coverage.sh [additional flutter test arguments]
# Example: tool/test_coverage.sh test/features/counter/
#
# This script:
# 1. Runs `flutter test --coverage` with any provided arguments
# 2. Automatically runs `dart run tool/update_coverage_summary.dart` to update coverage reports
# 3. Updates coverage/coverage_summary.md and README.md with latest coverage percentage

set -e

echo "Running flutter test with coverage..."
flutter test --coverage "$@"

echo ""
echo "Updating coverage summary..."
dart run tool/update_coverage_summary.dart

echo ""
echo "✅ Test coverage complete! Reports updated in coverage/"

