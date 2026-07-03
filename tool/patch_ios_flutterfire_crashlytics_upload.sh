#!/usr/bin/env bash
set -euo pipefail

# Idempotent guards for FlutterFire Crashlytics symbol upload:
# - SPM checkout path may be missing on local Debug simulator builds
# - flutterfire upload can fail locally without blocking app/test builds

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$project_root/workspace_paths.sh"

python3 - "$APP_ROOT" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
markers = {
    "missing_script": "Crashlytics upload script not found; skipping symbol upload.",
    "debug_sim": "Skipping Crashlytics symbol upload for Debug/simulator builds.",
    "upload_failed": "Crashlytics symbol upload failed; continuing build.",
}
flutterfire_line = "# Command to upload symbols script used to upload symbols to Firebase server"


def patch_pbxproj(path: Path) -> bool:
    if not path.is_file():
        return False

    text = path.read_text()
    original = text
    patched = False

    if markers["missing_script"] not in text:
        needle = (
            'PATH_TO_CRASHLYTICS_UPLOAD_SCRIPT=\\"$PODS_ROOT/FirebaseCrashlytics/run\\"\\nfi\\n\\n'
            f"{flutterfire_line}\\nflutterfire upload-crashlytics-symbols"
        )
        insert = (
            'PATH_TO_CRASHLYTICS_UPLOAD_SCRIPT=\\"$PODS_ROOT/FirebaseCrashlytics/run\\"\\nfi\\n\\n'
            'if [ ! -f \\"$PATH_TO_CRASHLYTICS_UPLOAD_SCRIPT\\" ]; then\\n'
            f'  echo \\"warning: {markers["missing_script"]}\\"\\n'
            "  exit 0\\n"
            "fi\\n\\n"
            f"{flutterfire_line}\\nflutterfire upload-crashlytics-symbols"
        )
        if needle in text:
            text = text.replace(needle, insert, 1)
            patched = True

    if markers["debug_sim"] not in text:
        needle = f"{flutterfire_line}\\nflutterfire upload-crashlytics-symbols"
        insert = (
            f"{flutterfire_line}\\n"
            'if echo \\"${CONFIGURATION} ${PLATFORM_NAME}\\" | grep -qiE \'debug|simulator\'; then\\n'
            f'  echo \\"warning: {markers["debug_sim"]}\\"\\n'
            "  exit 0\\n"
            "fi\\n\\n"
            "flutterfire upload-crashlytics-symbols"
        )
        if needle in text:
            text = text.replace(needle, insert, 1)
            patched = True

    if markers["upload_failed"] not in text:
        needle = '--default-config=default\\n";'
        replacement = (
            '--default-config=default\\n || {\\n'
            f'  echo \\"warning: {markers["upload_failed"]}\\"\\n'
            "  exit 0\\n"
            '}\\n";'
        )
        if needle in text and "flutterfire upload-crashlytics-symbols" in text:
            text = text.replace(needle, replacement, 1)
            patched = True

    if patched and text != original:
        path.write_text(text)
        print(f"patched|FlutterFireCrashlyticsUpload|{path.parent.name}")
        return True
    return False


for rel in (
    "ios/Runner.xcodeproj/project.pbxproj",
    "macos/Runner.xcodeproj/project.pbxproj",
):
    patch_pbxproj(root / rel)
PY
