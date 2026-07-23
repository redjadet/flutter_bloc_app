#!/usr/bin/env bash
# Ensure a local Android AVD is sized for integration tests (medium-phone viewport).
#
# Default stock "small phone" AVDs (720x1280@320 → ~360x640 logical) clip overflow
# menus and FirebaseUI footers, which fails integration taps. This script patches
# an existing AVD's config.ini to a medium-phone-like panel and can boot it.
#
# Usage:
#   tool/ensure_android_integration_avd.sh              # size + print status
#   tool/ensure_android_integration_avd.sh --launch     # size, boot, wait for adb
#   tool/ensure_android_integration_avd.sh --avd NAME
#   ANDROID_INTEGRATION_AVD=Small_Phone_3 tool/ensure_android_integration_avd.sh --launch
#
# Preferred panel (logical ~411x914 at 420dpi):
#   hw.lcd.width=1080 hw.lcd.height=2400 hw.lcd.density=420 hw.ramSize=2048
#
# Notes:
#   - Does not download system images (avdmanager/sdkmanager XML skew can block
#     create). Uses an already-registered AVD under ~/.android/avd/.
#   - AVD config lives outside the repo; re-run after cloning on a new machine.
#   - Owner: docs/engineering/integration_runner_contract.md § Android AVD

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/workspace_paths.sh" 2>/dev/null || true

AVD_NAME="${ANDROID_INTEGRATION_AVD:-Small_Phone_3}"
DO_LAUNCH=0
LCD_WIDTH="${ANDROID_INTEGRATION_LCD_WIDTH:-1080}"
LCD_HEIGHT="${ANDROID_INTEGRATION_LCD_HEIGHT:-2400}"
LCD_DENSITY="${ANDROID_INTEGRATION_LCD_DENSITY:-420}"
RAM_MB="${ANDROID_INTEGRATION_RAM_MB:-2048}"
BOOT_TIMEOUT_SECONDS="${ANDROID_INTEGRATION_BOOT_TIMEOUT_SECONDS:-180}"

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --launch)
      DO_LAUNCH=1
      shift
      ;;
    --avd)
      AVD_NAME="$2"
      shift 2
      ;;
    -h|--help)
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

ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
export ANDROID_HOME
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

AVD_ROOT="${ANDROID_AVD_HOME:-$HOME/.android/avd}"
INI_PATH="$AVD_ROOT/${AVD_NAME}.ini"
CONFIG_PATH="$AVD_ROOT/${AVD_NAME}.avd/config.ini"

if [ ! -f "$CONFIG_PATH" ]; then
  echo "❌ AVD config not found: $CONFIG_PATH" >&2
  echo "   Create an AVD in Android Studio (or flutter emulators --create), then re-run." >&2
  echo "   Available:" >&2
  ls -1 "$AVD_ROOT"/*.ini 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.ini$//' | sed 's/^/     - /' || true
  exit 1
fi

set_ini_kv() {
  local key="$1"
  local value="$2"
  local file="$3"
  if grep -q "^${key}=" "$file"; then
    # macOS/BSD sed; GNU sed also accepts this form for simple substitutions
    sed -i.bak "s|^${key}=.*|${key}=${value}|" "$file"
    rm -f "${file}.bak"
  else
    printf '%s=%s\n' "$key" "$value" >>"$file"
  fi
}

echo "ensure-android-avd|avd|$AVD_NAME"
echo "ensure-android-avd|config|$CONFIG_PATH"
set_ini_kv "hw.lcd.width" "$LCD_WIDTH" "$CONFIG_PATH"
set_ini_kv "hw.lcd.height" "$LCD_HEIGHT" "$CONFIG_PATH"
set_ini_kv "hw.lcd.density" "$LCD_DENSITY" "$CONFIG_PATH"
set_ini_kv "hw.ramSize" "$RAM_MB" "$CONFIG_PATH"
echo "ensure-android-avd|panel|${LCD_WIDTH}x${LCD_HEIGHT}@${LCD_DENSITY}|ram=${RAM_MB}MB"

if [ ! -f "$INI_PATH" ]; then
  # Some AVDs have a folder but missing top-level .ini (not listed by flutter).
  cat >"$INI_PATH" <<EOF
avd.ini.encoding=UTF-8
path=$AVD_ROOT/${AVD_NAME}.avd
path.rel=avd/${AVD_NAME}.avd
target=android-36
EOF
  echo "ensure-android-avd|ini|created|$INI_PATH"
fi

if [ "$DO_LAUNCH" -ne 1 ]; then
  if adb devices 2>/dev/null | grep -qE 'emulator-[0-9]+\s+device'; then
    DEV="$(adb devices | awk '/^emulator-/{print $1; exit}')"
    echo "ensure-android-avd|device|$DEV"
    echo "ensure-android-avd|hint|CHECKLIST_INTEGRATION_DEVICE=$DEV ./bin/integration_tests"
  else
    echo "ensure-android-avd|device|none"
    echo "ensure-android-avd|hint|Re-run with --launch, then CHECKLIST_INTEGRATION_DEVICE=emulator-5554 ./bin/integration_tests"
  fi
  exit 0
fi

if ! command -v emulator >/dev/null 2>&1; then
  echo "❌ emulator binary not on PATH (ANDROID_HOME=$ANDROID_HOME)" >&2
  exit 1
fi

if adb devices 2>/dev/null | grep -qE 'emulator-[0-9]+\s+device'; then
  DEV="$(adb devices | awk '/^emulator-/{print $1; exit}')"
  echo "ensure-android-avd|already-booted|$DEV"
else
  echo "ensure-android-avd|launch|$AVD_NAME"
  # Keep emulator in background; caller owns lifecycle.
  nohup emulator -avd "$AVD_NAME" -no-snapshot-load -no-snapshot-save -no-boot-anim -gpu auto \
    >"${TMPDIR:-/tmp}/android_integration_avd_${AVD_NAME}.log" 2>&1 &
  echo "ensure-android-avd|emulator-pid|$!"
fi

deadline=$((SECONDS + BOOT_TIMEOUT_SECONDS))
DEV=""
while [ "$SECONDS" -lt "$deadline" ]; do
  if adb devices 2>/dev/null | grep -qE 'emulator-[0-9]+\s+device'; then
    DEV="$(adb devices | awk '/^emulator-/{print $1; exit}')"
    boot="$(adb -s "$DEV" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [ "$boot" = "1" ]; then
      adb -s "$DEV" shell wm size >/dev/null 2>&1 || true
      echo "ensure-android-avd|ready|$DEV"
      echo "ensure-android-avd|wm-size|$(adb -s "$DEV" shell wm size 2>/dev/null | tr -d '\r')"
      echo "ensure-android-avd|hint|CHECKLIST_INTEGRATION_DEVICE=$DEV ./bin/integration_tests"
      exit 0
    fi
  fi
  sleep 3
done

echo "❌ Timed out waiting for AVD '$AVD_NAME' boot (${BOOT_TIMEOUT_SECONDS}s)" >&2
tail -40 "${TMPDIR:-/tmp}/android_integration_avd_${AVD_NAME}.log" 2>/dev/null || true
exit 1
