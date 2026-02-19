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

echo "  Checking for raw dialog APIs..."
bash tool/check_raw_dialogs.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for raw network image usage..."
bash tool/check_raw_network_images.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for raw print() usage..."
bash tool/check_raw_print.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for per-widget GoogleFonts usage..."
bash tool/check_raw_google_fonts.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for side effects in build() method..."
bash tool/check_side_effects_build.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for missing context.mounted checks after async operations..."
bash tool/check_context_mounted.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for missing mounted checks before setState() after await..."
bash tool/check_setstate_mounted.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for hard-coded colors..."
bash tool/check_hardcoded_colors.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for hard-coded strings in Text widgets..."
bash tool/check_hardcoded_strings.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for missing localization keys..."
bash tool/check_missing_localizations.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for missing isClosed checks before emit() in cubits..."
bash tool/check_cubit_isclosed.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for missing const constructors in StatelessWidget..."
bash tool/check_missing_const.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for data-layer imports in presentation (SOLID DIP)..."
bash tool/check_solid_presentation_data_imports.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for presentation imports in data layer (SOLID layering)..."
bash tool/check_solid_data_presentation_imports.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for shrinkWrap: true in presentation lists (perf)..."
bash tool/check_perf_shrinkwrap_lists.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for non-builder ListView/GridView in presentation (perf)..."
bash tool/check_perf_nonbuilder_lists.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for missing RepaintBoundary around heavy widgets (perf)..."
bash tool/check_perf_missing_repaint_boundary.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for unnecessary rebuilds (perf)..."
bash tool/check_perf_unnecessary_rebuilds.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for StreamController without close() (memory)..."
bash tool/check_memory_unclosed_streams.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for controllers without dispose() in presentation (memory)..."
bash tool/check_memory_missing_dispose.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for potential concurrent modification issues..."
bash tool/check_concurrent_modification.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for potential unnecessary rebuilds (performance)..."
bash tool/check_perf_unnecessary_rebuilds.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for raw jsonDecode/jsonEncode usage (isolate optimization)..."
bash tool/check_raw_json_decode.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for compute() usage in domain layer (architecture)..."
bash tool/check_compute_domain_layer.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for compute() usage in lifecycle methods (heuristic)..."
bash tool/check_compute_lifecycle.sh || VALIDATION_FAILED=1
echo ""

echo "  Checking for Equatable usage (Freezed preferred)..."
bash tool/check_freezed_preferred.sh || VALIDATION_FAILED=1
echo ""

echo "  Running focused regression guard tests..."
bash tool/check_regression_guards.sh || VALIDATION_FAILED=1
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
