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
#   INTEGRATION_TESTS_ENABLE_SELECTIVE (0|1) — narrow target via map + changed paths
#   INTEGRATION_TESTS_CHANGED_FILES — comma/newline-separated paths for selective resolver
#   INTEGRATION_TESTS_RETRY_ON_FAILURE (0|1, default 0) — skips retry when logs look like assertion failures
#   INTEGRATION_TESTS_TIMEOUT_SECONDS (default 1800)
#   DEVICE_DISCOVERY_TIMEOUT_SECONDS (default 60)
#   PROGRESS_HEARTBEAT_SECONDS (default 60)
#   IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS (default 180)
#   IOS_SIMULATOR_PREFERRED_NAMES (comma-separated preferred iPhone simulators)
#   ALLOW_DESKTOP_INTEGRATION_DEVICE (0|1, default 0)
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

INTEGRATION_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
INTEGRATION_START_EPOCH_MS="$(python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
)"
INTEGRATION_FAILURE_CATEGORY="none"
INTEGRATION_SELECTED_TARGETS=""
INTEGRATION_RETRIED="0"
INTEGRATION_RETRY_REASON=""
INTEGRATION_ARTIFACT_DIR=""
INTEGRATION_INFERRED_FAILURE_CATEGORY=""
INTEGRATION_SELECTIVE_REASON="off"
INTEGRATION_DURATION_MS=""
INTEGRATION_PUBLISH_PORT_REQUIRED="0"
INTEGRATION_USED_PUBLISH_PORT="0"

classify_exit_category() {
  local exit_code="$1"
  if [ "$exit_code" -eq 0 ]; then
    echo "ok"
    return
  fi
  case "$exit_code" in
    124)
      echo "timeout"
      ;;
    130|137|143)
      echo "cancelled_or_terminated"
      ;;
    *)
      if [ -n "${INTEGRATION_INFERRED_FAILURE_CATEGORY:-}" ]; then
        echo "$INTEGRATION_INFERRED_FAILURE_CATEGORY"
        return
      fi
      if [ "$INTEGRATION_RETRIED" = "1" ] && [ -n "$INTEGRATION_RETRY_REASON" ]; then
        echo "$INTEGRATION_RETRY_REASON"
      else
        echo "test_assertion_or_app_failure"
      fi
      ;;
  esac
}

write_integration_artifact() {
  local exit_code="$1"
  local device_id="${2:-unknown}"
  local selected_targets="${3:-}"
  [ -n "${INTEGRATION_ARTIFACT_DIR:-}" ] || return 0
  mkdir -p "$INTEGRATION_ARTIFACT_DIR"
  /usr/bin/python3 - "$INTEGRATION_ARTIFACT_DIR" "$exit_code" "$INTEGRATION_FAILURE_CATEGORY" "$device_id" "$selected_targets" "$INTEGRATION_RETRIED" "$INTEGRATION_RETRY_REASON" "$INTEGRATION_STARTED_AT" <<'PY'
import json
import os
import re
import sys
from datetime import datetime, timezone

out_dir = sys.argv[1]
exit_code = int(sys.argv[2])
failure_category = sys.argv[3]
device_id = sys.argv[4]
targets = [t for t in re.split(r"\s*,\s*|\s+", sys.argv[5].strip()) if t]
retried = sys.argv[6] == "1"
retry_reason = sys.argv[7]
started_at = sys.argv[8]
ended_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

duration_raw = os.environ.get("INTEGRATION_DURATION_MS", "").strip()
tier = os.environ.get("INTEGRATION_TESTS_TIER", "").strip()
selective_reason = os.environ.get("INTEGRATION_SELECTIVE_REASON", "").strip()

summary = {
    "started_at": started_at,
    "ended_at": ended_at,
    "exit_code": exit_code,
    "status": "ok" if exit_code == 0 else "failed",
    "failure_category": failure_category,
    "device_id": device_id,
    "targets": targets,
    "retried": retried,
    "retry_reason": retry_reason or None,
}
if duration_raw.isdigit():
    summary["duration_ms"] = int(duration_raw)
if tier:
    summary["tier"] = tier
if selective_reason and selective_reason not in ("unset", "off"):
    summary["selective_resolution_reason"] = selective_reason
with open(os.path.join(out_dir, "summary.json"), "w", encoding="utf-8") as f:
    json.dump(summary, f, indent=2, sort_keys=True)
    f.write("\n")
PY
  local _art_root="${INTEGRATION_TESTS_ARTIFACTS_ROOT:-artifacts/integration}"
  mkdir -p "$_art_root"
  printf '%s\n' "$INTEGRATION_ARTIFACT_DIR" > "${_art_root%/}/.last-run-dir"
}

