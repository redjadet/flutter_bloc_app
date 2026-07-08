#!/bin/bash
# Delivery Checklist Script
# Runs all delivery checklist steps in order:
# 1. flutter pub get (only when dependency metadata changed)
# 2. ./bin/format --changed (changed Dart files only)
# 3. flutter analyze
# 4. Best practices validation (parallel static checks + mix_lint + file_length_lint + optional focused tests)
# 5. tool/test_coverage.sh (optional via CHECKLIST_RUN_COVERAGE=0/auto)

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$WORKSPACE_ROOT/tool/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

# shellcheck disable=SC1091
source "$WORKSPACE_ROOT/tool/resolve_flutter_dart.sh"

usage() {
  cat <<'EOF'
Usage: ./bin/checklist [options]
       ./bin/checklist-fast [options]
       tool/delivery_checklist.sh [options]

Delivery checklist gate. Default mode: full.

Options:
  -h, --help           Show help.
  --mode <full|fast>   Override CHECKLIST_MODE.
  --explain            Print detected mode inputs + changed-file summary.
  --print-changed      Print changed files (git) and exit 0.
  --no-reuse           Force rerun (sets CHECKLIST_ALLOW_REUSE=0).

Env overrides:
  CHECKLIST_MODE=full|fast
  CHECKLIST_ALLOW_REUSE=auto|0|1
  CHECKLIST_RUN_COVERAGE=auto|0|1
  CHECKLIST_RUN_FOCUSED_TESTS=auto|0|1
  CHECKLIST_RUN_MIX_LINT=auto|0|1
  CHECKLIST_RUN_FILE_LENGTH_LINT=auto|0|1
  CHECKLIST_RUN_FILE_LENGTH_LINT_INTEGRATION_TEST=auto|0|1
  CHECKLIST_RUN_TODO_LAYOUT_TESTS=auto|0|1
  CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS=auto|0|1
  CHECKLIST_RUN_ANALYZE=auto|0|1
  CHECKLIST_JOBS=<int>
EOF
}

CHECKLIST_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
CHECKLIST_START_EPOCH_MS="$(
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
  else
    echo "$(( $(date -u +%s) * 1000 ))"
  fi
)"
CHECKLIST_TMP_DIR=""
CHECKLIST_CACHE_DIR="$WORKSPACE_ROOT/.dart_tool/checklist"
CHECKLIST_CONFIG_CACHE_FILE="$CHECKLIST_CACHE_DIR/config_validation.sha256"
CHECKLIST_EMIT_SCORECARD=1

emit_checklist_scorecard_event() {
  local exit_code="$1"
  local checklist_status="failed"
  local checklist_pass="0"
  local ended_at
  local duration_ms
  local workspace_fingerprint

  ended_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  duration_ms="$(
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$CHECKLIST_START_EPOCH_MS" <<'PY'
import sys
import time
start_ms = int(sys.argv[1])
print(max(0, int(time.time() * 1000) - start_ms))
PY
    else
      echo "$(( $(date -u +%s) * 1000 - CHECKLIST_START_EPOCH_MS ))"
    fi
  )"
  workspace_fingerprint="$(
    if command -v python3 >/dev/null 2>&1; then
      python3 "$WORKSPACE_ROOT/tool/validation_reuse.py" fingerprint 2>/dev/null || true
    else
      echo ""
    fi
  )"

  if [ "$exit_code" -eq 0 ]; then
    checklist_status="ok"
    checklist_pass="1"
  fi

  "$WORKSPACE_ROOT/tool/emit_agent_scorecard_event.sh" \
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
  if [ "${CHECKLIST_EMIT_SCORECARD:-1}" = "1" ]; then
    emit_checklist_scorecard_event "$checklist_exit_code"
  fi
  exit "$checklist_exit_code"
}

trap checklist_on_exit EXIT

# Initialized before any function references them (set -u safe).
declare -a changed_files=()
declare -a changed_dart_files=()
CHECKLIST_ALLOW_REUSE="${CHECKLIST_ALLOW_REUSE:-auto}"

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

compute_validation_cache_key() {
  python3 - "$WORKSPACE_ROOT" "$@" <<'PY'
from __future__ import annotations

import hashlib
import sys
from pathlib import Path

project_root = Path(sys.argv[1])
digest = hashlib.sha256()

for relative_path in sys.argv[2:]:
    path = project_root / relative_path
    digest.update(relative_path.encode("utf-8"))
    if not path.exists():
        digest.update(b":missing")
        continue
    stat = path.stat()
    digest.update(str(stat.st_mtime_ns).encode("utf-8"))
    digest.update(str(stat.st_size).encode("utf-8"))

print(digest.hexdigest())
PY
}

has_matching_validation_cache() {
  local cache_file="$1"
  local cache_key="$2"

  if [ ! -f "$cache_file" ]; then
    return 1
  fi

  [ "$(cat "$cache_file")" = "$cache_key" ]
}

write_validation_cache() {
  local cache_file="$1"
  local cache_key="$2"

  mkdir -p "$(dirname "$cache_file")"
  printf '%s\n' "$cache_key" >"$cache_file"
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

should_attempt_checklist_reuse() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi

  if [ ! -f "$WORKSPACE_ROOT/tool/validation_reuse.py" ]; then
    return 1
  fi

  case "$CHECKLIST_ALLOW_REUSE" in
    1)
      return 0
      ;;
    0)
      return 1
      ;;
    auto)
      return 0
      ;;
    *)
      echo "⚠️  Invalid CHECKLIST_ALLOW_REUSE='$CHECKLIST_ALLOW_REUSE'; using auto"
      CHECKLIST_ALLOW_REUSE=auto
      return 0
      ;;
  esac
}

reuse_checklist_if_available() {
  if ! should_attempt_checklist_reuse; then
    return 1
  fi

  if python3 "$WORKSPACE_ROOT/tool/validation_reuse.py" find --command checklist >/dev/null 2>&1; then
    echo "♻️  Reusing previous successful checklist run for the exact current worktree fingerprint"
    echo "    Set CHECKLIST_ALLOW_REUSE=0 to force a full rerun."
    echo ""
    echo "✅ Delivery checklist complete (reused prior passing run)."
    return 0
  fi

  return 1
}

# dart analyze on explicit paths under tool/** still loads root analyzer plugins
# (file_length_lint, mix_lint) even though tool/** is excluded from normal analysis.
# That plugin graph can hang indefinitely on standalone tool scripts.
validate_standalone_dart_syntax() {
  local -a files=("$@")
  local file
  local tmp_dill=""

  if [ "${#files[@]}" -eq 0 ]; then
    return 0
  fi

  for file in "${files[@]}"; do
    tmp_dill="$(mktemp "${TMPDIR:-/tmp}/checklist-dart-syntax.XXXXXX.dill")"
    if ! dart compile kernel --output "$tmp_dill" "$file"; then
      rm -f "$tmp_dill"
      return 1
    fi
    rm -f "$tmp_dill"
  done
  return 0
}

