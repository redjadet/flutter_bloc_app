#!/bin/bash
# Delivery Checklist Script
# Runs all delivery checklist steps in order:
# 1. dart format .
# 2. flutter analyze
# 3. tool/test_coverage.sh

set -e

echo "🚀 Running Delivery Checklist..."
echo ""

# Step 1: Format code
echo "📝 Step 1/3: Formatting code with 'dart format .'"
dart format .
echo "✅ Code formatting complete"
echo ""

# Step 2: Analyze code
echo "🔍 Step 2/3: Analyzing code with 'flutter analyze'"
flutter analyze
echo "✅ Code analysis complete"
echo ""

# Step 3: Run test coverage
echo "🧪 Step 3/3: Running test coverage with 'tool/test_coverage.sh'"
bash tool/test_coverage.sh
echo "✅ Test coverage complete"
echo ""

echo "🎉 Delivery checklist complete! All steps passed."

