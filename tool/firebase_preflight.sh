#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

require_cli=0
declare -a app_ids=()

usage() {
  cat <<'EOF'
firebase_preflight.sh

Checks that the active Firebase CLI project matches this checkout's expected project.

Reads expected project ID from `.firebaserc` (projects.default). Compares against
`firebase use --json` active project.

Usage:
  ./tool/firebase_preflight.sh [--require-cli] [--app-id <firebase-app-id>]...

Exit codes:
  0 OK
  2 mismatch
  3 missing/invalid repo config
  4 firebase CLI missing or cannot report active project (when --require-cli)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --require-cli)
      require_cli=1
      shift
      ;;
    --app-id)
      if [[ $# -lt 2 || -z "${2:-}" ]]; then
        echo "--app-id requires a value" >&2
        usage >&2
        exit 3
      fi
      app_ids+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 3
      ;;
  esac
done

firebaserc_path="$PROJECT_ROOT/.firebaserc"
if [[ ! -f "$firebaserc_path" ]]; then
  echo "Firebase preflight failed: missing .firebaserc at repo root." >&2
  echo "Fix: restore repo file or re-clone the repository." >&2
  exit 3
fi

expected_project_id="$(
  python3 - <<'PY' "$firebaserc_path"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
projects = data.get("projects") or {}
default = projects.get("default")
if not isinstance(default, str) or not default.strip():
    raise SystemExit(3)
print(default.strip())
PY
)" || {
  echo "Firebase preflight failed: could not read expected project ID from .firebaserc." >&2
  exit 3
}

if ! command -v firebase >/dev/null 2>&1; then
  if [[ "$require_cli" -eq 1 ]]; then
    echo "Firebase preflight failed: firebase CLI not found on PATH." >&2
    echo "Fix: install Firebase CLI, then login and select the repo project:" >&2
    echo "  firebase login" >&2
    echo "  firebase use \"$expected_project_id\"" >&2
    exit 4
  fi
  echo "Firebase preflight: firebase CLI not found; expected_project_id=$expected_project_id" >&2
  exit 0
fi

active_project_id="$(
  firebase use --json 2>/dev/null | python3 - <<'PY'
import json
import sys

raw = sys.stdin.read().strip()
if not raw:
    raise SystemExit(4)
data = json.loads(raw)
result = data.get("result") or {}
active = result.get("project") or result.get("activeProject")
if not isinstance(active, str) or not active.strip():
    raise SystemExit(4)
print(active.strip())
PY
)" || {
  if [[ "$require_cli" -eq 1 ]]; then
    echo "Firebase preflight failed: could not determine active Firebase project." >&2
    echo "Fix: login and select the repo project:" >&2
    echo "  firebase login" >&2
    echo "  firebase use \"$expected_project_id\"" >&2
    exit 4
  fi
  echo "Firebase preflight: could not determine active project; expected_project_id=$expected_project_id" >&2
  exit 0
}

if [[ "$active_project_id" != "$expected_project_id" ]]; then
  echo "Firebase preflight failed: active Firebase project mismatch." >&2
  echo "  expected: $expected_project_id (from .firebaserc)" >&2
  echo "  active:    $active_project_id (from firebase use --json)" >&2
  echo "" >&2
  echo "Fix:" >&2
  echo "  firebase use \"$expected_project_id\"" >&2
  echo "  firebase projects:list" >&2
  exit 2
fi

expected_project_number=""
if [[ "${#app_ids[@]}" -gt 0 ]]; then
  expected_project_number="$(
    firebase projects:list --json 2>/dev/null | python3 - <<'PY' "$expected_project_id"
import json
import sys

expected = sys.argv[1]
raw = sys.stdin.read().strip()
if not raw:
    raise SystemExit(4)
data = json.loads(raw)
result = data.get("result") or {}
projects = result.get("projects") or result.get("projectInfo") or []
for entry in projects:
    if not isinstance(entry, dict):
        continue
    pid = entry.get("projectId") or entry.get("project") or entry.get("id")
    if pid == expected:
        number = entry.get("projectNumber") or entry.get("project_number") or entry.get("number")
        if isinstance(number, (str, int)) and str(number).strip():
            print(str(number).strip())
            raise SystemExit(0)
raise SystemExit(4)
PY
  )" || {
    if [[ "$require_cli" -eq 1 ]]; then
      echo "Firebase preflight failed: could not resolve projectNumber for $expected_project_id." >&2
      echo "Fix: confirm access and that the project exists in your account:" >&2
      echo "  firebase login" >&2
      echo "  firebase projects:list" >&2
      exit 4
    fi
    expected_project_number=""
  }

  if [[ -n "$expected_project_number" ]]; then
    expected_prefix="1:${expected_project_number}:"
    for app_id in "${app_ids[@]}"; do
      if [[ "$app_id" != "$expected_prefix"* ]]; then
        echo "Firebase preflight failed: app id does not match expected Firebase project." >&2
        echo "  expected_project_id: $expected_project_id" >&2
        echo "  expected_app_id_prefix: $expected_prefix" >&2
        echo "  provided_app_id: $app_id" >&2
        echo "" >&2
        echo "Fix:" >&2
        echo "  - Use the App ID from Firebase Console -> Project Settings -> General" >&2
        echo "  - Or override env var (for App Distribution scripts), e.g.:" >&2
        echo "      FIREBASE_IOS_APP_ID=\"<correct id>\" ./tool/upload_ios_to_firebase_app_distribution.sh ..." >&2
        exit 2
      fi
    done
  fi
fi

echo "Firebase preflight OK: project=$active_project_id" >&2

