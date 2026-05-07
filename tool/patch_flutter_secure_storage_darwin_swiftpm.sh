#!/usr/bin/env bash
set -euo pipefail

# Repo-stable workaround: flutter_secure_storage_darwin 0.3.0 ships a SwiftPM
# manifest with iOS 12.0, but its code uses CryptoKit APIs requiring iOS 13+.
# When Flutter builds the generated SwiftPM plugin package, Xcode compiles using
# the manifest's platform mins and fails with:
# - 'SymmetricKey' is only available in iOS 13.0 or newer
# - 'AES' is only available in iOS 13.0 or newer
#
# This script patches the pub cache copy in-place (idempotent).

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

pub_cache="${PUB_CACHE:-$HOME/.pub-cache}"
hosted_dir="$pub_cache/hosted/pub.dev"

if [[ ! -d "$hosted_dir" ]]; then
  exit 0
fi

patched_any=0
shopt -s nullglob
for pkg_dir in "$hosted_dir"/flutter_secure_storage_darwin-*; do
  package_swift="$pkg_dir/darwin/flutter_secure_storage_darwin/Package.swift"
  if [[ ! -f "$package_swift" ]]; then
    continue
  fi

  if grep -qE '\.iOS\("12\.0"\)' "$package_swift"; then
    perl -0777 -i -pe 's/\.iOS\("12\.0"\)/.iOS("13.0")/g' "$package_swift"
    patched_any=1
  fi

  if grep -qE '\.macOS\("10\.14"\)' "$package_swift"; then
    perl -0777 -i -pe 's/\.macOS\("10\.14"\)/.macOS("10.15")/g' "$package_swift"
    patched_any=1
  fi
done
shopt -u nullglob

if [[ "$patched_any" -eq 1 ]]; then
  echo "patched|flutter_secure_storage_darwin|swiftpm_platforms"
fi

