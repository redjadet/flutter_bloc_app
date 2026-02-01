#!/usr/bin/env bash
# Upload an iOS IPA to Firebase App Distribution.
# Usage: ./tool/upload_ios_to_firebase_app_distribution.sh [path/to/app.ipa] [release-notes] [groups]
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IOS_APP_ID="${FIREBASE_IOS_APP_ID:-1:473097776453:ios:6962f6ddc4d7ea12bd222c}"

IPA_PATH="$1"
RELEASE_NOTES="${2:-Release uploaded $(date +%Y-%m-%d)}"
GROUPS="${3:-}"

if [[ -z "$IPA_PATH" ]]; then
  IPA_PATH=$(find "$PROJECT_ROOT/build/ios" -name "*.ipa" 2>/dev/null | head -1)
fi

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
  echo "No IPA found. Build one first:"
  echo "  ./tool/ios_entitlements.sh distribution   # requires paid Apple Developer account"
  echo "  flutter build ipa"
  echo "Or pass the path: $0 path/to/app.ipa \"Release notes\" [groups]"
  exit 1
fi

CMD=(firebase appdistribution:distribute "$IPA_PATH" --app "$IOS_APP_ID" --release-notes "$RELEASE_NOTES")
if [[ -n "$GROUPS" ]]; then
  CMD+=(--groups "$GROUPS")
fi

echo "Uploading $IPA_PATH to Firebase App Distribution (iOS App: $IOS_APP_ID)..."
"${CMD[@]}"
echo "Done. Check Firebase Console -> App Distribution for the release."
