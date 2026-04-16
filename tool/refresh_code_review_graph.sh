#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPH_DIR="$PROJECT_ROOT/.code-review-graph"
GRAPH_DB="$GRAPH_DIR/graph.db"

usage() {
  cat <<'EOF'
Usage: ./tool/refresh_code_review_graph.sh [--build] [--status-only]

Best-effort repo-native wrapper for code-review-graph.

Options:
  --build        Force a full rebuild instead of incremental update
  --status-only  Print graph status only

Environment:
  CODE_REVIEW_GRAPH_BIN   Absolute path to the code-review-graph executable
EOF
}

GRAPH_BIN="${CODE_REVIEW_GRAPH_BIN:-}"
FORCE_BUILD=0
STATUS_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      FORCE_BUILD=1
      ;;
    --status-only)
      STATUS_ONLY=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$GRAPH_BIN" ]]; then
  if command -v code-review-graph >/dev/null 2>&1; then
    GRAPH_BIN="$(command -v code-review-graph)"
  elif [[ -x "$HOME/.codex/venvs/code-review-graph/bin/code-review-graph" ]]; then
    GRAPH_BIN="$HOME/.codex/venvs/code-review-graph/bin/code-review-graph"
  fi
fi

if [[ -z "$GRAPH_BIN" || ! -x "$GRAPH_BIN" ]]; then
  echo "code-review-graph not installed; skipping refresh." >&2
  exit 0
fi

if [[ $STATUS_ONLY -eq 1 ]]; then
  exec "$GRAPH_BIN" status --repo "$PROJECT_ROOT"
fi

if [[ $FORCE_BUILD -eq 1 || ! -f "$GRAPH_DB" ]]; then
  echo "Refreshing code-review-graph with full build..."
  exec "$GRAPH_BIN" build --repo "$PROJECT_ROOT"
fi

echo "Refreshing code-review-graph incrementally..."
"$GRAPH_BIN" update --repo "$PROJECT_ROOT"

echo
exec "$GRAPH_BIN" status --repo "$PROJECT_ROOT"
