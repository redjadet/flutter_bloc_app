#!/usr/bin/env bash
# shellcheck shell=bash
#
# Load literal KEY=VALUE pairs from a dotenv-style file into the current shell.
# Used by Flutter wrappers and release scripts. Never commit real `.env` files.
# This is intentionally a parser, not `source`: local configuration must not
# execute commands when a wrapper reads it.
#
# Usage:
#   source tool/load_env_file.sh
#   load_env_file ".env"
#
# Or:
#   ./tool/load_env_file.sh .env [.env.local ...]

load_env_file() {
  local file="$1"
  local line
  local line_number=0
  local key
  local raw_value
  local value
  local keys=()
  local values=()
  if [ ! -f "$file" ]; then
    return 0
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    line_number=$((line_number + 1))
    line="${line%$'\r'}"

    if [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^[[:space:]]*# ]]; then
      continue
    fi

    if [[ ! "$line" =~ ^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      printf 'error: %s:%d: expected KEY=VALUE dotenv assignment\n' "$file" "$line_number" >&2
      return 2
    fi

    key="${BASH_REMATCH[2]}"
    raw_value="${BASH_REMATCH[3]}"

    if [[ "$raw_value" =~ ^\"([^\"]*)\"[[:space:]]*(#.*)?$ ]]; then
      value="${BASH_REMATCH[1]}"
    elif [[ "$raw_value" =~ ^\'([^\']*)\'[[:space:]]*(#.*)?$ ]]; then
      value="${BASH_REMATCH[1]}"
    elif [[ "$raw_value" =~ ^([^[:space:]#]*)([[:space:]]+#.*)?$ ]]; then
      value="${BASH_REMATCH[1]}"
      if [[ "$value" == *'$'* || "$value" == *'`'* ]]; then
        printf 'error: %s:%d: unquoted values cannot contain $ or backticks\n' \
          "$file" "$line_number" >&2
        return 2
      fi
    else
      printf 'error: %s:%d: quote values containing spaces; only literal dotenv values are supported\n' \
        "$file" "$line_number" >&2
      return 2
    fi

    keys+=("$key")
    values+=("$value")
  done <"$file"

  local index
  for ((index = 0; index < ${#keys[@]}; index += 1)); do
    export "${keys[$index]}=${values[$index]}"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  if [ "$#" -eq 0 ]; then
    echo "usage: tool/load_env_file.sh <file> [<file> ...]" >&2
    exit 2
  fi
  for file in "$@"; do
    load_env_file "$file"
    if [ -f "$file" ]; then
      echo "Loaded ${file}"
    fi
  done
fi
