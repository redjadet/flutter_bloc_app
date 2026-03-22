#!/bin/bash
# Runs integration tests on a supported non-web device.
#
# Usage:
#   tool/run_integration_tests.sh
#   CHECKLIST_INTEGRATION_DEVICE=<deviceId> tool/run_integration_tests.sh
#   INTEGRATION_TESTS_RUN_COVERAGE=0 tool/run_integration_tests.sh
#   tool/run_integration_tests.sh integration_test/smoke_flows_test.dart
#   tool/run_integration_tests.sh integration_test/app_test.dart
#
# Optional env:
#   INTEGRATION_TESTS_RETRY_ON_FAILURE (0|1, default 1) — full suite only
#   INTEGRATION_TESTS_TIMEOUT_SECONDS (default 1800)
#   DEVICE_DISCOVERY_TIMEOUT_SECONDS (default 60)
#   PROGRESS_HEARTBEAT_SECONDS (default 60)
#
# Behavior:
#   - No arguments: aggregated suite (integration_test/all_flows_test.dart),
#     optional coverage merge, and coverage/coverage_summary.md refresh.
#   - With arguments: runs flutter test for those targets (e.g. smoke or extended suite).
#   - If coverage/lcov.base.info exists from tool/test_coverage.sh, the full-suite
#     run can merge integration coverage into that baseline before the summary refresh.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2
}

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

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  echo "$value"
}

host_desktop_device_id() {
  case "$(uname -s)" in
    Darwin)
      echo "macos"
      ;;
    Linux)
      echo "linux"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "windows"
      ;;
    *)
      echo ""
      ;;
  esac
}

cleanup_project_xcodebuilds() {
  local pattern
  local patterns=(
    "$PROJECT_ROOT/build/ios"
    "$PROJECT_ROOT/ios/Runner.xcworkspace"
    "$PROJECT_ROOT/ios/Pods"
  )
  local deadline=$((SECONDS + 30))

  for pattern in "${patterns[@]}"; do
    log "Stopping lingering Xcode build processes for pattern: $pattern"
    pkill -TERM -f "$pattern" 2>/dev/null || true
  done

  while true; do
    local still_running=0
    for pattern in "${patterns[@]}"; do
      if pgrep -f "$pattern" >/dev/null 2>&1; then
        still_running=1
        break
      fi
    done
    if [ "$still_running" -eq 0 ]; then
      return
    fi
    if [ "$SECONDS" -ge "$deadline" ]; then
      for pattern in "${patterns[@]}"; do
        log "Force-killing lingering Xcode build processes for pattern: $pattern"
        pkill -KILL -f "$pattern" 2>/dev/null || true
      done
      return
    fi
    sleep 1
  done
}

run_flutter_devices() {
  local timeout_seconds="$1"
  local deadline=$((SECONDS + timeout_seconds))
  local attempt=1
  local output

  while true; do
    if output="$(flutter devices 2>&1)"; then
      printf '%s\n' "$output"
      return 0
    fi

    if [ "$SECONDS" -ge "$deadline" ]; then
      log "Timed out listing Flutter devices after ${timeout_seconds}s."
      printf '%s\n' "$output" >&2
      return 1
    fi

    log "flutter devices failed on attempt $attempt; retrying in 5s."
    printf '%s\n' "$output" >&2
    attempt=$((attempt + 1))
    sleep 5
  done
}

list_supported_devices() {
  while IFS= read -r line; do
    [[ "$line" == *"•"* ]] || continue
    [[ "$line" == *"web-javascript"* ]] && continue

    IFS='•' read -r _ id _ <<< "$line"
    id="$(trim "$id")"
    [ -n "$id" ] && printf '%s\t%s\n' "$id" "$line"
  done < <(run_flutter_devices "$DEVICE_DISCOVERY_TIMEOUT_SECONDS")
}

