#!/bin/bash
# Runs integration tests on a supported non-web device.
#
# Usage:
#   tool/run_integration_tests.sh
#   CHECKLIST_INTEGRATION_DEVICE=<deviceId> tool/run_integration_tests.sh
#   INTEGRATION_TESTS_RUN_COVERAGE=0 tool/run_integration_tests.sh
#   INTEGRATION_TESTS_RUN_COVERAGE=true tool/run_integration_tests.sh
#   INTEGRATION_TESTS_RUN_COVERAGE=false tool/run_integration_tests.sh
#   tool/run_integration_tests.sh integration_test/smoke_flows_test.dart
#   tool/run_integration_tests.sh integration_test/app_test.dart
#
# Optional env:
#   INTEGRATION_TESTS_RETRY_ON_FAILURE (0|1, default 1) — full suite only
#   INTEGRATION_TESTS_TIMEOUT_SECONDS (default 1800)
#   DEVICE_DISCOVERY_TIMEOUT_SECONDS (default 60)
#   PROGRESS_HEARTBEAT_SECONDS (default 60)
#   IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS (default 180)
#   XCODE_SIMULATOR_BUILD_RECOVERY_RETRY (0|1, default 1)
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

is_ios_simulator_device() {
  local device_id="$1"

  [ "$(uname -s)" = "Darwin" ] || return 1
  command -v xcrun >/dev/null 2>&1 || return 1

  xcrun simctl list devices available -j 2>/dev/null | /usr/bin/python3 -c '
import json
import sys

device_id = sys.argv[1]
data = json.load(sys.stdin)

for runtime_name, devices in data.get("devices", {}).items():
    if "iOS" not in runtime_name:
        continue
    for device in devices:
        if device.get("udid") == device_id and device.get("isAvailable", True):
            raise SystemExit(0)

raise SystemExit(1)
' "$device_id"
}

wait_for_simulator_boot() {
  local device_id="$1"
  local timeout_seconds="$2"

  /usr/bin/python3 - "$device_id" "$timeout_seconds" <<'PY'
import json
import subprocess
import sys
import time

udid = sys.argv[1]
timeout_seconds = int(sys.argv[2])
deadline = time.time() + timeout_seconds

while time.time() < deadline:
    result = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "--json"],
        check=True,
        capture_output=True,
        text=True,
    )
    data = json.loads(result.stdout)
    state = None
    for runtime_devices in data.get("devices", {}).values():
        for device in runtime_devices:
            if device.get("udid") == udid:
                state = device.get("state")
                break
        if state is not None:
            break
    if state == "Booted":
        raise SystemExit(0)
    time.sleep(5)

raise SystemExit(1)
PY
}

run_logged_command() {
  local log_path="$1"
  shift

  "$@" 2>&1 | tee "$log_path"
}

is_known_xcode_simulator_build_failure() {
  local log_path="$1"

  [ -s "$log_path" ] || return 1

  grep -Eq \
    'incompatible with DVTBuildVersion|Could not build the application for the simulator\.' \
    "$log_path"
}

recover_ios_simulator_after_build_failure() {
  local device_id="$1"

  log "Restarting iOS simulator $device_id after Xcode build infrastructure failure."
  xcrun simctl shutdown "$device_id" 2>/dev/null || true
  sleep 2
  if ! xcrun simctl boot "$device_id" 2>/dev/null; then
    log "Simulator $device_id was already booted or boot request returned non-zero; continuing with boot wait."
  fi
  if ! wait_for_simulator_boot "$device_id" "$IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS"; then
    log "Timed out waiting for simulator $device_id to boot after recovery."
    return 1
  fi
}

run_integration_command() {
  local label="$1"
  shift

  local log_path
  local exit_code=0

  log_path="$(mktemp "${TMPDIR:-/tmp}/integration-tests.XXXXXX.log")"
  run_with_timeout \
    "$label" \
    "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
    run_logged_command \
    "$log_path" \
    "$@"
  exit_code=$?

  if [ "$exit_code" -ne 0 ] &&
    [ "$XCODE_SIMULATOR_BUILD_RECOVERY_RETRY" -eq 1 ] &&
    is_ios_simulator_device "$DEVICE_ID" &&
    is_known_xcode_simulator_build_failure "$log_path"; then
    log "Detected intermittent Xcode simulator build failure for $label. Retrying once after simulator recovery..."
    cleanup_project_xcodebuilds
    if recover_ios_simulator_after_build_failure "$DEVICE_ID"; then
      rm -f "$log_path"
      log_path="$(mktemp "${TMPDIR:-/tmp}/integration-tests.XXXXXX.log")"
      run_with_timeout \
        "$label simulator recovery retry" \
        "$INTEGRATION_TESTS_TIMEOUT_SECONDS" \
        run_logged_command \
        "$log_path" \
        "$@"
      exit_code=$?
    else
      exit_code=1
    fi
  fi

  rm -f "$log_path"
  return "$exit_code"
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
IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS="${IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS:-180}"
XCODE_SIMULATOR_BUILD_RECOVERY_RETRY="${XCODE_SIMULATOR_BUILD_RECOVERY_RETRY:-1}"

normalized_run_coverage="$(trim "$RUN_COVERAGE")"
normalized_run_coverage="$(printf '%s' "$normalized_run_coverage" | tr '[:upper:]' '[:lower:]')"
case "$normalized_run_coverage" in
  true)
    RUN_COVERAGE=1
    ;;
  false)
    RUN_COVERAGE=0
    ;;
esac

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

if ! [[ "$IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] || [ "$IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS" -le 0 ]; then
  log "⚠️ Invalid IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS='$IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS'; using 180."
  IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS=180
fi

if ! [[ "$XCODE_SIMULATOR_BUILD_RECOVERY_RETRY" =~ ^(0|1)$ ]]; then
  log "⚠️ Invalid XCODE_SIMULATOR_BUILD_RECOVERY_RETRY='$XCODE_SIMULATOR_BUILD_RECOVERY_RETRY'; using 1."
  XCODE_SIMULATOR_BUILD_RECOVERY_RETRY=1
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
    log 'Coverage disabled via INTEGRATION_TESTS_RUN_COVERAGE=0|false.'
    run_integration_command \
      "$FULL_SUITE_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$FULL_SUITE_TARGET"
  elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ]; then
    log "Collecting and merging integration coverage with $BASE_COVERAGE_PATH."
    run_integration_command \
      "$FULL_SUITE_TARGET" \
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
    run_integration_command \
      "$FULL_SUITE_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$FULL_SUITE_TARGET"
  else
    log 'Collecting integration-only coverage.'
    log "No baseline coverage found at $BASE_COVERAGE_PATH; writing integration-only coverage."
    run_integration_command \
      "$FULL_SUITE_TARGET" \
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
      run_integration_command \
        "$FULL_SUITE_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$FULL_SUITE_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ]; then
      log "Retrying with merged integration coverage against $BASE_COVERAGE_PATH."
      run_integration_command \
        "$FULL_SUITE_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        --coverage \
        --merge-coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$FULL_SUITE_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ]; then
      run_integration_command \
        "$FULL_SUITE_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$FULL_SUITE_TARGET"
    else
      run_integration_command \
        "$FULL_SUITE_TARGET retry" \
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
  run_integration_command \
    "integration test selection" \
    flutter test --no-pub -d "$DEVICE_ID" "$@"
  exit_code=$?
  set -e
  cleanup_project_xcodebuilds
  exit "$exit_code"
fi
