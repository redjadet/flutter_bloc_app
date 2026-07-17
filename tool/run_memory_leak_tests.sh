#!/usr/bin/env bash
# Runs only widget tests that opt into the progressive memory-leak gate.
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"

memory_leak_tests=()
while IFS= read -r test_file; do
  memory_leak_tests+=("$test_file")
done < <(
  rg -l \
    --glob '*_test.dart' \
    'leakSafeTestWidgets[[:space:]]*\(' \
    "$APP_ROOT/test" \
    | sort
)

if [ "${#memory_leak_tests[@]}" -eq 0 ]; then
  echo "❌ No memory_leak-tagged tests found under $APP_ROOT/test"
  exit 1
fi

echo "🧪 Running ${#memory_leak_tests[@]} memory_leak-tagged widget test files..."
cd "$APP_ROOT"
flutter test "${memory_leak_tests[@]}" \
  --tags memory_leak \
  --concurrency="${MEMORY_LEAK_TEST_CONCURRENCY:-1}"
