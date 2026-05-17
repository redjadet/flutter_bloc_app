#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/update_global_agent_skills.sh [options]

Update globally installed agent skills (npx skills update -g -y).

Options:
  --check     Run npx skills check only (no update)
  --dry-run   Print commands without running npx
  -h, --help  Show this help

Install missing bundles first:
  bash tool/install_global_agent_skills.sh

See docs/agent_environment_setup.md.
EOF
}

# shellcheck source=./global_agent_skills_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/global_agent_skills_lib.sh"

dry_run=0
check_only=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      check_only=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if (( dry_run )); then
  if (( check_only )); then
    echo "global-agent-skills|dry-run|npx skills check"
  else
    echo "global-agent-skills|dry-run|npx skills update -g -y"
  fi
  exit 0
fi

require_global_agent_skills_runtime

if (( check_only )); then
  run_skills_check
else
  run_skills_update
fi

echo "global-agent-skills|done|update"
