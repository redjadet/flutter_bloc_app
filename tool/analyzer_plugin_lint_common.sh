#!/usr/bin/env bash
# Shared dart analyze --format machine for native analyzer plugins (mix_lint).
# Scope defaults to lib/ — full `.` can hang or crash the analysis server with plugins.
# shellcheck disable=SC2034
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
source "$ROOT/tool/resolve_flutter_dart.sh"

ANALYZER_PLUGIN_SCOPE="${ANALYZER_PLUGIN_SCOPE:-lib}"
ANALYZER_PLUGIN_TIMEOUT_SEC="${ANALYZER_PLUGIN_TIMEOUT_SEC:-600}"
ANALYZER_PLUGIN_HEARTBEAT_SEC="${ANALYZER_PLUGIN_HEARTBEAT_SEC:-30}"

analyzer_plugin_is_crash_output() {
  local output="$1"
  printf '%s\n' "$output" | grep -Eqi \
    'Bad state: The analysis server crashed|analysis server crashed|Analysis server exited unexpectedly|analysis server has terminated'
}

run_analyzer_plugin_machine_analysis() {
  local scope="${1:-$ANALYZER_PLUGIN_SCOPE}"
  local tmp_dir="${CHECKLIST_TMP_DIR:-${TMPDIR:-/tmp}}"
  local out_file="${ANALYZER_PLUGIN_MACHINE_OUTPUT:-$tmp_dir/analyzer_plugin_machine.out}"
  local status_file="${out_file}.exit"
  local label="${2:-analyzer plugin lint}"

  mkdir -p "$(dirname "$out_file")"
  : >"$out_file"
  : >"$status_file"

  local dart_bin
  dart_bin="$(resolve_flutter_dart)"

  echo "Running $label (dart analyze --format machine $scope)..." >&2

  set +e
  (
    "$dart_bin" analyze --format machine "$scope" >"$out_file" 2>&1
    echo $? >"$status_file"
  ) &
  local analyze_pid=$!

  local heartbeat_pid=""
  if [ "$ANALYZER_PLUGIN_HEARTBEAT_SEC" -gt 0 ]; then
    (
      while kill -0 "$analyze_pid" 2>/dev/null; do
        sleep "$ANALYZER_PLUGIN_HEARTBEAT_SEC"
        if kill -0 "$analyze_pid" 2>/dev/null; then
          echo "  … $label still running ($(date -u +%H:%M:%S) UTC)" >&2
        fi
      done
    ) &
    heartbeat_pid=$!
  fi

  local waited=0
  while kill -0 "$analyze_pid" 2>/dev/null; do
    if [ "$waited" -ge "$ANALYZER_PLUGIN_TIMEOUT_SEC" ]; then
      echo "❌ $label timed out after ${ANALYZER_PLUGIN_TIMEOUT_SEC}s (scope: $scope)." >&2
      kill "$analyze_pid" 2>/dev/null || true
      wait "$analyze_pid" 2>/dev/null || true
      if [ -n "$heartbeat_pid" ]; then
        kill "$heartbeat_pid" 2>/dev/null || true
        wait "$heartbeat_pid" 2>/dev/null || true
      fi
      echo 124 >"$status_file"
      ANALYZER_PLUGIN_MACHINE_OUTPUT="$out_file"
      export ANALYZER_PLUGIN_MACHINE_OUTPUT
      return 124
    fi
    sleep 1
    waited=$((waited + 1))
  done

  wait "$analyze_pid" 2>/dev/null || true
  if [ -n "$heartbeat_pid" ]; then
    kill "$heartbeat_pid" 2>/dev/null || true
    wait "$heartbeat_pid" 2>/dev/null || true
  fi
  set -e

  local analyze_status=0
  if [ -f "$status_file" ]; then
    analyze_status="$(cat "$status_file")"
  fi

  ANALYZER_PLUGIN_MACHINE_OUTPUT="$out_file"
  export ANALYZER_PLUGIN_MACHINE_OUTPUT

  local analyze_output
  analyze_output="$(cat "$out_file")"
  if analyzer_plugin_is_crash_output "$analyze_output"; then
    printf '%s\n' "$analyze_output" | grep -Ei \
      'Bad state: The analysis server crashed|analysis server crashed|Analysis server exited unexpectedly|analysis server has terminated' \
      | head -5 >&2 || true
    echo "❌ $label failed: analysis server crashed (scope: $scope)." >&2
    return 1
  fi

  return "$analyze_status"
}
