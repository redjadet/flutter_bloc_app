#!/usr/bin/env bash
# Ensures apps/mobile/lib/features/features.dart exports every feature module.
# See docs/modularity.md § Feature barrel.

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/check_helpers.sh"

FEATURES_DIR="$PROJECT_ROOT/lib/features"
BARREL_FILE="$FEATURES_DIR/features.dart"

echo "🔍 Checking features.dart barrel completeness..."

if [[ ! -f "$BARREL_FILE" ]]; then
  echo "❌ Missing barrel: $BARREL_FILE"
  exit 1
fi

mapfile -t FEATURE_DIRS < <(
  find "$FEATURES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
)

mapfile -t EXPORT_LINES < <(grep -E "^export '" "$BARREL_FILE" || true)

MISSING=()
ORPHAN=()

for feature in "${FEATURE_DIRS[@]}"; do
  found=0
  for line in "${EXPORT_LINES[@]}"; do
    if [[ "$line" == export\ \'${feature}/* ]]; then
      found=1
      break
    fi
  done
  if [[ "$found" -eq 0 ]]; then
    MISSING+=("$feature")
  fi
done

for line in "${EXPORT_LINES[@]}"; do
  rel="${line#export \'}"
  rel="${rel%\';}"
  target="$FEATURES_DIR/$rel"
  if [[ ! -f "$target" ]]; then
    ORPHAN+=("$rel")
  fi
done

FAIL=0
if ((${#MISSING[@]} > 0)); then
  FAIL=1
  echo "❌ Feature folders missing from features.dart:"
  printf '  - %s\n' "${MISSING[@]}"
fi

if ((${#ORPHAN[@]} > 0)); then
  FAIL=1
  echo "❌ features.dart exports point to missing files:"
  printf '  - %s\n' "${ORPHAN[@]}"
fi

if [[ "$FAIL" -eq 1 ]]; then
  exit 1
fi

echo "✅ features.dart exports all ${#FEATURE_DIRS[@]} feature modules"