validate_checklist_configuration() {
  local failed=0
  local script
  local syntax_exit=0
  local -a dart_analyze_files=()
  local total_messages="${#CHECK_MESSAGES[@]}"
  local total_scripts="${#CHECK_SCRIPTS[@]}"
  local cache_key=""
  local extra_scripts=(
    "tool/resolve_flutter_dart.sh"
    "tool/run_mix_lint.sh"
    "tool/run_file_length_lint.sh"
    "tool/run_file_length_lint_test.py"
    "tool/test_coverage.sh"
    "tool/check_regression_guards.sh"
    "tool/check_todo_keyboard_layout.sh"
    "tool/validate_validation_docs.sh"
    "tool/patch_flutter_secure_storage_darwin_swiftpm.sh"
    "tool/check_agent_asset_drift.sh"
    "tool/check_agent_knowledge_base.sh"
    "tool/check_agent_memory_compounding.sh"
    "tool/check_docs_gardening.sh"
    "tool/check_checklist_cli_contract.sh"
    "tool/check_macos_debug_web_guard.sh"
    "tool/validate_task_trackers.sh"
    "tool/run_harness_fixtures.sh"
    "tool/agent_session_bootstrap.sh"
    "tool/check_widget_identity.sh"
    "tool/check_widget_identity.dart"
  )

  if [ "$total_messages" -ne "$total_scripts" ]; then
    echo "❌ CHECK_MESSAGES/CHECK_SCRIPTS length mismatch: $total_messages messages vs $total_scripts scripts"
    return 1
  fi

  if declare -p CHECK_SCRIPT_THEMES &>/dev/null; then
    local total_themes="${#CHECK_SCRIPT_THEMES[@]}"
    if [ "$total_themes" -ne "$total_scripts" ]; then
      echo "❌ CHECK_SCRIPT_THEMES/CHECK_SCRIPTS length mismatch: $total_themes themes vs $total_scripts scripts"
      failed=1
    fi
  fi

  for script in "${CHECK_SCRIPTS[@]}" "${extra_scripts[@]}"; do
    if [ ! -f "$WORKSPACE_ROOT/$script" ]; then
      echo "❌ Missing checklist dependency: $script"
      failed=1
    fi
  done

  if [ "$failed" -ne 0 ]; then
    return 1
  fi

  validation_doc_cache_inputs=( "docs/validation_scripts.md" )
  if [ -d "$WORKSPACE_ROOT/docs/validation_scripts" ]; then
    while IFS= read -r shard; do
      validation_doc_cache_inputs+=( "${shard#"$WORKSPACE_ROOT/"}" )
    done < <(find "$WORKSPACE_ROOT/docs/validation_scripts" -maxdepth 1 -name '*.md' -print | LC_ALL=C sort)
  fi

  cache_key="$(compute_validation_cache_key \
    "tool/delivery_checklist.sh" \
    "${CHECK_SCRIPTS[@]}" \
    "${extra_scripts[@]}" \
    "${validation_doc_cache_inputs[@]}")"
  if has_matching_validation_cache "$CHECKLIST_CONFIG_CACHE_FILE" "$cache_key"; then
    return 0
  fi

  for script in "${CHECK_SCRIPTS[@]}" "${extra_scripts[@]}"; do
    case "$script" in
      *.sh|bin/*)
        if ! bash -n "$WORKSPACE_ROOT/$script"; then
          syntax_exit=1
        fi
        ;;
      *.dart)
        dart_analyze_files+=("$WORKSPACE_ROOT/$script")
        ;;
    esac
  done

  if [ "${#dart_analyze_files[@]}" -gt 0 ]; then
    if ! validate_standalone_dart_syntax "${dart_analyze_files[@]}"; then
      syntax_exit=1
    fi
  fi

  if [ "$syntax_exit" -ne 0 ]; then
    echo "❌ Checklist script syntax validation failed"
    return 1
  fi

  if ! bash "$WORKSPACE_ROOT/tool/validate_validation_docs.sh"; then
    echo "❌ validation_scripts docs out of sync with tool/check_*.sh inventory or catalog counts; update shards or run tool/validate_validation_docs.sh for details."
    return 1
  fi

  write_validation_cache "$CHECKLIST_CONFIG_CACHE_FILE" "$cache_key"
}

validate_docs_only_dependencies() {
  local failed=0
  local script
  local docs_only_scripts=(
    "tool/validate_validation_docs.sh"
    "tool/check_agent_asset_drift.sh"
    "tool/check_agent_knowledge_base.sh"
    "tool/check_agent_memory_compounding.sh"
    "tool/check_docs_gardening.sh"
    "tool/check_checklist_cli_contract.sh"
    "tool/validate_task_trackers.sh"
    "tool/run_harness_fixtures.sh"
    "tool/agent_session_bootstrap.sh"
  )

  for script in "${docs_only_scripts[@]}"; do
    if [ ! -f "$WORKSPACE_ROOT/$script" ]; then
      echo "❌ Missing docs-only checklist dependency: $script"
      failed=1
      continue
    fi
    if ! bash -n "$WORKSPACE_ROOT/$script"; then
      failed=1
    fi
  done

  if [ "$failed" -ne 0 ]; then
    echo "❌ Docs-only checklist dependency validation failed"
    return 1
  fi
}

validate_tooling_only_dependencies() {
  local failed=0
  local file
  local -a dart_analyze_files=()
  local -a python_test_files=()

  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      *.sh|bin/*)
        if [ ! -f "$WORKSPACE_ROOT/$file" ]; then
          echo "❌ Missing tooling file: $file"
          failed=1
          continue
        fi
        if ! bash -n "$WORKSPACE_ROOT/$file"; then
          failed=1
        fi
        ;;
      *.dart)
        if [ ! -f "$WORKSPACE_ROOT/$file" ]; then
          echo "❌ Missing tooling file: $file"
          failed=1
          continue
        fi
        dart_analyze_files+=("$WORKSPACE_ROOT/$file")
        ;;
      tool/*_test.py)
        if [ ! -f "$WORKSPACE_ROOT/$file" ]; then
          echo "❌ Missing tooling test file: $file"
          failed=1
          continue
        fi
        python_test_files+=("$file")
        ;;
    esac
  done

  if [ "${#dart_analyze_files[@]}" -gt 0 ]; then
    if ! validate_standalone_dart_syntax "${dart_analyze_files[@]}"; then
      failed=1
    fi
  fi

  if [ "${#python_test_files[@]}" -gt 0 ]; then
    if ! python3 -m unittest "${python_test_files[@]}"; then
      failed=1
    fi
  fi

  if [ "$failed" -ne 0 ]; then
    echo "❌ Tooling-only syntax validation failed"
    return 1
  fi
}

# Bash 3.2 (macOS /bin/bash) + set -u: "${arr[@]}" in for-loops errors on empty arrays; use ${arr[@]+"${arr[@]}"} instead.
collect_changed_files_from_worktree() {
  {
    git diff --name-only --diff-filter=ACDMRTUXB
    git diff --cached --name-only --diff-filter=ACDMRTUXB
    git ls-files --others --exclude-standard
  }
}

collect_changed_files_from_ci() {
  local event_name="${GITHUB_EVENT_NAME:-}"

  if [ "$HAS_GIT_REPO" -ne 1 ] || [ -z "${CI:-}" ]; then
    return 1
  fi

  case "$event_name" in
    pull_request|pull_request_target)
      # GitHub Actions usually checks out a synthetic merge commit for PRs.
      # Diff against the base parent when available so CI can recover branch scope
      # even from a clean checkout with no local git diff.
      if git rev-parse --verify HEAD^1 >/dev/null 2>&1; then
        git diff --name-only --diff-filter=ACDMRTUXB HEAD^1..HEAD
        return 0
      fi

      if [ -n "${GITHUB_BASE_REF:-}" ]; then
        local remote_base="origin/$GITHUB_BASE_REF"
        local merge_base=""
        git fetch --no-tags --depth=50 origin \
          "+refs/heads/$GITHUB_BASE_REF:refs/remotes/origin/$GITHUB_BASE_REF" >/dev/null 2>&1 || true
        if git rev-parse --verify "$remote_base" >/dev/null 2>&1; then
          merge_base="$(git merge-base HEAD "$remote_base" 2>/dev/null || true)"
          if [ -n "$merge_base" ]; then
            git diff --name-only --diff-filter=ACDMRTUXB "$merge_base"...HEAD
            return 0
          fi
        fi
      fi
      ;;
    push|merge_group)
      if git rev-parse --verify HEAD^ >/dev/null 2>&1; then
        git diff --name-only --diff-filter=ACDMRTUXB HEAD^..HEAD
      else
        git show --pretty='' --name-only --diff-filter=ACDMRTUXB HEAD
      fi
      return 0
      ;;
  esac

  return 1
}

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
      if [ -n "${CI:-}" ] && collect_changed_files_from_ci; then
        :
      else
        collect_changed_files_from_worktree
      fi
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
      packages/design_system/lib/src/styles/app_styles.dart|\
      packages/design_system/lib/src/theme/mix_app_theme.dart|\
      lib/app/theme/*|\
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

should_run_file_length_lint_auto() {
  should_run_flutter_analyze_auto
}

should_run_file_length_lint_integration_test_auto() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      custom_lints/file_length_lint/*|\
      analysis_options.yaml|\
      tool/run_file_length_lint.sh|\
      tool/run_file_length_lint_test.py)
        return 0
        ;;
    esac
  done

  return 1
}

should_run_pubspec_codegen_compat_preflight() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      pubspec.yaml|pubspec.lock)
        return 0
        ;;
    esac
  done

  return 1
}

run_pubspec_codegen_compat_preflight_if_needed() {
  if ! should_run_pubspec_codegen_compat_preflight; then
    return 0
  fi

  echo "🧩 Checking pubspec codegen/analyzer compatibility before dependency resolution"
  if ! bash "$WORKSPACE_ROOT/tool/check_pubspec_codegen_compat.sh"; then
    echo "❌ Pubspec codegen/analyzer compatibility failed; fix pubspec before running flutter pub get."
    return 1
  fi
  echo ""
}

is_docs_only_change_set() {
  if [ "$HAS_GIT_REPO" -ne 1 ] || [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      *.md|*.mdx|*.txt|*.rst|*.adoc|\
      .markdownlintignore|\
      .markdownlint-cli2ignore|\
      docs/*|\
      tool/agent_host_templates/*|\
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

is_tooling_only_change_set() {
  if [ -n "${CI:-}" ] || [ "$HAS_GIT_REPO" -ne 1 ] || [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      tool/*.sh|\
      tool/*.dart|\
      tool/*_test.py|\
      tool/direnv/bin/*|\
      bin/*|\
      tool/agent_host_templates/*|\
      tool/fixtures/harness/*|\
      AGENTS.md|\
      .markdownlintignore|\
      .markdownlint-cli2ignore|\
      docs/agents_quick_reference.md|\
      docs/validation_scripts.md|\
      docs/validation_scripts/*|\
      docs/testing_overview.md|\
      docs/new_developer_guide.md|\
      docs/engineering/validation_routing_fast_vs_full.md)
        ;;
      *)
        return 1
        ;;
    esac
  done

  return 0
}

is_checklist_fast_compatible_change_set() {
  if [ -n "${CI:-}" ] || [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 1
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    if ! is_checklist_fast_compatible_path "$file"; then
      return 1
    fi
  done

  return 0
}

is_checklist_fast_compatible_path() {
  local file="$1"
  case "$file" in
    tool/*.sh|\
    tool/*.dart|\
    tool/*_test.py|\
    tool/direnv/bin/*|\
    bin/*|\
    tool/agent_host_templates/*|\
    tool/fixtures/harness/*|\
    pyrightconfig.json|\
    demos/render_chat_api/pyrightconfig.json|\
    AGENTS.md|\
    CODEMAP.md|\
    PLAN.md|\
    DESIGN.md|\
    .markdownlintignore|\
    .markdownlint-cli2ignore|\
    docs/*|\
    llms.txt|\
    tasks/*.md|\
    README|README.*|\
    CHANGELOG|CHANGELOG.*|\
    LICENSE|LICENSE.*|\
    .gitignore|\
    .cursor/*|\
    .vscode/tasks.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}


should_run_router_feature_validate_auto() {
  if [ "${CHECKLIST_SKIP_ROUTER_VALIDATE:-0}" = "1" ]; then
    return 1
  fi
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi
  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi
  local rule_file="$WORKSPACE_ROOT/.cursor/rules/router-feature-validation.mdc"
  if [ ! -f "$rule_file" ] || ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi
  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    if python3 - "$rule_file" "$file" <<'PY'
import fnmatch
import sys
from pathlib import Path
rule_text = Path(sys.argv[1]).read_text(encoding="utf-8")
path = sys.argv[2]
globs = []
in_globs = False
for line in rule_text.splitlines():
    stripped = line.strip()
    if stripped.startswith("globs:"):
        rest = stripped[len("globs:"):].strip()
        if rest:
            globs = [g.strip() for g in rest.split(",") if g.strip()]
            break
        in_globs = True
        continue
    if in_globs:
        if stripped.startswith("- "):
            globs.append(stripped[2:].strip())
            continue
        if stripped and not stripped.startswith("#"):
            break
if not globs:
    raise SystemExit(1)
expanded = list(globs)
for pattern in globs:
    if pattern.endswith("/router/**/*.dart"):
        expanded.append(pattern.replace("/router/**/*.dart", "/router/*.dart"))
if any(fnmatch.fnmatch(path, pattern) for pattern in expanded):
    raise SystemExit(0)
raise SystemExit(1)
PY
    then
      return 0
    fi
  done
  return 1
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
      packages/design_system/lib/src/responsive/*|\
      packages/design_system/lib/src/widgets/*|\
      packages/design_system/lib/src/ui/*|\
      packages/design_system/lib/src/theme/*|\
      lib/app/theme/*|\
      lib/app/widgets/*|\
      packages/design_system/lib/src/platform_adaptive/*|\
      lib/app/extensions/build_context_l10n.dart|\
      lib/app/extensions/type_safe_bloc_access.dart)
        return 0
        ;;
    esac
  done

  return 1
}

should_run_action_bar_layout_tests_auto() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      lib/features/profile/presentation/*|\
      lib/features/settings/presentation/*|\
      lib/features/*/presentation/widgets/*|\
      lib/features/*/presentation/widgets/*dialog*|\
      lib/features/*/*dialog*.dart|\
      lib/features/*/presentation/forms/*|\
      lib/features/*/*actions_bar*.dart|\
      lib/features/*/*action_bar*.dart|\
      packages/design_system/lib/src/widgets/common_form_field.dart|\
      packages/design_system/lib/src/platform_adaptive/*|\
      packages/design_system/lib/src/responsive/*|\
      test/features/staff_app_demo/presentation/widgets/*|\
      test/shared/widgets/action_bar_layout_regression_test.dart|\
      tool/check_row_action_overflow.sh|\
      tool/check_action_bar_layout.sh)
        return 0
        ;;
    esac
  done

  return 1
}

should_run_agent_asset_drift_check() {
  if [ "$HAS_GIT_REPO" -ne 1 ] || [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      AGENTS.md|\
      docs/agents_quick_reference.md|\
      docs/ai_code_review_protocol.md|\
      tool/agent_host_templates/*)
        return 0
        ;;
    esac
  done

  return 1
}

should_run_flutter_analyze_auto() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      *.dart|\
      analysis_options.yaml|\
      pubspec.yaml|\
      pubspec.lock|\
      l10n.yaml|\
      lib/l10n/*.arb|\
      custom_lints/*)
        return 0
        ;;
    esac
  done

  return 1
}

should_run_coverage_auto() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      *.dart|\
      analysis_options.yaml|\
      pubspec.yaml|\
      pubspec.lock|\
      l10n.yaml|\
      lib/l10n/*.arb|\
      lib/*|\
      test/*|\
      integration_test/*|\
      android/*|\
      ios/*|\
      macos/*|\
      linux/*|\
      windows/*|\
      web/*|\
      custom_lints/*)
        return 0
        ;;
    esac
  done

  return 1
}

should_run_regression_guards_before_coverage() {
  if [ "$HAS_GIT_REPO" -ne 1 ] || [ "${#changed_files[@]}" -eq 0 ]; then
    return 1
  fi

  local file
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    case "$file" in
      lib/shared/utils/request_id_guard.dart|\
      packages/utilities/lib/src/request_id_guard.dart|\
      lib/app/presentation/cubit/app_auth_cubit.dart|\
      lib/app/presentation/cubit/app_auth_state.dart|\
      lib/app/auth/*|\
      lib/app/composition/features/register_auth_services.dart|\
      test/app/presentation/cubit/app_auth_cubit_test.dart|\
      test/app/auth/*|\
      lib/features/chat/*|\
      test/features/chat/*|\
      lib/features/online_therapy_demo/*|\
      test/features/online_therapy_demo/*|\
      tool/check_mutation_success_after_guard.sh|\
      tool/check_regression_guards.sh)
        return 0
        ;;
    esac
  done

  return 1
}

CHECKLIST_MODE="${CHECKLIST_MODE:-full}"
RUN_COVERAGE="${CHECKLIST_RUN_COVERAGE:-auto}"
RUN_FOCUSED_TESTS="${CHECKLIST_RUN_FOCUSED_TESTS:-auto}"
RUN_MIX_LINT="${CHECKLIST_RUN_MIX_LINT:-auto}"
RUN_FILE_LENGTH_LINT="${CHECKLIST_RUN_FILE_LENGTH_LINT:-auto}"
RUN_FILE_LENGTH_LINT_INTEGRATION_TEST="${CHECKLIST_RUN_FILE_LENGTH_LINT_INTEGRATION_TEST:-auto}"
RUN_TODO_LAYOUT_TESTS="${CHECKLIST_RUN_TODO_LAYOUT_TESTS:-auto}"
RUN_ACTION_BAR_LAYOUT_TESTS="${CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS:-auto}"
RUN_ANALYZE="${CHECKLIST_RUN_ANALYZE:-auto}"
HAS_GIT_REPO=0
CHECKLIST_EXPLAIN="${CHECKLIST_EXPLAIN:-0}"
CHECKLIST_EXPLAIN_THEMES="${CHECKLIST_EXPLAIN_THEMES:-0}"
CHECKLIST_PRINT_CHANGED="${CHECKLIST_PRINT_CHANGED:-0}"
CHECKLIST_MODE_FROM_ARG=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      CHECKLIST_EMIT_SCORECARD=0
      usage
      exit 0
      ;;
    --mode)
      CHECKLIST_MODE="${2:-}"
      CHECKLIST_MODE_FROM_ARG=1
      if [[ -z "$CHECKLIST_MODE" || "$CHECKLIST_MODE" == -* ]]; then
        CHECKLIST_EMIT_SCORECARD=0
        echo "usage-error|--mode requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --no-reuse)
      CHECKLIST_ALLOW_REUSE=0
      shift
      ;;
    --explain)
      CHECKLIST_EXPLAIN=1
      shift
      ;;
    --print-changed)
      CHECKLIST_PRINT_CHANGED=1
      shift
      ;;
    *)
      CHECKLIST_EMIT_SCORECARD=0
      echo "usage-error|unknown arg: $1" >&2
      echo "hint|use --help" >&2
      exit 2
      ;;
  esac
done

if ! [[ "$CHECKLIST_MODE" =~ ^(full|fast)$ ]]; then
  if [ "$CHECKLIST_MODE_FROM_ARG" = "1" ]; then
    CHECKLIST_EMIT_SCORECARD=0
    echo "usage-error|invalid --mode: $CHECKLIST_MODE" >&2
    echo "hint|use --mode full or --mode fast" >&2
    exit 2
  fi
  echo "⚠️  Invalid CHECKLIST_MODE='$CHECKLIST_MODE'; using full"
  CHECKLIST_MODE=full
fi

if ! [[ "$RUN_COVERAGE" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_COVERAGE='$RUN_COVERAGE'; using auto"
  RUN_COVERAGE=auto
fi

if ! [[ "$RUN_FOCUSED_TESTS" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_FOCUSED_TESTS='$RUN_FOCUSED_TESTS'; using auto"
  RUN_FOCUSED_TESTS=auto
fi

if ! [[ "$RUN_MIX_LINT" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_MIX_LINT='$RUN_MIX_LINT'; using auto"
  RUN_MIX_LINT=auto
fi
if ! [[ "$RUN_FILE_LENGTH_LINT" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_FILE_LENGTH_LINT='$RUN_FILE_LENGTH_LINT'; using auto"
  RUN_FILE_LENGTH_LINT=auto
fi
if ! [[ "$RUN_FILE_LENGTH_LINT_INTEGRATION_TEST" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_FILE_LENGTH_LINT_INTEGRATION_TEST='$RUN_FILE_LENGTH_LINT_INTEGRATION_TEST'; using auto"
  RUN_FILE_LENGTH_LINT_INTEGRATION_TEST=auto
fi

if ! [[ "$RUN_TODO_LAYOUT_TESTS" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_TODO_LAYOUT_TESTS='$RUN_TODO_LAYOUT_TESTS'; using auto"
  RUN_TODO_LAYOUT_TESTS=auto
fi

if ! [[ "$RUN_ACTION_BAR_LAYOUT_TESTS" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS='$RUN_ACTION_BAR_LAYOUT_TESTS'; using auto"
  RUN_ACTION_BAR_LAYOUT_TESTS=auto
fi

if ! [[ "$RUN_ANALYZE" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_RUN_ANALYZE='$RUN_ANALYZE'; using auto"
  RUN_ANALYZE=auto
fi

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  HAS_GIT_REPO=1
fi

if ! [[ "$CHECKLIST_ALLOW_REUSE" =~ ^(auto|0|1)$ ]]; then
  echo "⚠️  Invalid CHECKLIST_ALLOW_REUSE='$CHECKLIST_ALLOW_REUSE'; using auto"
  CHECKLIST_ALLOW_REUSE=auto
fi

collect_changed_files

print_changed_files_summary() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    echo "changed_files|git|unavailable"
    return 0
  fi
  if [ "${#changed_files[@]}" -eq 0 ]; then
    echo "changed_files|count|0"
    return 0
  fi
  echo "changed_files|count|${#changed_files[@]}"
  local f
  for f in "${changed_files[@]+"${changed_files[@]}"}"; do
    echo "changed_files|path|$f"
  done
}

if [ "$CHECKLIST_EXPLAIN" = "1" ]; then
  echo "explain|mode|$CHECKLIST_MODE"
  echo "explain|allow_reuse|$CHECKLIST_ALLOW_REUSE"
  print_changed_files_summary
  echo ""
fi

if [ "$CHECKLIST_PRINT_CHANGED" = "1" ]; then
  CHECKLIST_EMIT_SCORECARD=0
  if [ "$CHECKLIST_EXPLAIN" != "1" ]; then
    print_changed_files_summary
  fi
  exit 0
fi

print_flutter_resolution_report || true
echo ""
echo "🚀 Running Delivery Checklist..."
echo ""

if reuse_checklist_if_available; then
  exit 0
fi

normalize_doc_links() {
  local script="$WORKSPACE_ROOT/tool/normalize_doc_links.py"
  local -a doc_files=()
  local file

  if [ ! -f "$script" ]; then
    return 0
  fi

  if [ "${#changed_files[@]}" -gt 0 ]; then
    for file in "${changed_files[@]+"${changed_files[@]}"}"; do
      if [[ "$file" == "README.md" || "$file" == "SECURITY.md" || "$file" == "AGENTS.md" || ( "$file" == docs/* && "$file" == *.md ) || ( "$file" == tool/agent_host_templates/* && "$file" == *.md ) ]]; then
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

collect_changed_doc_files() {
  local -a out=()
  local file

  if [ "${#changed_files[@]}" -gt 0 ]; then
    for file in "${changed_files[@]+"${changed_files[@]}"}"; do
      if [[ "$file" == "README.md" || "$file" == "SECURITY.md" || "$file" == "AGENTS.md" || ( "$file" == docs/* && "$file" == *.md ) ]]; then
        if [ -f "$file" ]; then
          out+=("$file")
        fi
      fi
    done
  fi

  if [ "${#out[@]}" -eq 0 ]; then
    return 1
  fi

  printf '%s\n' "${out[@]}"
}

run_harness_docs_checks() {
  local -a doc_files=()
  local file

  while IFS= read -r file; do
    [ -n "$file" ] && doc_files+=("$file")
  done < <(collect_changed_doc_files || true)

  if [ "${#doc_files[@]}" -gt 0 ]; then
    if ! bash "$WORKSPACE_ROOT/tool/check_docs_gardening.sh" --paths "${doc_files[@]}"; then
      echo "❌ Doc gardening checks failed; fix broken doc references or validation doc drift."
      return 1
    fi
  else
    if ! bash "$WORKSPACE_ROOT/tool/check_docs_gardening.sh"; then
      echo "❌ Doc gardening checks failed; fix broken doc references or validation doc drift."
      return 1
    fi
  fi

  if ! bash "$WORKSPACE_ROOT/tool/validate_task_trackers.sh"; then
    echo "❌ Task tracker contract failed; update tasks/*/todo.md to match the canonical template."
    return 1
  fi

  if ! bash "$WORKSPACE_ROOT/tool/run_harness_fixtures.sh"; then
    echo "❌ Harness fixture tests failed; fix harness scripts or fixtures."
    return 1
  fi

  if ! bash "$WORKSPACE_ROOT/tool/check_harness_scorecard_gate.sh"; then
    echo "❌ Harness scorecard gate failed; keep Cursor/Codex max-score docs and proof gates in sync."
    return 1
  fi
}

