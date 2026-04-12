#!/usr/bin/env bash
set -euo pipefail

# Emits `--dart-define=KEY=value` args for any configured secrets in the current
# environment.
#
# Intended usage (direnv recommended):
#   eval "$(./tool/flutter_dart_defines_from_env.sh)"
#
# Or within a command:
#   # shellcheck disable=SC2046
#   flutter run $(./tool/flutter_dart_defines_from_env.sh)
#
# Notes:
# - This script intentionally does NOT print secret values.
# - It outputs args separated by spaces.

emit_define() {
  local key="$1"
  local value="${!key:-}"
  if [ -n "${value// /}" ]; then
    printf -- "--dart-define=%s=%s " "$key" "$value"
  fi
}

# Required by some remote-backed features.
emit_define "HUGGINGFACE_API_KEY"
emit_define "HUGGINGFACE_MODEL"
emit_define "HUGGINGFACE_USE_CHAT_COMPLETIONS"
emit_define "SUPABASE_URL"
emit_define "SUPABASE_ANON_KEY"

# Optional (feature-gated) keys.
emit_define "GEMINI_API_KEY"

# Back-compat: code may treat GOOGLE_API_KEY as a fallback for GEMINI_API_KEY.
emit_define "GOOGLE_API_KEY"

# Android/iOS maps keys are platform-specific; only include the generic key if present.
emit_define "GOOGLE_MAPS_API_KEY"

# Render FastAPI chat demo (`SecretConfig` compile-time gates; see
# docs/integrations/render_fastapi_chat_demo.md).
emit_define "CHAT_RENDER_DEMO_ENABLED"
emit_define "CHAT_RENDER_DEMO_STRICT"
emit_define "CHAT_RENDER_DEMO_BASE_URL"
emit_define "CHAT_RENDER_DEMO_SECRET"
emit_define "CHAT_RENDER_HF_READ_TOKEN_CALLABLE"
emit_define "CHAT_RENDER_HF_READ_TOKEN_CALLABLE_REGION"

printf "\n"

