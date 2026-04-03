#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: request_codex_feedback.sh [options]

Review the current git diff with the repo-managed cross-host review flow.
Default behavior:
  - prefers the Cursor->Codex delegate wrapper when available
  - falls back to direct `codex exec` otherwise
  - reviews staged diff first, then unstaged/untracked diff

Options:
  --focus TEXT        Extra review focus.
  --base BRANCH       Review BRANCH...HEAD instead of local changes.
  --staged            Review staged changes only.
  --unstaged          Review unstaged and untracked changes only.
  --profile NAME      fast or balanced. Default: balanced.
  --backend NAME      auto, cursor-wrapper, or codex-cli. Default: auto.
  --raw-response      Print backend output without final extraction.
  --workspace PATH    Repo/workspace root. Default: current repository root.
  -h, --help          Show this help.

Examples:
  ./tool/request_codex_feedback.sh
  ./tool/request_codex_feedback.sh --focus "routing and auth regressions"
  ./tool/request_codex_feedback.sh --base main
  ./tool/request_codex_feedback.sh --backend codex-cli
EOF
}

workspace=""
focus=""
diff_mode="auto"
base_branch=""
profile="balanced"
raw_response="false"
backend="auto"

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
    --backend)
      [[ $# -ge 2 ]] || {
        echo "Missing value for --backend" >&2
        exit 2
      }
      backend="$2"
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

case "$backend" in
  auto|cursor-wrapper|codex-cli) ;;
  *)
    echo "Unsupported --backend: $backend" >&2
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

  if [[ -n "$(git -C "$workspace" ls-files --others --exclude-standard)" ]]; then
    printf '%s\n' "unstaged"
    return 0
  fi

  return 1
}

build_untracked_diff() {
  local rel_path untracked_output="" file_diff

  while IFS= read -r rel_path; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "$workspace/$rel_path" || -L "$workspace/$rel_path" ]]; then
      file_diff="$(git -C "$workspace" diff --no-index -- /dev/null "$workspace/$rel_path" || true)"
      if [[ -n "${file_diff//[[:space:]]/}" ]]; then
        untracked_output+="${file_diff}"$'\n'
      fi
    fi
  done < <(git -C "$workspace" ls-files --others --exclude-standard)

  printf '%s' "$untracked_output"
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
    untracked_diff="$(build_untracked_diff)"
    if [[ -n "${untracked_diff//[[:space:]]/}" ]]; then
      diff_output+=$'\n'"$untracked_diff"
      stat_output+=$'\n'"(includes untracked files from git ls-files --others --exclude-standard)"
    fi
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

prompt_text="$(cat <<EOF
Review the current git diff from this Flutter/Dart repository.

Return findings only, ordered by severity.
- Focus on correctness, regressions, edge cases, failure handling, and missing validation.
- Apply the AI review gate mindset: draft-first, problem-fit, simplification,
  security, performance, edge cases, dependency skepticism, and tests.
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
)"

resolve_wrapper() {
  local candidate
  for candidate in \
    "$workspace/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh" \
    "$HOME/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
  do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

resolve_backend() {
  if [[ "$backend" == "cursor-wrapper" ]]; then
    resolve_wrapper >/dev/null || {
      echo "Requested --backend cursor-wrapper but no wrapper was found." >&2
      exit 1
    }
    printf '%s\n' "cursor-wrapper"
    return 0
  fi

  if [[ "$backend" == "codex-cli" ]]; then
    command -v codex >/dev/null 2>&1 || {
      echo "Requested --backend codex-cli but codex is not installed." >&2
      exit 127
    }
    printf '%s\n' "codex-cli"
    return 0
  fi

  if resolve_wrapper >/dev/null 2>&1; then
    printf '%s\n' "cursor-wrapper"
    return 0
  fi

  command -v codex >/dev/null 2>&1 || {
    echo "No Cursor delegate wrapper found and codex is not installed." >&2
    exit 127
  }
  printf '%s\n' "codex-cli"
}

run_cursor_wrapper() {
  local wrapper
  wrapper="$(resolve_wrapper)"
  cmd=(
    "$wrapper"
    "--workspace" "$workspace"
    "--profile" "$profile"
    "--skip-firebase-mcp"
  )
  if [[ "$raw_response" == "true" ]]; then
    cmd+=("--raw-response")
  fi
  printf '%s\n' "$prompt_text" | "${cmd[@]}"
}

run_direct_codex() {
  local schema_file output_file raw_file reasoning_effort
  command -v python3 >/dev/null 2>&1 || {
    echo "Direct codex backend requires python3." >&2
    return 127
  }
  command -v mktemp >/dev/null 2>&1 || {
    echo "Direct codex backend requires mktemp." >&2
    return 127
  }
  # Direct Codex CLI fallback uses file-backed schema/output paths. Callers can
  # steer placement via TMPDIR when the environment is constrained.
  schema_file="$(mktemp)"
  output_file="$(mktemp)"
  raw_file="$(mktemp)"
  trap 'rm -f "$schema_file" "$output_file" "$raw_file"' RETURN

  cat >"$schema_file" <<'EOF'
{
  "type": "object",
  "properties": {
    "final": { "type": "string" }
  },
  "required": ["final"],
  "additionalProperties": false
}
EOF

  reasoning_effort="medium"
  if [[ "$profile" == "fast" ]]; then
    reasoning_effort="low"
  fi

  cmd=(
    codex exec
    -C "$workspace"
    --sandbox read-only
    -c "model_reasoning_effort=\"$reasoning_effort\""
    -c 'model_reasoning_summary="auto"'
    -c 'mcp_servers.firebase.enabled=false'
    --output-schema "$schema_file"
    -o "$output_file"
  )

  if [[ "$raw_response" == "true" ]]; then
    cmd+=(--json)
    if ! printf '%s\n' "$prompt_text" | "${cmd[@]}" >"$raw_file"; then
      cat "$raw_file"
      return 1
    fi
    cat "$raw_file"
    return 0
  fi

  if ! printf '%s\n' "$prompt_text" | "${cmd[@]}" >"$raw_file"; then
    cat "$raw_file" >&2 || true
    return 1
  fi

  python3 - "$output_file" <<'PY'
import json
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read().strip()
if not text:
    raise SystemExit("Codex returned an empty final message.")
try:
    payload = json.loads(text)
except json.JSONDecodeError:
    print(text)
    raise SystemExit(0)
final = payload.get("final")
if not isinstance(final, str) or not final.strip():
    raise SystemExit("Codex final payload did not contain a non-empty 'final' string.")
print(final)
PY
}

selected_backend="$(resolve_backend)"

if [[ "$selected_backend" == "cursor-wrapper" ]]; then
  run_cursor_wrapper
else
  run_direct_codex
fi