emit_integration_scorecard_event() {
  local exit_code="$1"
  local event_status="failed"
  local integration_pass="0"
  local ended_at
  local duration_ms
  local workspace_fingerprint

  ended_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  duration_ms="$(python3 - "$INTEGRATION_START_EPOCH_MS" <<'PY'
import sys
import time
start_ms = int(sys.argv[1])
print(max(0, int(time.time() * 1000) - start_ms))
PY
)"
  workspace_fingerprint="$(python3 "$PROJECT_ROOT/tool/validation_reuse.py" fingerprint 2>/dev/null || true)"

  if [ "${INTEGRATION_SCORECARD_SKIPPED:-0}" = "1" ]; then
    event_status="cancelled"
    integration_pass="null"
  elif [ "$exit_code" -eq 0 ]; then
    event_status="ok"
    integration_pass="1"
  fi

  "$PROJECT_ROOT/tool/emit_agent_scorecard_event.sh" \
    --command integration_tests \
    --status "$event_status" \
    --started-at "$INTEGRATION_STARTED_AT" \
    --ended-at "$ended_at" \
    --duration-ms "$duration_ms" \
    --risk-class high \
    --workspace-fingerprint "$workspace_fingerprint" \
    --checklist-pass null \
    --router-pass null \
    --integration-pass "$integration_pass" \
    --attempt "${ATTEMPT:-1}" >/dev/null 2>&1 || true
}

record_integration_exit() {
  local integration_exit_code=$?
  INTEGRATION_DURATION_MS="$(/usr/bin/python3 - "$INTEGRATION_START_EPOCH_MS" <<'PY'
import sys
import time
print(max(0, int(time.time() * 1000) - int(sys.argv[1])))
PY
)"
  export INTEGRATION_DURATION_MS
  INTEGRATION_FAILURE_CATEGORY="$(classify_exit_category "$integration_exit_code")"
  write_integration_artifact "$integration_exit_code" "${DEVICE_ID:-unknown}" "${INTEGRATION_SELECTED_TARGETS:-}"
  emit_integration_scorecard_event "$integration_exit_code"
}

trap 'record_integration_exit' EXIT

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2
}

validate_integration_target_path() {
  local candidate="$1"

  case "$candidate" in
    *..*) return 1 ;;
  esac
  if [[ ! "$candidate" =~ ^integration_test/[a-zA-Z0-9_./-]+\.dart$ ]]; then
    return 1
  fi
  [ -f "$PROJECT_ROOT/$candidate" ]
}

validate_integration_runner_configuration() {
  local full_target="$1"
  local smoke_target="$2"
  local standard_target="$3"
  local failed=0
  local target

  for target in "$full_target" "$smoke_target" "$standard_target"; do
    if ! validate_integration_target_path "$target"; then
      log "❌ Missing or invalid integration target: $target"
      failed=1
    fi
  done

  if ! /usr/bin/python3 - "$PROJECT_ROOT/tool/integration_selective_map.json" <<'PY'
import json
import sys
from pathlib import Path

map_path = Path(sys.argv[1])
repo_root = map_path.parent.parent
raw = json.loads(map_path.read_text(encoding="utf-8"))
rules = raw.get("rules", [])
if not isinstance(rules, list):
    raise SystemExit("rules must be a list")

seen_ids = set()
seen_targets = set()
for index, rule in enumerate(rules):
    if not isinstance(rule, dict):
        raise SystemExit(f"rules[{index}] must be an object")
    rule_id = rule.get("id")
    target = rule.get("target")
    prefixes = rule.get("path_prefixes")
    if not isinstance(rule_id, str) or not rule_id:
        raise SystemExit(f"rules[{index}].id must be a non-empty string")
    if rule_id in seen_ids:
        raise SystemExit(f"duplicate rule id: {rule_id}")
    seen_ids.add(rule_id)
    if not isinstance(target, str) or not target.startswith("integration_test/"):
        raise SystemExit(f"rules[{index}].target must be an integration_test/*.dart path")
    if not (repo_root / target).is_file():
        raise SystemExit(f"missing target file for rule {rule_id}: {target}")
    seen_targets.add(target)
    if not isinstance(prefixes, list) or not prefixes or not all(isinstance(p, str) and p for p in prefixes):
        raise SystemExit(f"rules[{index}].path_prefixes must be a non-empty list of strings")

force_prefixes = raw.get("force_full_suite_prefixes", [])
if not isinstance(force_prefixes, list) or not all(isinstance(p, str) and p for p in force_prefixes):
    raise SystemExit("force_full_suite_prefixes must be a list of non-empty strings")
PY
  then
    log "❌ integration_selective_map.json validation failed"
    failed=1
  fi

  return "$failed"
}

