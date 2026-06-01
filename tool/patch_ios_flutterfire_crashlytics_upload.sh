#!/usr/bin/env bash
set -euo pipefail

# Idempotent guard for FlutterFire Crashlytics symbol upload when the SPM checkout
# path is not populated yet (common on local Debug simulator builds).

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
marker='Crashlytics upload script not found; skipping symbol upload.'
insert=$'if [ ! -f "$PATH_TO_CRASHLYTICS_UPLOAD_SCRIPT" ]; then\\n  echo "warning: Crashlytics upload script not found; skipping symbol upload."\\n  exit 0\\nfi\\n\\n'

patch_pbxproj() {
  local pbxproj="$1"
  if [[ ! -f "$pbxproj" ]]; then
    return 0
  fi
  if grep -qF "$marker" "$pbxproj"; then
    return 0
  fi
  perl -0777 -i -pe \
    's/(PATH_TO_CRASHLYTICS_UPLOAD_SCRIPT=\\"\$PODS_ROOT\/FirebaseCrashlytics\/run\\"\\nfi\\n\\n)(# Command to upload symbols script used to upload symbols to Firebase server\\nflutterfire upload-crashlytics-symbols)/$1if [ ! -f \\"\\$PATH_TO_CRASHLYTICS_UPLOAD_SCRIPT\\" ]; then\\n  echo \\"warning: Crashlytics upload script not found; skipping symbol upload.\\"\\n  exit 0\\nfi\\n\\n$2/s' \
    "$pbxproj"
  echo "patched|FlutterFireCrashlyticsUpload|$(basename "$(dirname "$pbxproj")")"
}

patch_pbxproj "$project_root/ios/Runner.xcodeproj/project.pbxproj"
patch_pbxproj "$project_root/macos/Runner.xcodeproj/project.pbxproj"
