#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run_codex_plan_review.sh PLAN_FILE [delegate options...]

Concatenate the repo-tracked Codex instructions template with PLAN_FILE and
pipe the combined prompt to the Cursor->Codex delegate wrapper (same entry
point style as cross-host diff review, but plan-based instead of git diff).

Arguments:
  PLAN_FILE       Path to a markdown plan (absolute or relative to cwd).

Delegate options (passed through):
  --profile fast|balanced   Default: balanced (see delegate_to_codex.sh -h).
  --raw-response            Raw Codex output (debug).
  --raw-response-tolerant   Raw output but tolerate MCP noise.
  --model NAME              Force Codex model.
  -h, --help                Show this help.

Environment:
  DELEGATE_SKIP_FIREBASE_MCP=1 is set for this script (same as request_codex_feedback).

Examples:
  ./tool/run_codex_plan_review.sh docs/plans/my_feature_plan.md
  ./tool/run_codex_plan_review.sh ../.cursor/plans/render_fastapi_chat_demo_e33e5891.plan.md --profile fast

Requires: python3, git, and either the repo-local or home Cursor delegate wrapper.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

plan_file="$1"
shift

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
template="$repo_root/tool/codex_plan_review_template.md"

if [[ ! -f "$template" ]]; then
  echo "Missing template: $template" >&2
  exit 2
fi

plan_resolved="$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$plan_file")"

if [[ ! -f "$plan_resolved" ]]; then
  echo "Plan file not found: $plan_resolved" >&2
  exit 2
fi

resolve_wrapper() {
  local candidate
  for candidate in \
    "$repo_root/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh" \
    "${HOME}/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
  do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

wrapper="$(resolve_wrapper)" || {
  echo "No executable delegate_to_codex.sh found (repo .cursor or HOME/.cursor)." >&2
  exit 127
}

export DELEGATE_SKIP_FIREBASE_MCP="${DELEGATE_SKIP_FIREBASE_MCP:-1}"

{
  cat "$template"
  printf '\n---PLAN---\n\n'
  cat "$plan_resolved"
} | "$wrapper" \
  --workspace "$repo_root" \
  --skip-firebase-mcp \
  "$@"
