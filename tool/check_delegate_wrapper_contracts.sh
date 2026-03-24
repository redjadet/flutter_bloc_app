#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_WRAPPER="$PROJECT_ROOT/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
GSTACK_CODEX_SKILL="$PROJECT_ROOT/.agents/skills/gstack/.agents/skills/gstack-codex/SKILL.md"
CURSOR_WRAPPER="$PROJECT_ROOT/.cursor/skills/codex-cursor-agent-delegate/scripts/delegate_to_cursor_agent.sh"

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
output_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      output_file="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
if [[ "$mode" == "success" ]]; then
  printf '{"final":"OK_FROM_MOCK_CODEX"}\n' >"$output_file"
  exit 0
fi
if [[ "$mode" == "malformed" ]]; then
  printf '{"wrong":"shape"}\n' >"$output_file"
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

schema_file="$tmp_dir/output_schema.json"
cat >"$schema_file" <<'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "required": ["final"],
  "properties": {
    "final": {
      "type": "string"
    }
  }
}
EOF

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

  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for the direct Codex contract fallback." >&2
    exit 127
  fi

  local delegated_prompt last_message_file stdout_file stderr_file codex_exit_code
  delegated_prompt=$(cat <<EOF
Return JSON that matches the provided schema.
- Put the entire final answer in the "final" string field.
- Do not wrap it in markdown fences.
- Do not add any keys beyond "final".

Task:
$prompt
EOF
)
  last_message_file="$tmp_dir/direct_codex_last_message.json"
  stdout_file="$tmp_dir/direct_codex_stdout.txt"
  stderr_file="$tmp_dir/direct_codex_stderr.txt"
  rm -f "$last_message_file" "$stdout_file" "$stderr_file"

  set +e
  codex exec \
    -m "gpt-5.4" \
    -c 'model_reasoning_effort="medium"' \
    -c 'model_reasoning_summary="auto"' \
    --sandbox read-only \
    --output-schema "$schema_file" \
    -o "$last_message_file" \
    -C "$PROJECT_ROOT" \
    "$delegated_prompt" \
    >"$stdout_file" 2>"$stderr_file"
  codex_exit_code=$?
  set -e

  if [[ ! -s "$last_message_file" ]]; then
    if [[ $codex_exit_code -ne 0 ]]; then
      echo "Codex exited with code $codex_exit_code and did not write a final message." >&2
    fi
    echo "Codex did not write the final message file." >&2
    cat "$stderr_file" >&2
    cat "$stdout_file" >&2
    exit 1
  fi

  jq -er '.final' "$last_message_file" >/dev/null || {
    echo "Codex did not return a valid structured final payload." >&2
    cat "$last_message_file" >&2
    exit 1
  }
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
