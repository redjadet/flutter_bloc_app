#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
USER_SKILLS="${HOME}/.cursor/skills"
CODEX_WRAPPER="$PROJECT_ROOT/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
if [[ ! -x "$CODEX_WRAPPER" ]]; then
  CODEX_WRAPPER="$USER_SKILLS/cursor-codex-delegate/scripts/delegate_to_codex.sh"
fi
GSTACK_CODEX_SKILL="$PROJECT_ROOT/.agents/skills/gstack/.agents/skills/gstack-codex/SKILL.md"
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
if [[ -n "$capture_args_file" ]]; then
  printf '%s\n' "$*" >"$capture_args_file"
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      json_mode="true"
      shift
      ;;
    -o)
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
if [[ "$mode" == "success" ]]; then
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

  if [[ ! -f "$GSTACK_CODEX_SKILL" ]]; then
    echo "Missing Codex delegate entrypoint. Checked:" >&2
    echo "  $CODEX_WRAPPER" >&2
    echo "  $GSTACK_CODEX_SKILL" >&2
    exit 1
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

  set +e
  codex exec \
    --json \
    -m "gpt-5.4" \
    -c 'model_reasoning_effort="medium"' \
    -c 'model_reasoning_summary="auto"' \
    --sandbox read-only \
    -C "$PROJECT_ROOT" \
    "$delegated_prompt" \
    >"$stdout_file" 2>"$stderr_file"
  codex_exit_code=$?
  set -e

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
    exit 1
  }
}

echo "== codex delegate: success contract =="
export MOCK_CODEX_MODE=success
run_codex_contract "ping"

echo "== codex delegate: no temp dir required in strict mode =="
readonly_tmp_root="$tmp_dir/readonly-root"
mkdir -p "$readonly_tmp_root"
chmod 555 "$readonly_tmp_root"
DELEGATE_TMPDIR="$readonly_tmp_root" run_codex_contract "ping"
chmod 755 "$readonly_tmp_root"

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

echo "== codex delegate: tolerant raw mode succeeds with valid payload even on non-zero codex exit =="
export MOCK_CODEX_MODE=success_nonzero
raw_tolerant_output="$("$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" --raw-response-tolerant 2>&1)"
if [[ "$raw_tolerant_output" != *'OK_FROM_MOCK_CODEX'* ]]; then
  echo "Expected tolerant raw mode to preserve the raw success payload." >&2
  exit 1
fi

echo "== codex delegate: strict raw mode preserves codex non-zero exit =="
set +e
"$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" --raw-response >/dev/null 2>&1
code=$?
set -e
if [[ "$code" -eq 0 ]]; then
  echo "Expected strict raw mode to preserve the Codex exit code." >&2
  exit 1
fi
unset MOCK_CODEX_MODE

echo "== codex delegate: heartbeat surfaces progress in strict mode =="
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

echo "== codex delegate: skip firebase flag adds config override =="
args_capture_file="$tmp_dir/codex-args.txt"
MOCK_CODEX_CAPTURE_ARGS_FILE="$args_capture_file" \
  "$CODEX_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" --skip-firebase-mcp >/dev/null
if ! grep -Fq 'mcp_servers.firebase.enabled=false' "$args_capture_file"; then
  echo "Expected skip firebase mode to add the Codex config override." >&2
  cat "$args_capture_file" >&2
  exit 1
fi

echo "== cursor wrapper: marker contract success =="
MOCK_AGENT_MODE=with_markers "$CURSOR_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" >/dev/null

echo "== cursor wrapper: missing marker fails =="
set +e
MOCK_AGENT_MODE=no_markers "$CURSOR_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" >/dev/null 2>&1
code=$?
set -e
if [[ "$code" -eq 0 ]]; then
  echo "Expected missing markers to fail." >&2
  exit 1
fi

echo "Delegate wrapper contract checks passed."
