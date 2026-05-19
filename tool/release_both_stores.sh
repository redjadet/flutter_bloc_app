#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -x "./tool/fastlane.sh" ]; then
  echo "Missing ./tool/fastlane.sh (repo fastlane wrapper)."
  exit 1
fi

load_env_file() {
  local file="$1"
  if [ -f "$file" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$file"
    set +a
    echo "Loaded ${file}"
  fi
}

load_env_file ".env.ios.release"
load_env_file ".env.android.release"

if [ -z "${JAVA_HOME:-}" ] && [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
fi

ACTION="${1:-deploy}"
shift || true

case "$ACTION" in
  preflight)
    ./tool/fastlane.sh deploy_all_preflight "$@"
    ;;
  deploy)
    ./tool/fastlane.sh deploy_all "$@"
    ;;
  ios)
    ./tool/fastlane.sh ios "${1:-upload_testflight}" "${@:2}"
    ;;
  android)
    ./tool/fastlane.sh android "${1:-play_upload_internal}" "${@:2}"
    ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Valid actions:"
    echo "  preflight  — validate iOS + Android release env"
    echo "  deploy     — iOS TestFlight upload, then Play internal (default)"
    echo "  ios [lane] — run a single iOS lane (default: upload_testflight)"
    echo "  android [lane] — run a single Android lane (default: play_upload_internal)"
    echo ""
    echo "Examples:"
    echo "  ./tool/release_both_stores.sh preflight"
    echo "  ./tool/release_both_stores.sh deploy"
    echo "  ./tool/release_both_stores.sh ios upload_appstore"
    echo "  ./tool/release_both_stores.sh android play_upload_track track:alpha"
    exit 1
    ;;
esac
