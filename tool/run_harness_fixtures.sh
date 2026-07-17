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

echo "fixtures|agent_maintain|help"
bash tool/agent_maintain.sh --help >/dev/null

echo "fixtures|agent_maintain|list"
bash tool/agent_maintain.sh list >/dev/null

echo "fixtures|agent_maintain|auto_dry"
AGENT_MAINTAIN_PLAN_ONLY=1 bash tool/agent_maintain.sh auto >/dev/null

echo "fixtures|bin_agent_maintain|help"
agent_maintain_help="$(./bin/agent-maintain --help)"
if ! grep -q -- "Usage: ./bin/agent-maintain" <<<"$agent_maintain_help"; then
  echo "❌ fixtures failed: agent-maintain --help missing Usage line" >&2
  echo "$agent_maintain_help" >&2
  exit 1
fi

echo "fixtures|validate_task_trackers|help"
bash tool/validate_task_trackers.sh --help >/dev/null

echo "fixtures|check_docs_gardening|help"
bash tool/check_docs_gardening.sh --help >/dev/null

echo "fixtures|check_agent_memory_compounding|help"
bash tool/check_agent_memory_compounding.sh --help >/dev/null

echo "fixtures|check_agent_memory_compounding|missing_conditional_owner"
tmp_bootstrap="$(mktemp)"
grep -vF 'read_if_review|docs/ai_code_review_protocol.md' \
  tool/agent_session_bootstrap.sh >"$tmp_bootstrap"
set +e
AGENT_BOOTSTRAP_PATH="$tmp_bootstrap" \
  bash tool/check_agent_memory_compounding.sh >/dev/null 2>&1
memory_guard_status=$?
set -e
rm -f "$tmp_bootstrap"
if [[ "$memory_guard_status" -eq 0 ]]; then
  echo "❌ fixtures failed: memory guard accepted missing conditional owner" >&2
  exit 1
fi

echo "fixtures|check_harness_scorecard_gate|help"
bash tool/check_harness_scorecard_gate.sh --help >/dev/null

echo "fixtures|update_harness_score_badge|help"
bash tool/update_harness_score_badge.sh --help >/dev/null

echo "fixtures|update_harness_score_badge|check"
bash tool/update_harness_score_badge.sh --check >/dev/null

echo "fixtures|check_harness_scorecard_gate|current"
bash tool/check_harness_scorecard_gate.sh >/dev/null

echo "fixtures|check_ai_failure_risk_register|help"
bash tool/check_ai_failure_risk_register.sh --help >/dev/null

echo "fixtures|check_ai_failure_risk_register|negative"
tmp_risk_doc="$(mktemp)"
printf '# Incomplete risk doc\n\nRISK-ARCH-LAYER\n' >"$tmp_risk_doc"
set +e
  risk_bad_output="$(bash tool/check_ai_failure_risk_register.sh --path "$tmp_risk_doc" 2>&1)"
status=$?
set -e
rm -f "$tmp_risk_doc"
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected AI failure risk register check to fail on incomplete doc" >&2
  exit 1
fi
if ! grep -q -- "RISK-BLOC-DIVERGENCE" <<<"$risk_bad_output"; then
  echo "❌ fixtures failed: AI failure risk register failure missing required token" >&2
  echo "$risk_bad_output" >&2
  exit 1
fi

echo "fixtures|check_ai_failure_risk_register|current"
bash tool/check_ai_failure_risk_register.sh >/dev/null

echo "fixtures|agent_memory_auto_maintain|help"
bash tool/agent_memory_auto_maintain.sh --help >/dev/null

echo "fixtures|agent_memory_auto_maintain|verify"
bash tool/agent_memory_auto_maintain.sh --verify >/dev/null

echo "fixtures|agent_memory_auto_maintain|codex_memory_health"
bash tool/agent_memory_auto_maintain.sh --codex-memory-health >/dev/null

