#!/bin/bash
# End-to-end upgrade and validation workflow.
# - Updates Flutter SDK
# - Upgrades package graph
# - Runs checklist + integration tests
# - Refreshes and verifies documentation artifacts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "==> Step 1/5: Upgrade Flutter SDK"
flutter upgrade

echo "==> Step 2/5: Upgrade packages (major versions when possible)"
flutter pub upgrade --major-versions

echo "==> Step 3/5: Run delivery checklist"
"$PROJECT_ROOT/bin/checklist"

echo "==> Step 4/5: Run integration tests"
"$PROJECT_ROOT/bin/integration_tests"

echo "==> Step 5/5: Refresh and auto-fix documentation artifacts"
dart run tool/update_coverage_summary.dart
bash "$PROJECT_ROOT/tool/fix_validation_docs.sh"
bash "$PROJECT_ROOT/tool/validate_validation_docs.sh"

echo "✅ upgrade_validate_all completed successfully."
