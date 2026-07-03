#!/usr/bin/env bash
# Read-only modular architecture metrics (stdout only). Redirect to a file for baselines.
# Usage: bash tool/modular_metrics.sh [--cross-feature-only]

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/workspace_paths.sh"
PROJECT_ROOT="$APP_ROOT"
cd "$PROJECT_ROOT"

CROSS_FEATURE_ONLY=false
if [[ "${1:-}" == "--cross-feature-only" ]]; then
  CROSS_FEATURE_ONLY=true
fi

run_rg() {
  if command -v rg &>/dev/null; then
    rg "$@" 2>/dev/null || true
  else
    return 1
  fi
}

echo "=== Modular metrics ($(date -u +%Y-%m-%dT%H:%M:%SZ)) ==="
echo "repo: $APP_ROOT"
echo

if [[ "$CROSS_FEATURE_ONLY" == true ]]; then
  echo "--- Cross-feature imports (lib/features/<A> imports package:flutter_bloc_app/features/<B>/) ---"
  if command -v rg &>/dev/null; then
    while IFS= read -r row; do
      [[ -z "$row" ]] && continue
      file="${row%%:*}"
      [[ "$file" =~ ^lib/features/([^/]+)/ ]] || continue
      from="${BASH_REMATCH[1]}"
      if [[ "$row" =~ package:flutter_bloc_app/features/([A-Za-z0-9_]+)/ ]]; then
        to="${BASH_REMATCH[1]}"
        if [[ "$from" != "$to" ]]; then
          echo "$row  (from_feature=$from -> to_feature=$to)"
        fi
      fi
    done < <(rg -n "package:flutter_bloc_app/features/" lib/features \
      --glob "*.dart" \
      --glob "!**/*.g.dart" \
      --glob "!**/*.freezed.dart" \
      2>/dev/null || true) | sort -u
  else
    echo "(install ripgrep for cross-feature report)"
  fi
  exit 0
fi

echo "--- Per-feature Dart LOC (lib/features/<name>, excl generated) ---"
for d in lib/features/*/; do
  name=$(basename "$d")
  loc=$(find "$d" -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.gr.dart' -print0 2>/dev/null | xargs -0 wc -l 2>/dev/null | tail -1 | awk '{print $1}')
  echo "  $name: ${loc:-0}"
done | sort -t: -k2 -nr

echo
echo "--- Feature barrels (top-level <feature>.dart under lib/features/<name>/) ---"
for d in lib/features/*/; do
  name=$(basename "$d")
  if [[ -f "lib/features/$name/${name}.dart" ]]; then
    echo "  $name: yes (lib/features/$name/${name}.dart)"
  else
    echo "  $name: no"
  fi
done

echo
echo "--- Shared -> feature imports (should be empty) ---"
if command -v rg &>/dev/null; then
  run_rg -n "package:flutter_bloc_app/features/" lib/shared --glob "*.dart" || echo "  (none)"
else
  grep -Rsn "package:flutter_bloc_app/features/" lib/shared --include="*.dart" 2>/dev/null || echo "  (none)"
fi

echo
echo "--- Domain layer: imports of app/router or core/di (should be empty) ---"
if command -v rg &>/dev/null; then
  V=$(run_rg -n "^import ['\"]package:flutter_bloc_app/(app/|core/di/)" lib/features --glob "*/domain/**/*.dart" --glob "!**/*.g.dart" --glob "!**/*.freezed.dart" || true)
  if [[ -n "$V" ]]; then
    echo "$V"
  else
    echo "  (none)"
  fi
else
  echo "  (need rg)"
fi

echo
echo "--- Fan-in rough counts (import references, heuristic) ---"
for pkgpath in shared/ core/ app/; do
  c=$(run_rg -l "package:flutter_bloc_app/${pkgpath}" lib --glob "*.dart" 2>/dev/null | wc -l | tr -d ' ')
  echo "  package:flutter_bloc_app/${pkgpath}: ~$c files"
done

echo
echo "--- Cross-feature import summary (run with --cross-feature-only for full list) ---"
bash "$PROJECT_ROOT/tool/modular_metrics.sh" --cross-feature-only | head -80
echo "  (truncated; full: bash tool/modular_metrics.sh --cross-feature-only)"
