#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/run_harness_fixtures.sh

Run minimal fixture-based tests for harness scripts added by this plan.
Exit non-zero on first unexpected result.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

echo "fixtures|start"

echo "fixtures|agent_session_bootstrap|help"
bash tool/agent_session_bootstrap.sh --help >/dev/null

echo "fixtures|validate_task_trackers|help"
bash tool/validate_task_trackers.sh --help >/dev/null

echo "fixtures|check_docs_gardening|help"
bash tool/check_docs_gardening.sh --help >/dev/null

fixture_bad="tool/fixtures/harness/bad_missing_md_token.md"
fixture_space="tool/fixtures/harness/fixture with space.md"

if [[ ! -f "$fixture_bad" || ! -f "$fixture_space" ]]; then
  echo "❌ fixtures failed: missing fixture docs under tool/fixtures/harness" >&2
  exit 1
fi

echo "fixtures|check_docs_gardening|negative"
set +e
  env -u HARNESS_SKIP_DOC_GARDENING bash tool/check_docs_gardening.sh --paths "$fixture_bad" >/dev/null 2>&1
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected doc gardening to fail on missing token" >&2
  exit 1
fi

echo "fixtures|check_docs_gardening|spaces"
env -u HARNESS_SKIP_DOC_GARDENING bash tool/check_docs_gardening.sh --paths "$fixture_space" >/dev/null

echo "fixtures|check_ai_generated_code_smells|help"
bash tool/check_ai_generated_code_smells.sh --help >/dev/null

fixture_smells_bad_secret="tool/fixtures/ai_generated_code_smells/bad_secret.ts"
fixture_smells_ok_allowlisted="tool/fixtures/ai_generated_code_smells/ok_allowlisted.ts"
fixture_smells_bad_except="tool/fixtures/ai_generated_code_smells/bad_swallowed_exception.py"
fixture_smells_bad_verify_jwt="tool/fixtures/ai_generated_code_smells/bad_verify_jwt_false_config.toml"
fixture_smells_ok_public_verify_jwt="tool/fixtures/ai_generated_code_smells/ok_public_sync_verify_jwt_false_config.toml"

if [[ ! -f "$fixture_smells_bad_secret" || ! -f "$fixture_smells_ok_allowlisted" || ! -f "$fixture_smells_bad_except" || ! -f "$fixture_smells_bad_verify_jwt" || ! -f "$fixture_smells_ok_public_verify_jwt" ]]; then
  echo "❌ fixtures failed: missing smell fixtures under tool/fixtures/ai_generated_code_smells" >&2
  exit 1
fi

echo "fixtures|check_ai_generated_code_smells|negative"
set +e
  bash tool/check_ai_generated_code_smells.sh --paths "$fixture_smells_bad_secret" >/dev/null 2>&1
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected ai smells to fail on bad_secret.ts" >&2
  exit 1
fi

echo "fixtures|check_ai_generated_code_smells|allowlisted"
bash tool/check_ai_generated_code_smells.sh --paths "$fixture_smells_ok_allowlisted" >/dev/null

echo "fixtures|check_ai_generated_code_smells|swallowed_exception"
set +e
  bash tool/check_ai_generated_code_smells.sh --paths "$fixture_smells_bad_except" >/dev/null 2>&1
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected ai smells to fail on bad_swallowed_exception.py" >&2
  exit 1
fi

echo "fixtures|check_ai_generated_code_smells|verify_jwt_false_sensitive"
set +e
  bash tool/check_ai_generated_code_smells.sh --paths "$fixture_smells_bad_verify_jwt" >/dev/null 2>&1
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected ai smells to fail on bad_verify_jwt_false_config.toml" >&2
  exit 1
fi

echo "fixtures|check_ai_generated_code_smells|verify_jwt_false_public_ok"
bash tool/check_ai_generated_code_smells.sh --paths "$fixture_smells_ok_public_verify_jwt" >/dev/null

echo "fixtures|done"
