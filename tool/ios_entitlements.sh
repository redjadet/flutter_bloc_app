#!/usr/bin/env bash
# Switch iOS entitlements between development (personal Apple ID) and distribution
# (Ad Hoc / App Store). Personal dev accounts do not support Associated Domains;
# distribution builds require it for universal links.
#
# Usage:
#   ./tool/ios_entitlements.sh development   # For local runs on your device
#   ./tool/ios_entitlements.sh distribution  # Before Ad Hoc or App Store builds
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENTITLEMENTS_DIR="$PROJECT_ROOT/ios/Runner"
ENTITLEMENTS="$ENTITLEMENTS_DIR/Runner.entitlements"
DEV_ENTITLEMENTS="$ENTITLEMENTS_DIR/Runner.entitlements.development"
DIST_ENTITLEMENTS="$ENTITLEMENTS_DIR/Runner.entitlements.distribution"

usage() {
  echo "Usage: $0 {development|distribution}" >&2
  echo "" >&2
  echo "  development   Use minimal entitlements (no Associated Domains)." >&2
  echo "                Use for local runs with a personal Apple ID." >&2
  echo "  distribution  Use full entitlements (with Associated Domains)." >&2
  echo "                Use before Ad Hoc or App Store distribution." >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

MODE="$1"
case "$MODE" in
  development)
    SOURCE="$DEV_ENTITLEMENTS"
    ;;
  distribution)
    SOURCE="$DIST_ENTITLEMENTS"
    ;;
  *)
    usage
    ;;
esac

if [[ ! -f "$SOURCE" ]]; then
  echo "Error: Entitlements template not found: $SOURCE" >&2
  exit 1
fi

cp "$SOURCE" "$ENTITLEMENTS"
echo "Switched to $MODE entitlements (Runner.entitlements updated from $(basename "$SOURCE"))."
