#!/bin/bash
# Delivery Checklist Script
# Runs all delivery checklist steps in order:
# 1. flutter pub get
# 2. dart format .
# 3. flutter analyze
# 4. Best practices validation (multiple checks)
# 5. tool/test_coverage.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Running Delivery Checklist..."
echo ""

# Step 1: Fetch dependencies
echo "📦 Step 1/5: Fetching dependencies with 'flutter pub get'"
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Step 2: Format code
echo "📝 Step 2/5: Formatting code with 'dart format .'"
dart format .
echo "✅ Code formatting complete"
echo ""

# Step 3: Analyze code
echo "🔍 Step 3/5: Analyzing code with 'flutter analyze'"
flutter analyze
echo "✅ Code analysis complete"
echo ""

# Step 4: Best practices validation
echo "🛡️  Step 4/5: Running best practices validation checks..."
echo ""

# Make sure all validation scripts are executable
chmod +x tool/check_*.sh 2>/dev/null || true

# Run all validation scripts
VALIDATION_FAILED=0

echo "  Checking for Flutter imports in domain layer..."
bash tool/check_flutter_domain_imports.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for raw Material buttons..."
bash tool/check_material_buttons.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for direct Hive.openBox usage..."
bash tool/check_no_hive_openbox.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for raw Timer usage..."
bash tool/check_raw_timer.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for direct GetIt usage in presentation..."
bash tool/check_direct_getit.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for side effects in build() method..."
bash tool/check_side_effects_build.sh || VALIDATION_FAILED=1
echo ""

if [ $VALIDATION_FAILED -eq 1 ]; then
  echo "❌ Best practices validation failed! Please fix the violations above."
  exit 1
fi

echo "✅ All best practices validation checks passed"
echo ""

# Step 5: Run test coverage
echo "🧪 Step 5/5: Running test coverage with 'tool/test_coverage.sh'"
bash tool/test_coverage.sh
echo "✅ Test coverage complete"
echo ""

echo "🎉 Delivery checklist complete! All steps passed."
