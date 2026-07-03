#!/usr/bin/env bash
# Workspace vs app package roots for Melos monorepo layout.
# Source from tool/ or bin/ scripts; do not execute directly.

if [[ -n "${WORKSPACE_PATHS_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi

WORKSPACE_PATHS_LOADED=1

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  _workspace_paths_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  _workspace_paths_dir="$(cd "$(dirname "$0")" && pwd)"
fi

WORKSPACE_ROOT="$(cd "$_workspace_paths_dir/.." && pwd)"

if [[ -f "$WORKSPACE_ROOT/apps/mobile/pubspec.yaml" ]]; then
  APP_ROOT="$WORKSPACE_ROOT/apps/mobile"
else
  APP_ROOT="$WORKSPACE_ROOT"
fi

export WORKSPACE_ROOT APP_ROOT WORKSPACE_PATHS_LOADED
