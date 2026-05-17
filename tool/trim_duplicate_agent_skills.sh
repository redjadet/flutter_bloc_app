#!/usr/bin/env bash
# Trim duplicate / low-value global skills under ~/.agents/skills to cut context cost.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/trim_duplicate_agent_skills.sh [options]

Reduces duplicate global skills after install_global_agent_skills.sh.
Archives directories under ~/.agents/skills/.archived/<timestamp>/ (reversible).

Modes (combine with multiple --mode flags or use --mode full):
  balanced       When ~/.cursor/skills has the same skill name, archive the
                 ~/.agents/skills copy (keeps repo-thin Cursor skills).
  flutter-legacy Archive legacy flutter/* skills only in agents (upstream removed).
  ios-minimal    Archive flat swift-ios kit skills; keep ios-development router,
                 swift-development, release-review, security, macos-development.
  superpowers    Archive obra/superpowers copies in agents when Cursor already
                 has the same skill name (pairs with balanced).

  full           balanced + flutter-legacy + ios-minimal

Options:
  --apply        Move skills to archive (default: dry-run)
  --report PATH  Write JSON plan (default: docs/audits/skill_trim_plan_latest.json)
  -h, --help

After trim:
  Reload Cursor (Developer: Reload Window)
  dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json
  bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json report

Restore: mv ~/.agents/skills/.archived/<stamp>/<name> ~/.agents/skills/
EOF
}

# shellcheck source=./global_agent_skills_lib.sh disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/global_agent_skills_lib.sh"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
apply=0
report_path="$PROJECT_ROOT/docs/audits/skill_trim_plan_latest.json"
declare -a MODES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODES+=("$2")
      shift 2
      ;;
    --apply)
      apply=1
      shift
      ;;
    --report)
      report_path="$2"
      shift 2
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

if ((${#MODES[@]} == 0)); then
  MODES=(balanced)
fi

for m in "${MODES[@]}"; do
  if [[ "$m" == "full" ]]; then
    MODES=(balanced flutter-legacy ios-minimal)
    break
  fi
done

if [[ ! -d "$GLOBAL_AGENT_SKILLS_HOME" ]]; then
  echo "global-agent-skills|error|missing $GLOBAL_AGENT_SKILLS_HOME" >&2
  exit 2
fi

stamp="$(date +%Y%m%d-%H%M%S)"
archive_root="$GLOBAL_AGENT_SKILLS_HOME/.archived/$stamp"
declare -a PLAN_LINES=()
planned=0

mode_enabled() {
  local want="$1"
  local m
  for m in "${MODES[@]}"; do
    [[ "$m" == "$want" ]] && return 0
  done
  return 1
}

add_plan() {
  local reason="$1"
  local path="$2"
  PLAN_LINES+=("$reason|$path")
  ((planned++)) || true
}

should_skip_dir() {
  local name="$1"
  [[ "$name" == ".archived" ]] && return 0
  return 1
}

trim_balanced() {
  local name path skill_md fm_name
  if [[ ! -d "$GLOBAL_CURSOR_SKILLS_HOME" ]]; then
    echo "global-agent-skills|skip|balanced (no $GLOBAL_CURSOR_SKILLS_HOME)"
    return 0
  fi
  for path in "$GLOBAL_AGENT_SKILLS_HOME"/*; do
    [[ -d "$path" ]] || continue
    name="$(basename "$path")"
    should_skip_dir "$name" && continue
    skill_md="$path/SKILL.md"
    [[ -f "$skill_md" ]] || continue
    fm_name="$(_skill_frontmatter_name "$skill_md")"
    [[ -n "$fm_name" ]] || name="$name"
    [[ -n "$fm_name" ]] && name="$fm_name"
    if _cursor_has_skill_name "$name"; then
      add_plan "balanced-duplicate" "$path"
      _archive_agent_skill_dir "$path" "$archive_root" "$apply"
    fi
  done
}

trim_flutter_legacy() {
  local name path
  for name in "${LEGACY_FLUTTER_SKILL_NAMES[@]}"; do
    path="$GLOBAL_AGENT_SKILLS_HOME/$name"
    [[ -d "$path" ]] || continue
    add_plan "flutter-legacy" "$path"
    _archive_agent_skill_dir "$path" "$archive_root" "$apply"
  done
}

trim_ios_minimal() {
  local name path
  for path in "$GLOBAL_AGENT_SKILLS_HOME"/*; do
    [[ -d "$path" ]] || continue
    name="$(basename "$path")"
    should_skip_dir "$name" && continue
    _ios_minimal_is_bloat_name "$name" || continue
    add_plan "ios-minimal" "$path"
    _archive_agent_skill_dir "$path" "$archive_root" "$apply"
  done
}

trim_superpowers_agents() {
  local names=(
    using-superpowers
    brainstorming
    systematic-debugging
    test-driven-development
    verification-before-completion
    writing-plans
    dispatching-parallel-agents
    executing-plans
    finishing-a-development-branch
    receiving-code-review
    requesting-code-review
    subagent-driven-development
    using-git-worktrees
    writing-skills
  )
  local name path
  for name in "${names[@]}"; do
    path="$GLOBAL_AGENT_SKILLS_HOME/$name"
    [[ -d "$path" ]] || continue
    if _cursor_has_skill_name "$name"; then
      add_plan "superpowers-duplicate" "$path"
      _archive_agent_skill_dir "$path" "$archive_root" "$apply"
    fi
  done
}

if [[ -d "$GLOBAL_CURSOR_SKILLS_HOME" ]]; then
  _cursor_skill_name_index_build
fi

if mode_enabled balanced; then
  trim_balanced
fi
if mode_enabled flutter-legacy; then
  trim_flutter_legacy
fi
if mode_enabled ios-minimal; then
  trim_ios_minimal
fi
if mode_enabled superpowers; then
  trim_superpowers_agents
fi

mkdir -p "$(dirname "$report_path")"
modes_json="$(printf '"%s",' "${MODES[@]}")"
modes_json="[${modes_json%,}]"
python3 - "$report_path" "$apply" "$archive_root" "$planned" "$modes_json" <<'PY' "${PLAN_LINES[@]}"
import json, sys
from datetime import datetime, timezone
report_path, apply_s, archive_root, planned_s, modes_json = sys.argv[1:6]
lines = sys.argv[6:]
entries = []
for line in lines:
    reason, path = line.split("|", 1)
    entries.append({"reason": reason, "path": path})
payload = {
    "generatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "apply": apply_s == "1",
    "modes": json.loads(modes_json),
    "archiveRoot": archive_root,
    "plannedCount": int(planned_s),
    "entries": entries,
}
open(report_path, "w", encoding="utf-8").write(json.dumps(payload, indent=2) + "\n")
PY

if [[ -n "${CURSOR_SKILL_INDEX_FILE:-}" && -f "$CURSOR_SKILL_INDEX_FILE" ]]; then
  rm -f "$CURSOR_SKILL_INDEX_FILE"
fi

echo "global-agent-skills|plan|$planned entries -> $report_path"
if (( apply )); then
  echo "global-agent-skills|done|trim apply archive=$archive_root"
else
  echo "global-agent-skills|done|trim dry-run (use --apply to archive)"
fi
