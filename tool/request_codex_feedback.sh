#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: request_codex_feedback.sh [options]

Ask the repo's Cursor->Codex delegate wrapper to review the current git diff.
By default this reviews staged changes first, then falls back to unstaged
changes.

Options:
  --focus TEXT        Extra review focus to append to the Codex prompt.
  --base BRANCH       Review committed branch diff against BRANCH via
                      git diff BRANCH...HEAD.
  --staged            Review only staged changes.
  --unstaged          Review only unstaged changes.
  --profile NAME      Delegation profile: fast or balanced. Default: balanced.
  --raw-response      Print raw Codex output instead of extracted final payload.
  --workspace PATH    Repo/workspace root. Default: current repository root.
  -h, --help          Show this help.
EOF
}

workspace=""
focus=""
diff_mode="auto"
base_branch=""
profile="balanced"
raw_response="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --focus)
      [[ $# -ge 2 ]] || {
        echo "Missing value for --focus" >&2
        exit 2
      }
      focus="$2"
      shift 2
      ;;
    --base)
      [[ $# -ge 2 ]] || {
        echo "Missing value for --base" >&2
        exit 2
      }
      base_branch="$2"
      shift 2
      ;;
    --staged)
      diff_mode="staged"
      shift
      ;;
    --unstaged)
      diff_mode="unstaged"
      shift
      ;;
    --profile)
      [[ $# -ge 2 ]] || {
        echo "Missing value for --profile" >&2
        exit 2
      }
      profile="$2"
      shift 2
      ;;
    --raw-response)
      raw_response="true"
      shift
      ;;
    --workspace)
      [[ $# -ge 2 ]] || {
        echo "Missing value for --workspace" >&2
        exit 2
      }
      workspace="$2"
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

if [[ -z "$workspace" ]]; then
  workspace="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

if [[ ! -d "$workspace" ]]; then
  echo "Workspace does not exist or is not a directory: $workspace" >&2
  exit 2
fi

wrapper="$workspace/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
if [[ ! -x "$wrapper" ]]; then
  echo "Cursor->Codex delegate wrapper not found: $wrapper" >&2
  exit 1
fi

if ! git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Workspace is not a git repository: $workspace" >&2
  exit 2
fi

case "$profile" in
  fast|balanced) ;;
  *)
    echo "Unsupported --profile: $profile (expected fast or balanced)" >&2
    exit 2
    ;;
esac

if [[ -n "$base_branch" && "$diff_mode" != "auto" ]]; then
  echo "--base cannot be combined with --staged or --unstaged." >&2
  exit 2
fi

select_diff_mode() {
  if [[ "$diff_mode" == "staged" || "$diff_mode" == "unstaged" ]]; then
    printf '%s\n' "$diff_mode"
    return 0
  fi

  if ! git -C "$workspace" diff --cached --quiet --exit-code; then
    printf '%s\n' "staged"
    return 0
  fi

  if ! git -C "$workspace" diff --quiet --exit-code; then
    printf '%s\n' "unstaged"
    return 0
  fi

  return 1
}

if [[ -n "$base_branch" ]]; then
  if ! git -C "$workspace" rev-parse --verify --quiet "$base_branch^{commit}" >/dev/null; then
    echo "Base branch or ref not found: $base_branch" >&2
    exit 2
  fi

  if ! git -C "$workspace" merge-base "$base_branch" HEAD >/dev/null 2>&1; then
    echo "Could not determine merge base between $base_branch and HEAD." >&2
    exit 1
  fi

  mode_description="branch diff against $base_branch (merge-base ... HEAD)"
  stat_output="$(git -C "$workspace" diff "$base_branch...HEAD" --stat)"
  diff_output="$(git -C "$workspace" diff "$base_branch...HEAD")"
else
  resolved_mode="$(select_diff_mode)" || {
    echo "No staged or unstaged git diff found in $workspace." >&2
    exit 1
  }

  if [[ "$resolved_mode" == "staged" ]]; then
    mode_description="staged changes"
    stat_output="$(git -C "$workspace" diff --cached --stat)"
    diff_output="$(git -C "$workspace" diff --cached)"
  else
    mode_description="unstaged changes"
    stat_output="$(git -C "$workspace" diff --stat)"
    diff_output="$(git -C "$workspace" diff)"
  fi
fi

status_output="$(git -C "$workspace" status --short)"

if [[ -z "${diff_output//[[:space:]]/}" ]]; then
  echo "Resolved $mode_description but the diff was empty." >&2
  exit 1
fi

focus_block="Additional focus: none."
if [[ -n "${focus//[[:space:]]/}" ]]; then
  focus_block="Additional focus: $focus"
fi

prompt_file="$(mktemp)"
cleanup() {
  rm -f "$prompt_file"
}
trap cleanup EXIT

cat >"$prompt_file" <<EOF
Review the current git diff from this Flutter/Dart repository.

Return findings only, ordered by severity.
- Focus on correctness, regressions, edge cases, failure handling, and missing validation.
- Call out shell/script robustness issues when relevant.
- Do not praise the code or restate the diff.
- If you find no material issues, respond with exactly: No material findings.

Diff mode reviewed: $mode_description
$focus_block

Git status:
$status_output

Diff stat:
$stat_output

Diff:
$diff_output
EOF

cmd=("$wrapper" "--workspace" "$workspace" "--profile" "$profile")
if [[ "$raw_response" == "true" ]]; then
  cmd+=("--raw-response")
fi

cat "$prompt_file" | "${cmd[@]}"
