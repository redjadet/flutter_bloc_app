#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_checklist_cli_contract.sh

Verify checklist CLI/debug surfaces without running broad Flutter validation.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/checklist-cli-contract.XXXXXX")"
scope_fixture="tool/agent_tool_router_scope_fixture.tmp"
trap 'rm -rf "$tmp_dir"; rm -f "$scope_fixture"' EXIT

run_ok() {
  local name="$1"
  shift
  echo "checklist_cli|$name"
  "$@" >"$tmp_dir/$name.out" 2>"$tmp_dir/$name.err"
}

run_fail() {
  local name="$1"
  local expected_status="$2"
  shift 2
  local status

  echo "checklist_cli|$name"
  set +e
  "$@" >"$tmp_dir/$name.out" 2>"$tmp_dir/$name.err"
  status=$?
  set -e
  if [[ "$status" -ne "$expected_status" ]]; then
    echo "❌ $name: expected exit $expected_status, got $status" >&2
    cat "$tmp_dir/$name.out" >&2
    cat "$tmp_dir/$name.err" >&2
    exit 1
  fi
}

assert_contains() {
  local name="$1"
  local file="$2"
  local pattern="$3"

  if ! grep -q -- "$pattern" "$file"; then
    echo "❌ $name: missing pattern '$pattern' in $file" >&2
    cat "$file" >&2
    exit 1
  fi
}

run_ok checklist_fast_help ./bin/checklist-fast --help
assert_contains checklist_fast_help "$tmp_dir/checklist_fast_help.out" "Usage: ./bin/checklist-fast"
assert_contains checklist_fast_help "$tmp_dir/checklist_fast_help.out" "--explain"
assert_contains checklist_fast_help "$tmp_dir/checklist_fast_help.out" "--print-changed"
assert_contains checklist_fast_help "$tmp_dir/checklist_fast_help.out" "--no-reuse"

run_ok delivery_help bash tool/delivery_checklist.sh --help
assert_contains delivery_help "$tmp_dir/delivery_help.out" "Usage: ./bin/checklist"
assert_contains delivery_help "$tmp_dir/delivery_help.out" "--mode <full|fast>"

run_ok print_changed ./bin/checklist-fast --print-changed
assert_contains print_changed "$tmp_dir/print_changed.out" "changed_files|"

run_ok explain_no_reuse ./bin/checklist-fast --explain --print-changed --no-reuse
assert_contains explain_no_reuse "$tmp_dir/explain_no_reuse.out" "explain|mode|fast"
assert_contains explain_no_reuse "$tmp_dir/explain_no_reuse.out" "explain|allow_reuse|0"
assert_contains explain_no_reuse "$tmp_dir/explain_no_reuse.out" "changed_files|"

run_fail bad_mode 2 ./bin/checklist-fast --mode invalid --print-changed
assert_contains bad_mode "$tmp_dir/bad_mode.err" "usage-error|invalid --mode: invalid"
assert_contains bad_mode "$tmp_dir/bad_mode.err" "hint|use --mode full or --mode fast"

run_ok agent_maintain_help ./bin/agent-maintain --help
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "Usage: ./bin/agent-maintain"
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "routine"
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "host-full"
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "closeout"
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "harness"
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "harness-maintain"
assert_contains agent_maintain_help "$tmp_dir/agent_maintain_help.out" "tools, tool-route"

run_ok agent_maintain_list ./bin/agent-maintain list
assert_contains agent_maintain_list "$tmp_dir/agent_maintain_list.out" "agent-maintain commands"
assert_contains agent_maintain_list "$tmp_dir/agent_maintain_list.out" "tools tool-route"

run_ok agent_tool_router_help bash tool/agent_tool_router.sh --help
assert_contains agent_tool_router_help "$tmp_dir/agent_tool_router_help.out" \
  "Usage: tool/agent_tool_router.sh"

run_ok agent_tool_router_runtime bash tool/agent_tool_router.sh \
  --intent "runtime crash" --paths apps/mobile/lib/app.dart
assert_contains agent_tool_router_runtime "$tmp_dir/agent_tool_router_runtime.out" \
  "tool_route|runtime|dart-mcp|"
assert_contains agent_tool_router_runtime "$tmp_dir/agent_tool_router_runtime.out" \
  "tool_route|app-debug|dart-mcp|"

run_ok agent_tool_router_mixed bash tool/agent_tool_router.sh \
  --intent "package API" \
  --paths pubspec.yaml apps/mobile/lib/app/router/app_router.dart docs/README.md tool/example.sh
for route in package-api router docs shell; do
  assert_contains agent_tool_router_mixed "$tmp_dir/agent_tool_router_mixed.out" \
    "tool_route|$route|"
done

run_ok agent_maintain_tools ./bin/agent-maintain tools \
  --intent "browser UI" --paths apps/mobile/lib/features/counter/presentation/counter_page.dart
assert_contains agent_maintain_tools "$tmp_dir/agent_maintain_tools.out" \
  "tool_route|browser|"
assert_contains agent_maintain_tools "$tmp_dir/agent_maintain_tools.out" \
  "tool_route|ui|"

