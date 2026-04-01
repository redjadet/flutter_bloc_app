#!/bin/bash
# Delivery Checklist Script
# Runs all delivery checklist steps in order:
# 1. flutter pub get (only when dependency metadata changed)
# 2. dart format (changed Dart files only)
# 3. flutter analyze
# 4. Best practices validation (parallel static checks + mix_lint + optional focused tests)
# 5. tool/test_coverage.sh (optional via CHECKLIST_RUN_COVERAGE=0)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

CHECKLIST_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
CHECKLIST_START_EPOCH_MS="$(python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
)"
CHECKLIST_TMP_DIR=""

emit_checklist_scorecard_event() {
  local exit_code="$1"
  local checklist_status="failed"
  local checklist_pass="0"
  local ended_at
  local duration_ms
  local workspace_fingerprint

  ended_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  duration_ms="$(python3 - "$CHECKLIST_START_EPOCH_MS" <<'PY'
import sys
import time
start_ms = int(sys.argv[1])
print(max(0, int(time.time() * 1000) - start_ms))
PY
)"
  workspace_fingerprint="$(python3 "$PROJECT_ROOT/tool/validation_reuse.py" fingerprint 2>/dev/null || true)"

  if [ "$exit_code" -eq 0 ]; then
    checklist_status="ok"
    checklist_pass="1"
  fi

  "$PROJECT_ROOT/tool/emit_agent_scorecard_event.sh" \
    --command checklist \
    --status "$checklist_status" \
    --started-at "$CHECKLIST_STARTED_AT" \
    --ended-at "$ended_at" \
    --duration-ms "$duration_ms" \
    --risk-class medium \
    --workspace-fingerprint "$workspace_fingerprint" \
    --checklist-pass "$checklist_pass" \
    --router-pass null \
    --integration-pass null \
    --attempt "${ATTEMPT:-1}" >/dev/null 2>&1 || true
}

cleanup_checklist_tmp() {
  if [ -n "${CHECKLIST_TMP_DIR:-}" ] && [ -d "$CHECKLIST_TMP_DIR" ]; then
    rm -rf "$CHECKLIST_TMP_DIR"
  fi
}

checklist_on_exit() {
  local checklist_exit_code=$?
  cleanup_checklist_tmp
  emit_checklist_scorecard_event "$checklist_exit_code"
  exit "$checklist_exit_code"
}

trap checklist_on_exit EXIT

# Initialized before any function references them (set -u safe).
declare -a changed_files=()
declare -a changed_dart_files=()

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

# Bash 3.2 (macOS /bin/bash) + set -u: "${arr[@]}" in for-loops errors on empty arrays; use ${arr[@]+"${arr[@]}"} instead.
collect_changed_files() {
  changed_files=()
  changed_dart_files=()
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return
  fi

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    changed_files+=("$file")
  done < <(
    {
      git diff --name-only --diff-filter=ACMRTUXB
      git diff --cached --name-only --diff-filter=ACMRTUXB
      git ls-files --others --exclude-standard
    } | sort -u | sed '/^$/d'
  )

  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    if [[ "$file" == *.dart ]] && [ -f "$file" ]; then
      changed_dart_files+=("$file")
    fi
  done
}

