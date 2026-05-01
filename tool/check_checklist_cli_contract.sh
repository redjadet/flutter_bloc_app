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
trap 'rm -rf "$tmp_dir"' EXIT

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

echo "✅ Checklist CLI contract passed"