select_device_id() {
  local requested_device="${CHECKLIST_INTEGRATION_DEVICE:-${INTEGRATION_TEST_DEVICE:-}}"
  local preferred_device
  local device_id
  local device_line
  local index
  local attempt=1
  local max_attempts=6
  local retry_delay_seconds=5
  local -a supported_device_ids=()
  local -a supported_device_lines=()

  while true; do
    supported_device_ids=()
    supported_device_lines=()

    while IFS=$'\t' read -r device_id device_line; do
      [ -z "$device_id" ] && continue
      supported_device_ids+=("$device_id")
      supported_device_lines+=("$device_line")
    done < <(list_supported_devices)

    if [ "${#supported_device_ids[@]}" -gt 0 ]; then
      if [ -n "$requested_device" ]; then
        for device_id in "${supported_device_ids[@]}"; do
          if [ "$device_id" = "$requested_device" ]; then
            echo "$device_id"
            return
          fi
        done
      else
        break
      fi
    fi

    if [ "$attempt" -ge "$max_attempts" ]; then
      break
    fi

    if [ -n "$requested_device" ]; then
      log "Waiting for requested integration device '$requested_device' to become available..."
    else
      log 'Waiting for a supported non-web integration device to become available...'
    fi
    sleep "$retry_delay_seconds"
    attempt=$((attempt + 1))
  done

  if [ "${#supported_device_ids[@]}" -eq 0 ]; then
    log '❌ No supported non-web device found for integration tests.'
    log 'Connect a device or set CHECKLIST_INTEGRATION_DEVICE to a valid id.'
    exit 1
  fi

  if [ -n "$requested_device" ]; then
    log "❌ CHECKLIST_INTEGRATION_DEVICE='$requested_device' is not available."
    log "Available device ids: ${supported_device_ids[*]}"
    exit 1
  fi

  for index in "${!supported_device_ids[@]}"; do
    device_line="${supported_device_lines[$index]}"
    if [[ "$device_line" == *"ios"* ]] && [[ "$device_line" == *"simulator"* ]]; then
      echo "${supported_device_ids[$index]}"
      return
    fi
  done

  preferred_device="$(host_desktop_device_id)"
  if [ -n "$preferred_device" ]; then
    for device_id in "${supported_device_ids[@]}"; do
      if [ "$device_id" = "$preferred_device" ]; then
        echo "$device_id"
        return
      fi
    done
  fi

  if [ "${#supported_device_ids[@]}" -eq 1 ]; then
    echo "${supported_device_ids[0]}"
    return
  fi

  log "❌ Multiple supported devices detected: ${supported_device_ids[*]}"
  log 'Set CHECKLIST_INTEGRATION_DEVICE=<deviceId> to choose one.'
  exit 1
}

start_heartbeat() {
  local label="$1"
  local interval_seconds="$2"
  local command_pid="$3"
  (
    while kill -0 "$command_pid" 2>/dev/null; do
      sleep "$interval_seconds"
      kill -0 "$command_pid" 2>/dev/null || break
      log "$label is still running..."
    done
  ) &
  printf '%s\n' "$!"
}

run_with_timeout() {
  local label="$1"
  local timeout_seconds="$2"
  shift 2

  local command_pid
  local heartbeat_pid
  local start_time=$SECONDS
  local exit_code=0

  log "Starting $label (timeout ${timeout_seconds}s)."
  "$@" &
  command_pid=$!
  heartbeat_pid="$(start_heartbeat "$label" "$PROGRESS_HEARTBEAT_SECONDS" "$command_pid")"

  while kill -0 "$command_pid" 2>/dev/null; do
    if [ $((SECONDS - start_time)) -ge "$timeout_seconds" ]; then
      log "$label exceeded timeout after ${timeout_seconds}s. Sending TERM..."
      kill -TERM "$command_pid" 2>/dev/null || true
      sleep 10
      if kill -0 "$command_pid" 2>/dev/null; then
        log "$label did not exit after TERM. Sending KILL..."
        kill -KILL "$command_pid" 2>/dev/null || true
      fi
      wait "$command_pid" || true
      kill "$heartbeat_pid" 2>/dev/null || true
      wait "$heartbeat_pid" 2>/dev/null || true
      return 124
    fi
    sleep 5
  done

  wait "$command_pid" || exit_code=$?
  kill "$heartbeat_pid" 2>/dev/null || true
  wait "$heartbeat_pid" 2>/dev/null || true
  log "$label finished with exit code $exit_code after $((SECONDS - start_time))s."
  return "$exit_code"
}

