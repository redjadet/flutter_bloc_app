#!/usr/bin/env bash
# High-confidence sensitive logging expressions in apps/packages lib + iOS Swift.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/check_helpers.sh"

FIXTURE_DIR="$WORKSPACE_ROOT/tool/fixtures/sensitive_logging"
SELF_TEST=0
if [[ "${1:-}" == "--self-test" ]]; then
  SELF_TEST=1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "sensitive-logging|skip|ripgrep-missing"
  exit 0
fi

emit_violation() {
  printf 'violation|%s:%s:%s:%s\n' "$1" "$2" "$3" "$4"
}

# stdout: "ok" | "missing_reason" | "none"
ignore_status() {
  local file="$1"
  local lineno="$2"
  local current previous reason
  current=$(sed -n "${lineno}p" "$file")
  previous=""
  if [[ "$lineno" -gt 1 ]]; then
    previous=$(sed -n "$((lineno - 1))p" "$file")
  fi
  if [[ "$current" != *"check-ignore"* && "$previous" != *"check-ignore"* ]]; then
    echo none
    return
  fi
  if [[ "$current" == *"check-ignore"* ]]; then
    reason=$(printf '%s' "$current" | sed -n 's/.*check-ignore[: ]*//p')
  else
    reason=$(printf '%s' "$previous" | sed -n 's/.*check-ignore[: ]*//p')
  fi
  reason=$(printf '%s' "$reason" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [[ -z "$reason" ]]; then
    echo missing_reason
  else
    echo ok
  fi
}

handle_match() {
  local file="$1"
  local line="$2"
  local rule="$3"
  local message="$4"
  local status
  status=$(ignore_status "$file" "$line")
  case "$status" in
    ok) ;;
    missing_reason)
      emit_violation "$file" "$line" "ignore_missing_reason" "check-ignore requires a non-empty reason"
      ;;
    none)
      emit_violation "$file" "$line" "$rule" "$message"
      ;;
  esac
}

# Parse rg --with-filename lines: path:lineno:rest (path may contain spaces).
parse_rg_hit() {
  local raw="$1"
  local file line
  file="${raw%%:*}"
  local rest="${raw#*:}"
  line="${rest%%:*}"
  if [[ ! "$line" =~ ^[0-9]+$ ]]; then
    return 1
  fi
  printf '%s\t%s\n' "$file" "$line"
}

scan_paths() {
  local paths=("$@")
  local raw parsed file line

  while IFS= read -r raw; do
    [[ -z "$raw" ]] && continue
    parsed=$(parse_rg_hit "$raw") || continue
    file="${parsed%%$'\t'*}"
    line="${parsed#*$'\t'}"
    handle_match "$file" "$line" "raw_uri_interpolation" \
      "do not interpolate raw URI into AppLogger messages"
  done < <(
    rg -n --with-filename --no-heading \
      -e 'AppLogger\.(debug|info|warning|error|event|debugInDebugMode)\([^)]*\$(uri|initialUri|targetUri)\b' \
      -e 'AppLogger\.(debug|info|warning|error|event|debugInDebugMode)\([^)]*\$\{(uri|initialUri|targetUri)\}' \
      "${paths[@]}" 2>/dev/null || true
  )

  while IFS= read -r raw; do
    [[ -z "$raw" ]] && continue
    parsed=$(parse_rg_hit "$raw") || continue
    file="${parsed%%$'\t'*}"
    line="${parsed#*$'\t'}"
    handle_match "$file" "$line" "response_body" "do not log response/request body"
  done < <(
    rg -n --with-filename --no-heading \
      -e 'AppLogger\.(debug|info|warning|error|event|debugInDebugMode)\([^)]*\.body\b' \
      -e '\b(print|debugPrint)\([^)]*\.body\b' \
      "${paths[@]}" 2>/dev/null || true
  )

  while IFS= read -r raw; do
    [[ -z "$raw" ]] && continue
    parsed=$(parse_rg_hit "$raw") || continue
    file="${parsed%%$'\t'*}"
    line="${parsed#*$'\t'}"
    handle_match "$file" "$line" "bearer_literal" "do not log Bearer credentials"
  done < <(
    rg -n --with-filename --no-heading -i \
      -e 'AppLogger\.(debug|info|warning|error|event|debugInDebugMode)\([^)]*Bearer[[:space:]]' \
      -e '\b(print|debugPrint)\([^)]*Bearer[[:space:]]' \
      "${paths[@]}" 2>/dev/null || true
  )

  while IFS= read -r raw; do
    [[ -z "$raw" ]] && continue
    parsed=$(parse_rg_hit "$raw") || continue
    file="${parsed%%$'\t'*}"
    line="${parsed#*$'\t'}"
    handle_match "$file" "$line" "absolute_string" "do not log url.absoluteString"
  done < <(
    rg -n --with-filename --no-heading \
      -e '(debugPrint|print|NSLog)\([^\n]*absoluteString' \
      "${paths[@]}" 2>/dev/null || true
  )
}

