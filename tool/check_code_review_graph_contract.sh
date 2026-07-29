#!/usr/bin/env bash
# Contract tests for tool/refresh_code_review_graph.sh (fake-binary injection).
# Usage: bash tool/check_code_review_graph_contract.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REFRESH="$PROJECT_ROOT/tool/refresh_code_review_graph.sh"

usage() {
  cat <<'EOF'
Usage: bash tool/check_code_review_graph_contract.sh

Fake-binary contract coverage for refresh_code_review_graph.sh:
- status-only reports not built without creating a cache
- clean HEAD skip under --if-needed
- dirty worktree forces update (never skip on HEAD alone)
- rename/delete transition forces full build
- missing tool exits 0 (best-effort)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "$#" -gt 0 ]]; then
  echo "usage-error|unknown arg: $1" >&2
  exit 2
fi

failures=0
fail() {
  echo "❌ $*" >&2
  failures=$((failures + 1))
}

tmp_root="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

fake_bin="$tmp_root/bin"
mkdir -p "$fake_bin"
log_file="$tmp_root/fake_calls.log"
: >"$log_file"

cat >"$fake_bin/code-review-graph" <<EOF
#!/usr/bin/env bash
set -euo pipefail
log_file="$log_file"
printf '%s\n' "\$*" >>"\$log_file"
cmd="\${1:-}"
repo=""
shift || true
while [[ \$# -gt 0 ]]; do
  case "\$1" in
    --repo)
      repo="\$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
graph_dir="\${repo:-.}/.code-review-graph"
mkdir -p "\$graph_dir"
case "\$cmd" in
  status)
    if [[ -f "\$graph_dir/graph.db" ]]; then
      echo "Nodes: 1"
    else
      # Real vendor status can create a DB; contract forbids wrapper from
      # calling status when not built. If we get here, wrapper leaked a call.
      echo "Nodes: 0"
      : >"\$graph_dir/graph.db"
    fi
    ;;
  build)
    # Simulate a built graph with non-trivial size + one sqlite node when
    # sqlite3 is available; otherwise a large placeholder file.
    if command -v sqlite3 >/dev/null 2>&1; then
      sqlite3 "\$graph_dir/graph.db" <<'SQL'
CREATE TABLE IF NOT EXISTS nodes (
  id INTEGER PRIMARY KEY,
  kind TEXT,
  name TEXT
);
DELETE FROM nodes;
INSERT INTO nodes(kind, name) VALUES ('File', 'fake.dart');
SQL
    else
      dd if=/dev/zero of="\$graph_dir/graph.db" bs=1024 count=600 status=none 2>/dev/null \
        || head -c 614400 /dev/zero >"\$graph_dir/graph.db"
    fi
    echo "Full build: fake"
    ;;
  update)
    if [[ ! -f "\$graph_dir/graph.db" ]]; then
      echo "update without db" >&2
      exit 1
    fi
    echo "Incremental update: fake"
    ;;
  *)
    echo "unexpected command: \$cmd" >&2
    exit 1
    ;;
esac
exit 0
EOF
chmod +x "$fake_bin/code-review-graph"

# Isolated fake git repo for dirty/rename scenarios.
repo="$tmp_root/repo"
mkdir -p "$repo/apps" "$repo/tool"
git -C "$repo" init -q
git -C "$repo" config user.email "contract@example.com"
git -C "$repo" config user.name "Contract Test"
echo "a" >"$repo/apps/a.dart"
echo "b" >"$repo/apps/b.dart"
printf '%s\n' '.code-review-graph/' >"$repo/.gitignore"
# Copy wrapper into repo tree so PROJECT_ROOT resolves under fake repo.
cp "$REFRESH" "$repo/tool/refresh_code_review_graph.sh"
chmod +x "$repo/tool/refresh_code_review_graph.sh"
git -C "$repo" add apps .gitignore tool
git -C "$repo" commit -qm "init"

run_refresh() {
  (
    cd "$repo"
    PATH="$fake_bin:$PATH"
    env -u CODE_REVIEW_GRAPH_BIN "$@"
  )
}

call_count() {
  local needle="$1"
  if [[ -f "$log_file" ]]; then
    grep -c "$needle" "$log_file" || true
  else
    echo 0
  fi
}

reset_log() {
  : >"$log_file"
}