echo "fixtures|agent_memory_auto_maintain|untracked_if_changed"
fixture_path="docs/changes/agent_memory_auto_maintain_fixture.md"
cleanup_auto_maintain_fixture() {
  rm -f "$fixture_path"
}
trap cleanup_auto_maintain_fixture EXIT
printf 'See `docs/agents_quick_reference.md`.\n' >"$fixture_path"
bash tool/agent_memory_auto_maintain.sh --if-changed >/dev/null
grep -qF '[`agents_quick_reference.md`](../agents_quick_reference.md)' "$fixture_path"
cleanup_auto_maintain_fixture
trap - EXIT

echo "fixtures|checklist_cli_contract"
bash tool/check_checklist_cli_contract.sh >/dev/null

echo "fixtures|check_clean_architecture_imports|help"
bash tool/check_clean_architecture_imports.sh --help >/dev/null

fixture_clean_arch="tool/fixtures/clean_architecture_imports"

echo "fixtures|check_clean_architecture_imports|bad_package"
set +e
  clean_arch_bad_package="$(bash tool/check_clean_architecture_imports.sh --paths "$fixture_clean_arch/domain/bad_package.dart" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected clean architecture check to fail on bad_package.dart" >&2
  exit 1
fi
if ! grep -q -- "domain must not import Flutter" <<<"$clean_arch_bad_package"; then
  echo "❌ fixtures failed: clean architecture package failure missing reason" >&2
  echo "$clean_arch_bad_package" >&2
  exit 1
fi

echo "fixtures|check_clean_architecture_imports|bad_relative"
set +e
  clean_arch_bad_relative="$(bash tool/check_clean_architecture_imports.sh --paths "$fixture_clean_arch/lib/features/orders/domain/bad_relative.dart" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected clean architecture check to fail on bad_relative.dart" >&2
  exit 1
fi
if ! grep -q -- "domain must not import relative data/presentation" <<<"$clean_arch_bad_relative"; then
  echo "❌ fixtures failed: clean architecture relative failure missing reason" >&2
  echo "$clean_arch_bad_relative" >&2
  exit 1
fi

echo "fixtures|check_clean_architecture_imports|presentation_data"
set +e
  clean_arch_bad_presentation="$(bash tool/check_clean_architecture_imports.sh --paths "$fixture_clean_arch/lib/features/orders/presentation/bad_data_import.dart" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected clean architecture check to fail on presentation data import" >&2
  exit 1
fi
if ! grep -q -- "presentation must not import relative data layer" <<<"$clean_arch_bad_presentation"; then
  echo "❌ fixtures failed: clean architecture presentation failure missing reason" >&2
  echo "$clean_arch_bad_presentation" >&2
  exit 1
fi

echo "fixtures|check_clean_architecture_imports|data_presentation"
set +e
  clean_arch_bad_data="$(bash tool/check_clean_architecture_imports.sh --paths "$fixture_clean_arch/lib/features/orders/data/bad_presentation_import.dart" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected clean architecture check to fail on data presentation import" >&2
  exit 1
fi
if ! grep -q -- "data must not import relative presentation layer" <<<"$clean_arch_bad_data"; then
  echo "❌ fixtures failed: clean architecture data failure missing reason" >&2
  echo "$clean_arch_bad_data" >&2
  exit 1
fi

echo "fixtures|check_clean_architecture_imports|suppressed_good"
bash tool/check_clean_architecture_imports.sh --paths \
  "$fixture_clean_arch/lib/features/orders/domain/suppressed.dart" \
  "$fixture_clean_arch/lib/features/orders/domain/good.dart" >/dev/null

fixture_folder_contract="tool/fixtures/feature_folder_contract"

echo "fixtures|check_feature_folder_contract|help"
bash tool/check_feature_folder_contract.sh --help >/dev/null

