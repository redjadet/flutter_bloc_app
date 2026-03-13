#!/usr/bin/env bash
# Regression guard: offline-first repos must not overwrite newer unsynced local
# state with older remote (e.g. remote watch). Prevents UI flicker (e.g. counter
# up then down then up). See AGENTS.md §5 Offline-first repositories and
# test/features/counter/data/offline_first_counter_repository_test.dart.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Running offline-first remote-merge regression tests (don't overwrite newer local with older remote)..."

tests=(
  "test/features/counter/data/offline_first_counter_repository_test.dart"
  "test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart"
)

for test_file in "${tests[@]}"; do
  echo "  • $test_file"
done

flutter test --no-pub "${tests[@]}"

echo "✅ Offline-first remote-merge regression tests passed"