print_checklist_fast_incompatibilities() {
  if [ "$HAS_GIT_REPO" -ne 1 ]; then
    return 0
  fi
  if [ "${#changed_files[@]}" -eq 0 ]; then
    return 0
  fi

  local file
  local mismatches=0
  for file in "${changed_files[@]+"${changed_files[@]}"}"; do
    if is_checklist_fast_compatible_path "$file"; then
      continue
    fi
    if [ "$mismatches" -eq 0 ]; then
      echo ""
      echo "checklist-fast|incompatible_files|begin"
    fi
    echo "  - $file"
    mismatches=1
  done

  if [ "$mismatches" -ne 0 ]; then
    echo "checklist-fast|incompatible_files|end"
  fi
}

if [ "$CHECKLIST_MODE" = "fast" ]; then
  if [ -n "${CI:-}" ]; then
    echo "❌ checklist-fast is local-only. Use ./bin/checklist on CI."
    exit 1
  fi

  if ! is_checklist_fast_compatible_change_set; then
    echo "❌ checklist-fast only supports clean trees or narrow local docs/tooling change sets."
    echo "   Use ./bin/checklist or targeted validation for app/runtime changes."
    print_checklist_fast_incompatibilities
    exit 1
  fi

  echo "⚡ Running checklist-fast local sanity path"
  if ! validate_tooling_only_dependencies; then
    exit 1
  fi
  if ! normalize_doc_links; then
    exit 1
  fi
  if ! bash "$WORKSPACE_ROOT/tool/validate_validation_docs.sh"; then
    echo "❌ validation_scripts docs out of sync with tool/check_*.sh inventory or catalog counts; update shards or run tool/validate_validation_docs.sh for details."
    exit 1
  fi
  if ! bash "$WORKSPACE_ROOT/tool/check_agent_knowledge_base.sh"; then
    echo "❌ Agent knowledge base map is out of sync; update AGENTS/docs indexes or source-of-truth links."
    exit 1
  fi
  if ! run_harness_docs_checks; then
    exit 1
  fi
  if should_run_agent_asset_drift_check; then
    echo "🤖 Verifying managed AI agent asset drift for policy/template docs..."
    if ! bash "$WORKSPACE_ROOT/tool/check_agent_asset_drift.sh"; then
      echo "❌ Managed AI agent assets are out of sync; inspect with ./tool/sync_agent_assets.sh --dry-run, then reconcile with ./bin/agent-maintain sync --apply."
      exit 1
    fi
  fi

  if [ "${#changed_dart_files[@]}" -gt 0 ]; then
    echo ""
    echo "🧩 Widget identity drift check (changed Dart files present)"
    if ! bash "$WORKSPACE_ROOT/tool/check_widget_identity.sh"; then
      exit 1
    fi
  fi

  echo "✅ Skipping dependency, analyze, app validation, and coverage steps"
  echo ""
  if [ "${#changed_files[@]}" -eq 0 ]; then
    echo "🎉 Delivery checklist fast mode complete! Clean-tree local sanity checks passed."
  else
    echo "🎉 Delivery checklist fast mode complete! Narrow local docs/tooling checks passed."
  fi
  exit 0