echo "fixtures|check_feature_folder_contract|bad_root_cubit"
set +e
  folder_contract_bad="$(bash tool/check_feature_folder_contract.sh --paths \
    "$fixture_folder_contract/lib/features/orders/presentation/bad_cubit.dart" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected feature folder contract to fail on root cubit" >&2
  exit 1
fi
if ! grep -q -- "presentation/ root\|must not sit at presentation" <<<"$folder_contract_bad"; then
  echo "❌ fixtures failed: feature folder contract failure missing reason" >&2
  echo "$folder_contract_bad" >&2
  exit 1
fi

echo "fixtures|check_feature_folder_contract|good_cubit"
bash tool/check_feature_folder_contract.sh --paths \
  "$fixture_folder_contract/lib/features/orders/presentation/cubit/good_cubit.dart" >/dev/null

fixture_remote_fetch="tool/fixtures/remote_fetch_failure_fallback"

echo "fixtures|check_remote_fetch_failure_fallback|help"
bash tool/check_remote_fetch_failure_fallback.sh --help >/dev/null

echo "fixtures|check_remote_fetch_failure_fallback|bad"
if bad_out="$(bash tool/check_remote_fetch_failure_fallback.sh --paths \
  "$fixture_remote_fetch/bad_fetch_all_fallback.dart" 2>&1)"; then
  echo "❌ fixtures failed: expected remote fetch fallback check to fail on bad fixture" >&2
  exit 1
fi
if ! printf '%s' "$bad_out" | grep -q "onFailureFallback"; then
  echo "❌ fixtures failed: remote fetch fallback failure missing reason" >&2
  exit 1
fi

echo "fixtures|check_remote_fetch_failure_fallback|good"
bash tool/check_remote_fetch_failure_fallback.sh --paths \
  "$fixture_remote_fetch/good_read_no_fallback.dart" >/dev/null

echo "fixtures|scaffold_feature_contract|help"
bash tool/scaffold_feature_contract.sh --help >/dev/null

echo "fixtures|scaffold_feature_contract|dry_run"
scaffold_output="$(bash tool/scaffold_feature_contract.sh --name harness_fixture_demo)"
if ! grep -q -- "scaffold_feature_contract|dry-run" <<<"$scaffold_output"; then
  echo "❌ fixtures failed: scaffold dry-run missing mode line" >&2
  echo "$scaffold_output" >&2
  exit 1
fi
if ! grep -q -- "plan|dir|lib/features/harness_fixture_demo/domain" <<<"$scaffold_output"; then
  echo "❌ fixtures failed: scaffold dry-run missing domain folder" >&2
  echo "$scaffold_output" >&2
  exit 1
fi
if ! grep -q -- "plan|file|docs/changes/" <<<"$scaffold_output"; then
  echo "❌ fixtures failed: scaffold dry-run missing feature brief path" >&2
  echo "$scaffold_output" >&2
  exit 1
fi
if [[ -e "lib/features/harness_fixture_demo" || -e "test/features/harness_fixture_demo" ]]; then
  echo "❌ fixtures failed: scaffold dry-run created feature directories" >&2
  exit 1
fi

echo "fixtures|scaffold_feature_contract|bad_name"
set +e
  scaffold_bad_output="$(bash tool/scaffold_feature_contract.sh --name BadName 2>&1)"
status=$?
set -e
if [[ "$status" -ne 2 ]]; then
  echo "❌ fixtures failed: expected exit 2 for invalid scaffold name, got $status" >&2
  exit 1
fi
if ! grep -q -- "Invalid feature name: BadName" <<<"$scaffold_bad_output"; then
  echo "❌ fixtures failed: invalid scaffold name did not print clear error" >&2
  echo "$scaffold_bad_output" >&2
  exit 1
fi

echo "fixtures|upgrade_validate_all|help"
upgrade_help="$(./bin/upgrade_validate_all --help)"
if ! grep -q -- "Usage: upgrade_validate_all" <<<"$upgrade_help"; then
  echo "❌ fixtures failed: upgrade_validate_all --help missing Usage line" >&2
  echo "$upgrade_help" >&2
  exit 1
