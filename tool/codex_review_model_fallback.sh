#!/usr/bin/env bash

# Shared policy for repo-managed Cursor -> Codex review helpers.
CODEX_REVIEW_PREFERRED_MODEL="gpt-6-sol"
CODEX_REVIEW_FALLBACK_MODEL="gpt-5.6-sol"

codex_review_with_model_fallback() {
  local preferred_model="$1" allow_fallback="$2" runner="$3"
  local error_file exit_code unsupported
  shift 3

  error_file="$(mktemp)" || return 1
  if "$runner" "$preferred_model" "$@" 2>"$error_file"; then
    cat "$error_file" >&2
    rm -f "$error_file"
    return 0
  else
    exit_code=$?
  fi

  unsupported='not supported|unsupported|not available|unavailable|doesn.t support|unknown model|model not found|invalid model'
  if [[ "$allow_fallback" == "true" && "$preferred_model" == "$CODEX_REVIEW_PREFERRED_MODEL" ]] &&
     rg -qi -- "(gpt-6-sol.*($unsupported)|($unsupported).*gpt-6-sol)" "$error_file"; then
    rm -f "$error_file"
    echo "GPT-6 Sol is unavailable for this account; retrying with GPT-5.6 Sol using the same reasoning profile." >&2
    "$runner" "$CODEX_REVIEW_FALLBACK_MODEL" "$@"
    return $?
  fi

  cat "$error_file" >&2
  rm -f "$error_file"
  return "$exit_code"
}