echo "code-review-graph-contract|status-not-built"
reset_log
rm -rf "$repo/.code-review-graph"
out="$(run_refresh ./tool/refresh_code_review_graph.sh --status-only 2>&1 || true)"
if [[ "$out" != *"not built"* ]]; then
  fail "status-only without db should print not built; got: $out"
fi
if [[ -e "$repo/.code-review-graph/graph.db" ]]; then
  fail "status-only must not create graph.db"
fi
if [[ "$(call_count '^status')" != "0" ]]; then
  fail "status-only not-built must not invoke vendor status"
fi

echo "code-review-graph-contract|missing-tool"
reset_log
out="$(
  cd "$repo"
  CODE_REVIEW_GRAPH_BIN="$tmp_root/missing-code-review-graph" \
    ./tool/refresh_code_review_graph.sh --build 2>&1 || true
)"
rc=0
(
  cd "$repo"
  CODE_REVIEW_GRAPH_BIN="$tmp_root/missing-code-review-graph" \
    ./tool/refresh_code_review_graph.sh --build >/dev/null 2>&1
) || rc=$?
if [[ "$rc" -ne 0 ]]; then
  fail "missing tool must exit 0 (best-effort); rc=$rc out=$out"
fi
if [[ "$out" != *"not installed"* ]]; then
  fail "missing tool should mention not installed; got: $out"
fi

echo "code-review-graph-contract|build-then-clean-skip"
reset_log
rm -rf "$repo/.code-review-graph"
run_refresh ./tool/refresh_code_review_graph.sh --build >/dev/null
if [[ ! -f "$repo/.code-review-graph/graph.db" ]]; then
  fail "build should create graph.db"
fi
if [[ "$(call_count '^build')" -lt 1 ]]; then
  fail "expected build invocation"
fi
head="$(git -C "$repo" rev-parse HEAD)"
printf '%s' "$head" >"$repo/.code-review-graph/last_head"
reset_log
out="$(run_refresh ./tool/refresh_code_review_graph.sh --if-needed 2>&1)"
if [[ "$out" != *"skipping refresh"* ]]; then
  fail "clean matching HEAD should skip; got: $out"
fi
if [[ "$(call_count '^update')" != "0" || "$(call_count '^build')" != "0" ]]; then
  fail "clean skip must not call build/update"
fi
if [[ -f "$repo/.code-review-graph/refresh_meta" ]]; then
  if ! grep -q 'mode=skip' "$repo/.code-review-graph/refresh_meta"; then
    fail "refresh_meta should record mode=skip"
  fi
else
  fail "refresh_meta missing after clean skip"
fi

echo "code-review-graph-contract|dirty-update"
# Dirty edit without HEAD change
echo "dirty" >>"$repo/apps/a.dart"
reset_log
out="$(run_refresh ./tool/refresh_code_review_graph.sh --if-needed 2>&1)"
if [[ "$out" == *"skipping refresh"* ]]; then
  fail "dirty worktree must not skip solely because HEAD matches"
fi
if [[ "$(call_count '^update')" -lt 1 ]]; then
  fail "dirty worktree should incremental update; log=$(cat "$log_file")"
fi
if ! grep -q 'reason=dirty_worktree\|mode=update' "$repo/.code-review-graph/refresh_meta"; then
  fail "refresh_meta should note dirty update"
fi
git -C "$repo" checkout -- apps/a.dart

echo "code-review-graph-contract|rename-delete-rebuild"
# Recreate a built graph + matching last_head, then delete a tracked file
reset_log
run_refresh ./tool/refresh_code_review_graph.sh --build >/dev/null
printf '%s' "$(git -C "$repo" rev-parse HEAD)" >"$repo/.code-review-graph/last_head"
git -C "$repo" rm -q apps/b.dart
reset_log
out="$(run_refresh ./tool/refresh_code_review_graph.sh --if-needed 2>&1)"
if [[ "$out" != *"full build"* ]]; then
  fail "delete transition should force full build; got: $out"
fi
if [[ "$(call_count '^build')" -lt 1 ]]; then
  fail "delete transition must invoke build"
fi
if ! grep -q 'reason=rename_or_delete_transition\|mode=build' "$repo/.code-review-graph/refresh_meta"; then
  fail "refresh_meta should note rename/delete rebuild"
fi
# Restore repo for cleanliness of tmp (optional)
git -C "$repo" reset -q --hard HEAD

if [[ "$failures" -ne 0 ]]; then
  echo "❌ code-review-graph contract checks failed ($failures)" >&2
  exit 1
fi

echo "✅ Code-review-graph contract checks passed."