fi
if ! grep -q -- "SKIP_PUB_UPGRADE" <<<"$upgrade_help"; then
  echo "❌ fixtures failed: upgrade_validate_all --help missing SKIP_PUB_UPGRADE" >&2
  echo "$upgrade_help" >&2
  exit 1
fi
if ! grep -q -- "SYNC_AGENT_ASSETS" <<<"$upgrade_help"; then
  echo "❌ fixtures failed: upgrade_validate_all --help missing SYNC_AGENT_ASSETS" >&2
  echo "$upgrade_help" >&2
  exit 1
fi

echo "fixtures|upgrade_validate_all|bad_arg"
set +e
  bad_arg_output="$(./bin/upgrade_validate_all --definitely-not-a-real-arg 2>&1)"
status=$?
set -e
if [[ "$status" -ne 2 ]]; then
  echo "❌ fixtures failed: expected exit 2 for unknown arg, got $status" >&2
  exit 1
fi
if ! grep -q -- "Unknown argument: --definitely-not-a-real-arg" <<<"$bad_arg_output"; then
  echo "❌ fixtures failed: unknown arg did not print usage failure" >&2
  echo "$bad_arg_output" >&2
  exit 1
fi

echo "fixtures|upgrade_validate_all|bad_env_skip_pub_upgrade"
set +e
  bad_skip_output="$(SKIP_PUB_UPGRADE=maybe ./bin/upgrade_validate_all 2>&1)"
status=$?
set -e
if [[ "$status" -ne 2 ]]; then
  echo "❌ fixtures failed: expected exit 2 for invalid SKIP_PUB_UPGRADE, got $status" >&2
  exit 1
fi
if ! grep -q -- "Unsupported SKIP_PUB_UPGRADE value: maybe" <<<"$bad_skip_output"; then
  echo "❌ fixtures failed: invalid SKIP_PUB_UPGRADE did not print env failure" >&2
  echo "$bad_skip_output" >&2
  exit 1
fi

echo "fixtures|upgrade_validate_all|bad_env_sync_agent_assets"
set +e
  bad_sync_output="$(SYNC_AGENT_ASSETS=banana ./bin/upgrade_validate_all 2>&1)"
status=$?
set -e
if [[ "$status" -ne 2 ]]; then
  echo "❌ fixtures failed: expected exit 2 for invalid SYNC_AGENT_ASSETS, got $status" >&2
  exit 1
fi
if ! grep -q -- "Unsupported SYNC_AGENT_ASSETS value: banana" <<<"$bad_sync_output"; then
  echo "❌ fixtures failed: invalid SYNC_AGENT_ASSETS did not print env failure" >&2
  echo "$bad_sync_output" >&2
  exit 1
fi

echo "fixtures|upgrade_pr_triage_skill|upgrade_lane_contract"
upgrade_skill="tool/agent_host_templates/cursor/skills/upgrade-pr-triage-validate/SKILL.md"
if ! grep -q -- "SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all" "$upgrade_skill"; then
  echo "❌ fixtures failed: upgrade triage skill missing SKIP_PUB_UPGRADE lane command" >&2
  exit 1
fi
if ! grep -q -- "SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all" "$upgrade_skill"; then
  echo "❌ fixtures failed: upgrade triage skill missing SYNC_AGENT_ASSETS=skip lane command" >&2
  exit 1
fi

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

echo "fixtures|check_adr_quality|help"
bash tool/check_adr_quality.sh --help >/dev/null

echo "fixtures|check_adr_quality|negative"
set +e
bash tool/check_adr_quality.sh --paths \
  tool/fixtures/harness/bad_adr_missing_date.md >/dev/null 2>&1
adr_status=$?
set -e
if [[ "$adr_status" -eq 0 ]]; then
  echo "❌ fixtures failed: ADR quality guard accepted missing date" >&2
  exit 1
fi

