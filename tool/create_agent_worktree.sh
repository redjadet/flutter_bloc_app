#!/usr/bin/env bash
# Plan or create an isolated AI-agent worktree from a known local Git ref.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/create_agent_worktree.sh --name <slug> [options]

Plans an isolated worktree by default. Pass --apply to create it.

Options:
  --name <slug>      Task slug used by default branch and path (required).
  --base <git-ref>   Existing local base ref (default: origin/main).
  --branch <branch>  New branch (default: codex/<slug>).
  --path <path>      New worktree path (default: ../<repo-name>-<slug>).
  --apply            Run git worktree add after all checks pass.
  -h, --help         Show help.

The command never fetches, deletes, reuses, or overwrites refs or paths.
EOF
}

name=""
base_ref="origin/main"
branch=""
target_path=""
apply=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      name="${2:-}"
      [[ -n "$name" ]] || { echo "usage-error|--name requires a value" >&2; exit 2; }
      shift 2
      ;;
    --base)
      base_ref="${2:-}"
      [[ -n "$base_ref" ]] || { echo "usage-error|--base requires a value" >&2; exit 2; }
      shift 2
      ;;
    --branch)
      branch="${2:-}"
      [[ -n "$branch" ]] || { echo "usage-error|--branch requires a value" >&2; exit 2; }
      shift 2
      ;;
    --path)
      target_path="${2:-}"
      [[ -n "$target_path" ]] || { echo "usage-error|--path requires a value" >&2; exit 2; }
      shift 2
      ;;
    --apply)
      apply=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$name" ]]; then
  echo "usage-error|--name is required" >&2
  exit 2
fi
if [[ ! "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
  echo "usage-error|invalid name: use lowercase letters, digits, hyphens, or underscores" >&2
  exit 2
fi

repo_root="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "worktree-error|repository unavailable" >&2
  exit 1
fi
repo_name="$(basename "$repo_root")"
branch="${branch:-codex/$name}"
target_path="${target_path:-$(dirname "$repo_root")/$repo_name-$name}"
if [[ "$target_path" != /* ]]; then
  target_path="$repo_root/$target_path"
fi

if ! git -C "$repo_root" check-ref-format --branch "$branch" >/dev/null 2>&1; then
  echo "usage-error|invalid branch: $branch" >&2
  exit 2
fi
if ! git -C "$repo_root" rev-parse --verify --quiet "$base_ref^{commit}" >/dev/null; then
  echo "worktree-error|base-ref-missing|$base_ref" >&2
  exit 1
fi
if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  echo "worktree-error|branch-exists|$branch" >&2
  exit 1
fi

target_parent="$(dirname "$target_path")"
if [[ ! -d "$target_parent" ]]; then
  echo "worktree-error|parent-missing|$target_parent" >&2
  exit 1
fi
target_path="$(cd "$target_parent" && pwd -P)/$(basename "$target_path")"
if [[ -e "$target_path" ]]; then
  echo "worktree-error|path-exists|$target_path" >&2
  exit 1
fi
while IFS= read -r existing_path; do
  if [[ "$existing_path" == "$target_path" ]]; then
    echo "worktree-error|path-registered|$target_path" >&2
    exit 1
  fi
  if [[ "$target_path" == "$existing_path"/* ]]; then
    echo "worktree-error|path-inside-worktree|$existing_path" >&2
    exit 1
  fi
done < <(git -C "$repo_root" worktree list --porcelain | sed -n 's/^worktree //p')

echo "worktree|repo|$repo_root"
echo "worktree|base|$base_ref"
echo "worktree|branch|$branch"
echo "worktree|path|$target_path"

if (( ! apply )); then
  echo "worktree|plan|git worktree add -b $branch $target_path $base_ref"
  echo "worktree|hint|pass --apply to create"
  exit 0
fi

git -C "$repo_root" worktree add -b "$branch" "$target_path" "$base_ref"
echo "worktree|created|$target_path"
