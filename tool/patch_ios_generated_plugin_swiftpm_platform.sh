#!/usr/bin/env bash
set -euo pipefail

# Repo-stable workaround: Flutter's generated iOS SwiftPM plugin package can
# keep an older platform minimum than the app target. Recent Firebase Swift
# packages require iOS 15+, and this repo already targets iOS 16, so align the
# generated package manifest before simulator/device builds.

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_swift="$project_root/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"

if [[ ! -f "$package_swift" ]]; then
  exit 0
fi

if grep -qE '\.iOS\("13\.0"\)' "$package_swift"; then
  perl -0777 -i -pe 's/\.iOS\("13\.0"\)/.iOS("16.0")/g' "$package_swift"
  echo "patched|FlutterGeneratedPluginSwiftPackage|ios16"
elif grep -qE '\.iOS\("(1[6-9]|[2-9][0-9]+)\.[0-9]+"\)' "$package_swift"; then
  :
else
  echo "warn|FlutterGeneratedPluginSwiftPackage|unexpected-platform-declaration" >&2
fi

bash "$(dirname "${BASH_SOURCE[0]}")/patch_ios_flutterfire_crashlytics_upload.sh"
