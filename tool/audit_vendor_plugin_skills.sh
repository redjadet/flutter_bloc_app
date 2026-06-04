#!/usr/bin/env bash
# Report-only rollup of Cursor Marketplace plugin skills (plugin cache).
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

out_path="${1:-docs/audits/vendor_plugin_inventory_latest.json}"
dart run tool/skill_vendor_plugin_inventory.dart "$out_path"
