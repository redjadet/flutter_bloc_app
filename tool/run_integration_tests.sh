#!/bin/bash
# Runs integration tests on a supported non-web device.
#
# Usage:
#   tool/run_integration_tests.sh
#   CHECKLIST_INTEGRATION_DEVICE=macos tool/run_integration_tests.sh
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

DEVICE_ID="$(select_device_id)"

echo "Running integration tests on device: $DEVICE_ID"
if [ "$#" -eq 0 ]; then
  flutter test --no-pub integration_test -d "$DEVICE_ID"
else
  flutter test --no-pub -d "$DEVICE_ID" "$@"
fi
