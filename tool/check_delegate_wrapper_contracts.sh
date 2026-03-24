#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODEx_WRAPPER="$PROJECT_ROOT/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh"
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

echo "== codex wrapper: success contract =="
MOCK_CODEX_MODE=success "$CODEx_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" >/dev/null

echo "== codex wrapper: malformed payload fails =="
set +e
MOCK_CODEX_MODE=malformed "$CODEx_WRAPPER" --prompt "ping" --workspace "$PROJECT_ROOT" >/dev/null 2>&1
code=$?
set -e
if [[ "$code" -eq 0 ]]; then
  echo "Expected malformed payload to fail." >&2
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
