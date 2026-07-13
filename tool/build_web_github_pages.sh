#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workspace_paths.sh"
cd "$APP_ROOT"

# Deterministic Flutter web build for GitHub Pages project sites.
#
# Usage:
#   REPO_NAME="<repo>" bash tool/build_web_github_pages.sh
#
# Notes:
# - GitHub Pages project sites are hosted under "/<repo>/".
# - This script forwards compile-time defines from tool/flutter_dart_defines_from_env.sh.

ENTRYPOINT="${ENTRYPOINT:-lib/main_prod.dart}"
REPO_NAME="${REPO_NAME:-}"
BASE_HREF="${BASE_HREF:-}"

fail() {
  echo "Error: $1" >&2
  exit 1
}

if [[ ! -f "$ENTRYPOINT" ]]; then
  fail "ENTRYPOINT '$ENTRYPOINT' does not exist"
fi

if [[ -z "${BASE_HREF// /}" ]]; then
  if [[ -z "${REPO_NAME// /}" ]]; then
    fail "REPO_NAME is required when BASE_HREF is not provided"
  fi
  BASE_HREF="/${REPO_NAME}/"
fi

if [[ ! "$BASE_HREF" =~ ^/[a-zA-Z0-9_.-]+/$ && "$BASE_HREF" != "/" ]]; then
  fail "BASE_HREF must be '/<segment>/' (project site) or '/' (root). Got: '$BASE_HREF'"
fi

if [[ "$REPO_NAME" == *".github.io"* && "$BASE_HREF" != "/" ]]; then
  fail "REPO_NAME looks like a root Pages repo; use BASE_HREF='/' for root hosting"
fi

# shellcheck disable=SC2046
DEFINE_ARGS=( $(bash "$WORKSPACE_ROOT/tool/flutter_dart_defines_from_env.sh") )

# WebAssembly (skwasm with canvaskit fallback) improves first-load and runtime
# performance. Opt out with WEB_WASM=0 if a dependency regresses wasm support.
WEB_WASM="${WEB_WASM:-1}"

CMD=(
  flutter build web
  --release
  -t "$ENTRYPOINT"
  --base-href "$BASE_HREF"
)

if [[ "$WEB_WASM" == "1" || "$WEB_WASM" == "true" ]]; then
  CMD+=(--wasm)
else
  CMD+=(--no-wasm-dry-run)
fi

echo "Running:"
printf '  %q' "${CMD[@]}" "${DEFINE_ARGS[@]}"
echo

${CMD[@]} "${DEFINE_ARGS[@]}"

