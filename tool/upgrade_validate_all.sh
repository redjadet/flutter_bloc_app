#!/bin/bash
# End-to-end upgrade and validation workflow.
# - Updates Flutter SDK
# - Upgrades package graph
# - Runs checklist + integration tests
# - Refreshes and verifies documentation + AI agent toolchain artifacts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

SYNC_AGENT_ASSETS_MODE="${SYNC_AGENT_ASSETS:-auto}"

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
dart run tool/update_coverage_summary.dart
bash "$PROJECT_ROOT/tool/fix_validation_docs.sh"
bash "$PROJECT_ROOT/tool/validate_validation_docs.sh"

echo "==> Step 6/6: Sync and verify managed AI agent assets"
run_agent_asset_sync_step
bash "$PROJECT_ROOT/tool/check_agent_asset_drift.sh"

echo "✅ upgrade_validate_all completed successfully."