echo "fixtures|check_adr_quality|current"
bash tool/check_adr_quality.sh >/dev/null

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

echo "fixtures|check_tool_dart_async_main_blocking_io|fixtures"
tmp_tool_io_dir="$(mktemp -d)"
cleanup_tool_io_dir() {
  rm -rf "$tmp_tool_io_dir"
}
trap cleanup_tool_io_dir EXIT
cat >"$tmp_tool_io_dir/bad_async_main.dart" <<'EOF'
import 'dart:io';

Future<void> main(List<String> args) async {
  File('x').readAsStringSync();
}
EOF
cat >"$tmp_tool_io_dir/ok_sync_main.dart" <<'EOF'
import 'dart:io';

void main(List<String> args) {
  File('x').readAsStringSync();
}
EOF
cat >"$tmp_tool_io_dir/ok_comment_only.dart" <<'EOF'
Future<void> main(List<String> args) async {
  // readAsStringSync() in a comment must not fail the checker.
}
EOF
cat >"$tmp_tool_io_dir/ok_ignored.dart" <<'EOF'
import 'dart:io';

Future<void> main(List<String> args) async {
  // check-ignore: fixture intentionally uses sync IO
  File('x').readAsStringSync();
}
EOF

set +e
  bad_tool_io_output="$(bash tool/check_tool_dart_async_main_blocking_io.sh --paths "$tmp_tool_io_dir/bad_async_main.dart" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected async-main sync-IO checker to fail on bad_async_main.dart" >&2
  exit 1
fi
if ! grep -q -- "bad_async_main.dart" <<<"$bad_tool_io_output"; then
  echo "❌ fixtures failed: async-main sync-IO checker did not include filename" >&2
  echo "$bad_tool_io_output" >&2
  exit 1
fi

bash tool/check_tool_dart_async_main_blocking_io.sh --paths \
  "$tmp_tool_io_dir/ok_sync_main.dart" \
  "$tmp_tool_io_dir/ok_comment_only.dart" \
  "$tmp_tool_io_dir/ok_ignored.dart" >/dev/null

echo "fixtures|check_runtime_errors|help"
bash tool/check_runtime_errors.sh --help >/dev/null

echo "fixtures|check_runtime_errors|self_test"
bash tool/check_runtime_errors.sh --self-test >/dev/null

echo "fixtures|check_runtime_errors|skip_no_app"
bash tool/check_runtime_errors.sh >/dev/null

echo "fixtures|check_ai_snapshot_freshness|help"
bash tool/check_ai_snapshot_freshness.sh --help >/dev/null

echo "fixtures|check_ai_snapshot_freshness|forbidden_path"
tmp_snapshot="$(mktemp)"
cat >"$tmp_snapshot" <<'EOF'
---
ai_snapshot:
  generated_at: "2026-07-14T00:00:00Z"
  git_head: "0000000000000000000000000000000000000000"
  app_root: "apps/mobile"
  canon_links:
    - CODEMAP.md
---
# bad snapshot
`lib/core/foo`
EOF
set +e
  snapshot_bad_output="$(bash tool/check_ai_snapshot_freshness.sh --paths "$tmp_snapshot" 2>&1)"
status=$?
set -e
rm -f "$tmp_snapshot"
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected AI snapshot freshness to fail on forbidden path" >&2
  exit 1
fi
if ! grep -q -- "forbidden pattern" <<<"$snapshot_bad_output"; then
  echo "❌ fixtures failed: AI snapshot freshness missing forbidden pattern message" >&2
  echo "$snapshot_bad_output" >&2
  exit 1
fi

echo "fixtures|check_ai_snapshot_freshness|missing_metadata"
tmp_snapshot="$(mktemp)"
printf '# no frontmatter\n' >"$tmp_snapshot"
set +e
  snapshot_meta_output="$(bash tool/check_ai_snapshot_freshness.sh --paths "$tmp_snapshot" 2>&1)"