# When running in GitHub Actions, we only want integration tests to execute on
# manual runs (`workflow_dispatch`). For push/pull_request we exit successfully
# so the workflow job doesn't fail and doesn't waste time.
if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  if [ "${GITHUB_EVENT_NAME:-}" != "workflow_dispatch" ]; then
    log "Skipping integration tests: requires workflow_dispatch (got GITHUB_EVENT_NAME='${GITHUB_EVENT_NAME:-unset}')."
    INTEGRATION_SCORECARD_SKIPPED=1
    exit 0
  fi
fi

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

preferred_ios_simulator_selection() {
  [ "$(uname -s)" = "Darwin" ] || return 1
  command -v xcrun >/dev/null 2>&1 || return 1

  xcrun simctl list devices available -j 2>/dev/null | /usr/bin/python3 -c '
import json
import sys

preferred_names = [
    name.strip()
    for name in sys.argv[1].split(",")
    if name.strip()
]
data = json.load(sys.stdin)
available_iphones = []

for runtime_name, devices in data.get("devices", {}).items():
    if "iOS" not in runtime_name:
        continue
    for device in devices:
        if device.get("isAvailable", True) and "iPhone" in device.get("name", ""):
            available_iphones.append(device)

for preferred_name in preferred_names:
    for device in available_iphones:
        if device.get("name") == preferred_name:
            print(f"{device['udid']}\t{device['name']}")
            raise SystemExit(0)

if available_iphones:
    print(f"{available_iphones[0]['udid']}\t{available_iphones[0]['name']}")
    raise SystemExit(0)

raise SystemExit(1)
' "$IOS_SIMULATOR_PREFERRED_NAMES"
}