fi

if is_docs_only_change_set; then
  echo "📝 Docs-only change set detected"
  if ! validate_docs_only_dependencies; then
    exit 1
  fi
  if ! normalize_doc_links; then
    exit 1
  fi
  if ! bash "$WORKSPACE_ROOT/tool/validate_validation_docs.sh"; then
    echo "❌ validation_scripts docs out of sync with tool/check_*.sh inventory or catalog counts; update shards or run tool/validate_validation_docs.sh for details."
    exit 1
  fi
  if ! bash "$WORKSPACE_ROOT/tool/check_agent_knowledge_base.sh"; then
    echo "❌ Agent knowledge base map is out of sync; update AGENTS/docs indexes or source-of-truth links."
    exit 1
  fi
  if ! run_harness_docs_checks; then
    exit 1
  fi
  if should_run_agent_asset_drift_check; then
    echo "🤖 Verifying managed AI agent asset drift for policy/template docs..."
    if ! bash "$WORKSPACE_ROOT/tool/check_agent_asset_drift.sh"; then
      echo "❌ Managed AI agent assets are out of sync; inspect with ./tool/sync_agent_assets.sh --dry-run, then reconcile with ./bin/agent-maintain sync --apply."
      exit 1
    fi
  fi

  echo "✅ Skipping dependency, analyze, validation, and coverage steps"
  echo ""
  echo "🎉 Delivery checklist complete! No code-relevant work detected."
  exit 0
