#!/usr/bin/env bash
# Fail: production ad-hoc Dio() construction outside approved factories.
# Theme: architecture | Severity: fail
set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
# shellcheck disable=SC1091
source "$TOOL_DIR/check_helpers.sh"

ROOT="$WORKSPACE_ROOT"
cd "$ROOT"

echo "🔍 Checking ad-hoc Dio() construction..."

usage() {
  cat <<'EOF'
Usage: tool/check_adhoc_dio_construction.sh [--self-test | --paths PATH...]

Default scope: apps/mobile/lib/**/*.dart
Fail on:
  - ?? Dio() anywhere under apps/mobile/lib
  - bare Dio( constructor outside allowlisted factory files
Allowlist:
  - apps/mobile/lib/app/http/app_dio.dart
  - apps/mobile/lib/features/chat/data/render_chat_dio_factory.dart
EOF
}

ALLOWLIST=(
  "apps/mobile/lib/app/http/app_dio.dart"
  "apps/mobile/lib/features/chat/data/render_chat_dio_factory.dart"
)

is_allowlisted() {
  local file="$1"
  local a
  for a in "${ALLOWLIST[@]}"; do
    if [[ "$file" == "$a" ]]; then
      return 0
    fi
  done
  return 1
}

to_rel() {
  local file="$1"
  case "$file" in
    "$ROOT"/*) echo "${file#"$ROOT"/}" ;;
    *) echo "$file" ;;
  esac
}

# Emit violation lines for one or more paths (files or dirs). Prints count on last line.
scan_targets() {
  local -a targets=("$@")
  local hits=0
  local line file_part rest rel

  # Fallback constructors always fail
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    echo "❌ $line"
    hits=$((hits + 1))
  done < <(
    rg -n --no-heading -e '\?\?[[:space:]]*Dio[[:space:]]*\(' "${targets[@]}" 2>/dev/null || true
  )

  # Bare Dio( constructor — skip allowlisted factory files
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    file_part="${line%%:*}"
    rest="${line#*:}"
    rel="$(to_rel "$file_part")"
    if is_allowlisted "$rel"; then
      continue
    fi
    if [[ "$rest" == *'??'* ]]; then
      continue
    fi
    echo "❌ $line"
    hits=$((hits + 1))
  done < <(
    rg -n --no-heading -e '\bDio[[:space:]]*\(' "${targets[@]}" 2>/dev/null || true
  )

  echo "$hits"
}

run_self_test() {
  local bad="$ROOT/tool/fixtures/adhoc_dio/bad_repository_fallback.dart"
  local good_app="$ROOT/tool/fixtures/adhoc_dio/good_create_app_dio_usage.dart"
  local good_render="$ROOT/tool/fixtures/adhoc_dio/good_render_chat_dio_factory.dart"

  local bad_out bad_hits
  bad_out="$(scan_targets "$bad")"
  bad_hits="$(echo "$bad_out" | tail -1)"
  if [[ "$bad_hits" -lt 1 ]]; then
    echo "❌ self-test failed: expected violations in bad fixture"
    echo "$bad_out"
    exit 1
  fi

  if rg -n '\?\?[[:space:]]*Dio[[:space:]]*\(' "$good_app" "$good_render" >/dev/null 2>&1; then
    echo "❌ self-test failed: good fixtures contain ?? Dio()"
    exit 1
  fi

  if ! rg -n '\bDio[[:space:]]*\(' "$good_app" "$good_render" >/dev/null 2>&1; then
    echo "❌ self-test failed: good fixtures must demonstrate Dio( factory construction"
    exit 1
  fi

  echo "✅ ok|adhoc-dio|self-test"
}

PATHS=()
SELF_TEST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --self-test)
      SELF_TEST=1
      shift
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        PATHS+=("$1")
        shift
      done
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$SELF_TEST" -eq 1 ]]; then
  run_self_test
  exit 0
fi

TARGETS=()
if [[ ${#PATHS[@]} -gt 0 ]]; then
  for p in "${PATHS[@]}"; do
    if [[ "$p" = /* ]]; then
      TARGETS+=("$p")
    else
      TARGETS+=("$ROOT/$p")
    fi
  done
else
  TARGETS+=("$ROOT/apps/mobile/lib")
fi

out="$(scan_targets "${TARGETS[@]}")"
hits="$(echo "$out" | tail -1)"
if [[ "$hits" -gt 0 ]]; then
  echo "$out" | sed '$d'
  echo "❌ fail|adhoc-dio|violations=$hits"
  echo "   Allowed Dio factories only: createAppDio (app_dio.dart), createRenderChatDio (render_chat_dio_factory.dart)."
  exit 1
fi

echo "✅ ok|adhoc-dio|violations=0"
exit 0