booted_ios_simulator_selection() {
  [ "$(uname -s)" = "Darwin" ] || return 1
  command -v xcrun >/dev/null 2>&1 || return 1

  xcrun simctl list devices booted -j 2>/dev/null | /usr/bin/python3 -c '
import json
import sys

data = json.load(sys.stdin)
booted_iphones = []

for runtime_name, devices in data.get("devices", {}).items():
    if "iOS" not in runtime_name:
        continue
    for device in devices:
        if device.get("isAvailable", True) and "iPhone" in device.get("name", ""):
            booted_iphones.append(device)

if booted_iphones:
    device = booted_iphones[0]
    print(f"{device.get('udid','')}\t{device.get('name','')}")
    raise SystemExit(0)

raise SystemExit(1)
'
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

boot_preferred_ios_simulator() {
  local simulator_selection
  local simulator_udid
  local simulator_name

  simulator_selection="$(preferred_ios_simulator_selection 2>/dev/null || true)"
  [ -n "$simulator_selection" ] || return 1

  IFS=$'\t' read -r simulator_udid simulator_name <<< "$simulator_selection"
  [ -n "${simulator_udid:-}" ] || return 1

  log "Booting preferred iPhone simulator: ${simulator_name:-unknown} ($simulator_udid)"
  if ! xcrun simctl boot "$simulator_udid" 2>/dev/null; then
    log "Simulator $simulator_udid was already booted or boot request returned non-zero; continuing with boot wait."
  fi

  if ! wait_for_simulator_boot "$simulator_udid" "$IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS"; then
    log "Timed out waiting for simulator $simulator_udid to boot."
    return 1
  fi

  return 0
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

validate_integration_selective_target_path() {
  local candidate="$1"

  case "$candidate" in
    *..*) return 1 ;;
  esac
  if [[ ! "$candidate" =~ ^integration_test/[a-zA-Z0-9_]+\.dart$ ]]; then
    return 1
  fi
  [ -f "$PROJECT_ROOT/$candidate" ]
}

infer_flutter_failure_category_from_log() {
  local log_path="$1"

  [ -s "$log_path" ] || {
    printf '%s\n' ""
    return
  }
  /usr/bin/python3 - "$log_path" <<'PY'
import sys

path = sys.argv[1]
try:
    text = open(path, "r", encoding="utf-8", errors="replace").read()
except OSError:
    print("")
    raise SystemExit(0)
tail = text[-200000:] if len(text) > 200000 else text
low = tail.lower()
# Deterministic test assertion failures (do not auto-retry).
if "testfailure" in low or "flutter test framework" in low:
    print("test_assertion_or_app_failure")
elif "══╡" in tail and "exception" in low:
    print("test_assertion_or_app_failure")
elif "expected:" in low and "actual:" in low:
    print("test_assertion_or_app_failure")
elif "some tests failed" in low:
    print("test_assertion_or_app_failure")
elif "could not build the application" in low:
    print("simulator_build_infra")
elif "xcodebuild" in low and " error " in low:
    print("simulator_build_infra")
elif "failed to load asset" in low:
    print("test_assertion_or_app_failure")
elif "socketexception" in low or "connection reset" in low or "connection refused" in low:
    print("infra_device_or_tooling")
elif (
    "failed to connect to the vm service" in low
    or "failed to connect to vm service" in low
    or "unable to connect to vm service" in low
    or "vm service disappeared" in low
    or "dart vm service was not discovered" in low
    or "unable to start the app on the device" in low
    or "lost connection to device" in low
):
    print("infra_device_or_tooling")
elif "cannot start app on wirelessly tethered ios device" in low:
    print("wireless_publish_port_required")
else:
    print("unknown_transient_or_infra")
PY
}

emit_actionable_hint_from_log() {
  local log_path="$1"

  [ -s "$log_path" ] || return 0

  # Keep this lightweight and tail-focused; we only want to surface hints for
  # the most common, non-code failures that waste time during upgrades.
  if grep -Eqi 'Dart VM Service was not discovered|Unable to start the app on the device' "$log_path"; then
    log "⚠️ Flutter couldn't discover the Dart VM Service / couldn't start the app."
    if [ "$(uname -s)" = "Darwin" ]; then
      log "   If this is iOS, check macOS Automation permissions:"
      log "   Settings → Privacy & Security → Automation (allow Xcode/Flutter control)."
      log "   Then retry: ./bin/integration_tests (or set CHECKLIST_INTEGRATION_DEVICE=<deviceId>)."
    else
      log "   Check device connectivity and developer tooling permissions, then retry."
    fi
  fi
}

run_integration_command() {
  local label="$1"
  shift

  local log_path
  local temp_dir
  local exit_code=0

  temp_dir="${TMPDIR:-/tmp}"
  temp_dir="${temp_dir%/}"
  log_path="$(mktemp "$temp_dir/integration-tests.XXXXXX")"
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
      log_path="$(mktemp "$temp_dir/integration-tests.XXXXXX")"
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

  if [ "$exit_code" -eq 0 ]; then
    INTEGRATION_INFERRED_FAILURE_CATEGORY=""
  else
    INTEGRATION_INFERRED_FAILURE_CATEGORY="$(infer_flutter_failure_category_from_log "$log_path")"
    log "Inferred failure category from flutter output: ${INTEGRATION_INFERRED_FAILURE_CATEGORY:-unknown}"
    emit_actionable_hint_from_log "$log_path"
    if [ "${INTEGRATION_INFERRED_FAILURE_CATEGORY:-}" = "wireless_publish_port_required" ]; then
      INTEGRATION_PUBLISH_PORT_REQUIRED="1"
    fi
  fi

  if [ -n "${INTEGRATION_ARTIFACT_DIR:-}" ] && [ -s "$log_path" ]; then
    safe_label="$(printf '%s' "$label" | tr -cs '[:alnum:]._-' '_')"
    cp "$log_path" "$INTEGRATION_ARTIFACT_DIR/flutter_test_${safe_label}.log" 2>/dev/null || true
  fi

  rm -f "$log_path"
  return "$exit_code"
}

cleanup_project_xcodebuilds() {
  if [ -z "${DEVICE_ID:-}" ] || ! is_ios_simulator_device "$DEVICE_ID"; then
    return 0
  fi

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

    if [ -z "$requested_device" ] && [ "$(uname -s)" = "Darwin" ]; then
      local booted_simulator_selection=""
      local booted_simulator_udid=""
      local booted_simulator_name=""

      booted_simulator_selection="$(booted_ios_simulator_selection 2>/dev/null || true)"
      if [ -n "$booted_simulator_selection" ]; then
        IFS=$'\t' read -r booted_simulator_udid booted_simulator_name <<< "$booted_simulator_selection"
        if [ -n "${booted_simulator_udid:-}" ]; then
          for index in "${!supported_device_ids[@]}"; do
            if [ "${supported_device_ids[$index]}" = "$booted_simulator_udid" ]; then
              echo "$booted_simulator_udid"
              return
            fi
          done
        fi
      fi

      local has_ios_simulator=0
      for index in "${!supported_device_ids[@]}"; do
        device_line="${supported_device_lines[$index]}"
        if [[ "$device_line" == *"ios"* ]] && [[ "$device_line" == *"simulator"* ]]; then
          has_ios_simulator=1
          break
        fi
      done

      if [ "$has_ios_simulator" -eq 0 ] && boot_preferred_ios_simulator; then
        sleep 5
        continue
      fi
    fi

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

  for index in "${!supported_device_ids[@]}"; do
    device_line="${supported_device_lines[$index]}"
    if [[ "$device_line" == *"ios"* ]]; then
      echo "${supported_device_ids[$index]}"
      return
    fi
  done

  preferred_device="$(host_desktop_device_id)"
  if [ "$ALLOW_DESKTOP_INTEGRATION_DEVICE" -eq 1 ] && [ -n "$preferred_device" ]; then
    for device_id in "${supported_device_ids[@]}"; do
      if [ "$device_id" = "$preferred_device" ]; then
        echo "$device_id"
        return
      fi
    done
  fi

  if [ "${#supported_device_ids[@]}" -eq 1 ] && [ "$ALLOW_DESKTOP_INTEGRATION_DEVICE" -eq 1 ]; then
    echo "${supported_device_ids[0]}"
    return
  fi

  log '❌ No iPhone simulator or iPhone device was selected for integration tests.'
  log "Available supported device ids: ${supported_device_ids[*]}"
  log 'Boot an iPhone simulator, connect an iPhone, or set CHECKLIST_INTEGRATION_DEVICE=<deviceId>.'
  log 'If you intentionally want the desktop target, rerun with ALLOW_DESKTOP_INTEGRATION_DEVICE=1.'
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

  case "${INTEGRATION_INFERRED_FAILURE_CATEGORY:-}" in
    test_assertion_or_app_failure)
      log 'Not retrying: flutter log classified as test/assertion failure (category-based retry).'
      return 1
      ;;
  esac

  if [ -n "${INTEGRATION_INFERRED_FAILURE_CATEGORY:-}" ]; then
    log "Retry allowed for failure category: ${INTEGRATION_INFERRED_FAILURE_CATEGORY}"
  fi

  return 0
}

