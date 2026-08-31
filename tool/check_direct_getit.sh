#!/usr/bin/env bash
# Check for direct GetIt access in presentation widgets.
# Dependencies must be injected via constructors or cubits instead.
#
# Usage:
#   bash tool/check_direct_getit.sh           # self-test then production scan
#   bash tool/check_direct_getit.sh --self-test  # self-test only

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$WORKSPACE_ROOT"

source "$WORKSPACE_ROOT/tool/check_helpers.sh"
# check_helpers sets APP_ROOT and cds into apps/mobile.

GETIT_PATTERN='\bgetIt(?:[[:space:]]*<|[[:space:]]*\.)'
SCAN_ROOT="$APP_ROOT/lib/features"

run_scan() {
  local root="$1"
  local VIOLATIONS=""

  if command -v rg &> /dev/null; then
    VIOLATIONS=$(rg -n "$GETIT_PATTERN" "$root" \
      --glob '**/presentation/**' \
      --glob '!**/*.g.dart' \
      --glob '!**/*.freezed.dart' \
      --glob '!**/*.gr.dart' \
      2>/dev/null \
      | rg -v '/[^/]+_demo/' \
      | rg -v '/debug/' \
      | rg -v '/tooling/' \
      | rg -v ':[0-9]+:[[:space:]]*//' \
      | rg -v ':[0-9]+:[[:space:]]*///' \
      || true)
  else
    VIOLATIONS=$(grep -RInE "$GETIT_PATTERN" "$root" 2>/dev/null \
      | grep '/presentation/' \
      | grep -E -v '/[^/]+_demo/' \
      | grep -v '/debug/' \
      | grep -v '/tooling/' \
      | grep -vE ':[0-9]+:[[:space:]]*//' \
      | grep -vE ':[0-9]+:[[:space:]]*///' \
      || true)
  fi

  printf '%s' "$VIOLATIONS"
}

run_self_test() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/check_direct_getit.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN

  mkdir -p "$tmp/features/sample/presentation/widgets"
  cat >"$tmp/features/sample/presentation/widgets/bad_generic.dart" <<'EOF'
final x = getIt<Foo>();
EOF
  cat >"$tmp/features/sample/presentation/widgets/bad_member.dart" <<'EOF'
final y = getIt.isRegistered<Foo>();
EOF
  cat >"$tmp/features/sample/presentation/widgets/comment_only.dart" <<'EOF'
// getIt<Foo>()
/// getIt.isRegistered<Foo>()
final ok = 1;
EOF

  local hits
  hits="$(run_scan "$tmp/features")"

  if ! printf '%s\n' "$hits" | grep -q 'bad_generic.dart'; then
    echo "❌ Self-test failed: expected getIt< detection"
    echo "$hits"
    return 1
  fi
  if ! printf '%s\n' "$hits" | grep -q 'bad_member.dart'; then
    echo "❌ Self-test failed: expected getIt. member detection"
    echo "$hits"
    return 1
  fi
  if printf '%s\n' "$hits" | grep -q 'comment_only.dart'; then
    echo "❌ Self-test failed: comment-only fixture should be ignored"
    echo "$hits"
    return 1
  fi

  echo "✅ Self-test passed (generic + member flagged; comments ignored)"
  return 0
}

SELF_TEST_ONLY=0
if [[ "${1:-}" == "--self-test" ]]; then
  SELF_TEST_ONLY=1
fi

echo "🔍 Checking for direct GetIt usage in presentation layer..."

run_self_test

if [[ "$SELF_TEST_ONLY" -eq 1 ]]; then
  exit 0
fi

IGNORED=""
VIOLATIONS="$(run_scan "$SCAN_ROOT")"
VIOLATIONS="$(filter_ignored "$VIOLATIONS")"

if [ -n "${IGNORED:-}" ]; then
  echo "ℹ️  Ignored (check-ignore):"
  echo "$IGNORED"
fi

if [ -n "$VIOLATIONS" ]; then
  echo "❌ Violations found: Direct GetIt access in presentation (inject via constructors/cubits)"
  echo "$VIOLATIONS"
  echo "Note: Debug/tooling widgets are exceptions and should be documented"
  exit 1
fi

echo "✅ No direct GetIt usage in presentation layer"
exit 0
