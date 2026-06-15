#!/usr/bin/env bash
# Point this clone's git hooks at tracked githooks/ (local core.hooksPath).
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v git >/dev/null 2>&1; then
  echo "❌ git is required to install hooks" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git worktree" >&2
  exit 1
fi

if [ ! -d "$PROJECT_ROOT/githooks" ]; then
  echo "❌ Missing githooks/ directory" >&2
  exit 1
fi

chmod +x "$PROJECT_ROOT/githooks/"* 2>/dev/null || true
git config core.hooksPath githooks

echo "✅ Installed git hooks (core.hooksPath=githooks)"
echo "   Pre-commit runs: tool/check_mutation_success_after_guard.sh --staged"
echo "   Full static sweep still runs via ./bin/checklist / CI"