fi

if is_tooling_only_change_set; then
  echo "🛠️  Tooling-only local change set detected"
  if ! validate_tooling_only_dependencies; then
    exit 1
  fi
  if ! normalize_doc_links; then
    exit 1
  fi
  if ! bash "$WORKSPACE_ROOT/tool/validate_validation_docs.sh"; then
    echo "❌ validation_scripts docs out of sync with tool/check_*.sh inventory or catalog counts; update shards or run tool/validate_validation_docs.sh for details."
    exit 1
  fi
  if ! bash "$WORKSPACE_ROOT/tool/check_agent_knowledge_base.sh"; then
    echo "❌ Agent knowledge base map is out of sync; update AGENTS/docs indexes or source-of-truth links."
    exit 1
  fi
  if ! run_harness_docs_checks; then
    exit 1
  fi
  if should_run_agent_asset_drift_check; then
    echo "🤖 Verifying managed AI agent asset drift for policy/template docs..."
    if ! bash "$WORKSPACE_ROOT/tool/check_agent_asset_drift.sh"; then
      echo "❌ Managed AI agent assets are out of sync; inspect with ./tool/sync_agent_assets.sh --dry-run, then reconcile with ./bin/agent-maintain sync --apply."
      exit 1
    fi
  fi

  echo "✅ Skipping dependency, analyze, app validation, and coverage steps"
  echo ""
  echo "🎉 Delivery checklist complete! Tooling-only local validation passed."
  exit 0