should_run_mix_lint_auto() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  # In clean working trees (e.g. CI), keep running mix_lint.
  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      lib/shared/design_system/app_styles.dart|\
      lib/core/theme/mix_app_theme.dart|\
      custom_lints/*|\
      analysis_options.yaml|\
      pubspec.yaml|\
      pubspec.lock)
        return 0
        ;;
    esac
  done

  return 1
}

is_docs_only_change_set() {
  if [ "$HAS_GIT_REPO" -ne 1 ] || [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      *.md|*.mdx|*.txt|*.rst|*.adoc|\
      docs/*|\
      README|README.*|\
      CHANGELOG|CHANGELOG.*|\
      LICENSE|LICENSE.*|\
      .gitignore|\
      .cursor/*)
        ;;
      *)
        return 1
        ;;
    esac
  done

  return 0
}

should_run_todo_layout_tests_auto() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      lib/features/todo_list/*|\
      test/features/todo_list/*|\
      lib/shared/extensions/responsive.dart|\
      lib/shared/widgets/*|\
      lib/shared/ui/*|\
      lib/shared/design_system/*|\
      lib/core/theme/*|\
      lib/shared/utils/platform_adaptive*|\
      lib/shared/extensions/build_context_l10n.dart|\
      lib/shared/extensions/type_safe_bloc_access.dart)
        return 0
        ;;
    esac
  done

  return 1
}

echo "🚀 Running Delivery Checklist..."
echo ""

DART_BIN="$(resolve_flutter_dart)"
RUN_COVERAGE="${CHECKLIST_RUN_COVERAGE:-1}"
RUN_FOCUSED_TESTS="${CHECKLIST_RUN_FOCUSED_TESTS:-auto}"
RUN_MIX_LINT="${CHECKLIST_RUN_MIX_LINT:-auto}"
RUN_TODO_LAYOUT_TESTS="${CHECKLIST_RUN_TODO_LAYOUT_TESTS:-auto}"
HAS_GIT_REPO=0

if ! [[ "$RUN_COVERAGE" =~ ^(0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_COVERAGE='$RUN_COVERAGE'; using 1"
  RUN_COVERAGE=1
fi

if ! [[ "$RUN_FOCUSED_TESTS" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_FOCUSED_TESTS='$RUN_FOCUSED_TESTS'; using auto"
  RUN_FOCUSED_TESTS=auto
fi

if ! [[ "$RUN_MIX_LINT" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_MIX_LINT='$RUN_MIX_LINT'; using auto"
  RUN_MIX_LINT=auto
fi

if ! [[ "$RUN_TODO_LAYOUT_TESTS" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_TODO_LAYOUT_TESTS='$RUN_TODO_LAYOUT_TESTS'; using auto"
  RUN_TODO_LAYOUT_TESTS=auto
fi

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  HAS_GIT_REPO=1
fi

collect_changed_files

normalize_doc_links() {
  local script="$PROJECT_ROOT/tool/normalize_doc_links.py"
  local -a doc_files=()
  local file

  if [ ! -f "$script" ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -gt 0 ]; then
    for file in "${changed_files[@]+"${changed_files[@]}"}"; do
      if [[ "$file" == "README.md" || "$file" == "SECURITY.md" || ( "$file" == docs/* && "$file" == *.md ) ]]; then
        if [ -f "$file" ]; then
          doc_files+=("$file")
        fi
      fi
    done
  fi

  echo "🔗 Normalizing documentation links..."
  if [ "${#doc_files[@]}" -gt 0 ]; then
    if ! python3 "$script" "${doc_files[@]}"; then
      echo "❌ Documentation link normalization failed"
      return 1
    fi
  else
    echo "normalize_doc_links: no matching files"
  fi
  echo "✅ Documentation links normalized"
  echo ""
}

if is_docs_only_change_set; then
  echo "📝 Docs-only change set detected"
  if ! normalize_doc_links; then
    exit 1
  fi
  if ! bash "$PROJECT_ROOT/tool/validate_validation_docs.sh"; then
    echo "❌ docs/validation_scripts.md out of sync with CHECK_SCRIPTS; update the doc or run tool/validate_validation_docs.sh for details."
    exit 1
  fi

  echo "✅ Skipping dependency, analyze, validation, and coverage steps"
  echo ""
  echo "🎉 Delivery checklist complete! No code-relevant work detected."
  exit 0
fi

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
echo "📝 Step 2/5: Formatting changed Dart files"
if [ "${#changed_dart_files[@]}" -gt 0 ]; then
  echo "  Found ${#changed_dart_files[@]} changed Dart file(s)"
  "$DART_BIN" format "${changed_dart_files[@]}"
else
  echo "  No changed Dart files, skipping format"
fi
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
  "Checking for Future.delayed in lib/ (use TimerService where needed)..."
  "Checking for direct GetIt usage in presentation..."
  "Checking for raw dialog APIs..."
  "Checking for raw network image usage..."
  "Checking for raw print() usage..."
  "Checking for per-widget GoogleFonts usage..."
  "Checking for side effects in build() method..."
  "Checking for missing context.mounted checks after async operations..."
  "Checking for InheritedWidget reads in Provider create callbacks..."
  "Checking for inherited/provider reads in initState()..."
  "Checking for missing mounted checks before setState() after await..."
  "Checking for hard-coded colors..."
  "Checking for hard-coded user-facing strings..."
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
  "Checking for dialog + controller dispose anti-pattern (TextEditingController used after disposed)..."
  "Checking for potential concurrent modification issues..."
  "Checking for raw jsonDecode/jsonEncode usage (isolate optimization)..."
  "Checking for unvalidated dynamic baseUrl parsing..."
  "Checking auth refresh single-flight retry safety..."
  "Checking for compute() usage in domain layer (architecture)..."
  "Checking for compute() usage in lifecycle methods (heuristic)..."
  "Checking for Equatable usage (Freezed preferred)..."
  "Checking for unguarded null assertion (!) usage..."
  "Checking for Row+Icon+Text overflow risk (use IconLabelRow or Flexible/Expanded)..."
  "Checking for lifecycle and error-handling (snackbar/listen/dialog mounted)..."
  "Checking offline-first remote-merge (do not overwrite newer local with older remote)..."
  "Checking feature modularity (library_demo / settings cross-imports)..."
  "Checking centralized memory-pressure handling..."
)

CHECK_SCRIPTS=(
  "tool/check_flutter_domain_imports.sh"
  "tool/check_material_buttons.sh"
  "tool/check_no_hive_openbox.sh"
  "tool/check_raw_timer.sh"
  "tool/check_raw_future_delayed.sh"
  "tool/check_direct_getit.sh"
  "tool/check_raw_dialogs.sh"
  "tool/check_raw_network_images.sh"
  "tool/check_raw_print.sh"
  "tool/check_raw_google_fonts.sh"
  "tool/check_side_effects_build.sh"
  "tool/check_context_mounted.sh"
  "tool/check_inherited_widget_in_create.sh"
  "tool/check_inherited_widget_in_initstate.sh"
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
  "tool/check_dialog_controller_dispose.sh"
  "tool/check_concurrent_modification.sh"
  "tool/check_raw_json_decode.sh"
  "tool/check_unvalidated_base_url_parse.sh"
  "tool/check_auth_refresh_single_flight.sh"
  "tool/check_compute_domain_layer.sh"
  "tool/check_compute_lifecycle.sh"
  "tool/check_freezed_preferred.sh"
  "tool/check_unguarded_null_assertion.sh"
  "tool/check_row_text_overflow.sh"
  "tool/check_lifecycle_error_handling.sh"
  "tool/check_offline_first_remote_merge.sh"
  "tool/check_feature_modularity_leaks.sh"
  "tool/check_memory_pressure_centralized.sh"
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
if ! normalize_doc_links; then
  exit 1
fi
if ! bash "$PROJECT_ROOT/tool/validate_validation_docs.sh"; then
  echo "❌ docs/validation_scripts.md out of sync with CHECK_SCRIPTS; update the doc or run tool/validate_validation_docs.sh for details."
  exit 1
fi
echo "  Running ${#CHECK_SCRIPTS[@]} static checks with $CHECKLIST_JOBS workers (in parallel with analyze)"
CHECKLIST_TMP_DIR="$(mktemp -d)"

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

should_run_mix_lint=1
if [ "$RUN_MIX_LINT" = "0" ]; then
  should_run_mix_lint=0
elif [ "$RUN_MIX_LINT" = "auto" ]; then
  if ! should_run_mix_lint_auto; then
    should_run_mix_lint=0
  fi
fi

if [ "$should_run_mix_lint" -eq 1 ]; then
  echo "  Running mix_lint checks..."
  if ! bash tool/run_mix_lint.sh; then
    VALIDATION_FAILED=1
  fi
else
  echo "  Skipping mix_lint (no Mix-related changes; override with CHECKLIST_RUN_MIX_LINT=1)"
fi
echo ""

should_run_focused_tests=1
if [ "$RUN_FOCUSED_TESTS" = "0" ]; then
  should_run_focused_tests=0
elif [ "$RUN_FOCUSED_TESTS" = "auto" ] && [ "$RUN_COVERAGE" = "1" ]; then
  should_run_focused_tests=0
fi

if [ "$should_run_focused_tests" -eq 1 ]; then
  echo "  Running focused regression guard tests..."
  bash tool/check_regression_guards.sh || VALIDATION_FAILED=1
  echo ""

  should_run_todo_layout_tests=1
  if [ "$RUN_TODO_LAYOUT_TESTS" = "0" ]; then
    should_run_todo_layout_tests=0
  elif [ "$RUN_TODO_LAYOUT_TESTS" = "auto" ]; then
    if ! should_run_todo_layout_tests_auto; then
      should_run_todo_layout_tests=0
    fi
  fi

  if [ "$should_run_todo_layout_tests" -eq 1 ]; then
    echo "  Running Todo keyboard/layout regression tests..."
    bash tool/check_todo_keyboard_layout.sh || VALIDATION_FAILED=1
    echo ""
  else
    echo "  Skipping Todo keyboard/layout regression tests (no relevant Todo/layout changes; override with CHECKLIST_RUN_TODO_LAYOUT_TESTS=1)"
    echo ""
  fi
else
  echo "  Skipping focused regression suites (covered by Step 5 full coverage run)"
  echo ""
fi

if [ "$VALIDATION_FAILED" -eq 1 ]; then
  echo "❌ Best practices validation failed! Please fix the violations above."
  exit 1
fi

echo "✅ All best practices validation checks passed"
echo ""

if [ "$RUN_COVERAGE" = "1" ]; then
  # Step 5: Run test coverage
  echo "🧪 Step 5/5: Running test coverage with 'tool/test_coverage.sh'"
  bash tool/test_coverage.sh
  echo "✅ Test coverage complete"
  echo ""
else
  echo "🧪 Step 5/5: Skipped coverage (CHECKLIST_RUN_COVERAGE=0)"
  echo ""
fi

echo "🎉 Delivery checklist complete! All steps passed."
