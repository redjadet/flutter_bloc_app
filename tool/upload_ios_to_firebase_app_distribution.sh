#!/usr/bin/env bash
# Upload an iOS IPA to Firebase App Distribution.
# Docs: docs/firebase_app_distribution.md#ios-upload-script
# Usage: ./tool/upload_ios_to_firebase_app_distribution.sh [ipa] [release-notes] [groups-or-emails]
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IOS_APP_ID="${FIREBASE_IOS_APP_ID:-1:473097776453:ios:6962f6ddc4d7ea12bd222c}"

IPA_PATH="$1"
RELEASE_NOTES="${2:-Release uploaded $(date +%Y-%m-%d)}"
# Third arg: group alias(es) or comma-separated tester emails (emails → --testers).
# You may instead set FIREBASE_GROUPS / FIREBASE_TESTERS in the environment.
RECIPIENT_ARG="${3:-}"
GROUPS_VALUE="${FIREBASE_GROUPS:-}"
TESTERS_VALUE="${FIREBASE_TESTERS:-}"
if [[ -n "$RECIPIENT_ARG" ]]; then
  if [[ "$RECIPIENT_ARG" == *"@"* ]]; then
    TESTERS_VALUE="$RECIPIENT_ARG"
  else
    GROUPS_VALUE="$RECIPIENT_ARG"
  fi
fi

bash "$PROJECT_ROOT/tool/firebase_preflight.sh" --require-cli --app-id "$IOS_APP_ID"

if [[ -z "$IPA_PATH" ]]; then
  IPA_PATH=$(find "$PROJECT_ROOT/build/ios" -name "*.ipa" 2>/dev/null | head -1)
fi

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
  echo "No IPA found. Build one first:"
  echo "  ./tool/ios_entitlements.sh distribution   # requires paid Apple Developer account"
  echo "  flutter build ipa"
  echo "Or pass the path: $0 path/to/app.ipa \"Release notes\" [groups-or-tester-emails]"
  exit 1
fi

if [[ -z "${GROUPS_VALUE// /}" && -z "${TESTERS_VALUE// /}" ]]; then
  echo "Set recipients: pass group alias(es) or tester emails as arg 3, or set FIREBASE_GROUPS / FIREBASE_TESTERS." >&2
  exit 1
fi

CMD=(firebase appdistribution:distribute "$IPA_PATH" --app "$IOS_APP_ID" --release-notes "$RELEASE_NOTES")
if [[ -n "${GROUPS_VALUE// /}" ]]; then
  CMD+=(--groups "$GROUPS_VALUE")
fi
if [[ -n "${TESTERS_VALUE// /}" ]]; then
  CMD+=(--testers "$TESTERS_VALUE")
fi

echo "Uploading $IPA_PATH to Firebase App Distribution (iOS App: $IOS_APP_ID)..."
"${CMD[@]}"
echo "Done. Check Firebase Console -> App Distribution for the release."
