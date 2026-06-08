#!/usr/bin/env bash
# Read live Flutter/Dart runtime errors via dart mcp-server (DTD + get_runtime_errors).
# Optional local preflight when a debug session is running — not part of ./bin/checklist.
#
# Default: exit 0 when DTD or connected app is unavailable (skip).
# --strict: exit 1 when no controllable debug session exists.
#
# See docs/agent_kb/devtools_runtime_errors.md

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

usage() {
  cat <<'EOF'
Usage: tool/check_runtime_errors.sh [options]

Read runtime VM errors from the active Flutter debug app via Dart MCP.

Options:
  --strict     Fail when DTD or a connected debug app is unavailable
  --clear      Clear stale runtime errors before reading
  --json       Emit JSON summary (passed to script/mcp_runtime_errors.js)
  --self-test  Verify dart mcp-server + DTD list/connect (no app required)
  -h, --help   Show this help

Exit codes:
  0  No runtime errors, or skipped (no session) unless --strict
  1  Runtime errors present, or --strict with no session/app
  2  MCP / tooling failure

Requires: dart on PATH (Flutter SDK), Node.js for script/mcp_runtime_errors.js
EOF
}

node_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) node_args+=(--strict) ;;
    --clear) node_args+=(--clear) ;;
    --json) node_args+=(--json) ;;
    --self-test) node_args+=(--self-test) ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v dart >/dev/null 2>&1; then
  echo "❌ dart not found on PATH" >&2
  exit 2
fi
if ! command -v node >/dev/null 2>&1; then
  echo "❌ node not found on PATH" >&2
  exit 2
fi

exec env REPO_ROOT="$PROJECT_ROOT" node "$PROJECT_ROOT/script/mcp_runtime_errors.js" \
  --repo-root "$PROJECT_ROOT" \
  "${node_args[@]}"
