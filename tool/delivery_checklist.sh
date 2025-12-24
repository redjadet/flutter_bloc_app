#!/bin/bash
# Delivery Checklist Script
# Runs all delivery checklist steps in order:
# 1. flutter pub get
# 2. dart format .
# 3. flutter analyze
# 4. tool/test_coverage.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Running Delivery Checklist..."
echo ""

# Step 1: Fetch dependencies
echo "📦 Step 1/4: Fetching dependencies with 'flutter pub get'"
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Step 2: Format code
echo "📝 Step 2/4: Formatting code with 'dart format .'"
dart format .
echo "✅ Code formatting complete"
echo ""

# Step 3: Analyze code
echo "🔍 Step 3/4: Analyzing code with 'flutter analyze'"
flutter analyze
echo "✅ Code analysis complete"
echo ""

# Step 4: Run test coverage
echo "🧪 Step 4/4: Running test coverage with 'tool/test_coverage.sh'"
bash tool/test_coverage.sh
echo "✅ Test coverage complete"
echo ""

echo "🎉 Delivery checklist complete! All steps passed."