fi

resolve_flutter_dart >/dev/null

if ! run_pubspec_codegen_compat_preflight_if_needed; then
  exit 1
fi

# Step 1: Fetch dependencies (only if needed)
echo "📦 Step 1/5: Checking dependency state"
PACKAGE_CONFIG="$WORKSPACE_ROOT/.dart_tool/package_config.json"
APP_PUBSPEC="$APP_ROOT/pubspec.yaml"
SHOULD_RUN_PUB_GET=0
if [ ! -f "$PACKAGE_CONFIG" ]; then
  SHOULD_RUN_PUB_GET=1
elif [ "$APP_PUBSPEC" -nt "$PACKAGE_CONFIG" ] || \
  { [ -f "$WORKSPACE_ROOT/pubspec.lock" ] && [ "$WORKSPACE_ROOT/pubspec.lock" -nt "$PACKAGE_CONFIG" ]; }; then
  SHOULD_RUN_PUB_GET=1
fi

if [ "$SHOULD_RUN_PUB_GET" -eq 1 ]; then
  echo "  Dependency metadata changed, running workspace pub get"
  pub_get_log="$(mktemp)"
  if ! bash "$WORKSPACE_ROOT/tool/workspace_pub_get.sh" >"$pub_get_log" 2>&1; then
    cat "$pub_get_log" >&2
    rm -f "$pub_get_log"
    exit 1
  fi
  rm -f "$pub_get_log"
else
  echo "  Dependencies already up-to-date, skipping pub get"
fi

# Patch known broken SwiftPM platform mins in pub cache (Darwin only).
bash "$WORKSPACE_ROOT/tool/patch_flutter_secure_storage_darwin_swiftpm.sh" || true
echo "✅ Dependencies ready"
echo ""

# Step 2: Format code
echo "📝 Step 2/5: Formatting changed Dart files"
if [ "${#changed_dart_files[@]}" -gt 0 ]; then
  echo "  Found ${#changed_dart_files[@]} changed Dart file(s)"
  bash "$WORKSPACE_ROOT/bin/format" --changed
else
  echo "  No changed Dart files, skipping format"
fi
echo "✅ Code formatting complete"
echo ""

