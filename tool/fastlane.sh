#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v bundle >/dev/null 2>&1; then
  echo "bundler (bundle) not found on PATH"
  echo "Install bundler 2.7.1 with: gem install bundler -v 2.7.1 --user-install"
  exit 1
fi

# Ensure we're in the repo root (Fastlane reads Gemfile/Fastfile from here).
if [ ! -f "Gemfile" ] || [ ! -f "fastlane/Fastfile" ]; then
  echo "Run from the repo root (Gemfile + fastlane/Fastfile required)."
  exit 1
fi

# This repo's Gemfile.lock expects Bundler 2.7.1. Using an explicit version avoids
# local shim drift (e.g. missing bundler 4.x errors).
BUNDLER_VERSION="2.7.1"

exec bundle "_${BUNDLER_VERSION}_" exec fastlane "$@"

