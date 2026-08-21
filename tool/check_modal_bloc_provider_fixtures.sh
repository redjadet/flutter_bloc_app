#!/usr/bin/env bash
# Self-test for tool/check_modal_bloc_provider.sh
set -euo pipefail
TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$TOOL_DIR/workspace_paths.sh"
ROOT="$WORKSPACE_ROOT"
cd "$ROOT"

BAD="$ROOT/tool/fixtures/modal_bloc_provider/bad_sheet_reads_cubit.dart"
GOOD="$ROOT/tool/fixtures/modal_bloc_provider/good_sheet_bloc_provider_value.dart"

echo "Checking bad fixture fails..."
if bash "$ROOT/tool/check_modal_bloc_provider.sh" --paths "$BAD"; then
  echo "❌ expected bad fixture to fail" >&2
  exit 1
fi

echo "Checking good fixture passes..."
if ! bash "$ROOT/tool/check_modal_bloc_provider.sh" --paths "$GOOD"; then
  echo "❌ expected good fixture to pass" >&2
  exit 1
fi

echo "✅ modal BlocProvider fixtures ok"