VALIDATION_FAILED=0
CHECK_MESSAGES=(
  "Checking for Flutter imports in domain layer..."
  "Checking Clean Architecture import boundaries..."
  "Checking feature folder contract..."
  "Checking features.dart barrel completeness..."
  "Checking offline-first stale-sync guard (do not overwrite newer state)..."
  "Checking remote fetch failure fallbacks (no empty snapshot on read errors)..."
  "Checking for raw Material buttons..."
  "Checking for direct Hive.openBox usage..."
  "Checking for raw Timer usage..."
  "Checking for Future.delayed in lib/ (use TimerService where needed)..."
  "Checking for direct GetIt usage in presentation..."
  "Checking for raw dialog APIs..."
  "Checking for raw network image usage..."
  "Checking for raw print() usage..."
  "Checking for per-widget GoogleFonts usage..."
  "Running focused UI regression tests (widget layout/sizing)..."
  "Checking for side effects in build() method..."
  "Checking tool/ Dart (async main) for blocking dart:io *Sync calls..."
  "Checking for missing context.mounted checks after async operations..."
  "Checking for InheritedWidget reads in Provider create callbacks..."
  "Checking for inherited/provider reads in initState()..."
  "Checking for missing mounted checks before setState() after await..."
  "Checking for async setState() callbacks (must be synchronous)..."
  "Checking for hard-coded colors..."
  "Checking for hard-coded user-facing strings..."
  "Checking for missing localization keys..."
  "Checking for missing isClosed checks before emit() in cubits..."
  "Checking for missing const constructors in StatelessWidget..."
  "Checking pubspec codegen/analyzer compatibility..."
  "Checking workspace package dependency DAG..."
  "Checking for data-layer imports in presentation (SOLID DIP)..."
  "Checking for presentation imports in data layer (SOLID layering)..."
  "Checking for shrinkWrap: true in presentation lists (perf)..."
  "Checking for non-builder ListView/GridView in presentation (perf)..."
  "Checking for widget identity drift (keys in builders/switchers)..."
  "Checking for missing RepaintBoundary around heavy widgets (perf)..."
  "Checking for unnecessary rebuilds (perf)..."
  "Checking for live state-list indexing in presentation builders..."
  "Checking selectors for allocating list getters..."
  "Checking for StreamController without close() (memory)..."
  "Checking for controllers without dispose() in presentation (memory)..."
  "Checking for dialog + controller dispose anti-pattern (TextEditingController used after disposed)..."
  "Checking for local TextEditingController in async code with dialog APIs (lifecycle)..."
  "Checking for potential concurrent modification issues..."
  "Checking for raw jsonDecode/jsonEncode usage (isolate optimization)..."
  "Checking for unvalidated dynamic baseUrl parsing..."
  "Checking auth refresh single-flight retry safety..."
  "Checking for compute() usage in domain layer (architecture)..."
  "Checking for compute() usage in lifecycle methods (heuristic)..."
  "Checking for Isolate.run in presentation (use compute + top-level callback)..."
  "Checking for Equatable usage (Freezed preferred)..."
  "Checking for unguarded null assertion (!) usage..."
  "Checking for Row+Icon+Text overflow risk (use IconLabelRow or Flexible/Expanded)..."
  "Checking for Row+multi-button action overflow risk (OverflowBar, Wrap, or Expanded)..."
  "Checking for lifecycle and error-handling (snackbar/listen/dialog mounted)..."
  "Checking mutation success after request-id guard supersession (no false failure after write)..."
  "Checking feature brief/change note is linked for feature Dart changes..."
  "Checking feature modularity (library_demo / settings cross-imports)..."
  "Checking centralized memory-pressure handling..."
  "Checking macOS debug fallback web guards..."
  "Checking Apple debug Hive + secret-storage guards..."
  "Checking iOS simulator CocoaPods framework embed..."
  "Checking agent knowledge base map..."
  "Checking Cursor/Codex harness scorecard gate..."
  "Checking AI failure risk register..."
  "Checking agent memory compounding..."
  "Checking tracked files for secret-like literals..."
  "Checking AI-generated-code smells (high-signal)..."
  "Checking navigation APIs outside presentation layer..."
  "Checking presentation layer for blocking dart:io *Sync calls..."
  "Checking remote image cache hints..."
  "Checking cubit stream subscription hygiene..."
  "Checking WidgetsBindingObserver removeObserver in dispose..."
  "Checking deferred route imports stay on router allowlist..."
  "Running Pyright on Python (Render chat demo + tool/)..."
  "Checking for Flutter layout overflows in tests..."
)