run_self_test() {
  local failed=0
  local out

  expect_fail() {
    local file="$1"
    local rule="$2"
    out=$(scan_paths "$file")
    if ! printf '%s\n' "$out" | grep -q "violation|.*:${rule}:"; then
      echo "self-test|fail|expected rule $rule in $file"
      echo "$out"
      failed=1
    else
      echo "self-test|ok|fail|$rule|$file"
    fi
  }

  expect_pass() {
    local file="$1"
    out=$(scan_paths "$file")
    if [[ -n "$out" ]]; then
      echo "self-test|fail|expected clean $file"
      echo "$out"
      failed=1
    else
      echo "self-test|ok|pass|$file"
    fi
  }

  expect_fail "$FIXTURE_DIR/bad_uri.dart" "raw_uri_interpolation"
  expect_fail "$FIXTURE_DIR/bad_body.dart" "response_body"
  expect_fail "$FIXTURE_DIR/bad_bearer.dart" "bearer_literal"
  expect_fail "$FIXTURE_DIR/bad_url.swift" "absolute_string"
  expect_fail "$FIXTURE_DIR/bad_ignore.dart" "ignore_missing_reason"
  expect_pass "$FIXTURE_DIR/good_event_uri.dart"
  expect_pass "$FIXTURE_DIR/good_status.dart"
  expect_pass "$FIXTURE_DIR/good_redacted.dart"
  expect_pass "$FIXTURE_DIR/good_url.swift"
  expect_pass "$FIXTURE_DIR/ignored_body.dart"

  if [[ "$failed" -ne 0 ]]; then
    echo "self-test|failed"
    exit 1
  fi
  echo "self-test|passed"
  exit 0
}

if [[ "$SELF_TEST" -eq 1 ]]; then
  run_self_test
fi

echo "🔍 Checking for sensitive logging patterns..."

mapfile -t SCAN_FILES < <(
  rg --files \
    "$WORKSPACE_ROOT/apps" \
    "$WORKSPACE_ROOT/packages" \
    --glob '**/lib/**/*.dart' \
    --glob '**/ios/**/*.swift' \
    --glob '!**/*.g.dart' \
    --glob '!**/*.freezed.dart' \
    --glob '!**/*.gr.dart' \
    --glob '!**/test/**' \
    2>/dev/null || true
)

if [[ "${#SCAN_FILES[@]}" -eq 0 ]]; then
  echo "✅ No sensitive logging violations found"
  exit 0
fi

FINDINGS=$(scan_paths "${SCAN_FILES[@]}")
if [[ -n "$FINDINGS" ]]; then
  echo "❌ Sensitive logging violations found"
  printf '%s\n' "$FINDINGS"
  exit 1
fi

echo "✅ No sensitive logging violations found"
exit 0