status=$?
set -e
rm -f "$tmp_snapshot"
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected AI snapshot freshness to fail on missing metadata" >&2
  exit 1
fi
if ! grep -q -- "frontmatter" <<<"$snapshot_meta_output"; then
  echo "❌ fixtures failed: AI snapshot freshness missing frontmatter message" >&2
  echo "$snapshot_meta_output" >&2
  exit 1
fi

echo "fixtures|check_ai_snapshot_freshness|current"
bash tool/check_ai_snapshot_freshness.sh >/dev/null

echo "fixtures|check_ai_snapshot_freshness|strict_current_or_snapshot_parent"
bash tool/check_ai_snapshot_freshness.sh --strict-head >/dev/null

echo "fixtures|check_ai_change_contract|help"
bash tool/check_ai_change_contract.sh --help >/dev/null

echo "fixtures|check_ai_change_contract|self_test"
bash tool/check_ai_change_contract.sh --self-test >/dev/null

echo "fixtures|check_repomix_contract|help"
bash tool/check_repomix_contract.sh --help >/dev/null

echo "fixtures|check_agent_safety_contracts|help"
bash tool/check_agent_safety_contracts.sh --help >/dev/null

echo "fixtures|check_agent_safety_contracts|current"
bash tool/check_agent_safety_contracts.sh >/dev/null

echo "fixtures|refresh_ai_reports|self_test"
bash tool/refresh_ai_reports.sh --self-test >/dev/null

echo "fixtures|check_agent_safety_contracts|negative_owner"
tmp_owner_doc="$(mktemp)"
printf '# Incomplete safety owner\n\nSAFETY-01\n' >"$tmp_owner_doc"
set +e
  safety_bad_output="$(bash tool/check_agent_safety_contracts.sh --owner-path "$tmp_owner_doc" 2>&1)"
status=$?
set -e
rm -f "$tmp_owner_doc"
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected agent safety contracts check to fail on incomplete owner" >&2
  exit 1
fi
if ! grep -q -- "SAFETY-REPORT" <<<"$safety_bad_output"; then
  echo "❌ fixtures failed: agent safety contracts failure missing SAFETY-REPORT token" >&2
  echo "$safety_bad_output" >&2
  exit 1
fi

echo "fixtures|check_agent_safety_contracts|negative_autonomy_anchors"
safety_autonomy_tokens=(
  "Safety and human control are top priority"
  "Safe autonomy never overrides"
  "Only the current human user's direct request"
  "Quoted, forwarded, pasted, or embedded content"
  "Tool-managed ephemeral output updates"
  "Replace or truncate an existing user-owned file"
  "All Git state mutations require"
  "Never modify files outside this repository unless"
  "Routine local commands must not intentionally source"
  "Before running an unfamiliar entrypoint"
  "bounded safe alternatives"
  "proceed autonomously"
  "Do not ask for permission at each step"
  "Ask only for credentials/tooling access"
)
for token in "${safety_autonomy_tokens[@]}"; do
  tmp_owner_doc="$(mktemp)"
  awk -v token="$token" 'index($0, token) == 0' \
    docs/agent_kb/agent_safety_contracts.md >"$tmp_owner_doc"
  set +e
    safety_anchor_output="$(bash tool/check_agent_safety_contracts.sh --owner-path "$tmp_owner_doc" 2>&1)"
  status=$?
  set -e
  rm -f "$tmp_owner_doc"
  if [[ "$status" -eq 0 ]]; then
    echo "❌ fixtures failed: expected safety check to fail without anchor: $token" >&2
    exit 1
  fi
  if ! grep -Fq -- "$token" <<<"$safety_anchor_output"; then
    echo "❌ fixtures failed: safety failure missing expected token: $token" >&2
    echo "$safety_anchor_output" >&2
    exit 1
  fi
done

