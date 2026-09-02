#!/usr/bin/env bash
# shellcheck shell=bash
#
# Load gitignored repo-root `.env` / `.env.local` into the current shell.
# Tests may set FLUTTER_BLOC_APP_DOTENV_DIR to an isolated directory.

load_repo_dotenv() {
  local repo_root="$1"
  local dotenv_dir="${FLUTTER_BLOC_APP_DOTENV_DIR:-$repo_root}"
  # shellcheck disable=SC1091
  source "$repo_root/tool/load_env_file.sh"
  load_env_file "$dotenv_dir/.env"
  load_env_file "$dotenv_dir/.env.local"
}
