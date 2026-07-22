#!/usr/bin/env bash
set -euo pipefail

script_under_test="$(cd "$(dirname "$0")" && pwd)/create_agent_worktree.sh"
tmp_dir="$(mktemp -d -t create_agent_worktree.XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT

repo="$tmp_dir/sample_repo"
mkdir -p "$repo/tool"
repo="$(cd "$repo" && pwd -P)"
cp "$script_under_test" "$repo/tool/create_agent_worktree.sh"
git -C "$repo" init -q
git -C "$repo" config user.name "Agent Worktree Test"
git -C "$repo" config user.email "agent-worktree-test@example.invalid"
printf 'fixture\n' >"$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -qm "test: initialize fixture"
git -C "$repo" branch -M main
git -C "$repo" update-ref refs/remotes/origin/main HEAD

dry_output="$(bash "$repo/tool/create_agent_worktree.sh" --name task-one)"
grep -qF "worktree|branch|codex/task-one" <<<"$dry_output"
grep -qF "worktree|hint|pass --apply to create" <<<"$dry_output"
[[ ! -e "$repo-task-one" ]]

apply_output="$(bash "$repo/tool/create_agent_worktree.sh" --name task-one --apply 2>&1)"
grep -qF "worktree|created|$repo-task-one" <<<"$apply_output"
[[ "$(git -C "$repo-task-one" branch --show-current)" == "codex/task-one" ]]

if bash "$repo/tool/create_agent_worktree.sh" --name task-one >/dev/null 2>&1; then
  echo "expected duplicate branch to fail" >&2
  exit 1
fi
if bash "$repo/tool/create_agent_worktree.sh" --name 'Bad Name' >/dev/null 2>&1; then
  echo "expected invalid name to fail" >&2
  exit 1
fi
if bash "$repo/tool/create_agent_worktree.sh" \
  --name nested --path nested-worktree >/dev/null 2>&1; then
  echo "expected nested target path to fail" >&2
  exit 1
fi

echo "create_agent_worktree_test|ok"
