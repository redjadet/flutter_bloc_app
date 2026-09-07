#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
USER_SKILLS="${HOME}/.cursor/skills"
CODEX_WRAPPER="$PROJECT_ROOT/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
if [[ ! -x "$CODEX_WRAPPER" ]]; then
  CODEX_WRAPPER="$USER_SKILLS/cursor-codex-delegate/scripts/delegate_to_codex.sh"
fi
CURSOR_WRAPPER="$PROJECT_ROOT/.cursor/skills/codex-cursor-agent-delegate/scripts/delegate_to_cursor_agent.sh"
if [[ ! -x "$CURSOR_WRAPPER" ]]; then
  CURSOR_WRAPPER="$USER_SKILLS/codex-cursor-agent-delegate/scripts/delegate_to_cursor_agent.sh"
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

mock_bin="$tmp_dir/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mode="${MOCK_CODEX_MODE:-success}"
json_mode="false"
capture_args_file="${MOCK_CODEX_CAPTURE_ARGS_FILE:-}"
capture_stdin_file="${MOCK_CODEX_CAPTURE_STDIN_FILE:-}"
output_file=""
stdin_payload=""
if [[ ! -t 0 ]]; then
  stdin_payload="$(cat)"
fi
if [[ -n "$capture_args_file" ]]; then
  printf '%s\n' "$*" >"$capture_args_file"
fi
if [[ -n "$capture_stdin_file" ]]; then
  printf '%s' "$stdin_payload" >"$capture_stdin_file"
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      json_mode="true"
      shift
      ;;
    -o)
      output_file="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
emit_output_file() {
  if [[ -n "$output_file" ]]; then
    printf '%s\n' '{"final":"OK_FROM_MOCK_CODEX"}' >"$output_file"
  fi
}
if [[ "$mode" == "success" ]]; then
  emit_output_file
  if [[ "$json_mode" == "true" ]]; then
    printf '%s\n' '{"type":"thread.started","thread_id":"mock-thread"}'
    printf '%s\n' '{"type":"turn.started"}'
    printf '%s\n' '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"{\"final\":\"OK_FROM_MOCK_CODEX\"}"}}'
    printf '%s\n' '{"type":"turn.completed","usage":{"input_tokens":1,"cached_input_tokens":0,"output_tokens":1}}'
    exit 0
  fi
  exit 0
fi
if [[ "$mode" == "delayed_success" ]]; then
  sleep "${MOCK_CODEX_DELAY_SECONDS:-0.3}"
  emit_output_file
  if [[ "$json_mode" == "true" ]]; then
    printf '%s\n' '{"type":"thread.started","thread_id":"mock-thread"}'
    printf '%s\n' '{"type":"turn.started"}'
    printf '%s\n' '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"{\"final\":\"OK_FROM_MOCK_CODEX\"}"}}'
    printf '%s\n' '{"type":"turn.completed","usage":{"input_tokens":1,"cached_input_tokens":0,"output_tokens":1}}'
    exit 0
  fi
  exit 0
fi
if [[ "$mode" == "success_nonzero" ]]; then
  emit_output_file
  if [[ "$json_mode" == "true" ]]; then
    printf '%s\n' '{"type":"thread.started","thread_id":"mock-thread"}'
    printf '%s\n' '{"type":"turn.started"}'
    printf '%s\n' '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"{\"final\":\"OK_FROM_MOCK_CODEX\"}"}}'
    printf '%s\n' '{"type":"turn.completed","usage":{"input_tokens":1,"cached_input_tokens":0,"output_tokens":1}}'
    printf '%s\n' 'mock stderr noise from optional MCP startup' >&2
    exit 7
  fi
  exit 7
fi
if [[ "$mode" == "malformed" ]]; then
  if [[ "$json_mode" == "true" ]]; then
    printf '%s\n' '{"type":"thread.started","thread_id":"mock-thread"}'
    printf '%s\n' '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"{\"wrong\":\"shape\"}"}}'
    exit 0
  fi
  exit 0
fi
exit 7
EOF

cat >"$mock_bin/agent" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mode="${MOCK_AGENT_MODE:-with_markers}"
if [[ "$mode" == "with_markers" ]]; then
  printf '%s\n' '{"type":"result","result":"<<<CURSOR_AGENT_FINAL>>>\nOK_FROM_MOCK_AGENT\n<<<END_CURSOR_AGENT_FINAL>>>"}'
  exit 0
