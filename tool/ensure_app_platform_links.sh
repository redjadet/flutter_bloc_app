#!/usr/bin/env bash
# Link desktop/web platform folders into the Flutter app root after the Melos
# migration moved them under apps/other_platforms/.
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workspace_paths.sh"

OTHER_PLATFORMS_ROOT="${WORKSPACE_ROOT}/apps/other_platforms"
PLATFORMS=(web linux macos windows)

for platform in "${PLATFORMS[@]}"; do
  link_path="${APP_ROOT}/${platform}"
  source_path="${OTHER_PLATFORMS_ROOT}/${platform}"
  relative_target="../other_platforms/${platform}"

  if [[ ! -d "$source_path" ]]; then
    echo "Error: expected platform source directory at ${source_path}" >&2
    exit 1
  fi

  if [[ -L "$link_path" ]]; then
    current_target="$(readlink "$link_path")"
    if [[ "$current_target" == "$relative_target" ]]; then
      continue
    fi
    echo "Error: ${link_path} is a symlink to '${current_target}', expected '${relative_target}'" >&2
    exit 1
  fi

  if [[ -e "$link_path" ]]; then
    echo "Error: ${link_path} exists and is not the expected symlink to ${relative_target}" >&2
    exit 1
  fi

  ln -s "$relative_target" "$link_path"
done
