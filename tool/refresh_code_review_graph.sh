#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPH_DIR="$PROJECT_ROOT/.code-review-graph"
GRAPH_DB="$GRAPH_DIR/graph.db"

usage() {
  cat <<'EOF'
Usage: ./tool/refresh_code_review_graph.sh [--build] [--status-only] [--if-needed]

Best-effort repo-native wrapper for code-review-graph.

Options:
  --build        Force a full rebuild instead of incremental update
  --status-only  Print graph status only
  --if-needed    Skip refresh when repo HEAD unchanged since last refresh

Environment:
  CODE_REVIEW_GRAPH_BIN   Absolute path to the code-review-graph executable
EOF
}

GRAPH_BIN="${CODE_REVIEW_GRAPH_BIN:-}"
FORCE_BUILD=0
STATUS_ONLY=0
IF_NEEDED=0

HEAD_MARKER="$GRAPH_DIR/last_head"

git_head() {
  git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      FORCE_BUILD=1
      ;;
    --status-only)
      STATUS_ONLY=1
      ;;
    --if-needed)
      IF_NEEDED=1
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
  "$GRAPH_BIN" status --repo "$PROJECT_ROOT"
  exit $?
fi

if [[ $IF_NEEDED -eq 1 && $FORCE_BUILD -eq 0 ]]; then
  current_head="$(git_head)"
  if [[ -n "$current_head" && -f "$HEAD_MARKER" ]]; then
    last_head="$(cat "$HEAD_MARKER" 2>/dev/null || true)"
    if [[ "$last_head" == "$current_head" && -f "$GRAPH_DB" ]]; then
      echo "code-review-graph already up to date for HEAD=$current_head; skipping refresh."
      "$GRAPH_BIN" status --repo "$PROJECT_ROOT" || true
      exit 0
    fi
  fi
fi

if [[ $FORCE_BUILD -eq 1 || ! -f "$GRAPH_DB" ]]; then
  echo "Refreshing code-review-graph with full build..."
  "$GRAPH_BIN" build --repo "$PROJECT_ROOT"
  rc=$?
  if [[ $rc -ne 0 ]]; then
    exit $rc
  fi
else
  echo "Refreshing code-review-graph incrementally..."
  "$GRAPH_BIN" update --repo "$PROJECT_ROOT"
  rc=$?
  if [[ $rc -ne 0 ]]; then
    exit $rc
  fi
fi

mkdir -p "$GRAPH_DIR"
current_head="$(git_head)"
if [[ -n "$current_head" ]]; then
  printf '%s' "$current_head" >"$HEAD_MARKER"
fi

echo
"$GRAPH_BIN" status --repo "$PROJECT_ROOT"