fi
printf '%s\n' '{"type":"result","result":"NO_MARKERS"}'
exit 0
EOF

chmod +x "$mock_bin/codex" "$mock_bin/agent"

PATH="$mock_bin:$PATH"
export PATH

run_codex_contract() {
  local prompt="${1:-ping}"

  if [[ -x "$CODEX_WRAPPER" ]]; then
    "$CODEX_WRAPPER" --prompt "$prompt" --workspace "$PROJECT_ROOT" >/dev/null
    return $?
  fi

  if ! command -v codex >/dev/null 2>&1; then
    echo "Missing Codex CLI for direct fallback contract." >&2
    return 127
  fi

  local delegated_prompt stdout_file stderr_file codex_exit_code
  delegated_prompt=$(cat <<EOF
Return JSON that matches the provided schema.
- Put the entire final answer in the "final" string field.
- Do not wrap it in markdown fences.
- Do not add any keys beyond "final".

Task:
$prompt
EOF
)
  stdout_file="$tmp_dir/direct_codex_stdout.txt"
  stderr_file="$tmp_dir/direct_codex_stderr.txt"
  rm -f "$stdout_file" "$stderr_file"

  if codex exec \
    --json \
    --sandbox read-only \
    -C "$PROJECT_ROOT" \
    "$delegated_prompt" \
    >"$stdout_file" 2>"$stderr_file"
  then
    codex_exit_code=0
  else
    codex_exit_code=$?
  fi

  python3 - "$stdout_file" <<'PY' >/dev/null || {
import json
import sys

final_text = None
with open(sys.argv[1], "r", encoding="utf-8") as handle:
    for raw_line in handle:
        line = raw_line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if event.get("type") != "item.completed":
            continue
        item = event.get("item")
        if isinstance(item, dict) and item.get("type") == "agent_message":
            final_text = item.get("text")

if final_text is None:
    raise SystemExit(1)

payload = json.loads(final_text)
if not isinstance(payload, dict) or set(payload.keys()) != {"final"}:
    raise SystemExit(1)
if not isinstance(payload.get("final"), str):
    raise SystemExit(1)
PY
    if [[ $codex_exit_code -ne 0 ]]; then
      echo "Codex exited with code $codex_exit_code and did not return a valid structured payload." >&2
    fi
    echo "Codex did not return a valid structured final payload." >&2
    cat "$stdout_file" >&2
    cat "$stderr_file" >&2
    return 1
  }

  if [[ $codex_exit_code -ne 0 ]]; then
    echo "Codex exited with code $codex_exit_code despite a valid structured payload." >&2
    return "$codex_exit_code"
  fi
}

echo "== codex delegate: success contract =="
export MOCK_CODEX_MODE=success
run_codex_contract "ping"

echo "== codex delegate: malformed payload fails =="
set +e
export MOCK_CODEX_MODE=malformed
run_codex_contract "ping" >/dev/null 2>&1
code=$?
set -e
if [[ "$code" -eq 0 ]]; then
  echo "Expected malformed payload to fail." >&2
  exit 1
fi
unset MOCK_CODEX_MODE

