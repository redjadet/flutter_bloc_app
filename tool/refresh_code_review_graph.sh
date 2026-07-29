#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPH_DIR="$PROJECT_ROOT/.code-review-graph"
GRAPH_DB="$GRAPH_DIR/graph.db"
REFRESH_META="$GRAPH_DIR/refresh_meta"
HEAD_MARKER="$GRAPH_DIR/last_head"

usage() {
  cat <<'EOF'
Usage: ./tool/refresh_code_review_graph.sh [--build] [--status-only] [--if-needed]

Best-effort repo-native wrapper for code-review-graph.

Options:
  --build        Force a full rebuild instead of incremental update
  --status-only  Print graph status only (never creates a cache)
  --if-needed    Refresh when HEAD changed, worktree dirty, or graph missing;
                 never skip solely because HEAD matches last refresh

Environment:
  CODE_REVIEW_GRAPH_BIN   Absolute path to the code-review-graph executable
EOF
}

GRAPH_BIN="${CODE_REVIEW_GRAPH_BIN:-}"
FORCE_BUILD=0
STATUS_ONLY=0
IF_NEEDED=0

git_head() {
  git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || true
}

# True when the worktree has changes outside the local graph cache.
worktree_dirty() {
  local line path
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    path="${line:3}"
    # Porcelain may quote paths; strip simple quotes.
    path="${path#\"}"
    path="${path%\"}"
    case "$path" in
      .code-review-graph|.code-review-graph/*) continue ;;
    esac
    return 0
  done < <(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null || true)
  return 1
}

# Renames/deletes can leave stale nodes under incremental update.
needs_full_rebuild_for_transitions() {
  local line status path
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    status="${line:0:2}"
    # Unstaged/staged delete or rename indicators in porcelain v1.
    if [[ "$status" == *D* || "$status" == *R* ]]; then
      return 0
    fi
    # Also catch " D" / "D " / "RD" etc. via path rename arrow form is rare in
    # short porcelain; treat "R " / "RM" explicitly above via *R*.
  done < <(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null || true)

  # Diff vs HEAD catches index+worktree deletes/renames even when already staged.
  while IFS=$'\t' read -r status path; do
    [[ -z "${status:-}" ]] && continue
    case "$status" in
      D|R*) return 0 ;;
    esac
  done < <(git -C "$PROJECT_ROOT" diff --name-status --find-renames HEAD 2>/dev/null || true)

  return 1
}

graph_is_built() {
  if [[ ! -f "$GRAPH_DB" ]]; then
    return 1
  fi
  # Avoid vendor `status` here — it can create/migrate an empty cache.
  if command -v sqlite3 >/dev/null 2>&1; then
    local node_count
    node_count="$(
      sqlite3 "$GRAPH_DB" "SELECT COUNT(*) FROM nodes;" 2>/dev/null || echo 0
    )"
    [[ "${node_count:-0}" -gt 0 ]]
    return $?
  fi
  # Fallback: non-trivial DB size (empty migrated schema is ~150K).
  local size
  size="$(wc -c <"$GRAPH_DB" | tr -d ' ')"
  [[ "${size:-0}" -gt 500000 ]]
}

write_refresh_meta() {
  local revision="$1"
  local dirty="$2"
  local mode="$3"
  local reason="$4"
  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  mkdir -p "$GRAPH_DIR"
  cat >"$REFRESH_META" <<EOF
revision=${revision}
dirty=${dirty}
mode=${mode}
timestamp=${ts}
reason=${reason}
EOF
  if [[ -n "$revision" ]]; then
    printf '%s' "$revision" >"$HEAD_MARKER"
  fi
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

if [[ $STATUS_ONLY -eq 1 ]]; then
  if ! graph_is_built; then
    echo "code-review-graph: not built"
    exit 0
  fi
  if [[ -z "$GRAPH_BIN" || ! -x "$GRAPH_BIN" ]]; then
    echo "code-review-graph: built locally; tool binary missing (status unavailable)" >&2
    exit 0
  fi
  "$GRAPH_BIN" status --repo "$PROJECT_ROOT"
  exit $?
fi

if [[ -z "$GRAPH_BIN" || ! -x "$GRAPH_BIN" ]]; then
  echo "code-review-graph not installed; skipping refresh." >&2
  exit 0
fi

current_head="$(git_head)"
dirty=0
if worktree_dirty; then
  dirty=1
fi
dirty_label="false"
if [[ $dirty -eq 1 ]]; then
  dirty_label="true"
fi

if [[ $IF_NEEDED -eq 1 && $FORCE_BUILD -eq 0 ]]; then
  if graph_is_built && [[ $dirty -eq 0 && -n "$current_head" && -f "$HEAD_MARKER" ]]; then
    last_head="$(cat "$HEAD_MARKER" 2>/dev/null || true)"
    if [[ "$last_head" == "$current_head" ]]; then
      echo "code-review-graph already up to date for clean HEAD=$current_head; skipping refresh."
      write_refresh_meta "$current_head" "$dirty_label" "skip" "clean_head_unchanged"
      "$GRAPH_BIN" status --repo "$PROJECT_ROOT" || true
      exit 0
    fi
  fi
fi

reason="requested"
mode="update"
if [[ $FORCE_BUILD -eq 1 ]]; then
  reason="forced_build"
  mode="build"
elif ! graph_is_built; then
  reason="missing_or_empty_graph"
  mode="build"
elif needs_full_rebuild_for_transitions; then
  reason="rename_or_delete_transition"
  mode="build"
elif [[ $dirty -eq 1 ]]; then
  reason="dirty_worktree"
  mode="update"
elif [[ $IF_NEEDED -eq 1 ]]; then
  reason="head_changed_or_first_refresh"
fi

if [[ "$mode" == "build" ]]; then
  echo "Refreshing code-review-graph with full build (reason=$reason)..."
  "$GRAPH_BIN" build --repo "$PROJECT_ROOT"
  rc=$?
else
  echo "Refreshing code-review-graph incrementally (reason=$reason)..."
  "$GRAPH_BIN" update --repo "$PROJECT_ROOT"
  rc=$?
fi
if [[ $rc -ne 0 ]]; then
  exit $rc
fi

write_refresh_meta "$current_head" "$dirty_label" "$mode" "$reason"

echo
"$GRAPH_BIN" status --repo "$PROJECT_ROOT"