printf 'scope fixture\n' >"$scope_fixture"
run_ok agent_bootstrap_untracked bash tool/agent_session_bootstrap.sh --intent "tool audit"
assert_contains agent_bootstrap_untracked "$tmp_dir/agent_bootstrap_untracked.out" \
  "scope|path|$scope_fixture"
assert_contains agent_bootstrap_untracked "$tmp_dir/agent_bootstrap_untracked.out" \
  "tool_route|agent-harness|"
rm -f "$scope_fixture"

run_ok agent_asset_sync_dry ./tool/sync_agent_assets.sh --dry-run
assert_contains agent_asset_sync_dry "$tmp_dir/agent_asset_sync_dry.out" \
  ".cursor/rules/agent-execution.mdc"

run_ok agent_maintain_host_full_plan ./bin/agent-maintain host-full
assert_contains agent_maintain_host_full_plan "$tmp_dir/agent_maintain_host_full_plan.out" "plan|host-full"

scope_paths_file="$tmp_dir/agent_maintain_scope_paths.txt"
cat >"$scope_paths_file" <<'EOF'
docs/agent_knowledge_base.md
tool/agent_host_templates/cursor/commands/removed-example.md
EOF
run_ok agent_maintain_scope_auto env \
  AGENT_MAINTAIN_CHANGED_PATHS_FILE="$scope_paths_file" \
  AGENT_MAINTAIN_PLAN_ONLY=1 \
  bash tool/agent_maintain.sh auto
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "scope|agent_kb|yes"
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "scope|host_templates|yes"
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "auto_action|after-host-edit|"
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "auto_action|docs-sync|"
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "plan|after-host-edit|"
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "plan|docs-sync|"
assert_contains agent_maintain_scope_auto "$tmp_dir/agent_maintain_scope_auto.out" "harness gate"

run_ok agent_maintain_closeout_plan env AGENT_MAINTAIN_PLAN_ONLY=1 \
  bash tool/agent_maintain.sh closeout
assert_contains agent_maintain_closeout_plan "$tmp_dir/agent_maintain_closeout_plan.out" "workflow|closeout|"

empty_scope_file="$tmp_dir/agent_maintain_empty_scope.txt"
: >"$empty_scope_file"
run_ok agent_maintain_closeout_skip_after_host env \
  AGENT_MAINTAIN_CHANGED_PATHS_FILE="$empty_scope_file" \
  AGENT_MAINTAIN_PLAN_ONLY=1 \
  bash tool/agent_maintain.sh closeout
assert_contains agent_maintain_closeout_skip_after_host \
  "$tmp_dir/agent_maintain_closeout_skip_after_host.out" "scope|host_templates|no"
if grep -q "auto_action|after-host-edit|" "$tmp_dir/agent_maintain_closeout_skip_after_host.out"; then
  echo "❌ empty scope closeout must not plan after-host-edit" >&2
  exit 1
fi

host_scope_file="$tmp_dir/agent_maintain_host_scope.txt"
printf '%s\n' 'tool/agent_host_templates/cursor/rules/agent-execution.mdc' >"$host_scope_file"
run_ok agent_maintain_after_host_edit_plan env \
  AGENT_MAINTAIN_CHANGED_PATHS_FILE="$host_scope_file" \
  AGENT_MAINTAIN_PLAN_ONLY=1 \
  bash tool/agent_maintain.sh after-host-edit
assert_contains agent_maintain_after_host_edit_plan \
  "$tmp_dir/agent_maintain_after_host_edit_plan.out" \
  "plan|after-host-edit|sync --apply + strict drift + kb"

run_ok agent_maintain_closeout_harness_scope env \
  AGENT_MAINTAIN_CHANGED_PATHS_FILE="$host_scope_file" \
  AGENT_MAINTAIN_PLAN_ONLY=1 \
  bash tool/agent_maintain.sh closeout
assert_contains agent_maintain_closeout_harness_scope \
  "$tmp_dir/agent_maintain_closeout_harness_scope.out" \
  "scope|harness|yes"
assert_contains agent_maintain_closeout_harness_scope \
  "$tmp_dir/agent_maintain_closeout_harness_scope.out" \
  "auto_action|harness-maintain|"
assert_contains agent_maintain_closeout_harness_scope \
  "$tmp_dir/agent_maintain_closeout_harness_scope.out" \
  "plan|harness-maintain|"

maintain_scope_file="$tmp_dir/agent_maintain_only_scope.txt"
printf '%s\n' 'tool/agent_maintain.sh' >"$maintain_scope_file"
run_ok agent_maintain_closeout_docs_sync_scope env \
  AGENT_MAINTAIN_CHANGED_PATHS_FILE="$maintain_scope_file" \
  AGENT_MAINTAIN_PLAN_ONLY=1 \
  bash tool/agent_maintain.sh closeout
assert_contains agent_maintain_closeout_docs_sync_scope \
  "$tmp_dir/agent_maintain_closeout_docs_sync_scope.out" \
  "scope|validation_tooling|yes"
assert_contains agent_maintain_closeout_docs_sync_scope \
  "$tmp_dir/agent_maintain_closeout_docs_sync_scope.out" \
  "plan|docs-sync|"

echo "✅ Checklist CLI contract passed"
