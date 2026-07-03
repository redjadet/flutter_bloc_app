#!/bin/bash
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

echo "Checking widget identity fixtures..."
dart "$WORKSPACE_ROOT/tool/check_widget_identity.dart" \
  "$WORKSPACE_ROOT/tool/fixtures/widget_identity/good_dynamic_children_local_state.dart"
if dart "$WORKSPACE_ROOT/tool/check_widget_identity.dart" \
  "$WORKSPACE_ROOT/tool/fixtures/widget_identity/bad_dynamic_children_local_state.dart" \
  >/tmp/check_widget_identity_bad_fixture.out \
  2>/tmp/check_widget_identity_bad_fixture.err; then
  echo "❌ widget identity fixture failed: bad dynamic children case passed"
  exit 1
fi
if ! grep -q "FixtureSearchRow.*without a stable key" \
  /tmp/check_widget_identity_bad_fixture.err; then
  echo "❌ widget identity fixture failed: expected local-state key diagnostic"
  cat /tmp/check_widget_identity_bad_fixture.err
  exit 1
fi

echo "Checking for widget identity drift (keys, builders, switchers)..."
dart "$WORKSPACE_ROOT/tool/check_widget_identity.dart"
