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
        echo "CI detected; applying managed AI agent host assets before drift check."
        bash "$PROJECT_ROOT/tool/sync_agent_assets.sh" --apply
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

  # `pub upgrade --major-versions` rewrites custom analyzer plugin pins to caret
  # ranges; restore pinned analyzer 10 stack before compat checks.
  for custom_pkg in file_length_lint mix_lint; do
    custom_pubspec="custom_lints/$custom_pkg/pubspec.yaml"
    if [ -f "$custom_pubspec" ] && ! git diff --quiet -- "$custom_pubspec"; then
      git checkout -- "$custom_pubspec"
    fi
  done

  echo "==> Step 2b/6: Verify pubspec codegen/analyzer compatibility"
  if ! bash "$PROJECT_ROOT/tool/check_pubspec_codegen_compat.sh"; then
    echo "⚠️  pub upgrade introduced incompatible codegen constraints; restoring pinned analyzer/codegen stack."

    python3 - <<'PY'
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path("pubspec.yaml")
MOBILE = Path("apps/mobile/pubspec.yaml")


def sub_one(text: str, pattern: str, repl: str, label: str, pubspec: Path) -> str:
    text, count = re.subn(pattern, repl, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"could not restore {label} in {pubspec}")
    return text


def restore_mobile_codegen() -> None:
    if not MOBILE.is_file():
        return
    text = MOBILE.read_text(encoding="utf-8")
    text = sub_one(
        text,
        r"^  json_serializable:.*$",
        "  json_serializable: ^6.14.0",
        "json_serializable",
        MOBILE,
    )
    text = sub_one(
        text,
        r"^  json_annotation:.*$",
        "  json_annotation: ^4.12.0",
        "json_annotation",
        MOBILE,
    )
    MOBILE.write_text(text, encoding="utf-8")


def restore_root_analyzer_overrides() -> None:
    if not ROOT.is_file():
        return
    text = ROOT.read_text(encoding="utf-8")
    for key, value in (("analyzer", "10.0.2"), ("dart_style", "3.1.4")):
        line = f"  {key}: {value}"
        if re.search(rf"^  {key}:.*$", text, flags=re.MULTILINE):
            text, _ = re.subn(rf"^  {key}:.*$", line, text, count=1, flags=re.MULTILINE)
        elif "dependency_overrides:" in text:
            text = text.replace(
                "dependency_overrides:\n",
                f"dependency_overrides:\n{line}\n",
                1,
            )
        else:
            raise SystemExit(f"missing dependency_overrides block for {key} in {ROOT}")
    ROOT.write_text(text, encoding="utf-8")


restore_mobile_codegen()
restore_root_analyzer_overrides()
PY
    "$FLUTTER_BIN" pub get
    if ! bash "$PROJECT_ROOT/tool/check_pubspec_codegen_compat.sh"; then
      echo "❌ pubspec codegen/analyzer compatibility still failing after restore." >&2
      exit 1
    fi
    echo "✅ Restored custom_lint analyzer pins + json_serializable ^6.14.0 stack; remaining upgrades kept."
  fi
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
