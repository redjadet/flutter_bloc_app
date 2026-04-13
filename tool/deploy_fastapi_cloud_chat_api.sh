#!/usr/bin/env bash
# Deploy the FastAPI chat demo (demos/render_chat_api) to FastAPI Cloud.
#
# Requires:
# - A previously linked FastAPI Cloud app (demos/render_chat_api/.fastapicloud/cloud.json)
#
# Usage:
#   ./tool/deploy_fastapi_cloud_chat_api.sh
#   ./tool/deploy_fastapi_cloud_chat_api.sh --app-id <uuid>
#
# Notes:
# - This uses a local venv under demos/render_chat_api/.venv (created if missing).
# - The FastAPI Cloud deployment reflects the checked-out git state you deploy from.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_DIR="${REPO_ROOT}/demos/render_chat_api"
CLOUD_JSON="${DEMO_DIR}/.fastapicloud/cloud.json"

usage() {
  cat <<'EOF'
Deploy the FastAPI chat demo to FastAPI Cloud.

Usage:
  ./tool/deploy_fastapi_cloud_chat_api.sh
  ./tool/deploy_fastapi_cloud_chat_api.sh --app-id <uuid>

Options:
  --app-id <uuid>  Override app_id from demos/render_chat_api/.fastapicloud/cloud.json
  -h, --help       Show this help
EOF
}

APP_ID_OVERRIDE=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --app-id)
      APP_ID_OVERRIDE="${2:-}"
      if [ -z "${APP_ID_OVERRIDE}" ]; then
        echo "error: --app-id requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ ! -f "${CLOUD_JSON}" ] && [ -z "${APP_ID_OVERRIDE}" ]; then
  echo "error: ${CLOUD_JSON} not found." >&2
  echo "Run an interactive 'fastapi deploy' once to link an app, or pass --app-id." >&2
  exit 1
fi

APP_ID="$(
  APP_ID_OVERRIDE="${APP_ID_OVERRIDE}" CLOUD_JSON="${CLOUD_JSON}" python3 - <<'PY'
import json, os, sys

override = os.environ.get("APP_ID_OVERRIDE", "").strip()
if override:
    print(override)
    sys.exit(0)

path = os.environ["CLOUD_JSON"]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
app_id = (data.get("app_id") or "").strip()
if not app_id:
    print(f"error: app_id missing in {path}", file=sys.stderr)
    sys.exit(1)
print(app_id)
PY
)"

cd "${DEMO_DIR}"

if [ ! -x ".venv/bin/python" ]; then
  python3 -m venv .venv
fi

.venv/bin/pip install -q -r requirements.txt

# FastAPI Cloud CLI transitively depends on rich-toolkit; newer versions have
# broken compatibility with some FastAPI Cloud CLI builds.
.venv/bin/pip install -q "rich-toolkit==0.18.1"

echo "Deploying demos/render_chat_api to FastAPI Cloud (app_id=${APP_ID})"
.venv/bin/fastapi deploy --app-id "${APP_ID}"
