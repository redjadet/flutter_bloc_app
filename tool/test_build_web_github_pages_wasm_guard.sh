#!/usr/bin/env bash
# Regression: web Pages build must not default to --wasm while Hive 2.x is used.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/tool/build_web_github_pages.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "$SCRIPT" ]] || fail "missing $SCRIPT"

grep -q 'WEB_WASM="\${WEB_WASM:-0}"' "$SCRIPT" \
  || fail "expected WEB_WASM default 0 (Hive dart2wasm stub)"

grep -q 'WEB_WASM_FORCE' "$SCRIPT" \
  || fail "expected WEB_WASM_FORCE gate before --wasm"

# Dry-run: sourcing the wasm decision without flutter by extracting defaults.
WEB_WASM="${WEB_WASM:-0}"
if [[ "$WEB_WASM" == "1" || "$WEB_WASM" == "true" ]]; then
  fail "test env must not set WEB_WASM=1"
fi

echo "ok|web_wasm_guard|default_off"
