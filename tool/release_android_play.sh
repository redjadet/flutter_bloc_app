#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v fastlane >/dev/null 2>&1; then
  echo "fastlane is not installed. Install with: gem install fastlane"
  exit 1
fi

if [ ! -f ".env.android.release" ]; then
  echo "Missing .env.android.release. Create it from .env.android.release.example"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source ".env.android.release"
set +a

require_env() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "Missing required env var in .env.android.release: ${name}"
    exit 1
  fi
}

require_env "ANDROID_PACKAGE_NAME"
require_env "ANDROID_JSON_KEY"
require_env "SUPABASE_URL"
require_env "SUPABASE_ANON_KEY"
require_env "HUGGINGFACE_API_KEY"

# Maps key must be present during release build so manifest placeholders do not
# fall back to the demo value.
if [ -z "${GOOGLE_MAPS_ANDROID_API_KEY:-}" ] && [ -z "${GOOGLE_MAPS_API_KEY:-}" ]; then
  echo "Missing GOOGLE_MAPS_ANDROID_API_KEY (or GOOGLE_MAPS_API_KEY) in .env.android.release"
  exit 1
fi

if [ -z "${JAVA_HOME:-}" ] && [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
fi

ACTION="${1:-upload_internal}"
shift || true

case "$ACTION" in
  preflight)
    fastlane android preflight "$@"
    ;;
  build_release)
    fastlane android build_release "$@"
    ;;
  metadata_sync)
    fastlane android metadata_sync "$@"
    ;;
  upload_internal)
    fastlane android upload_internal "$@"
    ;;
  upload_track)
    fastlane android upload_track "$@"
    ;;
  promote_track)
    fastlane android promote_track "$@"
    ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Valid actions: preflight | build_release | metadata_sync | upload_internal | upload_track | promote_track"
    exit 1
    ;;
esac
