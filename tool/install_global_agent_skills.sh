#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/install_global_agent_skills.sh [options]

Install or refresh global agent skills for Cursor (Flutter, Dart, iOS, AI
workflow). Uses the skills CLI (npx skills) with -g -a cursor -y.

Bundles (default: all):
  dart          dart-lang/skills (all)
  flutter       flutter/skills (all) + legacy local copies when present
  ios           dpearson2699/swift-ios-skills (all) + ios-development
  ai            obra/superpowers, dart-flutter-patterns, caveman, find-skills

Options:
  --dart-only       Install only Dart skills
  --flutter-only    Install only Flutter skills (+ legacy unless --skip-legacy)
  --ios-only        Install only iOS/Swift skills
  --ai-only         Install only AI workflow skills
  --skip-legacy     Skip linking legacy flutter/* skills from ~/.agents/skills
  --dry-run         Print commands without running npx
  -h, --help        Show this help

After install:
  npx skills list -g
  Reload Cursor (Developer: Reload Window)

Repo policy: project canon (AGENTS.md, docs/, tool/agent_host_templates/) wins
over vendor skills. See docs/agent_environment_setup.md.
EOF
}

# shellcheck source=./global_agent_skills_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/global_agent_skills_lib.sh"

dry_run=0
skip_legacy=0
install_dart=0
install_flutter=0
install_ios=0
install_ai=0
install_all=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dart-only)
      install_all=0
      install_dart=1
      shift
      ;;
    --flutter-only)
      install_all=0
      install_flutter=1
      shift
      ;;
    --ios-only)
      install_all=0
      install_ios=1
      shift
      ;;
    --ai-only)
      install_all=0
      install_ai=1
      shift
      ;;
    --skip-legacy)
      skip_legacy=1
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

if (( install_all )); then
  install_dart=1
  install_flutter=1
  install_ios=1
  install_ai=1
fi

if (( dry_run )); then
  run_skills_add() {
    shift # label
    echo "global-agent-skills|dry-run|npx skills add $* -g -a $GLOBAL_AGENT_SKILLS_AGENT -y"
  }
  run_skills_update() {
    echo "global-agent-skills|dry-run|npx skills update -g -y"
  }
else
  require_global_agent_skills_runtime
fi

if (( install_dart )); then
  install_dart_skills
fi

if (( install_flutter )); then
  install_flutter_skills
  if (( ! skip_legacy )); then
    install_legacy_flutter_skills
  fi
fi

if (( install_ios )); then
  install_ios_skills
fi

if (( install_ai )); then
  install_ai_workflow_skills
fi

echo "global-agent-skills|done|install"
echo "global-agent-skills|hint|trim: bash tool/trim_duplicate_agent_skills.sh --apply"
echo "global-agent-skills|hint|full host setup: bash tool/setup_cursor_agent_environment.sh --apply --install"