RUN_COVERAGE="${INTEGRATION_TESTS_RUN_COVERAGE:-1}"
RETRY_ON_FAILURE="${INTEGRATION_TESTS_RETRY_ON_FAILURE:-0}"
INTEGRATION_TESTS_TIMEOUT_SECONDS="${INTEGRATION_TESTS_TIMEOUT_SECONDS:-1800}"
DEVICE_DISCOVERY_TIMEOUT_SECONDS="${DEVICE_DISCOVERY_TIMEOUT_SECONDS:-60}"
PROGRESS_HEARTBEAT_SECONDS="${PROGRESS_HEARTBEAT_SECONDS:-60}"
IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS="${IOS_SIMULATOR_BOOT_TIMEOUT_SECONDS:-180}"
IOS_SIMULATOR_PREFERRED_NAMES="${IOS_SIMULATOR_PREFERRED_NAMES:-iPhone 17e,iPhone 17 Pro,iPhone 17,iPhone 16e,iPhone 16 Pro,iPhone 16}"
ALLOW_DESKTOP_INTEGRATION_DEVICE="${ALLOW_DESKTOP_INTEGRATION_DEVICE:-0}"
XCODE_SIMULATOR_BUILD_RECOVERY_RETRY="${XCODE_SIMULATOR_BUILD_RECOVERY_RETRY:-1}"
INTEGRATION_TESTS_TIER="${INTEGRATION_TESTS_TIER:-exhaustive}"
INTEGRATION_TESTS_TARGET_SET="${INTEGRATION_TESTS_TARGET_SET:-}"
INTEGRATION_TESTS_ARTIFACTS_ROOT="${INTEGRATION_TESTS_ARTIFACTS_ROOT:-artifacts/integration}"
INTEGRATION_TESTS_CHANGED_FILES="${INTEGRATION_TESTS_CHANGED_FILES:-}"
INTEGRATION_TESTS_ENABLE_SELECTIVE="${INTEGRATION_TESTS_ENABLE_SELECTIVE:-0}"

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
  log "⚠️ Invalid INTEGRATION_TESTS_RETRY_ON_FAILURE='$RETRY_ON_FAILURE'; using 0."
  RETRY_ON_FAILURE=0
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

