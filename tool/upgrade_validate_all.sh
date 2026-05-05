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
SKIP_PUB_UPGRADE_MODE="${SKIP_PUB_UPGRADE:-0}"

# shellcheck source=./resolve_flutter_dart.sh disable=SC1091
source "$PROJECT_ROOT/tool/resolve_flutter_dart.sh"

usage() {
  cat <<'EOF'
Usage: upgrade_validate_all [--help]

End-to-end upgrade and validation workflow:
  1. Upgrade Flutter SDK
  2. Upgrade package graph (unless SKIP_PUB_UPGRADE is true)
  3. Run delivery checklist
  4. Run integration tests
  5. Refresh docs/toolchain artifacts
  6. Sync and verify managed agent assets

Environment:
  SKIP_PUB_UPGRADE=1|true|yes|on    Skip major-version pub upgrade and run pub get.
  SKIP_PUB_UPGRADE=0|false|no|off   Run major-version pub upgrade (default).
  SYNC_AGENT_ASSETS=auto|apply|skip|1|0|true|false|yes|no
EOF
}

die_usage() {
  echo "❌ $1" >&2
  echo >&2
  usage >&2
  exit 2
}

parse_bool_env() {
  local name="$1"
  local value="$2"

  case "$value" in
    1|true|TRUE|yes|YES|on|ON)
      return 0
      ;;
    0|false|FALSE|no|NO|off|OFF|"")
      return 1
      ;;
    *)
      echo "❌ Unsupported $name value: $value" >&2
      echo "   Use one of: 1, 0, true, false, yes, no, on, off." >&2
      exit 2
      ;;
  esac
}

validate_bool_env() {
  local name="$1"
  local value="$2"

  case "$value" in
    1|true|TRUE|yes|YES|on|ON|0|false|FALSE|no|NO|off|OFF|"")
      return 0
      ;;
    *)
      echo "❌ Unsupported $name value: $value" >&2
      echo "   Use one of: 1, 0, true, false, yes, no, on, off." >&2
      exit 2
      ;;
  esac
}

validate_sync_agent_assets_mode() {
  case "$SYNC_AGENT_ASSETS_MODE" in
    1|true|TRUE|yes|YES|apply|0|false|FALSE|no|NO|skip|auto|"")
      return 0
      ;;
    *)
      echo "❌ Unsupported SYNC_AGENT_ASSETS value: $SYNC_AGENT_ASSETS_MODE" >&2
      echo "   Use one of: auto, apply, skip, 1, 0, true, false, yes, no." >&2
      exit 2
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die_usage "Unknown argument: $1"
      ;;
  esac
done

validate_bool_env "SKIP_PUB_UPGRADE" "$SKIP_PUB_UPGRADE_MODE"
validate_sync_agent_assets_mode

FLUTTER_BIN="$(resolve_flutter_sdk_flutter || true)"
if [ -z "$FLUTTER_BIN" ]; then
  print_flutter_resolution_report >&2 || true
  echo "❌ Flutter SDK binary not found." >&2
  exit 1
fi

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
      echo "   Use one of: auto, apply, skip, 1, 0, true, false, yes, no." >&2
      exit 2
      ;;
  esac
}

echo "==> Step 1/6: Upgrade Flutter SDK"
"$FLUTTER_BIN" upgrade

if parse_bool_env "SKIP_PUB_UPGRADE" "$SKIP_PUB_UPGRADE_MODE"; then
  echo "==> Step 2/6: Upgrade packages (major versions when possible) [SKIPPED]"
  "$FLUTTER_BIN" pub get
else
  echo "==> Step 2/6: Upgrade packages (major versions when possible)"
  "$FLUTTER_BIN" pub upgrade --major-versions
fi

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
