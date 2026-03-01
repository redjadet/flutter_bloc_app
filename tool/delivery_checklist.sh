#!/bin/bash
# Delivery Checklist Script
# Runs all delivery checklist steps in order:
# 1. flutter pub get (only when dependency metadata changed)
# 2. dart format .
# 3. flutter analyze
# 4. Best practices validation (parallel static checks + regression guards)
# 5. tool/test_coverage.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

resolve_flutter_dart() {
  local flutter_bin
  local flutter_root
  local dart_bin

  flutter_bin="$(command -v flutter || true)"
  if [ -z "$flutter_bin" ]; then
    echo "❌ 'flutter' command not found in PATH."
    exit 1
  fi

  flutter_root="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
  dart_bin="$flutter_root/bin/dart"

  if [ ! -x "$dart_bin" ]; then
    echo "❌ Flutter-managed Dart SDK not found at: $dart_bin"
    exit 1
  fi

  echo "$dart_bin"
}

detect_cpu_count() {
  local cpu_count

  if command -v getconf >/dev/null 2>&1; then
    cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)"
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
      echo "$cpu_count"
      return
    fi
  fi

  if command -v sysctl >/dev/null 2>&1; then
    cpu_count="$(sysctl -n hw.ncpu 2>/dev/null || true)"
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
      echo "$cpu_count"
      return
    fi
  fi

  if command -v nproc >/dev/null 2>&1; then
    cpu_count="$(nproc 2>/dev/null || true)"
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
      echo "$cpu_count"
      return
    fi
  fi

  echo 4
}

run_parallel_static_checks() {
  local jobs="$1"
  local tmp_dir="$2"
  local fifo="$tmp_dir/.parallel_fifo"
  local i
  local check_index
  local total_checks="${#CHECK_SCRIPTS[@]}"
  local static_failed=0

  mkfifo "$fifo"
  exec 9<>"$fifo"
  rm -f "$fifo"

  for ((i = 0; i < jobs; i++)); do
    printf 'token\n' >&9
  done

  for ((i = 0; i < total_checks; i++)); do
    check_index="$i"
    read -r -u 9 _
    {
      script="${CHECK_SCRIPTS[$check_index]}"
      message="${CHECK_MESSAGES[$check_index]}"
      log_file="$tmp_dir/check_${check_index}.log"
      status_file="$tmp_dir/check_${check_index}.status"
      check_exit=0

      {
        echo "  $message"
        if ! bash "$script"; then
          check_exit=1
        fi
      } >"$log_file" 2>&1
      echo "$check_exit" >"$status_file"
      echo "" >>"$log_file"

      printf 'token\n' >&9
    } &
  done

  wait
  exec 9>&-
  exec 9<&-

  for ((i = 0; i < total_checks; i++)); do
    cat "$tmp_dir/check_${i}.log"
    if [ "$(cat "$tmp_dir/check_${i}.status")" -ne 0 ]; then
      static_failed=1
    fi
  done

  return "$static_failed"
}

echo "🚀 Running Delivery Checklist..."
echo ""

DART_BIN="$(resolve_flutter_dart)"

# Step 1: Fetch dependencies (only if needed)
echo "📦 Step 1/5: Checking dependency state"
PACKAGE_CONFIG=".dart_tool/package_config.json"
SHOULD_RUN_PUB_GET=0
if [ ! -f "$PACKAGE_CONFIG" ]; then
  SHOULD_RUN_PUB_GET=1
elif [ "pubspec.yaml" -nt "$PACKAGE_CONFIG" ] || \
  { [ -f "pubspec.lock" ] && [ "pubspec.lock" -nt "$PACKAGE_CONFIG" ]; }; then
  SHOULD_RUN_PUB_GET=1
fi

if [ "$SHOULD_RUN_PUB_GET" -eq 1 ]; then
  echo "  Dependency metadata changed, running 'flutter pub get'"
  flutter pub get
else
  echo "  Dependencies already up-to-date, skipping 'flutter pub get'"
fi
echo "✅ Dependencies ready"
echo ""

# Step 2: Format code
echo "📝 Step 2/5: Formatting code with 'dart format .'"
"$DART_BIN" format .
echo "✅ Code formatting complete"
echo ""

# Make sure all validation scripts are executable
chmod +x tool/check_*.sh 2>/dev/null || true

VALIDATION_FAILED=0
CHECK_MESSAGES=(
  "Checking for Flutter imports in domain layer..."
  "Checking for raw Material buttons..."
  "Checking for direct Hive.openBox usage..."
  "Checking for raw Timer usage..."
  "Checking for direct GetIt usage in presentation..."
  "Checking for raw dialog APIs..."
  "Checking for raw network image usage..."
  "Checking for raw print() usage..."
  "Checking for per-widget GoogleFonts usage..."
  "Checking for side effects in build() method..."
  "Checking for missing context.mounted checks after async operations..."
  "Checking for InheritedWidget reads in Provider create callbacks..."
  "Checking for missing mounted checks before setState() after await..."
  "Checking for hard-coded colors..."
  "Checking for hard-coded strings in Text widgets..."
  "Checking for missing localization keys..."
  "Checking for missing isClosed checks before emit() in cubits..."
  "Checking for missing const constructors in StatelessWidget..."
  "Checking for data-layer imports in presentation (SOLID DIP)..."
  "Checking for presentation imports in data layer (SOLID layering)..."
  "Checking for shrinkWrap: true in presentation lists (perf)..."
  "Checking for non-builder ListView/GridView in presentation (perf)..."
  "Checking for missing RepaintBoundary around heavy widgets (perf)..."
  "Checking for unnecessary rebuilds (perf)..."
  "Checking for StreamController without close() (memory)..."
  "Checking for controllers without dispose() in presentation (memory)..."
  "Checking for potential concurrent modification issues..."
  "Checking for raw jsonDecode/jsonEncode usage (isolate optimization)..."
  "Checking for compute() usage in domain layer (architecture)..."
  "Checking for compute() usage in lifecycle methods (heuristic)..."
  "Checking for Equatable usage (Freezed preferred)..."
  "Checking for unguarded null assertion (!) usage..."
  "Checking for Row+Icon+Text overflow risk (use IconLabelRow or Flexible/Expanded)..."
)

