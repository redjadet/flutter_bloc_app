#!/usr/bin/env bash
# Smoke-test Repomix onboarding pack: exclusions and token budget (D3).
# Usage: bash tool/check_repomix_contract.sh

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
cd "$WORKSPACE_ROOT"

usage() {
  cat <<'EOF'
Usage: bash tool/check_repomix_contract.sh

Runs onboarding Repomix pack and asserts:
- packed file paths exclude .env, generated Dart, and .dart_tool
- onboarding token budget <= 120000 (estimated from character count / 4)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
elif [[ "$#" -gt 0 ]]; then
  echo "usage-error|unknown arg: $1" >&2
  exit 2
fi

ONBOARDING_TOKEN_BUDGET=120000
FEATURE_TOKEN_BUDGET=60000

failures=0
fail() {
  echo "❌ $*" >&2
  failures=$((failures + 1))
}

assert_no_forbidden_packed_paths() {
  local output_path="$1"
  local label="$2"
  if rg -n '^## File: ' "$output_path" | rg -q '\.env$|\.freezed\.dart$|\.g\.dart$|\.gr\.dart$|/\.dart_tool/'; then
    fail "$label pack includes forbidden packed file paths"
  fi
}

estimate_tokens() {
  local output_path="$1"
  local char_count
  char_count="$(wc -c <"$output_path" | tr -d ' ')"
  echo $((char_count / 4)) "$char_count"
}

echo "repomix-contract|onboarding"
mapfile -t pack_lines < <(bash tool/repomix_pack.sh onboarding 2>&1)
output_path=""
for line in "${pack_lines[@]}"; do
  if [[ "$line" == ✅\ Repomix\ pack\ written:* ]]; then
    output_path="${line#✅ Repomix pack written: }"
  fi
done

if [[ -z "$output_path" || ! -f "$output_path" ]]; then
  fail "onboarding pack missing output file"
else
  assert_no_forbidden_packed_paths "$output_path" "onboarding"
  read -r est_tokens char_count < <(estimate_tokens "$output_path")
  echo "repomix-contract|onboarding|est_tokens=$est_tokens|chars=$char_count"
  if [[ "$est_tokens" -gt "$ONBOARDING_TOKEN_BUDGET" ]]; then
    fail "onboarding pack exceeds token budget ($est_tokens > $ONBOARDING_TOKEN_BUDGET)"
  fi
fi

if [[ -d "apps/mobile/lib/features/counter" ]]; then
  echo "repomix-contract|feature|counter"
  mapfile -t feature_lines < <(bash tool/repomix_pack.sh feature --feature counter 2>&1)
  feature_output=""
  for line in "${feature_lines[@]}"; do
    if [[ "$line" == ✅\ Repomix\ pack\ written:* ]]; then
      feature_output="${line#✅ Repomix pack written: }"
    fi
  done
  if [[ -z "$feature_output" || ! -f "$feature_output" ]]; then
    fail "feature pack missing output file"
  else
    assert_no_forbidden_packed_paths "$feature_output" "feature"
    read -r est_tokens char_count < <(estimate_tokens "$feature_output")
    echo "repomix-contract|feature|est_tokens=$est_tokens|chars=$char_count"
    if [[ "$est_tokens" -gt "$FEATURE_TOKEN_BUDGET" ]]; then
      fail "feature pack exceeds token budget ($est_tokens > $FEATURE_TOKEN_BUDGET)"
    fi
  fi
fi

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "✅ Repomix contract checks passed."