CHECK_SCRIPTS=(
  "tool/check_flutter_domain_imports.sh"
  "tool/check_clean_architecture_imports.sh"
  "tool/check_feature_folder_contract.sh"
  "tool/check_features_barrel.sh"
  "tool/check_offline_first_remote_merge.sh"
  "tool/check_remote_fetch_failure_fallback.sh"
  "tool/check_material_buttons.sh"
  "tool/check_no_hive_openbox.sh"
  "tool/check_raw_timer.sh"
  "tool/check_raw_future_delayed.sh"
  "tool/check_direct_getit.sh"
  "tool/check_raw_dialogs.sh"
  "tool/check_raw_network_images.sh"
  "tool/check_raw_print.sh"
  "tool/check_raw_google_fonts.sh"
  "tool/check_ui_regressions.sh"
  "tool/check_side_effects_build.sh"
  "tool/check_tool_dart_async_main_blocking_io.sh"
  "tool/check_context_mounted.sh"
  "tool/check_inherited_widget_in_create.sh"
  "tool/check_inherited_widget_in_initstate.sh"
  "tool/check_setstate_mounted.sh"
  "tool/check_setstate_async.sh"
  "tool/check_hardcoded_colors.sh"
  "tool/check_hardcoded_strings.sh"
  "tool/check_missing_localizations.sh"
  "tool/check_cubit_isclosed.sh"
  "tool/check_missing_const.sh"
  "tool/check_pubspec_codegen_compat.sh"
  "tool/check_package_dependency_dag.sh"
  "tool/check_solid_presentation_data_imports.sh"
  "tool/check_solid_data_presentation_imports.sh"
  "tool/check_perf_shrinkwrap_lists.sh"
  "tool/check_perf_nonbuilder_lists.sh"
  "tool/check_widget_identity.sh"
  "tool/check_perf_missing_repaint_boundary.sh"
  "tool/check_perf_unnecessary_rebuilds.sh"
  "tool/check_live_state_list_indexing.sh"
  "tool/check_select_state_allocating_getters.sh"
  "tool/check_memory_unclosed_streams.sh"
  "tool/check_memory_missing_dispose.sh"
  "tool/check_dialog_controller_dispose.sh"
  "tool/check_dialog_text_controller_lifecycle.sh"
  "tool/check_concurrent_modification.sh"
  "tool/check_raw_json_decode.sh"
  "tool/check_unvalidated_base_url_parse.sh"
  "tool/check_auth_refresh_single_flight.sh"
  "tool/check_compute_domain_layer.sh"
  "tool/check_compute_lifecycle.sh"
  "tool/check_no_isolate_run_in_presentation.sh"
  "tool/check_freezed_preferred.sh"
  "tool/check_unguarded_null_assertion.sh"
  "tool/check_row_text_overflow.sh"
  "tool/check_row_action_overflow.sh"
  "tool/check_lifecycle_error_handling.sh"
  "tool/check_mutation_success_after_guard.sh"
  "tool/check_feature_brief_linked.sh"
  "tool/check_feature_modularity_leaks.sh"
  "tool/check_memory_pressure_centralized.sh"
  "tool/check_macos_debug_web_guard.sh"
  "tool/check_apple_debug_hive_storage.sh"
  "tool/check_ios_pod_framework_embed.sh"
  "tool/check_agent_knowledge_base.sh"
  "tool/check_harness_scorecard_gate.sh"
  "tool/check_ai_failure_risk_register.sh"
  "tool/check_agent_memory_compounding.sh"
  "tool/check_tracked_secret_literals.sh"
  "tool/check_ai_generated_code_smells.sh"
  "tool/check_navigation_outside_presentation.sh"
  "tool/check_sync_io_in_presentation.sh"
  "tool/check_remote_image_cache_hints.sh"
  "tool/check_cubit_subscription_cancel.sh"
  "tool/check_lifecycle_observer_dispose.sh"
  "tool/check_deferred_heavy_routes.sh"
  "tool/check_pyright_python.sh"
  "tool/check_flutter_layout_overflows.sh"
)
CHECK_SCRIPT_THEMES=(
  "architecture"
  "architecture"
  "architecture"
  "architecture"
  "background"
  "background"
  "ui"
  "architecture"
  "background"
  "background"
  "state-mgmt"
  "ui"
  "images"
  "ui"
  "ui"
  "ui"
  "rebuild"
  "blocking-io-tool"
  "async"
  "async"
  "async"
  "async"
  "async"
  "ui"
  "ui"
  "ui"
  "state-mgmt"
  "perf"
  "tooling"
  "architecture"
  "architecture"
  "architecture"
  "widget-trees"
  "widget-trees"
  "rebuild"
  "perf"
  "rebuild"
  "state-mgmt"
  "rebuild"
  "memory"
  "memory"
  "memory"
  "memory"
  "async"
  "blocking-io"
  "architecture"
  "async"
  "async-boundaries"
  "async-boundaries"
  "async-boundaries"
  "architecture"
  "async"
  "ui"
  "ui"
  "async"
  "async"
  "architecture"
  "architecture"
  "memory"
  "memory"
  "ui"
  "ios-native"
  "meta"
  "meta"
  "meta"
  "meta"
  "security"
  "meta"
  "navigation"
  "blocking-io"
  "images"
  "state-mgmt"
  "lifecycle"
  "navigation"
  "tooling"
  "ui"
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

if ! validate_checklist_configuration; then
  exit 1
fi

if [ "$CHECKLIST_EXPLAIN" = "1" ] && [ "$CHECKLIST_EXPLAIN_THEMES" = "1" ]; then
  for ((i = 0; i < ${#CHECK_SCRIPTS[@]}; i++)); do
    echo "explain|theme|${CHECK_SCRIPT_THEMES[$i]}|${CHECK_SCRIPTS[$i]}"
  done
  echo ""
fi

echo "🔍 Step 3/5: Analyzing code with 'flutter analyze'"
echo ""
echo "🛡️  Step 4/5: Running best practices validation checks..."
echo ""
if ! normalize_doc_links; then
  exit 1
fi
echo "  Running ${#CHECK_SCRIPTS[@]} static checks with $CHECKLIST_JOBS workers (in parallel with analyze)"
CHECKLIST_TMP_DIR="$(mktemp -d)"
export CHECK_PYRIGHT_PYTHON_MODE=auto
export CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE=auto
export CHECK_REGRESSION_GUARDS_MODE=auto

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
should_run_analyze=1
if [ "$RUN_ANALYZE" = "0" ]; then
  should_run_analyze=0
elif [ "$RUN_ANALYZE" = "auto" ]; then
  if ! should_run_flutter_analyze_auto; then
    should_run_analyze=0
  fi
fi

if [ "$should_run_analyze" -eq 1 ]; then
  if ! (cd "$APP_ROOT" && flutter analyze --no-pub); then
    ANALYZE_FAILED=1
  fi
else
  echo "Skipping flutter analyze (no Dart/analyzer-relevant local changes; override with CHECKLIST_RUN_ANALYZE=1)"
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
if should_run_router_feature_validate_auto; then
  echo "  Running router feature validation (path-triggered)..."
  if ! bash "$WORKSPACE_ROOT/bin/router_feature_validate"; then
    VALIDATION_FAILED=1
  fi
  echo ""
fi


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

should_run_file_length_lint=1
if [ "$RUN_FILE_LENGTH_LINT" = "0" ]; then
  should_run_file_length_lint=0
elif [ "$RUN_FILE_LENGTH_LINT" = "auto" ]; then
  if ! should_run_file_length_lint_auto; then
    should_run_file_length_lint=0
  fi
fi

if [ "$should_run_file_length_lint" -eq 1 ]; then
  echo "  Running file_length_lint checks..."
  if ! bash tool/run_file_length_lint.sh; then
    VALIDATION_FAILED=1
  fi
else
  echo "  Skipping file_length_lint (no Dart/analyzer-relevant changes; override with CHECKLIST_RUN_FILE_LENGTH_LINT=1)"
fi

should_run_file_length_lint_integration_test=1
if [ "$RUN_FILE_LENGTH_LINT_INTEGRATION_TEST" = "0" ]; then
  should_run_file_length_lint_integration_test=0
elif [ "$RUN_FILE_LENGTH_LINT_INTEGRATION_TEST" = "auto" ]; then
  if ! should_run_file_length_lint_integration_test_auto; then
    should_run_file_length_lint_integration_test=0
  fi
fi

if [ "$should_run_file_length_lint_integration_test" -eq 1 ]; then
  echo "  Running file_length_lint integration regression test..."
  if ! python3 tool/run_file_length_lint_test.py; then
    VALIDATION_FAILED=1
  fi
else
  echo "  Skipping file_length_lint integration test (no lint-wiring changes; override with CHECKLIST_RUN_FILE_LENGTH_LINT_INTEGRATION_TEST=1)"
fi
echo ""

should_run_coverage=1
if [ "$RUN_COVERAGE" = "0" ]; then
  should_run_coverage=0
elif [ "$RUN_COVERAGE" = "auto" ]; then
  if ! should_run_coverage_auto; then
    should_run_coverage=0
  fi
fi

should_run_focused_tests=1
if [ "$RUN_FOCUSED_TESTS" = "0" ]; then
  should_run_focused_tests=0
elif [ "$RUN_FOCUSED_TESTS" = "auto" ] && [ "$should_run_coverage" -eq 1 ]; then
  if ! should_run_regression_guards_before_coverage; then
    should_run_focused_tests=0
  fi
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

  should_run_action_bar_layout_tests=1
  if [ "$RUN_ACTION_BAR_LAYOUT_TESTS" = "0" ]; then
    should_run_action_bar_layout_tests=0
  elif [ "$RUN_ACTION_BAR_LAYOUT_TESTS" = "auto" ]; then
    if ! should_run_action_bar_layout_tests_auto; then
      should_run_action_bar_layout_tests=0
    fi
  fi

  if [ "$should_run_action_bar_layout_tests" -eq 1 ]; then
    echo "  Running action-bar layout regression tests..."
    bash tool/check_action_bar_layout.sh || VALIDATION_FAILED=1
    echo ""
  else
    echo "  Skipping action-bar layout regression tests (no relevant UI action-row changes; override with CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS=1)"
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

if [ "$should_run_coverage" -eq 1 ]; then
  # Step 5: Run test coverage
  echo "🧪 Step 5/5: Running test coverage with 'tool/test_coverage.sh'"
  bash tool/test_coverage.sh
  echo "✅ Test coverage complete"
  echo ""
else
  echo "🧪 Step 5/5: Skipped coverage (override with CHECKLIST_RUN_COVERAGE=1)"
  echo ""
fi

echo "🎉 Delivery checklist complete! All steps passed."
