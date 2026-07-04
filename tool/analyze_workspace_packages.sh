#!/usr/bin/env bash
# Analyze Melos workspace packages without asking dart analyze to scan package
# roots that include workspace .dart_tool metadata.
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workspace_paths.sh"

analyze_package() {
  local package_dir="$1"
  local rel="${package_dir#$WORKSPACE_ROOT/}"
  local pubspec="$package_dir/pubspec.yaml"
  local targets=()

  [ -d "$package_dir/lib" ] && targets+=(lib)
  [ -d "$package_dir/test" ] && targets+=(test)

  if [ "${#targets[@]}" -eq 0 ]; then
    echo "workspace-analyze|skip|$rel|no lib/test"
    return 0
  fi

  echo "workspace-analyze|start|$rel|${targets[*]}"
  if grep -q 'sdk: flutter' "$pubspec"; then
    (cd "$package_dir" && flutter analyze "${targets[@]}")
  else
    (cd "$package_dir" && dart analyze "${targets[@]}")
  fi
  echo "workspace-analyze|pass|$rel"
}

for package_dir in "$WORKSPACE_ROOT"/packages/* "$WORKSPACE_ROOT"/custom_lints/*; do
  [ -d "$package_dir" ] || continue
  [ -f "$package_dir/pubspec.yaml" ] || continue
  analyze_package "$package_dir"
done
