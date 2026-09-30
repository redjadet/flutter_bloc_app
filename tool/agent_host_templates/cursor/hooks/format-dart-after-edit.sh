#!/usr/bin/env bash
# afterFileEdit: format a single edited .dart file with dart format (fail-open).
set -euo pipefail

input="$(cat)"
file_path="$(
  printf '%s' "$input" | python3 -c '
import json,sys
try:
  d=json.load(sys.stdin)
except Exception:
  sys.exit(0)
path=d.get("file_path") or d.get("path") or d.get("filePath") or ""
# Cursor may nest under edited_file / file
if not path and isinstance(d.get("edited_file"), dict):
  path=d["edited_file"].get("path") or ""
if not path and isinstance(d.get("file"), dict):
  path=d["file"].get("path") or ""
print(path)
' 2>/dev/null || true
)"

if [[ -z "${file_path}" || "${file_path}" != *.dart ]]; then
  exit 0
fi

# Skip generated / vendor noise
case "${file_path}" in
  *.g.dart|*.freezed.dart|*.mocks.dart|*_test.mocks.dart|*/.dart_tool/*|*/build/*|*/third_party/*|*/tool/fixtures/*)
    exit 0
    ;;
esac

if [[ ! -f "${file_path}" ]]; then
  exit 0
fi

# Prefer repo Flutter SDK dart when available
DART_BIN="${DART_BIN:-}"
if [[ -z "${DART_BIN}" ]]; then
  if command -v dart >/dev/null 2>&1; then
    DART_BIN="$(command -v dart)"
  elif [[ -x "${HOME}/Flutter_SDK/flutter/bin/dart" ]]; then
    DART_BIN="${HOME}/Flutter_SDK/flutter/bin/dart"
  else
    exit 0
  fi
fi

"${DART_BIN}" format --output=write --fix-exit-if-changed "${file_path}" >/dev/null 2>&1 || \
  "${DART_BIN}" format --output=write "${file_path}" >/dev/null 2>&1 || true

# Fail-open: never block the edit
exit 0
