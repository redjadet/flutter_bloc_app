#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/find_global_agent_skills.sh <query> [query...]

Search the public skills catalog (npx skills find).

Examples:
  bash tool/find_global_agent_skills.sh flutter
  bash tool/find_global_agent_skills.sh ios swift
  bash tool/find_global_agent_skills.sh bloc

Install a hit globally for Cursor:
  npx skills add <owner/repo@skill> -g -a cursor -y

Or install default Flutter/Dart/iOS/AI bundles:
  bash tool/install_global_agent_skills.sh

Browse: https://skills.sh/
EOF
}

# shellcheck source=./global_agent_skills_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/global_agent_skills_lib.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if (($# == 0)); then
  usage >&2
  exit 2
fi

require_global_agent_skills_runtime
run_skills_find "$@"
