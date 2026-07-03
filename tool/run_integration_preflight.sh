#!/usr/bin/env bash
# Runs fast integration guardrails before the full device suite.
#
# Usage:
#   tool/run_integration_preflight.sh
#
# Optional env:
#   INTEGRATION_PREFLIGHT_WEB_DEVICE (default chrome; empty disables web smoke)

set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
WORKSPACE_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
# shellcheck disable=SC1091
source "$WORKSPACE_ROOT/tool/workspace_paths.sh"

# shellcheck disable=SC1091
source "$WORKSPACE_ROOT/tool/resolve_flutter_dart.sh"

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2
}

if ! FLUTTER_BIN="$(resolve_flutter_sdk_flutter)"; then
  echo "❌ Unable to resolve Flutter SDK binary for integration preflight." >&2
  exit 1
fi

PATCH_SCRIPT="$WORKSPACE_ROOT/tool/patch_ios_generated_plugin_swiftpm_platform.sh"
WEB_DEVICE_REQUESTED="${INTEGRATION_PREFLIGHT_WEB_DEVICE:-chrome}"

log "Syntax-checking SwiftPM patch script..."
bash -n "$PATCH_SCRIPT"

log "Validating generated SwiftPM platform declaration..."
patch_output="$(
  bash "$PATCH_SCRIPT" 2>&1
)"
if [ -n "$patch_output" ]; then
  printf '%s\n' "$patch_output"
fi
case "$patch_output" in
  *"warn|FlutterGeneratedPluginSwiftPackage|unexpected-platform-declaration"*)
    echo "❌ Integration preflight detected an unexpected iOS platform declaration in generated SwiftPM metadata." >&2
    exit 1
    ;;
esac

log "Running integration log-filter regression test..."
(cd "$APP_ROOT" && "$FLUTTER_BIN" test \
  --no-pub \
  test/integration_preflight/test_harness_log_filtering_test.dart)

if [ -z "$WEB_DEVICE_REQUESTED" ]; then
  log "Skipping web bootstrap smoke test because INTEGRATION_PREFLIGHT_WEB_DEVICE is empty."
  exit 0
fi

web_devices_json="$("$FLUTTER_BIN" devices --machine 2>/dev/null || true)"
web_device_id="$(
  WEB_DEVICES_JSON="$web_devices_json" /usr/bin/python3 - "$WEB_DEVICE_REQUESTED" <<'PY'
import json
import os
import sys

requested = sys.argv[1].strip().lower()
raw = os.environ.get("WEB_DEVICES_JSON", "").strip()

if not requested:
    sys.exit(1)

try:
    devices = json.loads(raw or "[]")
except json.JSONDecodeError:
    sys.exit(1)

for device in devices:
    device_id = str(device.get("id", "")).strip()
    name = str(device.get("name", "")).strip().lower()
    if device_id.lower() == requested or name == requested or name.startswith(requested):
        print(device_id)
        sys.exit(0)

sys.exit(1)
PY
)" || true

if [ -z "$web_device_id" ]; then
  log "Skipping web bootstrap smoke test; requested web device '$WEB_DEVICE_REQUESTED' is unavailable."
  exit 0
fi

log "Running web bootstrap smoke test on $web_device_id..."
(cd "$APP_ROOT" && "$FLUTTER_BIN" test \
  --no-pub \
  -d "$web_device_id" \
  test/integration_preflight/web_bootstrap_smoke_test.dart)