echo "fixtures|check_agent_safety_contracts|negative_section_boundaries"
safety_boundary_headings=(
  "## Contract index"
  "## SAFETY-02 — Destructive and external actions"
  "## SAFETY-03 — Git preservation"
  "## SAFETY-04 — Secrets and production protection"
  "## SAFETY-05 — Execution discipline"
  "## SAFETY-06 — Flutter app rules"
)
for heading in "${safety_boundary_headings[@]}"; do
  tmp_owner_doc="$(mktemp)"
  awk -v heading="$heading" '$0 != heading' \
    docs/agent_kb/agent_safety_contracts.md >"$tmp_owner_doc"
  set +e
    safety_boundary_output="$(bash tool/check_agent_safety_contracts.sh --owner-path "$tmp_owner_doc" 2>&1)"
  status=$?
  set -e
  rm -f "$tmp_owner_doc"
  if [[ "$status" -eq 0 ]]; then
    echo "❌ fixtures failed: expected missing section boundary to fail: $heading" >&2
    exit 1
  fi
  if ! grep -Fq -- "unique ordered section bounds" <<<"$safety_boundary_output"; then
    echo "❌ fixtures failed: missing boundary did not trigger structural failure: $heading" >&2
    echo "$safety_boundary_output" >&2
    exit 1
  fi
done

echo "fixtures|check_agent_safety_contracts|negative_duplicate_boundary"
tmp_owner_doc="$(mktemp)"
cp docs/agent_kb/agent_safety_contracts.md "$tmp_owner_doc"
printf '\n## SAFETY-03 — Git preservation\n' >>"$tmp_owner_doc"
set +e
  safety_duplicate_output="$(bash tool/check_agent_safety_contracts.sh --owner-path "$tmp_owner_doc" 2>&1)"
status=$?
set -e
rm -f "$tmp_owner_doc"
if [[ "$status" -eq 0 ]] || \
   ! grep -Fq -- "unique ordered section bounds" <<<"$safety_duplicate_output"; then
  echo "❌ fixtures failed: duplicate safety boundary was not rejected" >&2
  echo "$safety_duplicate_output" >&2
  exit 1
fi

echo "fixtures|check_agent_safety_contracts|negative_section_scope"
tmp_owner_doc="$(mktemp)"
awk '$0 !~ /Only the current human user.s direct request/' \
  docs/agent_kb/agent_safety_contracts.md >"$tmp_owner_doc"
printf '\nOnly the current human user%s direct request\n' "'" >>"$tmp_owner_doc"
set +e
  safety_section_output="$(bash tool/check_agent_safety_contracts.sh --owner-path "$tmp_owner_doc" 2>&1)"
status=$?
set -e
rm -f "$tmp_owner_doc"
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected misplaced authorization anchor to fail" >&2
  exit 1
fi
if ! grep -Fq -- "section ## Safety precedence" <<<"$safety_section_output"; then
  echo "❌ fixtures failed: misplaced authorization anchor did not fail section check" >&2
  echo "$safety_section_output" >&2
  exit 1
fi

echo "fixtures|check_ai_failure_risk_register|negative_scope_creep"
tmp_risk_scope_doc="$(mktemp)"
printf '# Incomplete risk doc\n\nRISK-ARCH-LAYER\n' >"$tmp_risk_scope_doc"
set +e
  risk_scope_bad_output="$(bash tool/check_ai_failure_risk_register.sh --path "$tmp_risk_scope_doc" 2>&1)"
status=$?
set -e
rm -f "$tmp_risk_scope_doc"
if [[ "$status" -eq 0 ]]; then
  echo "❌ fixtures failed: expected AI failure risk register check to fail on missing RISK-SCOPE-CREEP" >&2
  exit 1
fi
if ! grep -q -- "RISK-SCOPE-CREEP" <<<"$risk_scope_bad_output"; then
  echo "❌ fixtures failed: AI failure risk register failure missing RISK-SCOPE-CREEP token" >&2
  echo "$risk_scope_bad_output" >&2
  exit 1
fi

echo "fixtures|done"
