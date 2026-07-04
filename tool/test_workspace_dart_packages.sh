#!/usr/bin/env bash
# Run tests for non-Flutter Melos workspace packages.
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workspace_paths.sh"

for package_dir in "$WORKSPACE_ROOT"/packages/* "$WORKSPACE_ROOT"/custom_lints/*; do
  [ -d "$package_dir" ] || continue
  [ -f "$package_dir/pubspec.yaml" ] || continue
  [ -d "$package_dir/test" ] || continue

  rel="${package_dir#$WORKSPACE_ROOT/}"
  if grep -q 'sdk: flutter' "$package_dir/pubspec.yaml"; then
    echo "workspace-dart-test|skip|$rel|flutter package"
    continue
  fi

  echo "workspace-dart-test|start|$rel"
  (cd "$package_dir" && dart test)
  echo "workspace-dart-test|pass|$rel"
done