should_retry_integration_run() {
  local exit_code="$1"

  if [ "$RETRY_ON_FAILURE" -ne 1 ]; then
    log 'Automatic retry is disabled for this run.'
    return 1
  fi

  case "$exit_code" in
    124|130|137|143)
      log "Not retrying exit code $exit_code because it indicates timeout, cancellation, or forced termination."
      return 1
      ;;
  esac

  return 0
}

RUN_COVERAGE="${INTEGRATION_TESTS_RUN_COVERAGE:-1}"
RETRY_ON_FAILURE="${INTEGRATION_TESTS_RETRY_ON_FAILURE:-1}"
INTEGRATION_TESTS_TIMEOUT_SECONDS="${INTEGRATION_TESTS_TIMEOUT_SECONDS:-1800}"
DEVICE_DISCOVERY_TIMEOUT_SECONDS="${DEVICE_DISCOVERY_TIMEOUT_SECONDS:-60}"
PROGRESS_HEARTBEAT_SECONDS="${PROGRESS_HEARTBEAT_SECONDS:-60}"

if ! [[ "$RUN_COVERAGE" =~ ^(0|1)$ ]]; then
  log "⚠️ Invalid INTEGRATION_TESTS_RUN_COVERAGE='$RUN_COVERAGE'; using 1."
  RUN_COVERAGE=1
fi

if ! [[ "$RETRY_ON_FAILURE" =~ ^(0|1)$ ]]; then
  log "⚠️ Invalid INTEGRATION_TESTS_RETRY_ON_FAILURE='$RETRY_ON_FAILURE'; using 1."
  RETRY_ON_FAILURE=1
fi

