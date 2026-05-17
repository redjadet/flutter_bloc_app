#!/usr/bin/env bash
# One-shot Cursor/Codex host setup: sync repo adapters, optional global skills, trim, inventory.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/setup_cursor_agent_environment.sh [options]

Orchestrates repo-managed agent host setup for Cursor (and Codex adapters via sync).

Default (no --apply): dry-run sync + report planned install/trim/inventory steps.
With --apply: mutates ~/.cursor / ~/.codex / ~/.agents/skills as selected.

Typical flows:
  bash tool/setup_cursor_agent_environment.sh
  bash tool/setup_cursor_agent_environment.sh --apply
  bash tool/setup_cursor_agent_environment.sh --apply --install
  bash tool/setup_cursor_agent_environment.sh --apply --install --trim-mode full
  bash tool/setup_cursor_agent_environment.sh --apply --sync-only

Options:
  --apply              Apply sync, install, trim, and inventory (see flags below)
  --sync-only          Only sync/check repo-managed host assets
  --skip-sync          Skip sync + drift check
  --install            Run tool/install_global_agent_skills.sh (network; npx skills)
  --skip-trim          Skip trim even after --install
  --trim               Run trim (dry-run without --apply)
  --trim-mode MODE     balanced (default), flutter-legacy, ios-minimal, full
  --skip-inventory     Skip skill inventory + budget report
  --install-args ARGS  Extra args passed to install script (quote once)
  -h, --help

After --apply: reload Cursor (Developer: Reload Window).
Canon: AGENTS.md and docs/agent_environment_setup.md.
EOF
}

# shellcheck source=./global_agent_skills_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/global_agent_skills_lib.sh"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

apply=0
sync_only=0
skip_sync=0
do_install=0
do_trim=0
skip_trim=0
skip_inventory=0
trim_mode=balanced
install_extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      apply=1
      shift
      ;;
    --sync-only)
      sync_only=1
      shift
      ;;
    --skip-sync)
      skip_sync=1
      shift
      ;;
    --install)
      do_install=1
      shift
      ;;
    --skip-trim)
      skip_trim=1
      shift
      ;;
    --trim)
      do_trim=1
      shift
      ;;
    --trim-mode)
      trim_mode="${2:-}"
      if [[ -z "$trim_mode" ]]; then
        echo "setup-cursor-agent|error|--trim-mode requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --skip-inventory)
      skip_inventory=1
      shift
      ;;
    --install-args)
      install_extra_args+=("${2:-}")
      if [[ -z "${install_extra_args[0]}" ]]; then
        echo "setup-cursor-agent|error|--install-args requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "setup-cursor-agent|error|unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

run_trim() {
  local -a trim_cmd=(bash "$PROJECT_ROOT/tool/trim_duplicate_agent_skills.sh" --mode "$trim_mode")
  if (( apply )); then
    trim_cmd+=(--apply)
  fi
  echo "setup-cursor-agent|run|${trim_cmd[*]}"
  "${trim_cmd[@]}"
}

if (( ! skip_sync )); then
  if (( apply )); then
    echo "setup-cursor-agent|stage|sync-apply"
    bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --apply
  else
    echo "setup-cursor-agent|stage|sync-dry-run"
    bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --dry-run
  fi
  echo "setup-cursor-agent|stage|asset-drift"
  bash "$PROJECT_ROOT/tool/check_agent_asset_drift.sh" || true
fi

if (( sync_only )); then
  echo "setup-cursor-agent|done|sync-only"
  exit 0
fi

if (( do_install )); then
  if (( apply )); then
    require_global_agent_skills_runtime
    echo "setup-cursor-agent|stage|install-globals"
    bash "$PROJECT_ROOT/tool/install_global_agent_skills.sh" "${install_extra_args[@]}"
    if (( ! skip_trim )); then
      echo "setup-cursor-agent|stage|trim-after-install"
      run_trim
    fi
  else
    echo "setup-cursor-agent|plan|install|bash tool/install_global_agent_skills.sh ${install_extra_args[*]:-}"
    if (( ! skip_trim )); then
      echo "setup-cursor-agent|plan|trim|bash tool/trim_duplicate_agent_skills.sh --mode $trim_mode"
    fi
  fi
elif (( do_trim )); then
  echo "setup-cursor-agent|stage|trim"
  run_trim
fi

if (( ! skip_inventory && (apply || do_install || do_trim) )); then
  inventory_path="$PROJECT_ROOT/docs/audits/skill_inventory_latest.json"
  if (( apply )); then
    echo "setup-cursor-agent|stage|skill-inventory"
    dart run "$PROJECT_ROOT/tool/skill_inventory.dart" "$inventory_path"
    bash "$PROJECT_ROOT/tool/check_skill_budgets.sh" "$inventory_path" report || true
  else
    echo "setup-cursor-agent|plan|inventory|dart run tool/skill_inventory.dart $inventory_path"
    echo "setup-cursor-agent|plan|budget|bash tool/check_skill_budgets.sh $inventory_path report"
  fi
fi

if (( apply )); then
  echo "setup-cursor-agent|hint|reload Cursor (Developer: Reload Window)"
fi
echo "setup-cursor-agent|done"
