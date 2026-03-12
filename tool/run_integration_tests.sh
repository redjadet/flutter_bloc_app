#!/bin/bash
# Runs integration tests on a supported non-web device.
#
# Usage:
#   tool/run_integration_tests.sh
#   CHECKLIST_INTEGRATION_DEVICE=<deviceId> tool/run_integration_tests.sh
#   tool/run_integration_tests.sh integration_test/app_test.dart

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

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
        pkill -KILL -f "$pattern" 2>/dev/null || true
      done
      return
    fi
    sleep 1
  done
}

list_supported_devices() {
  flutter devices | while IFS= read -r line; do
    [[ "$line" == *"•"* ]] || continue
    [[ "$line" == *"web-javascript"* ]] && continue

    IFS='•' read -r _ id _ <<< "$line"
    id="$(trim "$id")"
    [ -n "$id" ] && printf '%s\t%s\n' "$id" "$line"
  done
}

preferred_ios_simulator_device_id() {
  local entry
  local device_id
  local device_line

  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    device_id="${entry%%$'\t'*}"
    device_line="${entry#*$'\t'}"

    if [[ "$device_line" == *"ios"* ]] && [[ "$device_line" == *"simulator"* ]]; then
      echo "$device_id"
      return
    fi
  done
}

select_device_id() {
  local requested_device="${CHECKLIST_INTEGRATION_DEVICE:-${INTEGRATION_TEST_DEVICE:-}}"
  local ios_simulator_device
  local preferred_device
  local device_id
  local -a supported_devices=()

  while IFS=$'\t' read -r device_id _; do
    [ -z "$device_id" ] && continue
    supported_devices+=("$device_id")
  done < <(list_supported_devices)

  if [ "${#supported_devices[@]}" -eq 0 ]; then
    echo "❌ No supported non-web device found for integration tests."
    echo "   Connect a device or set CHECKLIST_INTEGRATION_DEVICE to a valid id."
    exit 1
  fi

  if [ -n "$requested_device" ]; then
    for device_id in "${supported_devices[@]}"; do
      if [ "$device_id" = "$requested_device" ]; then
        echo "$device_id"
        return
      fi
    done

    echo "❌ CHECKLIST_INTEGRATION_DEVICE='$requested_device' is not available."
    echo "   Available device ids: ${supported_devices[*]}"
    exit 1
  fi

  ios_simulator_device="$(list_supported_devices | preferred_ios_simulator_device_id || true)"
  if [ -n "$ios_simulator_device" ]; then
    echo "$ios_simulator_device"
    return
  fi

  preferred_device="$(host_desktop_device_id)"
  if [ -n "$preferred_device" ]; then
    for device_id in "${supported_devices[@]}"; do
      if [ "$device_id" = "$preferred_device" ]; then
        echo "$device_id"
        return
      fi
    done
  fi

  if [ "${#supported_devices[@]}" -eq 1 ]; then
    echo "${supported_devices[0]}"
    return
  fi

  echo "❌ Multiple supported devices detected: ${supported_devices[*]}"
  echo "   Set CHECKLIST_INTEGRATION_DEVICE=<deviceId> to choose one."
  exit 1
}

run_integration_test_file() {
  local test_file="$1"

  cleanup_project_xcodebuilds
  echo ""
  echo "==> Running $test_file"
  flutter test --no-pub -d "$DEVICE_ID" "$test_file"
  cleanup_project_xcodebuilds
}

DEVICE_ID="$(select_device_id)"

echo "Running integration tests on device: $DEVICE_ID"
if [ "$#" -eq 0 ]; then
  cleanup_project_xcodebuilds
  flutter test --no-pub -d "$DEVICE_ID" integration_test/
  exit_code=$?
  cleanup_project_xcodebuilds
  exit ${exit_code}
else
  flutter test --no-pub -d "$DEVICE_ID" "$@"
fi