if ! [[ "$INTEGRATION_TESTS_TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] || [ "$INTEGRATION_TESTS_TIMEOUT_SECONDS" -le 0 ]; then
  log "⚠️ Invalid INTEGRATION_TESTS_TIMEOUT_SECONDS='$INTEGRATION_TESTS_TIMEOUT_SECONDS'; using 1800."
  INTEGRATION_TESTS_TIMEOUT_SECONDS=1800
fi

if ! [[ "$DEVICE_DISCOVERY_TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] || [ "$DEVICE_DISCOVERY_TIMEOUT_SECONDS" -le 0 ]; then
  log "⚠️ Invalid DEVICE_DISCOVERY_TIMEOUT_SECONDS='$DEVICE_DISCOVERY_TIMEOUT_SECONDS'; using 60."
  DEVICE_DISCOVERY_TIMEOUT_SECONDS=60
fi

if ! [[ "$PROGRESS_HEARTBEAT_SECONDS" =~ ^[0-9]+$ ]] || [ "$PROGRESS_HEARTBEAT_SECONDS" -le 0 ]; then
  log "⚠️ Invalid PROGRESS_HEARTBEAT_SECONDS='$PROGRESS_HEARTBEAT_SECONDS'; using 60."
  PROGRESS_HEARTBEAT_SECONDS=60
fi

DEVICE_ID="$(select_device_id)"
DART_BIN="$(resolve_flutter_dart)"
BASE_COVERAGE_PATH="coverage/lcov.base.info"
FINAL_COVERAGE_PATH="coverage/lcov.info"
FULL_SUITE_TARGET="integration_test/all_flows_test.dart"
HAS_LCOV=0

if command -v lcov >/dev/null 2>&1; then
  HAS_LCOV=1
fi

log "Running integration tests on device: $DEVICE_ID"
log "Coverage mode: $RUN_COVERAGE | Retry on failure: $RETRY_ON_FAILURE | Test timeout: ${INTEGRATION_TESTS_TIMEOUT_SECONDS}s"
if [ "$#" -eq 0 ]; then
  cleanup_project_xcodebuilds
  log "Running aggregated integration suite: $FULL_SUITE_TARGET"
  set +e
  if [ "$RUN_COVERAGE" -eq 0 ]; then
    log 'Coverage disabled via INTEGRATION_TESTS_RUN_COVERAGE=0.'
    run_with_timeout \
      "$FULL_SUITE_TARGET" \
      "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$FULL_SUITE_TARGET"
  elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ]; then
    log "Collecting and merging integration coverage with $BASE_COVERAGE_PATH."
    run_with_timeout \
      "$FULL_SUITE_TARGET" \
      "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      --coverage \
      --merge-coverage \
      --coverage-path="$FINAL_COVERAGE_PATH" \
      "$FULL_SUITE_TARGET"
  elif [ -s "$BASE_COVERAGE_PATH" ]; then
    log "⚠️ 'lcov' is not installed, so baseline merge is unavailable."
    log 'Running integration tests without coverage update.'
    run_with_timeout \
      "$FULL_SUITE_TARGET" \
      "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$FULL_SUITE_TARGET"
  else
    log 'Collecting integration-only coverage.'
    log "No baseline coverage found at $BASE_COVERAGE_PATH; writing integration-only coverage."
    run_with_timeout \
      "$FULL_SUITE_TARGET" \
      "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      --coverage \
      --coverage-path="$FINAL_COVERAGE_PATH" \
      "$FULL_SUITE_TARGET"
  fi
  exit_code=$?
  if [ "$exit_code" -ne 0 ] && should_retry_integration_run "$exit_code"; then
    log "Integration tests failed with exit $exit_code. Retrying once after cleanup..."
    cleanup_project_xcodebuilds
    sleep 5
    if [ "$RUN_COVERAGE" -eq 0 ]; then
      run_with_timeout \
        "$FULL_SUITE_TARGET retry" \
        "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$FULL_SUITE_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ]; then
      log "Retrying with merged integration coverage against $BASE_COVERAGE_PATH."
      run_with_timeout \
        "$FULL_SUITE_TARGET retry" \
        "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        --coverage \
        --merge-coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$FULL_SUITE_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ]; then
      run_with_timeout \
        "$FULL_SUITE_TARGET retry" \
        "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$FULL_SUITE_TARGET"
    else
      run_with_timeout \
        "$FULL_SUITE_TARGET retry" \
        "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        --coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$FULL_SUITE_TARGET"
    fi
    exit_code=$?
  fi
  set -e
  cleanup_project_xcodebuilds
  if [ "$exit_code" -eq 0 ] && [ "$RUN_COVERAGE" -eq 0 ]; then
    log 'Skipping coverage summary update because integration coverage is disabled.'
  elif [ "$exit_code" -eq 0 ] && { [ ! -s "$BASE_COVERAGE_PATH" ] || [ "$HAS_LCOV" -eq 1 ]; }; then
    log 'Updating coverage summary...'
    "$DART_BIN" run tool/update_coverage_summary.dart
  elif [ "$exit_code" -eq 0 ]; then
    log "Skipping coverage summary update because baseline merge requires 'lcov'."
  fi
  exit "$exit_code"
else
  cleanup_project_xcodebuilds
  set +e
  run_with_timeout \
    "integration test selection" \
    "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
    flutter test --no-pub -d "$DEVICE_ID" "$@"
  exit_code=$?
  set -e
  cleanup_project_xcodebuilds
  exit "$exit_code"
fi