if ! [[ "$ALLOW_DESKTOP_INTEGRATION_DEVICE" =~ ^(0|1)$ ]]; then
  log "⚠️ Invalid ALLOW_DESKTOP_INTEGRATION_DEVICE='$ALLOW_DESKTOP_INTEGRATION_DEVICE'; using 0."
  ALLOW_DESKTOP_INTEGRATION_DEVICE=0
fi

if ! [[ "$XCODE_SIMULATOR_BUILD_RECOVERY_RETRY" =~ ^(0|1)$ ]]; then
  log "⚠️ Invalid XCODE_SIMULATOR_BUILD_RECOVERY_RETRY='$XCODE_SIMULATOR_BUILD_RECOVERY_RETRY'; using 1."
  XCODE_SIMULATOR_BUILD_RECOVERY_RETRY=1
fi

INTEGRATION_TESTS_TIER="$(printf '%s' "$INTEGRATION_TESTS_TIER" | tr '[:upper:]' '[:lower:]')"
case "$INTEGRATION_TESTS_TIER" in
  smoke|standard|exhaustive)
    ;;
  *)
    log "⚠️ Invalid INTEGRATION_TESTS_TIER='$INTEGRATION_TESTS_TIER'; using exhaustive."
    INTEGRATION_TESTS_TIER="exhaustive"
    ;;
esac
export INTEGRATION_TESTS_TIER

if ! [[ "$INTEGRATION_TESTS_ENABLE_SELECTIVE" =~ ^(0|1)$ ]]; then
  log "⚠️ Invalid INTEGRATION_TESTS_ENABLE_SELECTIVE='$INTEGRATION_TESTS_ENABLE_SELECTIVE'; using 0."
  INTEGRATION_TESTS_ENABLE_SELECTIVE=0
fi

BASE_COVERAGE_PATH="coverage/lcov.base.info"
FINAL_COVERAGE_PATH="coverage/lcov.info"
FULL_SUITE_TARGET="integration_test/all_flows_test.dart"
SMOKE_SUITE_TARGET="integration_test/smoke_flows_test.dart"
STANDARD_SUITE_TARGET="integration_test/standard_flows_test.dart"
HAS_LCOV=0

if ! validate_integration_runner_configuration "$FULL_SUITE_TARGET" "$SMOKE_SUITE_TARGET" "$STANDARD_SUITE_TARGET"; then
  exit 1
fi

if [ "$#" -gt 0 ]; then
  for explicit_target in "$@"; do
    if ! validate_integration_target_path "$explicit_target"; then
      log "❌ Invalid explicit integration target: $explicit_target"
      exit 1
    fi
  done
fi

DEVICE_ID="$(select_device_id)"
DART_BIN="$(resolve_flutter_dart)"

if command -v lcov >/dev/null 2>&1; then
  HAS_LCOV=1
fi

