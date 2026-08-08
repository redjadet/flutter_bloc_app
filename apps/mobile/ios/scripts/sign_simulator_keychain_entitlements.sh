#!/bin/bash
# Ensure simulator CodeSign uses an empty entitlements plist.
#
# Xcode sets ENTITLEMENTS_ALLOWED=NO for iphonesimulator. Injecting
# keychain-access-groups (or other restricted entitlements) into the simulator
# .xcent causes SBMainWorkspace launch denial (FBSOpenApplicationServiceErrorDomain).
# An ad-hoc-signed Runner with empty entitlements still gets Keychain access for
# Firebase Auth; Keychain Sharing is device/macOS-only for this app.
set -euo pipefail

if [ "${PLATFORM_NAME:-}" != "iphonesimulator" ]; then
  exit 0
fi

if [ -z "${TARGET_TEMP_DIR:-}" ] || [ -z "${FULL_PRODUCT_NAME:-}" ]; then
  echo "warning: TARGET_TEMP_DIR/FULL_PRODUCT_NAME unset; skip simulator xcent clear"
  exit 0
fi

XCENT_PATH="${TARGET_TEMP_DIR}/${FULL_PRODUCT_NAME}.xcent"
mkdir -p "${TARGET_TEMP_DIR}"

cat > "${XCENT_PATH}" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
EOF
rm -f "${XCENT_PATH}.der"

echo "Cleared simulator entitlements at ${XCENT_PATH} (empty xcent; Keychain Sharing not applied on simulator)"