if [[ -x "$CODEX_WRAPPER" ]]; then
  echo "== optional Cursor-to-Codex wrapper: raw and heartbeat contracts =="
  export MOCK_CODEX_MODE=success_nonzero
  raw_tolerant_output="$("$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" --raw-response-tolerant 2>&1)"
  if [[ "$raw_tolerant_output" != *'OK_FROM_MOCK_CODEX'* ]]; then
    echo "Expected tolerant raw mode to preserve the raw success payload." >&2
    exit 1
  fi

  set +e
  "$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" --raw-response >/dev/null 2>&1
  code=$?
  set -e
  if [[ "$code" -eq 0 ]]; then
    echo "Expected strict raw mode to preserve the Codex exit code." >&2
    exit 1
  fi
  unset MOCK_CODEX_MODE

  export MOCK_CODEX_MODE=delayed_success
  heartbeat_output="$(
    DELEGATE_HEARTBEAT_SECONDS=0.1 \
      "$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" 2>&1
  )"
  if [[ "$heartbeat_output" != *'delegate_to_codex: waiting for Codex final payload...'* ]]; then
    echo "Expected non-raw mode to emit an initial heartbeat line." >&2
    exit 1
  fi
  if [[ "$heartbeat_output" != *'OK_FROM_MOCK_CODEX'* ]]; then
    echo "Expected strict mode to still emit the extracted final payload." >&2
    exit 1
  fi
  unset MOCK_CODEX_MODE

  echo "== optional Cursor-to-Codex wrapper: Firebase override =="
  args_capture_file="$tmp_dir/codex-args.txt"
  MOCK_CODEX_CAPTURE_ARGS_FILE="$args_capture_file" \
    "$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" --skip-firebase-mcp >/dev/null
  if ! grep -Fq 'mcp_servers.firebase.enabled=false' "$args_capture_file"; then
    echo "Expected skip Firebase mode to add the Codex config override." >&2
    cat "$args_capture_file" >&2
    exit 1
  fi
else
  echo "== optional Cursor-to-Codex wrapper: not installed; direct fallback covered =="
fi

if [[ -x "$CURSOR_WRAPPER" ]]; then
  echo "== optional Codex-to-Cursor wrapper: marker contract =="
  MOCK_AGENT_MODE=with_markers "$CURSOR_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" >/dev/null
else
  echo "== optional Codex-to-Cursor wrapper: not installed =="
fi

echo "== request_codex_feedback: direct codex backend success =="
request_repo="$tmp_dir/request-feedback-repo"
mkdir -p "$request_repo"
git -C "$request_repo" init -q
git -C "$request_repo" config user.email "mock@example.com"
git -C "$request_repo" config user.name "Mock User"
printf '%s\n' 'alpha' >"$request_repo/sample.txt"
git -C "$request_repo" add sample.txt
git -C "$request_repo" commit -q -m "init"
printf '%s\n' 'beta' >"$request_repo/sample.txt"
printf '%s\n' 'untracked' >"$request_repo/new_untracked.md"
direct_args_capture_file="$tmp_dir/request-helper-codex-args.txt"
direct_stdin_capture_file="$tmp_dir/request-helper-codex-stdin.txt"
direct_output="$(
  MOCK_CODEX_CAPTURE_ARGS_FILE="$direct_args_capture_file" \
  MOCK_CODEX_CAPTURE_STDIN_FILE="$direct_stdin_capture_file" \
    "$PROJECT_ROOT/tool/request_codex_feedback.sh" --backend codex-cli --workspace "$request_repo" --focus "contract test"
)"
if [[ "$direct_output" != *'OK_FROM_MOCK_CODEX'* ]]; then
  echo "Expected direct codex backend review helper to return the mock Codex payload." >&2
  exit 1
fi
if ! grep -Fq -- '--sandbox read-only' "$direct_args_capture_file"; then
  echo "Expected direct codex backend to force read-only sandbox mode." >&2
  cat "$direct_args_capture_file" >&2
  exit 1
fi
if grep -Fq -- '-m' "$direct_args_capture_file" || \
   grep -Fq -- 'model_reasoning_effort=' "$direct_args_capture_file"; then
  echo "Direct codex backend must use the authenticated default model without model overrides." >&2
  cat "$direct_args_capture_file" >&2
  exit 1
fi
if ! grep -Fq -- 'mcp_servers.firebase.enabled=false' "$direct_args_capture_file"; then
  echo "Expected direct codex backend to disable Firebase MCP like the wrapper path." >&2
  cat "$direct_args_capture_file" >&2
  exit 1
fi
if grep -Fq -- '-a' "$direct_args_capture_file"; then
  echo "Direct codex backend should not pass unsupported approval flags to codex exec." >&2
  cat "$direct_args_capture_file" >&2
  exit 1
fi
if ! grep -Fq -- 'new_untracked.md' "$direct_stdin_capture_file"; then
  echo "Expected direct codex backend prompt to include untracked files in the review diff." >&2
  cat "$direct_stdin_capture_file" >&2
  exit 1
fi