CHECK_SCRIPTS=(
  "tool/check_flutter_domain_imports.sh"
  "tool/check_material_buttons.sh"
  "tool/check_no_hive_openbox.sh"
  "tool/check_raw_timer.sh"
  "tool/check_direct_getit.sh"
  "tool/check_raw_dialogs.sh"
  "tool/check_raw_network_images.sh"
  "tool/check_raw_print.sh"
  "tool/check_raw_google_fonts.sh"
  "tool/check_side_effects_build.sh"
  "tool/check_context_mounted.sh"
  "tool/check_inherited_widget_in_create.sh"
  "tool/check_setstate_mounted.sh"
  "tool/check_hardcoded_colors.sh"
  "tool/check_hardcoded_strings.sh"
  "tool/check_missing_localizations.sh"
  "tool/check_cubit_isclosed.sh"
  "tool/check_missing_const.sh"
  "tool/check_solid_presentation_data_imports.sh"
  "tool/check_solid_data_presentation_imports.sh"
  "tool/check_perf_shrinkwrap_lists.sh"
  "tool/check_perf_nonbuilder_lists.sh"
  "tool/check_perf_missing_repaint_boundary.sh"
  "tool/check_perf_unnecessary_rebuilds.sh"
  "tool/check_memory_unclosed_streams.sh"
  "tool/check_memory_missing_dispose.sh"
  "tool/check_concurrent_modification.sh"
  "tool/check_raw_json_decode.sh"
  "tool/check_compute_domain_layer.sh"
  "tool/check_compute_lifecycle.sh"
  "tool/check_freezed_preferred.sh"
  "tool/check_unguarded_null_assertion.sh"
  "tool/check_row_text_overflow.sh"
)

DEFAULT_CHECKLIST_JOBS="$(detect_cpu_count)"
if [ "$DEFAULT_CHECKLIST_JOBS" -gt 8 ]; then
  DEFAULT_CHECKLIST_JOBS=8
fi
if [ "$DEFAULT_CHECKLIST_JOBS" -lt 2 ]; then
  DEFAULT_CHECKLIST_JOBS=2
fi

CHECKLIST_JOBS="${CHECKLIST_JOBS:-$DEFAULT_CHECKLIST_JOBS}"
if ! [[ "$CHECKLIST_JOBS" =~ ^[0-9]+$ ]] || [ "$CHECKLIST_JOBS" -lt 1 ]; then
  echo "⚠️  Invalid CHECKLIST_JOBS='$CHECKLIST_JOBS'; using $DEFAULT_CHECKLIST_JOBS"
  CHECKLIST_JOBS="$DEFAULT_CHECKLIST_JOBS"
fi

echo "🔍 Step 3/5: Analyzing code with 'flutter analyze'"
echo ""
echo "🛡️  Step 4/5: Running best practices validation checks..."
echo ""
echo "  Running ${#CHECK_SCRIPTS[@]} static checks with $CHECKLIST_JOBS workers (in parallel with analyze)"
CHECKLIST_TMP_DIR="$(mktemp -d)"
cleanup_checklist_tmp() {
  rm -rf "$CHECKLIST_TMP_DIR"
}
trap cleanup_checklist_tmp EXIT

STATIC_CHECKS_LOG="$CHECKLIST_TMP_DIR/static_checks.log"
STATIC_CHECKS_EXIT="$CHECKLIST_TMP_DIR/static_checks.exit"
(
  if run_parallel_static_checks "$CHECKLIST_JOBS" "$CHECKLIST_TMP_DIR"; then
    echo 0 > "$STATIC_CHECKS_EXIT"
  else
    echo 1 > "$STATIC_CHECKS_EXIT"
  fi
) > "$STATIC_CHECKS_LOG" 2>&1 &
STATIC_CHECKS_PID=$!

ANALYZE_FAILED=0
if ! flutter analyze --no-pub; then
  ANALYZE_FAILED=1
fi

if ! wait "$STATIC_CHECKS_PID"; then
  :
fi

cat "$STATIC_CHECKS_LOG"
if [ -f "$STATIC_CHECKS_EXIT" ] && [ "$(cat "$STATIC_CHECKS_EXIT")" -ne 0 ]; then
  VALIDATION_FAILED=1
fi

if [ "$ANALYZE_FAILED" -ne 0 ]; then
  echo "❌ Step 3 (flutter analyze) failed."
  exit 1
fi
echo "✅ Code analysis complete"
echo ""

echo "  Running mix_lint checks..."
if ! bash tool/run_mix_lint.sh; then
  VALIDATION_FAILED=1
fi
echo ""

echo "  Running focused regression guard tests..."
bash tool/check_regression_guards.sh || VALIDATION_FAILED=1
echo ""

echo "  Running Todo keyboard/layout regression tests..."
bash tool/check_todo_keyboard_layout.sh || VALIDATION_FAILED=1
echo ""

if [ "$VALIDATION_FAILED" -eq 1 ]; then
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
