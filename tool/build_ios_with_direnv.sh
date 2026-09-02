#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Ensure the current process has the same env vars that `direnv` would provide
# for this directory (useful when the script is invoked outside an activated
# direnv shell).
if command -v direnv >/dev/null 2>&1 && [ -f ".envrc" ]; then
  # direnv will fail with a clear message if `.envrc` wasn't allowed yet.
  eval "$(direnv export bash)"
fi

FLAVOR="${FLAVOR:-}"
ENTRYPOINT="${ENTRYPOINT:-lib/main_prod.dart}"
BUILD_MODE="${BUILD_MODE:-release}" # release|profile|debug

args=(flutter build ipa "--${BUILD_MODE}" "--target=${ENTRYPOINT}")
if [ -n "${FLAVOR// /}" ]; then
  args+=("--flavor" "${FLAVOR}")
fi

if [ "$BUILD_MODE" != "debug" ]; then
  # shellcheck disable=SC2207
  dart_defines=( $(./tool/flutter_dart_defines_from_env.sh --release) )
else
  # shellcheck disable=SC2207
  dart_defines=( $(./tool/flutter_dart_defines_from_env.sh) )
fi

if [ "$BUILD_MODE" != "debug" ]; then
  prohibited=(
    HUGGINGFACE_API_KEY
    GEMINI_API_KEY
    GOOGLE_API_KEY
    CHAT_FASTAPICLOUD_DEMO_SECRET
    CHAT_RENDER_DEMO_SECRET
  )
  for define in "${dart_defines[@]}"; do
    for name in "${prohibited[@]}"; do
      if [[ "$define" == "--dart-define=${name}="* ]]; then
        echo "${name} must not be supplied to a mobile release/profile build. Keep it on a trusted backend."
        exit 1
      fi
    done
  done
fi

args+=("${dart_defines[@]}")

echo "Building iOS IPA (${BUILD_MODE}) with dart-defines from environment (values redacted)."
echo "  - target: ${ENTRYPOINT}"
if [ -n "${FLAVOR// /}" ]; then
  echo "  - flavor: ${FLAVOR}"
fi

exec "${args[@]}"