echo "== request_codex_feedback: Cursor wrapper receives --prompt =="
wrapper_path="$request_repo/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
mkdir -p "$(dirname "$wrapper_path")"
cat >"$wrapper_path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" != "--prompt" || -z "${2:-}" ]]; then
  echo "Expected a non-empty --prompt argument." >&2
  exit 2
fi
if [[ -n "${MOCK_CURSOR_WRAPPER_CAPTURE_ARGS_FILE:-}" ]]; then
  printf '%s\n' "$*" >"$MOCK_CURSOR_WRAPPER_CAPTURE_ARGS_FILE"
fi
printf '%s\n' 'OK_FROM_MOCK_CURSOR_WRAPPER'
EOF
chmod +x "$wrapper_path"
wrapper_args_capture_file="$tmp_dir/request-helper-wrapper-args.txt"
wrapper_output="$(
  MOCK_CURSOR_WRAPPER_CAPTURE_ARGS_FILE="$wrapper_args_capture_file" \
    "$PROJECT_ROOT/tool/request_codex_feedback.sh" --backend cursor-wrapper --workspace "$request_repo" --focus "wrapper contract test"
)"
if [[ "$wrapper_output" != *'OK_FROM_MOCK_CURSOR_WRAPPER'* ]]; then
  echo "Expected Cursor wrapper backend to return the mock wrapper payload." >&2
  exit 1
fi
if ! grep -Fq -- '--prompt' "$wrapper_args_capture_file" || \
   ! grep -Fq -- 'new_untracked.md' "$wrapper_args_capture_file"; then
  echo "Expected Cursor wrapper backend to receive the complete review prompt." >&2
  cat "$wrapper_args_capture_file" >&2
  exit 1
fi

echo "== request_codex_feedback: auto backend prefers authenticated CLI =="
auto_output="$(
  "$PROJECT_ROOT/tool/request_codex_feedback.sh" --backend auto --workspace "$request_repo" --focus "auto backend contract test"
)"
if [[ "$auto_output" != *'OK_FROM_MOCK_CODEX'* ]] || \
   [[ "$auto_output" == *'OK_FROM_MOCK_CURSOR_WRAPPER'* ]]; then
  echo "Expected auto backend to prefer the direct authenticated Codex CLI." >&2
  exit 1
fi

echo "== request_codex_feedback: untracked-only repo success =="
untracked_only_repo="$tmp_dir/request-feedback-untracked-only-repo"
mkdir -p "$untracked_only_repo"
git -C "$untracked_only_repo" init -q
git -C "$untracked_only_repo" config user.email "mock@example.com"
git -C "$untracked_only_repo" config user.name "Mock User"
printf '%s\n' 'seed' >"$untracked_only_repo/base.txt"
git -C "$untracked_only_repo" add base.txt
git -C "$untracked_only_repo" commit -q -m "init"
rm "$untracked_only_repo/base.txt"
git -C "$untracked_only_repo" checkout -- base.txt
printf '%s\n' 'only-untracked' >"$untracked_only_repo/only_untracked.md"
untracked_only_stdin_capture_file="$tmp_dir/request-helper-untracked-only-stdin.txt"
untracked_only_output="$(
  MOCK_CODEX_CAPTURE_STDIN_FILE="$untracked_only_stdin_capture_file" \
    "$PROJECT_ROOT/tool/request_codex_feedback.sh" --backend codex-cli --workspace "$untracked_only_repo" --focus "untracked-only contract test"
)"
if [[ "$untracked_only_output" != *'OK_FROM_MOCK_CODEX'* ]]; then
  echo "Expected untracked-only review helper run to return the mock Codex payload." >&2
  exit 1
fi
if ! grep -Fq -- 'only_untracked.md' "$untracked_only_stdin_capture_file"; then
  echo "Expected untracked-only review helper run to include the untracked file in the prompt." >&2
  cat "$untracked_only_stdin_capture_file" >&2
  exit 1
fi

if [[ -x "$CURSOR_WRAPPER" ]]; then
  echo "== optional Codex-to-Cursor wrapper: missing marker fails =="
  set +e
  MOCK_AGENT_MODE=no_markers "$CURSOR_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" >/dev/null 2>&1
  code=$?
  set -e
  if [[ "$code" -eq 0 ]]; then
    echo "Expected missing markers to fail." >&2
    exit 1
  fi
fi

echo "Delegate wrapper contract checks passed."