log "Running integration tests on device: $DEVICE_ID"
INTEGRATION_ARTIFACT_DIR="$INTEGRATION_TESTS_ARTIFACTS_ROOT/$(date -u +%Y%m%d-%H%M%S)"
log "Coverage mode: $RUN_COVERAGE | Retry on failure: $RETRY_ON_FAILURE | Tier: $INTEGRATION_TESTS_TIER | Test timeout: ${INTEGRATION_TESTS_TIMEOUT_SECONDS}s"
if [ "$#" -eq 0 ]; then
  SELECTED_TARGET="$FULL_SUITE_TARGET"
  if [ "$INTEGRATION_TESTS_TIER" = "smoke" ]; then
    SELECTED_TARGET="$SMOKE_SUITE_TARGET"
  elif [ "$INTEGRATION_TESTS_TIER" = "standard" ]; then
    SELECTED_TARGET="$STANDARD_SUITE_TARGET"
  fi
  if [ -n "$INTEGRATION_TESTS_TARGET_SET" ]; then
    case "$INTEGRATION_TESTS_TARGET_SET" in
      smoke) SELECTED_TARGET="$SMOKE_SUITE_TARGET" ;;
      standard) SELECTED_TARGET="$STANDARD_SUITE_TARGET" ;;
      exhaustive|full) SELECTED_TARGET="$FULL_SUITE_TARGET" ;;
      *)
        log "Unknown INTEGRATION_TESTS_TARGET_SET='$INTEGRATION_TESTS_TARGET_SET'; falling back to full suite."
        SELECTED_TARGET="$FULL_SUITE_TARGET"
        ;;
    esac
  fi
  INTEGRATION_SELECTIVE_REASON="off"
  export INTEGRATION_SELECTIVE_REASON
  if [ "$INTEGRATION_TESTS_ENABLE_SELECTIVE" -eq 1 ] &&
    [ -n "$INTEGRATION_TESTS_CHANGED_FILES" ] &&
    [ "$INTEGRATION_TESTS_TIER" != "exhaustive" ]; then
    set +e
    _sel_out="$(
      printf '%s\n' "$INTEGRATION_TESTS_CHANGED_FILES" | tr ',' '\n' |
        /usr/bin/python3 "$PROJECT_ROOT/tool/integration_selective_resolve.py" --lines
    )"
    _sel_rc=$?
    set -e
    _sel_target="$(printf '%s\n' "$_sel_out" | sed -n '1p')"
    _sel_reason="$(printf '%s\n' "$_sel_out" | sed -n '2p')"
    if [ "$_sel_rc" -ne 0 ] || [ -z "$_sel_target" ] || [ -z "$_sel_reason" ]; then
      log "⚠️ Selective resolver failed (rc=${_sel_rc:-?}); using full suite."
      _sel_target="FULL_SUITE"
      _sel_reason="resolver_error"
    fi
    INTEGRATION_SELECTIVE_REASON="$_sel_reason"
    export INTEGRATION_SELECTIVE_REASON
    if [ "$_sel_target" != "FULL_SUITE" ] &&
      ! validate_integration_selective_target_path "$_sel_target"; then
      log "⚠️ Selective map target is missing or not allowed: $_sel_target; using full suite."
      _sel_target="FULL_SUITE"
      _sel_reason="invalid_selective_target"
      INTEGRATION_SELECTIVE_REASON="$_sel_reason"
      export INTEGRATION_SELECTIVE_REASON
    fi
    if [ "$_sel_target" != "FULL_SUITE" ]; then
      SELECTED_TARGET="$_sel_target"
      log "Selective map resolved target=$_sel_target (reason=$_sel_reason)"
    else
      SELECTED_TARGET="$FULL_SUITE_TARGET"
      log "Selective map fallthrough to full suite (reason=$_sel_reason)"
    fi
  elif [ "$INTEGRATION_TESTS_ENABLE_SELECTIVE" -eq 1 ] &&
    [ -n "$INTEGRATION_TESTS_CHANGED_FILES" ] &&
    [ "$INTEGRATION_TESTS_TIER" = "exhaustive" ]; then
    INTEGRATION_SELECTIVE_REASON="skipped_for_exhaustive_tier"
    export INTEGRATION_SELECTIVE_REASON
    log "Selective map skipped for exhaustive tier (running full aggregate target)."
  fi
  INTEGRATION_SELECTED_TARGETS="$SELECTED_TARGET"
  cleanup_project_xcodebuilds
  log "Running integration suite target: $SELECTED_TARGET"
  set +e
  if [ "$RUN_COVERAGE" -eq 0 ]; then
    log 'Coverage disabled via INTEGRATION_TESTS_RUN_COVERAGE=0|false.'
    run_integration_command \
      "$SELECTED_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$SELECTED_TARGET"
  elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ] && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
    log "Collecting and merging integration coverage with $BASE_COVERAGE_PATH."
    run_integration_command \
      "$SELECTED_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      --coverage \
      --merge-coverage \
      --coverage-path="$FINAL_COVERAGE_PATH" \
      "$SELECTED_TARGET"
  elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
    log "⚠️ 'lcov' is not installed, so baseline merge is unavailable."
    log 'Running integration tests without coverage update.'
    run_integration_command \
      "$SELECTED_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$SELECTED_TARGET"
  elif [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
    log 'Collecting integration-only coverage.'
    log "No baseline coverage found at $BASE_COVERAGE_PATH; writing integration-only coverage."
    run_integration_command \
      "$SELECTED_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      --coverage \
      --coverage-path="$FINAL_COVERAGE_PATH" \
      "$SELECTED_TARGET"
  else
    log 'Skipping --coverage for tiered integration run (coverage collection and summary are full-suite only).'
    run_integration_command \
      "$SELECTED_TARGET" \
      flutter test \
      --no-pub \
      -d "$DEVICE_ID" \
      "$SELECTED_TARGET"
  fi
  exit_code=$?
  if [ "$exit_code" -ne 0 ] &&
    [ "$INTEGRATION_PUBLISH_PORT_REQUIRED" = "1" ] &&
    [ "$INTEGRATION_USED_PUBLISH_PORT" = "0" ]; then
    INTEGRATION_RETRIED="1"
    INTEGRATION_RETRY_REASON="wireless_publish_port_required"
    INTEGRATION_USED_PUBLISH_PORT="1"
    log "Detected wirelessly tethered iOS device. Retrying once with --publish-port..."
    cleanup_project_xcodebuilds
    sleep 2
    set +e
    if [ "$RUN_COVERAGE" -eq 0 ]; then
      run_integration_command \
        "$SELECTED_TARGET publish-port retry" \
        flutter test \
        --no-pub \
        --publish-port \
        -d "$DEVICE_ID" \
        "$SELECTED_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ] && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
      run_integration_command \
        "$SELECTED_TARGET publish-port retry" \
        flutter test \
        --no-pub \
        --publish-port \
        -d "$DEVICE_ID" \
        --coverage \
        --merge-coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$SELECTED_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
      run_integration_command \
        "$SELECTED_TARGET publish-port retry" \
        flutter test \
        --no-pub \
        --publish-port \
        -d "$DEVICE_ID" \
        "$SELECTED_TARGET"
    elif [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
      run_integration_command \
        "$SELECTED_TARGET publish-port retry" \
        flutter test \
        --no-pub \
        --publish-port \
        -d "$DEVICE_ID" \
        --coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$SELECTED_TARGET"
    else
      run_integration_command \
        "$SELECTED_TARGET publish-port retry" \
        flutter test \
        --no-pub \
        --publish-port \
        -d "$DEVICE_ID" \
        "$SELECTED_TARGET"
    fi
    exit_code=$?
    set -e
  fi
  if [ "$exit_code" -ne 0 ] && should_retry_integration_run "$exit_code"; then
    INTEGRATION_RETRIED="1"
    # Generic retry path is opt-in; do not label as infra-specific.
    INTEGRATION_RETRY_REASON="retry_on_failure_enabled"
    log "Integration tests failed with exit $exit_code. Retrying once after cleanup..."
    cleanup_project_xcodebuilds
    sleep 5
    if [ "$RUN_COVERAGE" -eq 0 ]; then
      run_integration_command \
        "$SELECTED_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$SELECTED_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$HAS_LCOV" -eq 1 ] && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
      log "Retrying with merged integration coverage against $BASE_COVERAGE_PATH."
      run_integration_command \
        "$SELECTED_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        --coverage \
        --merge-coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$SELECTED_TARGET"
    elif [ -s "$BASE_COVERAGE_PATH" ] && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
      run_integration_command \
        "$SELECTED_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$SELECTED_TARGET"
    elif [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
      run_integration_command \
        "$SELECTED_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        --coverage \
        --coverage-path="$FINAL_COVERAGE_PATH" \
        "$SELECTED_TARGET"
    else
      run_integration_command \
        "$SELECTED_TARGET retry" \
        flutter test \
        --no-pub \
        -d "$DEVICE_ID" \
        "$SELECTED_TARGET"
    fi
    exit_code=$?
  fi
  set -e
  cleanup_project_xcodebuilds
  if [ "$exit_code" -eq 0 ] && [ "$RUN_COVERAGE" -eq 0 ]; then
    log 'Skipping coverage summary update because integration coverage is disabled.'
  elif [ "$exit_code" -eq 0 ] && { [ ! -s "$BASE_COVERAGE_PATH" ] || [ "$HAS_LCOV" -eq 1 ]; } && [ "$SELECTED_TARGET" = "$FULL_SUITE_TARGET" ]; then
    log 'Updating coverage summary...'
    "$DART_BIN" run tool/update_coverage_summary.dart
  elif [ "$exit_code" -eq 0 ]; then
    log "Skipping coverage summary update because baseline merge requires 'lcov'."
  fi
  exit "$exit_code"
else
  INTEGRATION_SELECTED_TARGETS="$(printf '%s,' "$@" | sed 's/,$//')"
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
