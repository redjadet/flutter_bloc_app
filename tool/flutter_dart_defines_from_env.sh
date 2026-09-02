#!/usr/bin/env bash
set -euo pipefail

# Emits `--dart-define=KEY=value` args for approved client configuration in the
# current environment. Never add provider credentials or shared backend secrets:
# command-line arguments are observable and Flutter embeds Dart defines.
#
# Intended usage (direnv recommended):
#   # shellcheck disable=SC2046
#   flutter run $(./tool/flutter_dart_defines_from_env.sh)
#   flutter build web $(./tool/flutter_dart_defines_from_env.sh --release)
#
# Notes:
# - Loads gitignored `.env` / `.env.local` from the repo root when present.
# - It outputs args separated by spaces.
# - Server-only variables such as HUGGINGFACE_API_KEY are intentionally excluded.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/tool/load_repo_dotenv.sh"
load_repo_dotenv "$ROOT_DIR"

release_safe=0
case "${1:-}" in
  "") ;;
  --release)
    release_safe=1
    shift
    ;;
  -h | --help)
    echo "usage: tool/flutter_dart_defines_from_env.sh [--release]"
    exit 0
    ;;
  *)
    echo "error: unknown option: $1" >&2
    exit 2
    ;;
esac
if [ "$#" -gt 0 ]; then
  echo "error: unexpected arguments" >&2
  exit 2
fi

if [ "$release_safe" -eq 1 ]; then
  prohibited=(
    HUGGINGFACE_API_KEY
    GEMINI_API_KEY
    GOOGLE_API_KEY
    CHAT_FASTAPICLOUD_DEMO_SECRET
    CHAT_RENDER_DEMO_SECRET
  )
  for key in "${prohibited[@]}"; do
    if [ -n "${!key:-}" ]; then
      echo "error: ${key} must not be supplied to a release/profile build" >&2
      exit 2
    fi
  done
fi

defines=()

emit_define() {
  local key="$1"
  local value="${!key:-}"
  if [ -n "${value// /}" ]; then
    if [[ "$value" =~ [[:space:]] ]]; then
      printf 'error: %s contains whitespace; dart-define output is space-separated\n' "$key" >&2
      return 2
    fi
    defines+=("--dart-define=${key}=${value}")
  fi
}

# Public client configuration for remote-backed features.
emit_define "SUPABASE_URL"
emit_define "SUPABASE_ANON_KEY"

# Optional Firebase local config. The committed Firebase options stay as
# placeholders; local direnv can inject real config for development.
emit_define "FIREBASE_ANDROID_API_KEY"
emit_define "FIREBASE_ANDROID_APP_ID"
emit_define "FIREBASE_IOS_API_KEY"
emit_define "FIREBASE_IOS_APP_ID"
emit_define "FIREBASE_IOS_CLIENT_ID"
emit_define "FIREBASE_IOS_BUNDLE_ID"
emit_define "FIREBASE_MACOS_API_KEY"
emit_define "FIREBASE_MACOS_APP_ID"
emit_define "FIREBASE_MACOS_CLIENT_ID"
emit_define "FIREBASE_MACOS_BUNDLE_ID"
emit_define "FIREBASE_MESSAGING_SENDER_ID"
emit_define "FIREBASE_PROJECT_ID"
emit_define "FIREBASE_DATABASE_URL"
emit_define "FIREBASE_STORAGE_BUCKET"

# Optional (feature-gated) keys.
emit_define "GEMINI_API_KEY"

# Local demo API (AI Decision Workbench).
emit_define "AI_DECISION_API_BASE_URL"

# Back-compat: code may treat GOOGLE_API_KEY as a fallback for GEMINI_API_KEY.
emit_define "GOOGLE_API_KEY"

# Android/iOS maps keys are platform-specific; only include the generic key if present.
emit_define "GOOGLE_MAPS_API_KEY"

# Render FastAPI chat demo (`SecretConfig` compile-time gates; see
# docs/integrations/render_fastapi_chat_demo.md).
emit_define "CHAT_RENDER_DEMO_ENABLED"
emit_define "CHAT_RENDER_DEMO_STRICT"
emit_define "CHAT_RENDER_DEMO_BASE_URL"
emit_define "CHAT_RENDER_HF_READ_TOKEN_CALLABLE"
emit_define "CHAT_RENDER_HF_READ_TOKEN_CALLABLE_REGION"

# FastAPI Cloud naming (preferred; back-compat keys above still supported).
emit_define "CHAT_FASTAPICLOUD_DEMO_ENABLED"
emit_define "CHAT_FASTAPICLOUD_DEMO_STRICT"
emit_define "CHAT_FASTAPICLOUD_DEMO_BASE_URL"
emit_define "CHAT_FASTAPICLOUD_HF_READ_TOKEN_CALLABLE"
emit_define "CHAT_FASTAPICLOUD_HF_READ_TOKEN_CALLABLE_REGION"

if [ "${#defines[@]}" -gt 0 ]; then
  printf '%s ' "${defines[@]}"
fi
printf "\n"
