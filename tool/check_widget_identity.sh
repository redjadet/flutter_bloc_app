#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Checking widget identity fixtures..."
dart run tool/check_widget_identity.dart \
  tool/fixtures/widget_identity/good_dynamic_children_local_state.dart
if dart run tool/check_widget_identity.dart \
  tool/fixtures/widget_identity/bad_dynamic_children_local_state.dart \
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
dart run tool/check_widget_identity.dart
