#!/usr/bin/env bash
# Trigger a manual deploy for the Render FastAPI chat demo web service.
#
# Requires RENDER_API_KEY in the environment (e.g. direnv / .envrc — never commit keys).
# Optional: RENDER_SERVICE_ID — if unset, resolves by RENDER_SERVICE_NAME (default below).
#
# Usage:
#   ./tool/trigger_render_chat_api_deploy.sh
#   ./tool/trigger_render_chat_api_deploy.sh --clear-cache
#   RENDER_SERVICE_NAME=my-api ./tool/trigger_render_chat_api_deploy.sh

set -euo pipefail

RENDER_API_BASE="${RENDER_API_BASE:-https://api.render.com/v1}"
RENDER_SERVICE_NAME="${RENDER_SERVICE_NAME:-flutter-bloc-render-chat-api}"
CLEAR_CACHE="${CLEAR_CACHE:-do_not_clear}"

usage() {
  cat <<'EOF'
Trigger a manual deploy for the Render FastAPI chat demo (POST .../services/{id}/deploys).

Environment:
  RENDER_API_KEY        Required. From direnv / .envrc — never commit.
  RENDER_SERVICE_ID     Optional. If unset, looks up RENDER_SERVICE_NAME in GET /v1/services.
  RENDER_SERVICE_NAME   Optional. Default: flutter-bloc-render-chat-api
  RENDER_API_BASE       Optional. Default: https://api.render.com/v1

Usage:
  ./tool/trigger_render_chat_api_deploy.sh
  ./tool/trigger_render_chat_api_deploy.sh --clear-cache

Options:
  --clear-cache   Request clearCache=clear (clean build cache on Render)
  -h, --help      Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --clear-cache)
      CLEAR_CACHE="clear"
      shift
      ;;
    -h | --help)
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

if [ -z "${RENDER_API_KEY:-}" ]; then
  echo "error: RENDER_API_KEY is not set (export it or use direnv before running)." >&2
  exit 1
fi

resolve_service_id() {
  local list_json
  list_json="$(
    curl -sS -f \
      -H "Authorization: Bearer ${RENDER_API_KEY}" \
      -H "Accept: application/json" \
      "${RENDER_API_BASE}/services?limit=100"
  )"
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "${tmp}"' RETURN
  printf '%s' "${list_json}" >"${tmp}"
  RENDER_SERVICE_ID="$(
    python3 - "${RENDER_SERVICE_NAME}" "${tmp}" <<'PY'
import json, sys

name, path = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as handle:
    data = json.load(handle)
if not isinstance(data, list):
    print("error: unexpected services list shape", file=sys.stderr)
    sys.exit(1)
for item in data:
    svc = item.get("service")
    if isinstance(svc, dict) and svc.get("name") == name:
        print(svc["id"])
        sys.exit(0)
print(f"error: no service named {name!r} in first page of services", file=sys.stderr)
sys.exit(1)
PY
  )"
}

if [ -z "${RENDER_SERVICE_ID:-}" ]; then
  resolve_service_id
fi

post_body="$(
  CLEAR_CACHE="${CLEAR_CACHE}" python3 -c "import json, os; print(json.dumps({'clearCache': os.environ['CLEAR_CACHE']}))"
)"

resp="$(
  curl -sS -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: Bearer ${RENDER_API_KEY}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "${RENDER_API_BASE}/services/${RENDER_SERVICE_ID}/deploys" \
    -d "${post_body}"
)"
http_code="$(printf '%s' "${resp}" | tail -n1)"
json_body="$(printf '%s' "${resp}" | sed '$d')"

if [ "${http_code}" != "201" ] && [ "${http_code}" != "202" ]; then
  echo "error: deploy request failed (HTTP ${http_code})" >&2
  printf '%s\n' "${json_body}" >&2
  exit 1
fi

printf '%s\n' "${json_body}" | python3 -c "
import json, sys
d = json.load(sys.stdin)
did = d.get('id', '')
status = d.get('status', '')
print(f'deploy_id={did}')
print(f'status={status}')
"
printf 'service_id=%s\n' "${RENDER_SERVICE_ID}"
printf 'dashboard=https://dashboard.render.com/web/%s\n' "${RENDER_SERVICE_ID}"
