#!/usr/bin/env bash
# Post-deploy / operator smoke: verify the live chat OpenAPI surface.
#
# Confirms OpenAPI exposes W12+ paths: /health, /ready, /v1/chat/completions.
# Retries on cold-start / transient timeouts. Not wired into ./bin/checklist
# (network + deploy drift); run after FastAPI Cloud / Render deploys.
#
# Usage:
#   ./tool/check_render_chat_live_surface.sh
#   ORIGIN=https://flutter-bloc-render-chat-api.onrender.com \
#     ./tool/check_render_chat_live_surface.sh
#
# Offline unit tests: python3 -m unittest tool/check_render_chat_live_surface_test.py

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORIGIN="${ORIGIN:-https://render-chat-api.fastapicloud.dev}"
ORIGIN="${ORIGIN%/}"
OPENAPI_URL="${ORIGIN}/openapi.json"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-6}"
ATTEMPT_TIMEOUT_SECS="${ATTEMPT_TIMEOUT_SECS:-45}"
SLEEP_SECS="${SLEEP_SECS:-5}"

TMP_JSON="$(mktemp)"
cleanup() {
  rm -f "${TMP_JSON}"
}
trap cleanup EXIT

echo "Checking live chat OpenAPI surface at ${OPENAPI_URL}"

attempt=1
http_code="000"
while [ "${attempt}" -le "${MAX_ATTEMPTS}" ]; do
  http_code="$(
    curl -sS -o "${TMP_JSON}" -w "%{http_code}" \
      --max-time "${ATTEMPT_TIMEOUT_SECS}" \
      -L "${OPENAPI_URL}" \
      || true
  )"
  if [ "${http_code}" = "200" ] && [ -s "${TMP_JSON}" ]; then
    break
  fi
  echo "attempt ${attempt}/${MAX_ATTEMPTS}: HTTP ${http_code} (retry in ${SLEEP_SECS}s; cold start possible)"
  if [ "${attempt}" -eq "${MAX_ATTEMPTS}" ]; then
    echo "error: failed to fetch ${OPENAPI_URL} after ${MAX_ATTEMPTS} attempts" >&2
    exit 2
  fi
  sleep "${SLEEP_SECS}"
  attempt=$((attempt + 1))
done

python3 "${REPO_ROOT}/tool/render_chat_live_surface.py" \
  --origin "${ORIGIN}" \
  "${TMP_JSON}"
