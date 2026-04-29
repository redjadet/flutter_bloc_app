#!/bin/bash
# End-to-end upgrade and validation workflow.
# - Updates Flutter SDK
# - Upgrades package graph
# - Runs checklist + integration tests
# - Refreshes and verifies documentation + AI agent toolchain artifacts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUN_STARTED_AT_EPOCH="$(date +%s)"

cd "$PROJECT_ROOT"

SYNC_AGENT_ASSETS_MODE="${SYNC_AGENT_ASSETS:-auto}"

get_mtime_epoch() {
  local path="$1"

  if [ ! -e "$path" ]; then
    return 1
  fi

  if stat -f "%m" "$path" >/dev/null 2>&1; then
    stat -f "%m" "$path"
    return 0
  fi

  stat -c "%Y" "$path"
}

maybe_update_coverage_summary() {
  local lcov_path="coverage/lcov.info"
  local summary_path="coverage/coverage_summary.md"

  if [ ! -f "$lcov_path" ]; then
    echo "No $lcov_path; skipping coverage summary update."
    return 0
  fi

  local lcov_mtime
  lcov_mtime="$(get_mtime_epoch "$lcov_path" || true)"
  if [ -z "$lcov_mtime" ]; then
    echo "Could not read mtime for $lcov_path; skipping coverage summary update."
    return 0
  fi

  if [ "$lcov_mtime" -lt "$RUN_STARTED_AT_EPOCH" ]; then
    echo "$lcov_path not updated in this run; skipping coverage summary update."
    return 0
  fi

  dart run tool/update_coverage_summary.dart
}

run_agent_asset_sync_step() {
  case "$SYNC_AGENT_ASSETS_MODE" in
    1|true|TRUE|yes|YES|apply)
      echo "Applying managed AI agent host assets."
      bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --apply
      ;;
    0|false|FALSE|no|NO|skip)
      echo "Skipping managed AI agent host asset sync (SYNC_AGENT_ASSETS=$SYNC_AGENT_ASSETS_MODE)."
      return 0
      ;;
    auto|"")
      if [ -n "${CI:-}" ]; then
        echo "CI detected; running managed AI agent host asset sync in dry-run mode."
        bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --dry-run
      else
        echo "Applying managed AI agent host assets."
        bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --apply
      fi
      ;;
    *)
      echo "❌ Unsupported SYNC_AGENT_ASSETS value: $SYNC_AGENT_ASSETS_MODE" >&2
      echo "   Use one of: auto, apply, skip, 1, 0, true, false." >&2
      exit 2
      ;;
  esac
}

echo "==> Step 1/6: Upgrade Flutter SDK"
flutter upgrade

echo "==> Step 2/6: Upgrade packages (major versions when possible)"
flutter pub upgrade --major-versions

echo "==> Step 3/6: Run delivery checklist"
"$PROJECT_ROOT/bin/checklist"

echo "==> Step 4/6: Run integration tests"
"$PROJECT_ROOT/bin/integration_tests"

echo "==> Step 5/6: Refresh documentation and AI agent toolchain artifacts"
python3 "$PROJECT_ROOT/tool/update_agent_toolchain_versions.py"
maybe_update_coverage_summary
bash "$PROJECT_ROOT/tool/fix_validation_docs.sh"
bash "$PROJECT_ROOT/tool/validate_validation_docs.sh"

echo "==> Step 6/6: Sync and verify managed AI agent assets"
run_agent_asset_sync_step
bash "$PROJECT_ROOT/tool/check_agent_asset_drift.sh"

echo "✅ upgrade_validate_all completed successfully."
